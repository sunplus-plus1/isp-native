#!/bin/bash

# $1: the path of the input/output file
# $2: input/output file name
# $3: 1= add sign flag before the sign data（uboot/kernel）  0:for xboot

CUR_PATH=
IN_IMG=
OUT_SIG=
TOOLPATH=build/tools/secure_sign
SIGN_BIN=$TOOLPATH/sign_ed25519
TEMPFILE=tempfile
SIGN_FLAG=0

# Put your real key pair in keys/ :
PRIV_K=$TOOLPATH/sign_keys/key_priv_0.hex
PUB_K=$TOOLPATH/sign_keys/key_pub_0.hex

if [ -f "$PRIV_K" -a -f "$PUB_K" ];then
	echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	echo "^^^ Sign with REAL keys ^^^"
	echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
else
	# A test key pair is in test-keys/ :
	PRIV_K=$TOOLPATH/sign_keys/test-keys/key_priv_0.hex
	PUB_K=$TOOLPATH/sign_keys/test-keys/key_pub_0.hex
	echo "**************************************"
	echo "*** Warning: Sign with TEST key !! ***"
	echo "*** Please put real keys in keys/. ***"
	echo "**************************************"
fi

echo "Private key: $PRIV_K"
echo "Public key : $PUB_K"

if [ ! -x $SIGN_BIN ];then
	echo "Can't execute $SIGN_BIN"
	exit 1
fi

if [ "$1" != "" ];then
	CUR_PATH=$1
fi
if [ "$2" != "" ];then
	IN_IMG=$CUR_PATH/$2
fi
if [ "$3" != "" ];then
	SIGN_FLAG=$3
fi
echo " input $IN_IMG"
if [ ! -f $IN_IMG ];then
	echo "input file is not exist"
	exit 1
fi

OUT_SIG=$CUR_PATH/sign.sig
echo "OUT_SIG: $OUT_SIG"
rm -f $OUT_SIG

#sign
echo "Sign: $IN_IMG"
$SIGN_BIN -p "$PRIV_K" -b "$PUB_K" -s $IN_IMG -o $OUT_SIG
if [ $? -ne 0 ];then
	echo "sign program failed"
	exit 1
fi

echo "Output signature: $OUT_SIG"
echo 7369676e00000000 | xxd -r -ps >> $TEMPFILE   #sign_data flag 
if [ "$SIGN_FLAG" = "1" ];then
	echo "add sign flag (uboot kernel)"
	cat $OUT_SIG>>$TEMPFILE
	cat $TEMPFILE>>$IN_IMG
	echo "add end"
else
	echo "no need to add sign flag (xboot)"
	echo "OUT_SIG: $OUT_SIG"
	echo "IN_IMG: $IN_IMG"
	cat $OUT_SIG>>$IN_IMG
fi
rm -f $OUT_SIG
rm -f $TEMPFILE
