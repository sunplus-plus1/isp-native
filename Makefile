##########################################################################
#                                                                        #
#          Copyright (c) 2016 by Sunplus Technology Co., Ltd.            #
#                                                                        #
#  This software is copyrighted by and is the property of Sunplus        #
#  Technology Co., Ltd.                                                  #
#  All rights are reserved by Sunplus Technology Co., Ltd.               #
#  This software may only be used in accordance with the corresponding   #
#  license agreement. Any unauthorized use, duplication, distribution,   #
#  or disclosure of this software is expressly forbidden.                #
#                                                                        #
#  This Copyright notice MUST not be removed or modified without prior   #
#  written consent of Sunplus Technology Co., Ltd.                       #
#                                                                        #
#  Sunplus Technology Co., Ltd. reserves the right to modify this        #
#  software without notice.                                              #
#                                                                        #
#  Sunplus Technology Co., Ltd.                                          #
#  19, Innovation First Road                                             #
#  Hsinchu Science Park, Taiwan 30076                                    #
#                                                                        #
##########################################################################
TOPDIR = $(PWD)
SHELL := sh 
include ./build/Makefile.tls
include ./build/color.mak
sinclude ./.config
sinclude ./.hwconfig

TOOLCHAIN_V7_PATH = $(TOPDIR)/crossgcc/arm-linux-gnueabihf/bin
TOOLCHAIN_V5_PATH = $(TOPDIR)/crossgcc/armv5-eabi--glibc--stable/bin
TOOLCHAIN_RISCV_PATH = $(TOPDIR)/crossgcc/riscv64-sifive-linux-gnu/bin

CROSS_V7_COMPILE = $(TOOLCHAIN_V7_PATH)/arm-linux-gnueabihf-
CROSS_V5_COMPILE = $(TOOLCHAIN_V5_PATH)/armv5-glibc-linux-
CROSS_RISCV_COMPILE = $(TOOLCHAIN_RISCV_PATH)/riscv64-sifive-linux-gnu-
CROSS_RISCV_UNKNOWN_COMPILE = $(TOPDIR)/crossgcc/riscv64-unknown-elf/bin/riscv64-unknown-elf-

NEED_ISP ?= 0
ZEBU_RUN ?= 0
BOOT_FROM ?= EMMC
IS_ASSIGN_DTB ?= 0
BOOT_CHIP ?= C_CHIP
CHIP ?= Q628

BOOT_KERNEL_FROM_TFTP ?= 0
TFTP_SERVER_IP ?=
TFTP_SERVER_PATH ?=
BOARD_MAC_ADDR ?=
USER_NAME ?= 

CONFIG_ROOT = ./.config
HW_CONFIG_ROOT = ./.hwconfig
ISP_SHELL = isp.sh
PART_SHELL = part.sh
SDCARD_BOOT_SHELL = sdcard_boot.sh

BUILD_PATH = build
XBOOT_PATH = boot/xboot
UBOOT_PATH = boot/uboot
LINUX_PATH = linux/kernel
ROOTFS_PATH = linux/rootfs
NONOS_B_PATH = nonos/Bchip-non-os
IPACK_PATH = ipack
OUT_PATH = out

XBOOT_BIN = xboot.img
UBOOT_BIN = u-boot.img
KERNEL_BIN = uImage
DTB = dtb
VMLINUX = vmlinux
ROOTFS_DIR = $(ROOTFS_PATH)/initramfs/disk
ROOTFS_IMG = rootfs.img
NONOS_B_IMG = rom.img

ROOTFS_CROSS = $(CROSS_V7_COMPILE)
ifeq ($(ROOTFS_CONFIG),v5)
ROOTFS_CROSS = $(CROSS_V5_COMPILE)
else ifeq ($(ARCH),riscv)
ROOTFS_CROSS = $(CROSS_RISCV_COMPILE)
endif

# xboot uses name field of u-boot header to differeciate between C-chip boot image
# and P-chip boot image. If name field has prefix "uboot_B", it boots from P chip.
ifeq ("$(BOOT_CHIP)", "C_CHIP")
img_name = "uboot_pentagram_board"
else
img_name = "uboot_B_pentagram_board"
endif

