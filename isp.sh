TOP=../

export PATH=$PATH:$TOP/build/tools/isp/

X=xboot.img
U=u-boot.img
K=uImage
ROOTFS=rootfs.img
D=dtb
N=a926.img
# Partition name = file name
cp $X xboot0
cp $U uboot0
cp $X xboot1
cp $U uboot1
cp $U uboot2
cp $K kernel
if [ -f $N ]; then
	cp $N nonos
fi
if [ "$1" != "SDCARD" ]; then
	cp $ROOTFS rootfs
fi
cp $D DTB

# Note:
#     If partitions' sizes listed before "kernel" are changed,
#     please make sure U-Boot settings of CONFIG_ENV_OFFSET, CONFIG_ENV_SIZE, CONFIG_SRCADDR_KERNEL and CONFIG_SRCADDR_DTB
#     are changed accordingly.
echo 'Unit in sector (512 bytes):'
for ADDR in "CONFIG_ENV_OFFSET" "CONFIG_ENV_SIZE" "CONFIG_SRCADDR_DTB" "CONFIG_SRCADDR_KERNEL"
do
	cat ${TOP}boot/uboot/.config | grep --color -e ${ADDR}
done

if [ "$1" = "SDCARD" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		nonos 0x100000 \
		dtb 0x40000 \
		kernel 0x2000000
elif [ "$1" = "EMMC" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		nonos 0x100000 \
		dtb 0x40000 \
		kernel 0x2000000 \
		rootfs 0xfc000000
elif [ "$1" = "NAND" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		nonos 0x100000 \
		dtb 0x40000 \
		kernel 0x1900000 \
		rootfs 0xe000000
elif [ "$1" = "USB" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		nonos 0x100000 \
		dtb 0x40000 \
		kernel 0xd80000
fi

rm -rf xboot0
rm -rf uboot0
rm -rf xboot1
rm -rf uboot1
rm -rf uboot2
rm -rf kernel
rm -rf DTB
rm -rf env
rm -rf env_redund
rm -rf rootfs
rm -rf nonos

# Create image for booting from SD card or USB storage.
if [ "$1" = "SDCARD" ]; then
	mkdir -p boot2linux_SDcard
	cp -rf $U $K $N ./boot2linux_SDcard
	isp extract4boot2linux_sdcardboot ISPBOOOT.BIN boot2linux_SDcard/ISPBOOOT.BIN
	rm -rf ISPBOOOT.BIN
fi
if [ "$1" = "USB" ]; then
	mkdir -p boot2linux_usb
	isp extract4boot2linux_usbboot ISPBOOOT.BIN boot2linux_usb/ISPBOOOT.BIN
	rm -rf ISPBOOOT.BIN
fi

# Create image for partial update:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN [list of partitions ...]
#   Example:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN kernel dtb
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2 kernel dtb
#
#   Execute update in U-Boot:
#     run update_usb
#     run update_sdcard
#

