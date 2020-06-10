#!/bin/bash
COLOR_RED="\033[0;1;31;40m"
COLOR_GREEN="\033[0;1;32;40m"
COLOR_YELLOW="\033[0;1;33;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"
BUILD_CONFIG=./.config

XBOOT_CONFIG_ROOT=./boot/xboot/configs
UBOOT_CONFIG_ROOT=./boot/uboot/configs
KERNEL_ARM_CONFIG_ROOT=./linux/kernel/arch/arm/configs
KERNEL_RISCV_CONFIG_ROOT=./linux/kernel/arch/riscv/configs

UBOOT_CONFIG=
KERNEL_CONFIG=
BOOT_FROM=
XBOOT_CONFIG=

ARCH=arm

set_uboot_config()
{
	if [ "$UBOOT_CONFIG" = "" ];then
		UBOOT_CONFIG=$1
	fi
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
}

set_kernel_config()
{
	if [ "$KERNEL_CONFIG" = "" ];then
		KERNEL_CONFIG=$1
	fi
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
}

set_bootfrom_config()
{
	if [ "$BOOT_FROM" = "" ];then
		BOOT_FROM=$1
	fi
	echo "BOOT_FROM="$BOOT_FROM >> $BUILD_CONFIG
}

set_xboot_config()
{
	if [ "$XBOOT_CONFIG" = "" ];then
		XBOOT_CONFIG=$1
	fi
	echo "XBOOT_CONFIG="$XBOOT_CONFIG >> $BUILD_CONFIG
}

p_chip_nand_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_SPINAND_defconfig
	set_uboot_config sp7021_nand_p_defconfig
	set_kernel_config sp7021_chipP_emu_nand_defconfig
	set_bootfrom_config NAND

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

p_chip_emmc_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_emmc_p_defconfig
	set_kernel_config sp7021_chipP_emu_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

p_chip_nor_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig
	set_bootfrom_config SPINOR
}

p_chip_tftp_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig

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
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig

	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

p_chip_usb_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig
	set_bootfrom_config USB

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_nand_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_SPINAND_defconfig
	set_uboot_config sp7021_nand_c_defconfig
	set_kernel_config sp7021_chipC_emu_nand_defconfig
	set_bootfrom_config NAND

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_emmc_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_emmc_c_defconfig
	set_kernel_config sp7021_chipC_emu_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_nor_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig
	set_bootfrom_config SPINOR
}

c_chip_tftp_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig

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
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig

	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