# 0: uImage, 1: qk_boot image (uncompressed)
USE_QK_BOOT=0

SPI_BIN = spi_all.bin
DOWN_TOOL = down_32M.exe
SECURE_PATH ?=

.PHONY: all xboot uboot kenel rom clean distclean config init check rootfs info nonos freertos
.PHONY: dtb spirom isp tool_isp

# rootfs image is created by :
# make initramfs -> re-create initial disk/
# make kernel    -> install kernel modules to disk/lib/modules/
# make rootfs    -> create rootfs image from disk/
all: check
	@$(MAKE) xboot
	@$(MAKE) dtb
	@$(MAKE) uboot
	@if [ $(CHIP) != "I143" ]; then \
		$(MAKE) nonos; \
	elif [ $(ARCH) = "riscv" ]; then \
		$(MAKE) freertos; \
	fi
	@$(MAKE) kernel
	@$(MAKE) secure
	@$(MAKE) rootfs
	@$(MAKE) rom

freertos:
	@$(MAKE) -C freertos CROSS_COMPILE=$(CROSS_RISCV_UNKNOWN_COMPILE)

#xboot build
xboot: check
	@if [ $(CHIP) = "I143" ]; then \
		$(MAKE) ARCH=riscv $(MAKE_JOBS) -C $(XBOOT_PATH) CROSS=$(CROSS_RISCV_UNKNOWN_COMPILE) all ;\
	else \
		$(MAKE) ARCH=arm $(MAKE_JOBS) -C $(XBOOT_PATH) CROSS=$(CROSS_V5_COMPILE) all ;\
	fi
	@$(MAKE) secure SECURE_PATH=xboot

#uboot build
uboot: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE_ARCH) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE) EXT_DTB=../../linux/kernel/dtb  \
			KCPPFLAGS="-DBOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) -DTFTP_SERVER_IP=$(TFTP_SERVER_IP) \
			-DBOARD_MAC_ADDR=$(BOARD_MAC_ADDR) -DUSER_NAME=$(USER_NAME)"; \
	else \
		$(MAKE_ARCH) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE) EXT_DTB=../../linux/kernel/dtb; \
	fi

	@if [ $(CHIP) = "I143" ]; then \
		if [ $(ARCH) = "riscv" ]; then \
			$(MAKE) -C $(TOPDIR)/boot/opensbi distclean && $(MAKE) -C $(TOPDIR)/boot/opensbi FW_PAYLOAD_PATH=$(TOPDIR)/$(UBOOT_PATH)/u-boot.bin CROSS_COMPILE=$(CROSS_RISCV_UNKNOWN_COMPILE); \
			$(TOPDIR)/build/tools/add_uhdr.sh "uboot_i143_riscv" $(TOPDIR)/boot/opensbi/out/fw_payload.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH) 0xA0100000 0xA0100000; \
		else \
			$(TOPDIR)/build/tools/add_uhdr.sh $(img_name) $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH) 0x20100000 0x20100000	;\
		fi; \
	else \
		$(TOPDIR)/build/tools/add_uhdr.sh $(img_name) $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH) 0x200040 0x200040	;\
	fi
	@img_sz=`du -sb $(TOPDIR)/boot/uboot/u-boot.img | cut -f1` ; \
	printf "size: %d (hex %x)\n" $$img_sz $$img_sz
	@$(MAKE) secure SECURE_PATH=uboot

#kernel build
kernel: check
	@$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) all CROSS_COMPILE=$(CROSS_COMPILE)
	@if [ $(CHIP) = "I143" -a $(ARCH) = "riscv" ]; then \
		echo "generate riscv uImage in the future" ;\
	else \
		$(RM) -rf $(ROOTFS_DIR)/lib/modules/;  \
		$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) modules_install INSTALL_MOD_PATH=../../$(ROOTFS_DIR) CROSS_COMPILE=$(CROSS_COMPILE); \
		$(RM) -f $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN); \
		$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) uImage V=0 CROSS_COMPILE=$(CROSS_COMPILE); UIMAGE_LOADADDR=0x20208000;\
		$(MAKE) secure SECURE_PATH=kernel ;\
	fi

