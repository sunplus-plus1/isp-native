#!/bin/bash 
COLOR_RED="\033[0;1;31;40m"
COLOR_GREEN="\033[0;1;32;40m"
COLOR_YELLOW="\033[0;1;33;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"
BUILD_CONFIG=./.config
HARDWARE_CONFIG=./.hwconfig
IS_ASSIGN_DTB=0

. $HARDWARE_CONFIG

XBOOT_CONFIG_ROOT=./boot/xboot/configs
UBOOT_CONFIG_ROOT=./boot/uboot/configs
KERNEL_CONFIG_ROOT=./linux/kernel/arch/arm/configs
DTB_CONFIG_ROOT=./linux/kernel/arch/arm/boot/dts

CHIPA_NAND_KERNEL_CONFIG=pentagram_sp7021_achip_emu_initramfs_defconfig
CHIPB_NAND_KERNEL_CONFIG=pentagram_sp7021_bchip_emu_initramfs_defconfig
CHIPA_EMMC_KERNEL_CONFIG=pentagram_sp7021_achip_emu_defconfig
CHIPB_EMMC_KERNEL_CONFIG=pentagram_sp7021_bchip_emu_defconfig
CHIPA_NOR_KERNEL_CONFIG=pentagram_sp7021_achip_emu_initramfs_defconfig
CHIPB_NOR_KERNEL_CONFIG=pentagram_sp7021_bchip_emu_initramfs_defconfig

BOOT_TYPE=

save_hwconfig()
{
	echo "IC_PROJ=pentagram" > $HARDWARE_CONFIG
	echo "IC_NAME=sp7021" >> $HARDWARE_CONFIG
	echo "IC_VER=${IC_VER}" >> $HARDWARE_CONFIG
	echo "CHIP_TYPE=${CHIP_TYPE}" >> $HARDWARE_CONFIG
	echo "HW_DTB=${HW_DTB}.dtb" >> $HARDWARE_CONFIG
	echo "IS_ASSIGN_DTB=${IS_ASSIGN_DTB}" >> $HARDWARE_CONFIG
}

save_config()
{
	echo "CROSS_COMPILE="$CROSS_COMPILE
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=${ROOTFS_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

chip_nand_config()
{
	if [ "$CHIP_TYPE" = "A" ];then
		UBOOT_CONFIG=pentagram_sp7021_nand_defconfig
		KERNEL_CONFIG=$CHIPA_NAND_KERNEL_CONFIG
	else
		UBOOT_CONFIG=pentagram_sp7021_nand_b_defconfig
		KERNEL_CONFIG=$CHIPB_NAND_KERNEL_CONFIG
	fi
}

chip_emmc_config()
{
	if [ "$CHIP_TYPE" = "A" ];then
		UBOOT_CONFIG=pentagram_sp7021_emmc_defconfig
		KERNEL_CONFIG=$CHIPA_EMMC_KERNEL_CONFIG
	else
		UBOOT_CONFIG=pentagram_sp7021_emmc_b_defconfig
		KERNEL_CONFIG=$CHIPB_EMMC_KERNEL_CONFIG
	fi
}

chip_nor_config()
{
	if [ "$CHIP_TYPE" = "A" ];then
		UBOOT_CONFIG=pentagram_sp7021_romter_defconfig
		KERNEL_CONFIG=$CHIPA_NOR_KERNEL_CONFIG
	else
		UBOOT_CONFIG=pentagram_sp7021_romter_b_defconfig
		KERNEL_CONFIG=$CHIPB_NOR_KERNEL_CONFIG
	fi
	NEED_ISP=0
}

change_configs()
{
	$ECHO $COLOR_GREEN"IC version ->"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] A"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] B"$COLOR_ORIGIN

	read -p "current version ["$IC_VER"]: " ic_version_num
	if [ ! -z $ic_version_num ]; then
		case "$ic_version_num" in
			1)
				IC_VER=A
				;;
			2)
				IC_VER=B
				;;
			*)
				echo "Error: Unknow config!!"
				exit 1
		esac
		echo $IC_VER" is selected"
	fi

	$ECHO $COLOR_GREEN"IC chip type ->"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] A chip"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] B chip"$COLOR_ORIGIN
	read -p "current select ["$CHIP_TYPE"]: " ic_chip_type_num
	if [ ! -z $ic_chip_type_num ]; then
		case "$ic_chip_type_num" in
			1)
				CHIP_TYPE=A
				;;
			2)
				CHIP_TYPE=B
				;;
			*)
				echo "Error: Unknow config!!"
				exit 1
		esac
		echo $CHIP_TYPE" is selected"
	fi
}

