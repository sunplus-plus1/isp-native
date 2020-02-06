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

CROSS_V7_COMPILE = $(TOOLCHAIN_V7_PATH)/arm-linux-gnueabihf-
CROSS_V5_COMPILE = $(TOOLCHAIN_V5_PATH)/armv5-glibc-linux-

NEED_ISP ?= 0
ZEBU_RUN ?= 0
SDCARD_BOOT ?= 0
IS_ASSIGN_DTB ?= 0

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

LINUX_DTB = $(shell echo $(KERNEL_CONFIG) | sed 's/_defconfig//g' | sed 's/_/-/g').dtb

BUILD_PATH = build
XBOOT_PATH = boot/xboot
UBOOT_PATH = boot/uboot
LINUX_PATH = linux/kernel
ROOTFS_PATH = linux/rootfs
IPACK_PATH = ipack
OUT_PATH = out

XBOOT_BIN = xboot.img
UBOOT_BIN = u-boot.img
KERNEL_BIN = uImage
DTB = dtb
VMLINUX = vmlinux
ROOTFS_DIR = $(ROOTFS_PATH)/initramfs/disk
ROOTFS_IMG = rootfs.img

ROOTFS_CROSS = $(CROSS_V7_COMPILE)
ifeq ($(ROOTFS_CONFIG),v5)
ROOTFS_CROSS = $(CROSS_V5_COMPILE)
endif

# 0: uImage, 1: qk_boot image (uncompressed)
USE_QK_BOOT=0

SPI_BIN = spi_all.bin
DOWN_TOOL  = down_32M.exe

.PHONY: all xboot uboot kenel rom clean distclean config init check rootfs info
.PHONY: dtb spirom isp tool_isp

#xboot build
xboot: check
	@$(MAKE) $(MAKE_JOBS) -C $(XBOOT_PATH) CROSS=$(TOOLCHAIN_V5_PATH)/armv5-glibc-linux- all

#uboot build
uboot: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE) \
			BOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) TFTP_SERVER_IP=$(TFTP_SERVER_IP) \
			BOARD_MAC_ADDR=$(BOARD_MAC_ADDR) USER_NAME=$(USER_NAME); \
	else \
		$(MAKE) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE); \
	fi
#kernel build
kernel: check
	@$(MAKE) $(MAKE_JOBS) -C $(LINUX_PATH) modules CROSS_COMPILE=$(CROSS_COMPILE)
	@$(RM) -rf $(ROOTFS_DIR)/lib/modules/
	@$(RM) -f $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN)
	@$(MAKE) $(MAKE_JOBS) -C $(LINUX_PATH) modules_install INSTALL_MOD_PATH=../../$(ROOTFS_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE)
	@$(MAKE) $(MAKE_JOBS) -C $(LINUX_PATH) uImage V=0 CROSS_COMPILE=$(CROSS_COMPILE)

clean:
	@$(MAKE) -C $(XBOOT_PATH) CROSS=$(TOOLCHAIN_V5_PATH)/armv5-glibc-linux- $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@
	@$(MAKE) -C $(ROOTFS_PATH) $@
	@$(RM) -rf $(OUT_PATH)
	@$(RM) -f $(HW_CONFIG_ROOT)

distclean: clean
	@$(MAKE) -C $(XBOOT_PATH) $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@
	@$(MAKE) -C $(ROOTFS_PATH) $@
	@$(RM) -f $(CONFIG_ROOT)
	@$(RM) -rf $(OUT_PATH)

config: init
	@if [ -z $(HCONFIG) ]; then \
		$(RM) -f $(HW_CONFIG_ROOT); \
	fi
	@$(MAKE) -C $(XBOOT_PATH) CROSS=$(TOOLCHAIN_V5_PATH)/armv5-glibc-linux- $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g')
	@$(MAKE) -C $(UBOOT_PATH) CROSS_COMPILE=$(CROSS_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'UBOOT_CONFIG=' | sed 's/UBOOT_CONFIG=//g')
	@$(MAKE) -C $(LINUX_PATH) CROSS_COMPILE=$(CROSS_COMPILE) $(shell cat $(CONFIG_ROOT) | grep 'KERNEL_CONFIG=' | sed 's/KERNEL_CONFIG=//g')
	@$(MAKE) -C $(LINUX_PATH) clean
	@$(MAKE) CROSS=$(TOOLCHAIN_V7_PATH)/arm-linux-gnueabihf- initramfs
	@$(MKDIR) -p $(OUT_PATH)
	@$(RM) -f $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(PART_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL)
	@$(CP) -f $(IPACK_PATH)/bin/$(DOWN_TOOL) $(OUT_PATH)
	@$(ECHO) $(COLOR_YELLOW)"platform info :"$(COLOR_ORIGIN)
	@$(MAKE) info

hconfig:  
	@./build/hconfig.sh $(CROSS_V5_COMPILE) $(CROSS_V7_COMPILE)
	$(MAKE) config HCONFIG="1"