c_chip_usb_config()
{
	if [ "$1" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig
	set_bootfrom_config USB

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

i143_c_chip_nor_config()
{
	set_xboot_config i143_romter_c_defconfig
	set_uboot_config i143_romter_c_defconfig
	set_kernel_config i143_chipC_ev_initramfs_defconfig
	set_bootfrom_config SPINOR
}

i143_c_chip_emmc_config()
{
	set_xboot_config i143_emmc_c_defconfig
	set_uboot_config i143_emmc_c_defconfig
	set_kernel_config i143_chipC_ev_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

i143_p_chip_nor_config()
{
	set_xboot_config i143_romter_p_defconfig
	set_uboot_config i143_romter_p_defconfig
	set_kernel_config i143_chipP_ev_initramfs_defconfig
	set_bootfrom_config SPINOR
}
i143_p_chip_emmc_config()
{
	set_xboot_config i143_emmc_p_defconfig
	set_uboot_config i143_emmc_p_defconfig
	set_kernel_config i143_chipP_ev_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}
i143_p_chip_tftp_config()
{
	set_xboot_config i143_romter_p_defconfig
	set_uboot_config i143_romter_p_defconfig
	set_kernel_config i143_chipP_ev_initramfs_defconfig

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
	set_uboot_config i143_romter_p_defconfig
	set_kernel_config i143_chipP_ev_initramfs_defconfig

	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

i143_p_chip_usb_config()
{
	set_xboot_config i143_romter_p_defconfig
	set_uboot_config i143_romter_p_defconfig
	set_kernel_config i143_chipP_ev_initramfs_defconfig
	set_bootfrom_config USB

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

i143_c_chip_zmem_config()
{
	set_xboot_config i143_Rev2_c_zmem_defconfig
	set_uboot_config i143_romter_c_zebu_defconfig
	set_kernel_config i143_chipC_ev_initramfs_defconfig
	set_bootfrom_config SPINOR

	ZEBU_RUN=1
	echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
}

i143_p_chip_zmem_config()
{
	set_xboot_config i143_Rev2_p_zmem_defconfig
	set_uboot_config i143_romter_p_zebu_defconfig
	set_kernel_config i143_chipP_ev_initramfs_defconfig
	set_bootfrom_config SPINOR

	ZEBU_RUN=1
	echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
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
	find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read UBOOT_CONFIG_NUM
	if [ -z $UBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	UBOOT_CONFIG=$(find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $UBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select kernel config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $KERNEL_ARM_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_ARM_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read KERNEL_CONFIG_NUM
	if [ -z $KERNEL_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	KERNEL_CONFIG=$(find $KERNEL_ARM_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_ARM_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $KERNEL_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

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

	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
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

num=0

list_config()
{
	sel=1
	if [ "$board" = "1" ];then # board == ev
		$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[3] NOR/Romter"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[4] SD Card"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[5] TFTP server"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[6] USB"$COLOR_ORIGIN
		# if [ "$chip" = "1" ];then # chip == C
		# 	$ECHO $COLOR_YELLOW"[7] others"$COLOR_ORIGIN
		# fi
		read sel
		if [ "$sel" = "4" ];then
			BOOT_FROM=SDCARD
		fi
	elif [ "$board" = "11" ];then
		$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[2] NOR/Romter"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[3] SD Card"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[4] TFTP server"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[5] USB"$COLOR_ORIGIN
		read sel
		if [ "$sel" = "3" ];then
			BOOT_FROM=SDCARD
		fi
	elif [ "$board" = "12" ];then
		sel=1
	else
		if [ "$board" != "2" ];then # board == ev
			$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] SD Card"$COLOR_ORIGIN
			read sel
		fi
		if [ "$sel" = "2" ];then
			BOOT_FROM=SDCARD
			sel=4
		fi
	fi
	num=`expr $sel + $num`
}

$ECHO $COLOR_GREEN"Select boards:"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] SP7021 Ev Board             [11] I143 Ev Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] LTPP3G2 Board               [12] I143 Zebu (zmem)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[3] SP7021 Demo Board (V1/V2)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[4] SP7021 Demo Board (V3)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[5] BPi-F2S Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[6] BPi-F2P Board"$COLOR_ORIGIN
read board
chip=1

if [ "$board" = "1" ];then
	echo "LINUX_DTB=sp7021-ev" > $BUILD_CONFIG
	$ECHO $COLOR_GREEN"Select chip."$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] Chip C"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] Chip P"$COLOR_ORIGIN
	read chip
elif [ "$board" = "2" ];then
	echo "LINUX_DTB=sp7021-ltpp3g2revD" > $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_tppg2_defconfig
	KERNEL_CONFIG=sp7021_chipC_ltpp3g2_defconfig
elif [ "$board" = "3" ];then
	echo "LINUX_DTB=sp7021-demov2" > $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_demov2_defconfig
	KERNEL_CONFIG=sp7021_chipC_demov2_defconfig
elif [ "$board" = "4" ];then
	echo "LINUX_DTB=sp7021-demov3" > $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_demov3_defconfig
	KERNEL_CONFIG=sp7021_chipC_demov3_defconfig
elif [ "$board" = "5" ];then
	echo "LINUX_DTB=sp7021-bpi-f2s" > $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_bpi_f2s_defconfig
	KERNEL_CONFIG=sp7021_chipC_bpi-f2s_defconfig
elif [ "$board" = "6" ];then
	echo "LINUX_DTB=sp7021-bpi-f2p" > $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_bpi_f2p_defconfig
	KERNEL_CONFIG=sp7021_chipC_bpi-f2p_defconfig
elif [ "$board" = "11" -o "$board" = "12" ];then
	$ECHO $COLOR_GREEN"Select chip."$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] Chip C"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] Chip P"$COLOR_ORIGIN
	read chip
else
	echo "Error: Unknow board!!"
	exit 1
fi

if [ "$board" = "11" -o "$board" = "12" ];then
	echo "CHIP=I143" > $BUILD_CONFIG
else
	echo "CHIP=Q628" >> $BUILD_CONFIG
fi

if [ "$chip" = "1" ];then
	$ECHO $COLOR_GREEN"Select configs (C chip)."$COLOR_ORIGIN
	if [ "$board" = "11" ];then
		echo "LINUX_DTB=pentagram-i143-achip-emu-initramfs" >> $BUILD_CONFIG
		num=12
	elif [ "$board" = "12" ];then
		echo "LINUX_DTB=pentagram-i143-achip-emu-initramfs" >> $BUILD_CONFIG
		num=22
	else
		num=6
	fi
	echo "CROSS_COMPILE="$1 >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "BOOT_CHIP=C_CHIP" >> $BUILD_CONFIG

elif [ "$chip" = "2" ];then
	$ECHO $COLOR_GREEN"Select configs (P chip)."$COLOR_ORIGIN
	if [ "$board" = "11" ];then
		ARCH=riscv
		echo "LINUX_DTB=sunplus/i143-ev" >> $BUILD_CONFIG
		echo "CROSS_COMPILE="$2 >> $BUILD_CONFIG
		echo "ROOTFS_CONFIG=riscv" >> $BUILD_CONFIG
		num=17
	elif [ "$board" = "12" ];then
		ARCH=riscv
		echo "LINUX_DTB=sunplus/i143-ev" >> $BUILD_CONFIG
		echo "CROSS_COMPILE="$2 >> $BUILD_CONFIG
		echo "ROOTFS_CONFIG=riscv" >> $BUILD_CONFIG
		num=25
	else
		echo "CROSS_COMPILE="$1 >> $BUILD_CONFIG
		echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	fi
	echo "BOOT_CHIP=P_CHIP" >> $BUILD_CONFIG
fi

echo "ARCH=$ARCH" >> $BUILD_CONFIG

list_config
echo "select "$num

case "$num" in
	1)
		p_chip_emmc_config revB
		;;
	2)
		p_chip_nand_config revB
		;;
	3)
		p_chip_nor_config revB
		;;
	4)
		p_chip_emmc_config revB
		;;
	5)
		p_chip_tftp_config revB
		;;
	6)
		p_chip_usb_config revB
		;;
	7)
		c_chip_emmc_config revB
		;;
	8)
		c_chip_nand_config revB
		;;
	9)
		c_chip_nor_config revB
		;;
	10)
		c_chip_emmc_config revB
		;;
	11)
		c_chip_tftp_config revB
		;;
	12)
		c_chip_usb_config revB
		;;
	13)
		i143_c_chip_emmc_config
		;;
	14)
		i143_c_chip_nor_config
		;;
	15)
		i143_c_chip_emmc_config
		;;
	18)
		i143_p_chip_emmc_config
		;;
	19)
		i143_p_chip_nor_config
		;;
	20)
		i143_p_chip_emmc_config
		;;
	21)
		i143_p_chip_tftp_config
		;;
	22)
		i143_p_chip_usb_config
		;;
	23)
		i143_c_chip_zmem_config
		;;
	26)
		i143_p_chip_zmem_config
		;;

	# 13)
	# 	others_config $1 $2
	# 	;;
	*)
		echo "Error: Unknow config!!"
		exit 1
esac
