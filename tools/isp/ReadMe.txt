-------------------------------------------------------------------------------
Example of building Binaries (ISPBOOOT.BIN, ISP_UPDT.BIN):

#!/bin/sh

SRC_DIR=${HOME}/Q_610/MajorRelease_2.2/out

cp ${SRC_DIR}/xboot.img xboot0
cp ${SRC_DIR}/xboot.img xboot1
cp ${SRC_DIR}/u-boot.img uboot0
cp ${SRC_DIR}/u-boot.img uboot1
cp ${SRC_DIR}/u-boot.img uboot2

./isp pack_image ISPBOOOT.BIN \
	xboot0 uboot0 \
	xboot1 0x100000 \
	uboot1 0x100000 \
	uboot2 0x100000 \
	env 0x80000 \
	env_redund 0x80000 \
	${SRC_DIR}/Image 0xa00000 \
	${SRC_DIR}/ecos.img 0xb00000 \
	${SRC_DIR}/app.sqfs 0xa00000 \
	${SRC_DIR}/latest 0x100000

PARTITION_TO_UPDATE='uboot2 Image'
./isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN ${PARTITION_TO_UPDATE}
./isp extract4tftpupdate ISPBOOOT.BIN ISP_TFTP ${PARTITION_TO_UPDATE}


-------------------------------------------------------------------------------
Run tests in U-Boot console:

Whole eMMC ISP:
setenv isp_if usb && setenv isp_dev 0 && setenv isp_ram_addr 0x1000000
$isp_if start && fatload $isp_if $isp_dev $isp_ram_addr /ISPBOOOT.BIN 0x800 0x100000 && md.b $isp_ram_addr 0x200
setenv isp_main_storage emmc
setexpr script_addr $isp_ram_addr + 0x20 && setenv script_addr 0x${script_addr} && source $script_addr



Partial Update:
setenv isp_if usb && setenv isp_dev 0 && setenv isp_ram_addr 0x1000000
setenv isp_update_file_name ISP_UPDT.BIN
$isp_if start && fatload $isp_if $isp_dev $isp_ram_addr /$isp_update_file_name 0x800 && md.b $isp_ram_addr 0x200
setenv isp_main_storage emmc
setenv isp_image_header_offset 0
setexpr script_addr $isp_ram_addr + 0x20 && setenv script_addr 0x${script_addr} && source $script_addr

