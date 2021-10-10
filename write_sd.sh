#!/bin/bash

WORKING_DIR=`dirname $0`

if [ -z "${1}" ]; then
    echo "usage: $0 /dev/sd?"
    echo "example: $0 /dev/sdb"
    exit 1
fi


# unmount partitions if mounted
sudo umount ${1}1
sudo umount ${1}2
sudo umount ${1}3
sudo umount ${1}4

sudo dd if=$WORKING_DIR/IMAGE/output.img of=${1} bs=4M status=progress
