#/bin/bash
TOP=../../..

#Generate a virtual image containing FAT and EXT3 partitions,
#ISPBOOOT.bin placed on the FAT partition,and uncompressed rootfs placed on the EXT2 partition
#1.set the fat partition and copy ISPBOOOT.BIN to fat.img
#2.copy resize2fs to disk/sbin/
#3.set the ext3 partition 


OUTPATH=$TOP/out/boot2linux_SDcard
FAT_FILE_IN=$OUTPATH
ROOT_DIR_IN=$TOP/linux/rootfs/initramfs/disk
OUT_FILE=$OUTPATH/ISP_SD_BOOOT.img
FAT_IMG_OUT=fat.img

#modify the rc.sdcardroot(EXT3 partition's first sector)
RC_SDCARDBOOTDIR=$ROOT_DIR_IN/etc/init.d
RC_SDCARDBOOTFILE=rc.sdcardboot
# part1 and part2 size unit:M
FAT_IMG_SIZE_M=50
ROOT_IMG_SIZE_M=1024

# block size is 512byte for sfdisk set and FAT sector is 1024 default
BLOCK_SIZE=512
FAT_SECTOR=1024

# fat.img offset 1M for EFI
seek_offset=1024
seek_bs=1024

# check file 
if [ -f $OUT_FILE ];then
	rm -rf $OUT_FILE
fi

if [ ! -d $FAT_FILE_IN ];then
	echo "Error: $FAT_FILE_IN doesn't exist!"
	exit 1
fi

if [ ! -d $ROOT_DIR_IN ];then
	echo "Error: $WORK_DIR doesn't exist!"
	exit 1
fi

# Calculated params.
mega="$(echo '2^20' | bc)"

partition_size_1=$(($FAT_IMG_SIZE_M * $mega))
partition_size_2=$(($ROOT_IMG_SIZE_M * $mega))

#create fat img and copy ISPBOOOT to fat.img
rm -f "$FAT_IMG_OUT"

sz=`du -sb $FAT_FILE_IN | cut -f1` 
if [ $sz -gt $partition_size_1 ];then 
	echo "$FAT_FILE_IN size(${sz}byte) is too larger. Please modify the FAT_IMG_SIZE_M size(${partition_size_1}byte).\n" ; 
	exit 1; 
fi

if [ -x "$(command -v mkfs.fat)" ]; then 
  echo '######do mkfs.fat cmd ########' 
  mkfs.fat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))" 
else 
	if [ -x "$(command -v mkfs.vfat)" ]; then 
	  echo '######do mkfs.vfat cmd ########' 
	  mkfs.vfat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))" 
		if [ $? -ne 0 ];then
			exit
		fi
	else 
	  echo "no mkfs.fat and mkfs.vfat cmd ,please install it" 
	  exit 
	fi
fi

if [ -x "$(command -v mcopy)" ]; then 
  echo '######do the mcopy cmd ########' 
  mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN/ISPBOOOT.BIN" "$FAT_FILE_IN/dtb" "$FAT_FILE_IN/uImage" "$FAT_FILE_IN/u-boot.img" ::
  if [ $? -ne 0 ];then
    exit
  fi
else 
  echo "no mcopy cmd ,please install it" 
  exit 
fi

# offset fat.img

dd if="$FAT_IMG_OUT" of="$OUT_FILE" bs="$seek_bs" seek="$seek_offset"
rm -f "$FAT_IMG_OUT"
#create and offset ext2.img 
#modify the ext partition's first sector in etc/init.d/rc.sdcardboot use to resize2fs root partition.
cp -rf "$RC_SDCARDBOOTFILE" $RC_SDCARDBOOTDIR

sz=`du -sb $ROOT_DIR_IN | cut -f1` 
if [ $sz -gt $partition_size_2 ];then 
	echo "$ROOT_DIR_IN size(${sz}byte) is too larger. Please modify the ROOT_IMG_SIZE_M size(${partition_size_2}byte).\n" ; 
	exit 1; 
fi
echo '######do mke2fs cmd ,mke2fs version need to bigger than 1.45.1########' 
chmod 777 $ROOT_DIR_IN/bin/busybox
./mke2fs -j -d "$ROOT_DIR_IN" \
  -r 1 \
  -N 0 \
  -m 5 \
  -L '' \
  -O ^64bit \
  -b 4096 \
  -E offset="$(($partition_size_1+$seek_bs*$seek_offset))" \
  "$OUT_FILE" "${ROOT_IMG_SIZE_M}M" \
;
if [ $? -ne 0 ];then
 	exit
fi
# create the partition info
echo '######do sfdisk cmd ,sfdisk version need to bigger than 2.27.1########' 
if [ -x "$(command -v sfdisk)" ]; then 
  sfdisk -v
  printf "
  type=b, size=$(($partition_size_1/$BLOCK_SIZE))
  type=83, size=$(($partition_size_2/$BLOCK_SIZE))
  " | sfdisk "$OUT_FILE"
else 
  echo "no sfdisk cmd ,please install it" 
  exit 
fi

#rm -rf $FAT_FILE_IN
#to avoid switch to emmc and init from rc.sdcard
#rm -rf $RC_SDCARDBOOTDIR/$RC_SDCARDBOOTFILE