dtb: check
	@if [ $(IS_ASSIGN_DTB) -eq 1 ]; then \
		$(MAKE) -C $(LINUX_PATH) $(HW_DTB) CROSS_COMPILE=$(CROSS_COMPILE); \
		$(LN) -fs arch/arm/boot/dts/$(HW_DTB) $(LINUX_PATH)/dtb; \
	else \
		$(MAKE) -C $(LINUX_PATH) $(LINUX_DTB) CROSS_COMPILE=$(CROSS_COMPILE); \
		$(LN) -fs arch/arm/boot/dts/$(LINUX_DTB) $(LINUX_PATH)/dtb; \
	fi

spirom: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN) BOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) \
		TFTP_SERVER_PATH=$(TFTP_SERVER_PATH); \
	else \
		$(MAKE) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN); \
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
	@if [ -f $(ROOTFS_PATH)/$(ROOTFS_IMG) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(ROOTFS_IMG)" to out folder."$(COLOR_ORIGIN); \
		$(CP) -vf $(ROOTFS_PATH)/$(ROOTFS_IMG) $(OUT_PATH)/ ;\
	else \
		$(ECHO) $(COLOR_YELLOW)$(ROOTFS_IMG)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@cd out/; ./$(ISP_SHELL)
	
	@if [ "$(SDCARD_BOOT)" = '1' ]; then  \
		cd build/tools/sdcard_boot; \
		echo "sdcard gen disk image" ; \
		./$(SDCARD_BOOT_SHELL) ; \
		cd ../../.. ;\
	fi
	
part:
	@$(ECHO) $(COLOR_YELLOW) "Please enter the Partition NAME!!!" $(COLOR_ORIGIN)
	@cd out; ./$(PART_SHELL)
	
secure: check
	@$(ECHO) $(COLOR_YELLOW) "###xboot add sign data ####!!!" $(COLOR_ORIGIN)
	@if [ ! -f $(XBOOT_PATH)/bin/xboot.bin ]; then \
		exit 1; \
	fi 
	@$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(XBOOT_PATH)/bin xboot.bin 0 
	@cd $(XBOOT_PATH); \
	/bin/bash ./add_xhdr.sh ./bin/xboot.bin ./bin/$(XBOOT_BIN) 1

	@$(ECHO) $(COLOR_YELLOW) "###uboot add sign data ####!!!" $(COLOR_ORIGIN)
	@if [ ! -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
		exit 1; \
	fi
	@$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(UBOOT_PATH) $(UBOOT_BIN) 1

	@$(ECHO) $(COLOR_YELLOW) "###kernel add sign data ####!!!" $(COLOR_ORIGIN)
	@if [ ! -f $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN) ]; then \
		exit 1;\
	fi
	@$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(LINUX_PATH)/arch/arm/boot $(KERNEL_BIN) 1

rom: check
	@if [ "$(NEED_ISP)" = '1' ]; then  \
		$(MAKE) isp; \
	else \
		$(MAKE) spirom; \
	fi

# rootfs image is created by :
# make initramfs -> re-create initial disk/
# make kernel    -> install kernel modules to disk/lib/modules/
# make rootfs    -> create rootfs image from disk/

all: check
	@$(MAKE) xboot
	@$(MAKE) uboot
	@$(MAKE) kernel
	@$(MAKE) secure
	@$(MAKE) rootfs
	@$(MAKE) dtb
	@$(MAKE) rom

mt: check
	@$(MAKE) kernel
	cp linux/application/module_test/mt2.sh $(ROOTFS_DIR)/bin
	@$(MAKE) rootfs rom
	
test: check
	@$(MAKE) $(MAKE_JOBS) -C linux/application/module_test/i2ctea5767 CROSS_COMPILE=$(CROSS_COMPILE)

init:
	@$(RM) -f $(CONFIG_ROOT)
	@./build/config.sh $(CROSS_V5_COMPILE) $(CROSS_V7_COMPILE)

check:
	@if ! [ -f $(CONFIG_ROOT) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Please \"make config\" first."$(COLOR_ORIGIN); \
		exit 1; \
	fi

initramfs:
	@$(MAKE) -C $(ROOTFS_PATH) CROSS=$(ROOTFS_CROSS) initramfs rootfs_cfg=$(ROOTFS_CONFIG)

rootfs:
	@$(MAKE) -C $(ROOTFS_PATH) CROSS=$(ROOTFS_CROSS) rootfs rootfs_cfg=$(ROOTFS_CONFIG)

info:
	@$(ECHO) "XBOOT =" $(XBOOT_CONFIG)
	@$(ECHO) "UBOOT =" $(UBOOT_CONFIG)
	@$(ECHO) "KERNEL =" $(KERNEL_CONFIG)
	@$(ECHO) "CROSS COMPILER =" $(CROSS_COMPILE)
	@$(ECHO) "NEED ISP =" $(NEED_ISP)
	@$(ECHO) "ZEBU RUN =" $(ZEBU_RUN)
	@$(ECHO) "SDCARD BOOT =" $(SDCARD_BOOT)