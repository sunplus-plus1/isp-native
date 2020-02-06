# How to use TFTP ISP to do partial update
# Execute "isp extract4tftpupdate" command to extract partial content from ISPBOOOT.BIN to produce
# TFTP BIN files. Please modify the partition name in the "isp extract4tftpupdate" instruction. You
# can update up to two partitions at the same time. For default, we will update uboot and kernel
# partitions. After TFTP BIN files are produced, let your board go into uboot and then execute the
# following uboot command.
# => run update_tftp 
# It will update these partitions on the main storage of your board.

# Set PATH environment variable
export PATH=$PATH:../build/tools/isp/

echo "Produce TFTP BIN files..."
cd ../out
isp extract4tftpupdate ISPBOOOT.BIN isp_tftp uboot2 kernel

echo
echo "Check TFTP BIN files..."
cd isp_tftp
pwd
ls -lF ./
isp_tftp_path=$(pwd)

echo
echo "Copy TFTP BIN files to TFTP server's folder..."
cd /home/scftp
pwd
rm TFTP*.BIN
cp ${isp_tftp_path}/*.BIN /home/scftp

echo
echo "Check TFTP server's foler..."
ls -lF

exit 0
