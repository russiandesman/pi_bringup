#!/bin/bash

WORKING_DIR=`dirname $0`

rm -rf $WORKING_DIR/IMAGE
mkdir -p $WORKING_DIR/IMAGE
pushd $WORKING_DIR/IMAGE

wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip
unzip 2021-03-04-raspios-buster-armhf-lite.zip

image_filename=output.img

cp "2021-03-04-raspios-buster-armhf-lite.img" $image_filename

# add free space to ext partition
truncate --size=+500M $image_filename
growpart $image_filename 2

#----mount image as real disk with partitions------------------

kpartx_output=$(sudo kpartx -av $image_filename)

{
    read _ _ fat_partition _
    read _ _ ext_partition _
} <<< $kpartx_output

# finalize fs extending
sudo resize2fs -f /dev/mapper/$ext_partition

mkdir -p disk_content/fat
mkdir -p disk_content/ext

sudo mount /dev/mapper/$fat_partition ./disk_content/fat
sudo mount /dev/mapper/$ext_partition ./disk_content/ext

#--------------------------------------------------------------

# enable UART
sudo cp -f ../canned_files/config.txt ./disk_content/fat

# chroot into EXT and run setup script "there"
# set up special dirs first -- just take them from host
sudo mount --bind /dev     ./disk_content/ext/dev
sudo mount --bind /dev/pts ./disk_content/ext/dev/pts
sudo mount --bind /sys     ./disk_content/ext/sys
sudo mount --bind /proc    ./disk_content/ext/proc
# little bit of street magic -- temporarily replace resolv.conf and ld.so.preload on target
# take resolv conf from host, make sure ld.so.preload is empty (i.e. use canned empty version of it)
sudo mount -o bind,ro /etc/resolv.conf ./disk_content/ext/etc/resolv.conf
if [ -f ./disk_content/ext/etc/ld.so.preload ]; then
    sudo mount -o bind,ro ../canned_files/ld.so.preload ./disk_content/ext/etc/ld.so.preload
fi
# temporarily mount folder with files from host to be installed 
mkdir -p ./disk_content/ext/tmp/files_to_install
sudo mount -o bind,ro ../files_to_install ./disk_content/ext/tmp/files_to_install


sudo cp /usr/bin/qemu-arm-static ./disk_content/ext/usr/bin/qemu-arm-static
sudo cp ../target_setup.sh ./disk_content/ext/target_setup.sh

sudo chroot ./disk_content/ext/ /usr/bin/env -i /target_setup.sh

sudo rm ./disk_content/ext/usr/bin/qemu-arm-static
sudo rm ./disk_content/ext/target_setup.sh

sudo umount ./disk_content/ext/tmp/files_to_install
# nothing criminal if wasn't mounted
sudo umount ./disk_content/ext/etc/ld.so.preload
sudo umount ./disk_content/ext/etc/resolv.conf
sudo umount ./disk_content/ext/proc
sudo umount ./disk_content/ext/sys
sudo umount ./disk_content/ext/dev/pts
sudo umount ./disk_content/ext/dev

#--------------------------------------------------------------
sudo umount ./disk_content/fat
sudo umount ./disk_content/ext

sudo kpartx -d $image_filename

popd
