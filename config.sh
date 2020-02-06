#!/bin/bash
COLOR_RED="\033[0;1;31;40m"
COLOR_GREEN="\033[0;1;32;40m"
COLOR_YELLOW="\033[0;1;33;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"
BUILD_CONFIG=./.config

XBOOT_CONFIG_ROOT=./boot/xboot/configs
UBOOT_CONFIG_ROOT=./boot/uboot/configs
KERNEL_CONFIG_ROOT=./linux/kernel/arch/arm/configs

pentagram_b_chip_nand_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_SPINAND_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_nand_b_defconfig
	KERNEL_CONFIG=pentagram_sp7021_bchip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=0
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_b_chip_emmc_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_emmc_b_defconfig
	KERNEL_CONFIG=pentagram_sp7021_bchip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=0
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_b_chip_nor_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_romter_b_defconfig
	KERNEL_CONFIG=pentagram_sp7021_bchip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
}

pentagram_b_chip_sdcard_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_emmc_b_defconfig
	KERNEL_CONFIG=pentagram_sp7021_bchip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_b_chip_tftp_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_romter_b_defconfig
	KERNEL_CONFIG=pentagram_sp7021_bchip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	BOOT_KERNEL_FROM_TFTP=1
	echo "Please enter TFTP server IP address: (Default is 172.18.12.62)"
	read TFTP_SERVER_IP
	if [ "${TFTP_SERVER_IP}" == "" ]; then
		TFTP_SERVER_IP=172.18.12.62
	fi
	echo "TFTP server IP address is ${TFTP_SERVER_IP}"
	echo "Please enter TFTP server path: (Default is /home/scftp)"
	read TFTP_SERVER_PATH
	if [ "${TFTP_SERVER_PATH}" == "" ]; then
		TFTP_SERVER_PATH=/home/scftp
	fi
	echo "TFTP server path is ${TFTP_SERVER_PATH}"
	echo "Please enter board MAC address:"
	read BOARD_MAC_ADDR
	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

pentagram_a_chip_nand_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_SPINAND_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_nand_defconfig
	KERNEL_CONFIG=pentagram_sp7021_achip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=0
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_a_chip_emmc_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_emmc_defconfig
	KERNEL_CONFIG=pentagram_sp7021_achip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=0
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_a_chip_nor_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_romter_defconfig
	KERNEL_CONFIG=pentagram_sp7021_achip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
}

pentagram_a_chip_sdcard_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_emmc_defconfig
	KERNEL_CONFIG=pentagram_sp7021_achip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	SDCARD_BOOT=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "SDCARD_BOOT="$SDCARD_BOOT >> $BUILD_CONFIG
}

pentagram_a_chip_tftp_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=pentagram_sp7021_romter_defconfig
	KERNEL_CONFIG=pentagram_sp7021_achip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	BOOT_KERNEL_FROM_TFTP=1
	echo "Please enter TFTP server IP address: (Default is 172.18.12.62)"
	read TFTP_SERVER_IP
	if [ "${TFTP_SERVER_IP}" == "" ]; then
		TFTP_SERVER_IP=172.18.12.62
	fi
	echo "TFTP server IP address is ${TFTP_SERVER_IP}"
	echo "Please enter TFTP server path: (Default is /home/scftp)"
	read TFTP_SERVER_PATH
	if [ "${TFTP_SERVER_PATH}" == "" ]; then
		TFTP_SERVER_PATH=/home/scftp
	fi
	echo "TFTP server path is ${TFTP_SERVER_PATH}"
	echo "Please enter MAC address of target board (ex: 00:22:60:00:88:20):"
	echo "(Press Enter directly if you want to use board's default MAC address.)"
	read BOARD_MAC_ADDR
	if [ "${BOARD_MAC_ADDR}" != "" ]; then
		echo "MAC address of target board is ${BOARD_MAC_ADDR}"
	fi
	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="${CROSS_COMPILE} >> $BUILD_CONFIG
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