nonos:
	@$(MAKE) -C $(NONOS_B_PATH) CROSS=$(CROSS_V5_COMPILE)
	@echo "Wrapping rom.bin -> rom.img..."
# for A:
#	$(TOPDIR)/build/tools/add_uhdr.sh uboot $(NONOS_B_PATH)/bin/rom.bin $(NONOS_B_PATH)/bin/rom.img arm 0x200040 0x200040
# for B:
	$(TOPDIR)/build/tools/add_uhdr.sh uboot $(NONOS_B_PATH)/bin/rom.bin $(NONOS_B_PATH)/bin/rom.img arm 0x10040 0x10040
	@sz=`du -sb $(NONOS_B_PATH)/bin/rom.img|cut -f1`; printf "rom size = %d (hex %x)\n" $$sz $$sz

clean:
	@$(MAKE_ARCH) -C $(NONOS_B_PATH) $@
	if [ $(CHIP) = "I143" ]; then \
		$(MAKE) ARCH=riscv -C $(XBOOT_PATH) CROSS=$(CROSS_RISCV_UNKNOWN_COMPILE) $@ ;\
	else \
		$(MAKE) ARCH=arm -C $(XBOOT_PATH) CROSS=$(CROSS_V5_COMPILE) $@ ;\
	fi
	@$(MAKE_ARCH) -C $(UBOOT_PATH) $@
	@$(MAKE_ARCH) -C $(LINUX_PATH) $@
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) $@
	@$(RM) -rf $(OUT_PATH)

distclean: clean
	if [ $(CHIP) = "I143" ]; then \
		$(MAKE) ARCH=riscv -C $(XBOOT_PATH) CROSS=$(CROSS_RISCV_UNKNOWN_COMPILE) $@ ;\
	else \
		$(MAKE) ARCH=arm -C $(XBOOT_PATH) CROSS=$(CROSS_V5_COMPILE) $@ ;\
	fi
	@$(MAKE_ARCH) -C $(UBOOT_PATH) $@
	@$(MAKE_ARCH) -C $(LINUX_PATH) $@
	@$(RM) -f $(CONFIG_ROOT)
	@$(RM) -f $(HW_CONFIG_ROOT)

config: init
	@if [ -z $(HCONFIG) ]; then \
		$(RM) -f $(HW_CONFIG_ROOT); \
	fi
	$(eval CROSS_COMPILE=$(shell cat $(CONFIG_ROOT) | grep 'CROSS_COMPILE=' | sed 's/CROSS_COMPILE=//g'))
	$(eval ARCH=$(shell cat $(CONFIG_ROOT) | grep 'ARCH=' | sed 's/ARCH=//g'))
	@if [ $(CHIP) = "I143" ]; then \
		$(MAKE) -C $(XBOOT_PATH) ARCH=riscv CROSS=$(CROSS_RISCV_UNKNOWN_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g') ;\
	else \
		$(MAKE) -C $(XBOOT_PATH) ARCH=arm CROSS=$(CROSS_V5_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g'); \
	fi
	@$(MAKE_ARCH) -C $(UBOOT_PATH) CROSS_COMPILE=$(CROSS_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'UBOOT_CONFIG=' | sed 's/UBOOT_CONFIG=//g')
	@$(MAKE_ARCH) -C $(UBOOT_PATH) clean
	@$(MAKE_ARCH) -C $(LINUX_PATH) CROSS_COMPILE=$(CROSS_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'KERNEL_CONFIG=' | sed 's/KERNEL_CONFIG=//g')
	@$(MAKE_ARCH) -C $(LINUX_PATH) clean
	@$(MAKE_ARCH) initramfs
	@$(MKDIR) -p $(OUT_PATH)
	@$(RM) -f $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(PART_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL)
	@$(CP) -f $(IPACK_PATH)/bin/$(DOWN_TOOL) $(OUT_PATH)
	@$(ECHO) $(COLOR_YELLOW)"platform info :"$(COLOR_ORIGIN)
	@$(MAKE) info

hconfig:  
	@./build/hconfig.sh $(CROSS_V7_COMPILE)
	$(MAKE) config HCONFIG="1"

