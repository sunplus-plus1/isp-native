#!/bin/bash

TOP=../../..

# Generate a disk image containing FAT and EXT3 partitions.
# ISPBOOOT.BIN, u-boot.img, uImage, a926.img, and uEnv.txt
# are placed on the FAT partition, and uncompressed rootfs
# is placed on the EXT3 partition.
# 1. Create boot (FAT) partition.
# 2. Copy ISPBOOOT.BIN, u-boot.img, uImage, a926.img, and 
#    uEnv.txt to it.
# 3. Copy boot partition to output file 'ISP_SD_BOOOT.img'.
# 4. Create root (ext3) partition.
# 5. Copy 'rc.sdcardboot' to '/etc/init.d' of root partition.
# 6. Resize root partition.
# 7. Copy root partition to output file 'ISP_SD_BOOOT.img'.
# 8. Create partition table.

OUTPATH=$TOP/out/boot2linux_SDcard
FAT_FILE_IN=$OUTPATH
ROOT_DIR_IN=$TOP/linux/rootfs/initramfs/disk
ROOT_IMG=$OUTPATH/../rootfs.img
OUT_FILE=$OUTPATH/ISP_SD_BOOOT.img
FAT_IMG_OUT=fat.img
EXT_ENV=uEnv.txt
NONOS_IMG=a926.img
RC_SDCARDBOOTDIR=$ROOT_DIR_IN/etc/init.d
RC_SDCARDBOOTFILE=rc.sdcardboot

# Size of FAT partition size (unit: M)
FAT_IMG_SIZE_M=100

# Block size is 512 bytes for sfdisk and FAT sector is 1024 bytes
BLOCK_SIZE=512
FAT_SECTOR=1024

# fat.img offset 1M for EFI
seek_offset=1024
seek_bs=1024

# Check file
if [ -f $OUT_FILE ]; then
	rm -rf $OUT_FILE
fi

if [ ! -d $FAT_FILE_IN ]; then
	echo "Error: $FAT_FILE_IN doesn't exist!"
	exit 1
fi

if [ ! -d $ROOT_DIR_IN ]; then
	echo "Error: $WORK_DIR doesn't exist!"
	exit 1
fi

# cp uEnv to out/sdcardboot 
cp $EXT_ENV $OUTPATH

# Calculate parameter.
partition_size_1=$(($FAT_IMG_SIZE_M*1024*1024))

# Check size of FAT partition.
rm -f "$FAT_IMG_OUT"

sz=`du -sb $FAT_FILE_IN | cut -f1`
if [ $sz -gt $partition_size_1 ]; then
	echo "Size of '$FAT_FILE_IN' (${sz} bytes) is too larger."
	echo "Please modify FAT_IMG_SIZE_M (${partition_size_1} bytes)."
	exit 1;
fi

if [ -x "$(command -v mkfs.fat)" ]; then
	echo '###### do mkfs.fat cmd ########'
	mkfs.fat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))"
	if [ $? -ne 0 ]; then
		exit
	fi
else
	if [ -x "$(command -v mkfs.vfat)" ]; then
		echo '###### do mkfs.vfat cmd ########'
		mkfs.vfat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))"
		if [ $? -ne 0 ]; then
			exit
		fi
	else
		echo "No mkfs.fat and mkfs.vfat cmd, please install it!"
		exit
	fi
fi

if [ -x "$(command -v mcopy)" ]; then
	echo '###### do the mcopy cmd ########'
	mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN/ISPBOOOT.BIN" "$OUTPATH/$EXT_ENV" "$FAT_FILE_IN/uImage" "$FAT_FILE_IN/u-boot.img" ::
	if [ -f $FAT_FILE_IN/$NONOS_IMG ]; then
		mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN/$NONOS_IMG" ::
	fi
	if [ $? -ne 0 ]; then
		exit
	fi
else
	echo "No mcopy cmd, please install it!"
	exit
fi

# Offset boot partition (FAT)
dd if="$FAT_IMG_OUT" of="$OUT_FILE" bs="$seek_bs" seek="$seek_offset"
rm -f "$FAT_IMG_OUT"

# Create root partition (exte)
# Copy 'rc.sdcardboot' to '/etc/init.d' of root partition.
cp -rf "$RC_SDCARDBOOTFILE" $RC_SDCARDBOOTDIR

# Calculate size of root partition (assume 40% + 10MB overhead).
sz=`du -sb $ROOT_DIR_IN | cut -f1`
sz=$((sz*14/10))
partition_size_2=$((sz/1024/1024+10))

echo '###### do mke2fs cmd (mke2fs version need to bigger than 1.45.1) ########'
chmod 777 $ROOT_DIR_IN/bin/busybox
rm -f "$ROOT_IMG"
./mke2fs -j -d "$ROOT_DIR_IN" -r 1 -N 0 -L '' -O ^64bit -b 4096 "$ROOT_IMG" "$((partition_size_2))M"
if [ $? -ne 0 ]; then
 	exit
fi

# Resize to minimum + 10%
resize2fs -M "$ROOT_IMG"
partition_size_2=`du -sb $ROOT_IMG | cut -f1`
partition_size_2=$((partition_size_2*11/10))
partition_size_2=$(((partition_size_2+1048575)/1024/1024))
echo "rootfs created size = $partition_size_2 MB"
resize2fs $ROOT_IMG $(($partition_size_2))M

# Offset root partition (ext3)
dd if="$ROOT_IMG" of="$OUT_FILE" bs="$seek_bs" seek="$(($seek_offset+$partition_size_1/$seek_bs))"

# Create the partition info
partition_size_2=$((partition_size_2*1024*1024))
echo '###### do sfdisk cmd (sfdisk version need to bigger than 2.27.1) ########'
if [ -x "$(command -v sfdisk)" ]; then
	sfdisk -v
	printf "type=b, size=$(($partition_size_1/$BLOCK_SIZE))
	        type=83, size=$(($partition_size_2/$BLOCK_SIZE))" |
	sfdisk "$OUT_FILE"
else
	echo "no sfdisk cmd, please install it"
	exit
fi