pentagram_8388_b_chip_config()
{
	XBOOT_CONFIG=8388_defconfig
	UBOOT_CONFIG=pentagram_8388_b_defconfig
	KERNEL_CONFIG=pentagram_8388_bchip_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
}

others_config()
{
	$ECHO $COLOR_GREEN"Initial all configs."$COLOR_ORIGIN

	$ECHO $COLOR_GREEN"Select xboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read XBOOT_CONFIG_NUM
	if [ -z $XBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	XBOOT_CONFIG=$(find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f  -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $XBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select uboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read UBOOT_CONFIG_NUM
	if [ -z $UBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	UBOOT_CONFIG=$(find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $UBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select kernel config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read KERNEL_CONFIG_NUM
	if [ -z $KERNEL_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	KERNEL_CONFIG=$(find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $KERNEL_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select rootfs config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read ROOTFS_CONFIG_NUM
	if [ $ROOTFS_CONFIG_NUM = '1' ];then
		ROOTFS_CONFIG=v5
	elif [ $ROOTFS_CONFIG_NUM = '2' ];then
		ROOTFS_CONFIG=v7
	fi

	$ECHO $COLOR_GREEN"Select compiler config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read COMPILER_CONFIG_NUM
	if [ $COMPILER_CONFIG_NUM = '1' ];then
		CROSS_COMPILE=$1
	elif [ $COMPILER_CONFIG_NUM = '2' ];then
		CROSS_COMPILE=$2
	fi

	$ECHO $COLOR_GREEN"Need isp?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ISP_CONFIG
	if [ $NEED_ISP_CONFIG = 'y' ];then
		NEED_ISP=1
	elif [ $NEED_ISP_CONFIG = 'n' ];then
		NEED_ISP=0
	fi

	$ECHO $COLOR_GREEN"Zebu run?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ZEBU_RUN
	if [ $NEED_ZEBU_RUN = 'y' ];then
		ZEBU_RUN=1
	elif [ $NEED_ZEBU_RUN = 'n' ];then
		ZEBU_RUN=0
	fi

	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=${ROOTFS_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	if [ $NEED_ISP = '1' ];then
		echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	fi
	if [ $ZEBU_RUN = '1' ];then
		echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
	fi
}

$ECHO $COLOR_GREEN"Q628 configs."$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] Pentagram B chip (EMMC), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] Pentagram B chip (SPI-NAND), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[3] Pentagram B chip (NOR/romter), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[4] Pentagram B chip (SDCARD), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[5] Pentagram B chip (TFTP), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[6] Pentagram A chip (EMMC), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[7] Pentagram A chip (SPI-NAND), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[8] Pentagram A chip (NOR/romter), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[9] Pentagram A chip (SDCARD), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[10] Pentagram A chip (TFTP), revB IC"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[11] 8388 B chip"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[12] others"$COLOR_ORIGIN
read num

case "$num" in
	1)
		pentagram_b_chip_emmc_config $1 revB
		;;
	2)
		pentagram_b_chip_nand_config $1 revB
		;;
	3)
		pentagram_b_chip_nor_config $1 revB
		;;
	4)
		pentagram_b_chip_sdcard_config $1 revB
		;;
	5)
		pentagram_b_chip_tftp_config $1 revB
		;;
	6)
		pentagram_a_chip_emmc_config $2 revB
		;;
	7)
		pentagram_a_chip_nand_config $2 revB
		;;
	8)
		pentagram_a_chip_nor_config $2 revB
		;;
	9)
		pentagram_a_chip_sdcard_config $2 revB
		;;
	10)
		pentagram_a_chip_tftp_config $2 revB
		;;
	11)
		pentagram_8388_b_chip_config $1
		;;
	12)
		others_config $1 $2
		;;
	*)
		echo "Error: Unknow config!!"
		exit 1
esac