dtb: check
	$(eval LINUX_DTB=$(shell cat $(CONFIG_ROOT) | grep 'LINUX_DTB=' | sed 's/LINUX_DTB=//g').dtb)

	@if [ $(IS_ASSIGN_DTB) -eq 1 ]; then \
		$(MAKE_ARCH) -C $(LINUX_PATH) $(HW_DTB) CROSS_COMPILE=$(CROSS_COMPILE); \
		$(LN) -fs arch/$(ARCH)/boot/dts/$(HW_DTB) $(LINUX_PATH)/dtb; \
	else \
		$(MAKE_ARCH) -C $(LINUX_PATH) $(LINUX_DTB) CROSS_COMPILE=$(CROSS_COMPILE); \
		$(LN) -fs arch/$(ARCH)/boot/dts/$(LINUX_DTB) $(LINUX_PATH)/dtb; \
	fi
	
spirom: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE_ARCH) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN) BOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) \
		TFTP_SERVER_PATH=$(TFTP_SERVER_PATH); \
	else \
		$(MAKE_ARCH) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN) CHIP=$(CHIP); \
	fi
	@if [ -f $(IPACK_PATH)/bin/$(SPI_BIN) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(SPI_BIN)" to out folder."$(COLOR_ORIGIN); \
		$(CP) -f $(IPACK_PATH)/bin/$(SPI_BIN) $(OUT_PATH); \
	fi

tool_isp:
	@$(MAKE) -C $(TOPDIR)/build/tools/isp

isp: check tool_isp
	@if [ -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) ]; then \
		$(CP) -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(XBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(XBOOT_BIN)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
		$(CP) -f $(UBOOT_PATH)/u-boot.img $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(UBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)"u-boot.img doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(NONOS_B_PATH)/bin/$(NONOS_B_IMG) ]; then \
		$(CP) -f $(NONOS_B_PATH)/bin/$(NONOS_B_IMG) $(OUT_PATH)/a926.img; \
		$(ECHO) $(COLOR_YELLOW)"Copy nonos img to out folder."$(COLOR_ORIGIN); \
	fi
	@if [ -f $(LINUX_PATH)/$(VMLINUX) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ];then \
			$(CP) -f $(LINUX_PATH)/$(VMLINUX) $(OUT_PATH); \
			$(ECHO) $(COLOR_YELLOW)"Copy "$(VMLINUX)" to out folder."$(COLOR_ORIGIN); \
			$(CROSS_COMPILE)objcopy -O binary -S $(OUT_PATH)/$(VMLINUX) $(OUT_PATH)/$(VMLINUX).bin; \
			cd $(IPACK_PATH); \
			./add_uhdr.sh linux-`date +%Y%m%d-%H%M%S` $(PWD)/$(OUT_PATH)/$(VMLINUX).bin \
			$(PWD)/$(OUT_PATH)/$(KERNEL_BIN) 0x308000 0x308000; \
			cd $(PWD); \
			if [ -f $(OUT_PATH)/$(KERNEL_BIN) ]; then \
				$(ECHO) $(COLOR_YELLOW)"Add uhdr in "$(KERNEL_BIN)"."$(COLOR_ORIGIN); \
			else \
				$(ECHO) $(COLOR_YELLOW)"Gen "$(KERNEL_BIN)" fail."$(COLOR_ORIGIN); \
			fi; \
		else \
			$(CP) -vf $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN) $(OUT_PATH); \
		fi ; \
	else \
		$(ECHO) $(COLOR_YELLOW)$(VMLINUX)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(LINUX_PATH)/$(DTB) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ];then \
			$(CP) -f $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB).raw ; \
			cd $(IPACK_PATH); \
			pwd && pwd && pwd; \
			./add_uhdr.sh dtb-`date +%Y%m%d-%H%M%S` ../$(OUT_PATH)/$(DTB).raw ../$(OUT_PATH)/$(DTB) 0x000000 0x000000; \
			cd .. ; \
		else \
			$(CP) -vf $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB) ; \
		fi ; \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(DTB)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(DTB)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ "$(BOOT_FROM)" != "SDCARD" ]; then  \
		if [ -f $(ROOTFS_PATH)/$(ROOTFS_IMG) ]; then \
			$(ECHO) $(COLOR_YELLOW)"Copy "$(ROOTFS_IMG)" to out folder."$(COLOR_ORIGIN); \
			$(CP) -vf $(ROOTFS_PATH)/$(ROOTFS_IMG) $(OUT_PATH)/ ;\
		else \
			$(ECHO) $(COLOR_YELLOW)$(ROOTFS_IMG)" doesn't exist."$(COLOR_ORIGIN); \
			exit 1; \
		fi \
	fi
	@cd out/; ./$(ISP_SHELL) $(BOOT_FROM)
	
	@if [ "$(BOOT_FROM)" = "SDCARD" ]; then  \
		$(ECHO) $(COLOR_YELLOW) "Generating image for SD card..." $(COLOR_ORIGIN); \
		cd build/tools/sdcard_boot; ./$(SDCARD_BOOT_SHELL) ; \
	fi
	