assign_dtb()
{
	$ECHO $COLOR_GREEN"Select dtb :"$COLOR_ORIGIN
	$ECHO "================================================"
	find $DTB_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram-sp*.dts" | sort -i | sed "s,"$DTB_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g" | sed "s/.dts//g"
	$ECHO ""
	read -p "current dtb ["$HW_DTB"]: " DTB_NUM

	if [ ! -z $DTB_NUM ];then
		if [ $DTB_NUM -gt 0 ]; then		
			HW_DTB=$(find $DTB_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram-sp*.dts" | sort -i | sed "s,"$DTB_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed "s/.dts//g" | sed -n $DTB_NUM"p" | sed -r "s, +[0-9]* ,,g")
			IS_ASSIGN_DTB=1
		fi
	fi

	echo "HW_DTB="$HW_DTB
	echo "IS_ASSIGN_DTB="$IS_ASSIGN_DTB
}

BREAK=0
NEW_HW_CONFIG=0
CUR_SELECT=1

if [ -z $IC_NAME ]; then
	NEW_HW_CONFIG=1
	IC_NAME=sp7021
fi

# while [ $BREAK -eq 0 ]
# do 
# 	$ECHO $COLOR_GREEN"Q628 configs <IC name: "$IC_NAME" , IC ver: "$IC_VER" ,chip: "$CHIP_TYPE">"$COLOR_ORIGIN	
# 	if [ $IS_ASSIGN_DTB -eq 1 ]; then
# 		$ECHO $COLOR_GREEN"dtb: "$HW_DTB
# 	fi

# 	if [ $NEW_HW_CONFIG -eq 1 ]; then
# 		$ECHO $COLOR_YELLOW"[1] set hw config"$COLOR_ORIGIN
# 	else
# 		$ECHO $COLOR_YELLOW"[1] EMMC"$COLOR_ORIGIN
# 		$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
# 		$ECHO $COLOR_YELLOW"[3] NOR/romter"$COLOR_ORIGIN
# 		$ECHO $COLOR_YELLOW"[4] change configs"$COLOR_ORIGIN
# 		$ECHO $COLOR_YELLOW"[5] assign dtb"$COLOR_ORIGIN
# 	fi
# 	read -p "select ["$CUR_SELECT"]: " num

# 	if [ -z $num ];then
# 		num=$CUR_SELECT
# 		echo "num0="$num
# 	fi
# 	echo "select "$num
# 	BREAK=1
# 	if [ $NEW_HW_CONFIG -eq 1 ]; then
# 		case "$num" in
# 			1)
# 				BREAK=0
# 				change_configs
# 				NEW_HW_CONFIG=0
# 				save_hwconfig
# 				;;
# 			*)
# 				echo "Error: Unknow config!!"
# 		esac
# 	else
# 		case "$num" in
# 			1)
# 				chip_emmc_config
# 				NEED_ISP=1
# 				;;
# 			2)
# 				chip_nand_config
# 				NEED_ISP=1
# 				;;
# 			3)
# 				chip_nor_config
# 				NEED_ISP=0
# 				;;
# 			4)	
# 				BREAK=0
# 				change_configs
# 				save_hwconfig
# 				;;
# 			5)
# 				BREAK=0
# 				assign_dtb
# 				save_hwconfig
# 				;;
# 			*)
# 				BREAK=0
# 				echo "Unknow config!!"
# 		esac
# 	fi
# done 

# if [ "$IC_VER" = "A" ];then
# 	XBOOT_CONFIG=q628_defconfig
# elif [ "$IC_VER" = "B" ];then
# 	XBOOT_CONFIG=q628_Rev2_defconfig
# fi

# if [ "$CHIP_TYPE" = "A" ];then
# 	ROOTFS_CONFIG=v7
# 	CROSS_COMPILE=$2
# elif [ "$CHIP_TYPE" = "B" ];then
# 	ROOTFS_CONFIG=v5
# 	CROSS_COMPILE=$1
# fi
assign_dtb
save_hwconfig
# save_config
