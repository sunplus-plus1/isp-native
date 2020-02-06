#!/bin/bash

XBIN=armv5-eabi--glibc--stable/bin
FROM=arm-linux-
TO=armv5-glibc-linux-
if [ -d $XBIN ];then
	cd $XBIN
	flist=`ls $FROM*`
	for file in $flist ;do
		if [ ! -L $ile ];then		
			echo "$file is not a link!!"
			exit 1
		fi
		#echo "-> $TO${file#arm-linux-}"
		mv -v $file $TO${file#arm-linux-}
	done
	
fi