part:
	@$(ECHO) $(COLOR_YELLOW) "Please enter the Partition NAME!!!" $(COLOR_ORIGIN)
	@cd out; ./$(PART_SHELL)
	
secure: 
	@if [ "$(SECURE_PATH)" = "xboot" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###xboot add sign data ####!!!" $(COLOR_ORIGIN) ;\
		if [ ! -f $(XBOOT_PATH)/bin/xboot.bin ]; then \
			exit 1; \
		fi ;\
		$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(XBOOT_PATH)/bin xboot.bin 0 ;\
		cd $(XBOOT_PATH); \
		/bin/bash ./add_xhdr.sh ./bin/xboot.bin ./bin/$(XBOOT_BIN) 1 ; make size_check ;\
	elif [ "$(SECURE_PATH)" = "uboot" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###uboot add sign data ####!!!" $(COLOR_ORIGIN) ;\
		if [ ! -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
			exit 1; \
		fi ;\
		$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(UBOOT_PATH) $(UBOOT_BIN) 1 ;\
	elif [ "$(SECURE_PATH)" = "kernel" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###kernel add sign data ####!!!" $(COLOR_ORIGIN);\
		if [ ! -f $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN) ]; then \
			exit 1;\
		fi ;\
		$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(LINUX_PATH)/arch/arm/boot $(KERNEL_BIN) 1 ;\
	fi

rom: check
	@if [ "$(NEED_ISP)" = '1' ]; then  \
		$(MAKE) isp; \
	else \
		$(MAKE) spirom; \
	fi

mt: check
	@$(MAKE) kernel
	cp linux/application/module_test/mt2.sh $(ROOTFS_DIR)/bin
	@$(MAKE) rootfs rom
	
init:
	@$(RM) -f $(CONFIG_ROOT)
	@./build/config.sh $(CROSS_V7_COMPILE) $(CROSS_RISCV_COMPILE)

check:
	@if ! [ -f $(CONFIG_ROOT) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Please \"make config\" first."$(COLOR_ORIGIN); \
		exit 1; \
	fi

initramfs:
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) CROSS=$(ROOTFS_CROSS) initramfs rootfs_cfg=$(ROOTFS_CONFIG) boot_from=$(BOOT_FROM)

rootfs:
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) CROSS=$(ROOTFS_CROSS) rootfs rootfs_cfg=$(ROOTFS_CONFIG) boot_from=$(BOOT_FROM)

info:
	@$(ECHO) "XBOOT =" $(XBOOT_CONFIG)
	@$(ECHO) "UBOOT =" $(UBOOT_CONFIG)
	@$(ECHO) "KERNEL =" $(KERNEL_CONFIG)
	@$(ECHO) "LINUX_DTB =" $(LINUX_DTB)
	@$(ECHO) "CROSS COMPILER =" $(CROSS_COMPILE)
	@$(ECHO) "NEED ISP =" $(NEED_ISP)
	@$(ECHO) "ZEBU RUN =" $(ZEBU_RUN)
	@$(ECHO) "BOOT FROM =" $(BOOT_FROM)
	@$(ECHO) "BOOT CHIP =" $(BOOT_CHIP)
	@$(ECHO) "ARCH =" $(ARCH)
	@$(ECHO) "CHIP =" $(CHIP)

