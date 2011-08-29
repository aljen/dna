#!/bin/bash
# $1 - disk name
# $2 - cylinders
# $3 - heads
# $4 - sectors
# $5 - mnt point
sfdisk -C$2 -H$3 -S$4 -uS $1 > /dev/null << EOF
1,,,*
;
;
;
EOF
mkdir -p $5
losetup /dev/loop0 -o 512 $1
sleep 1
mkfs.ext2 /dev/loop0 > /dev/null
sleep 1
losetup -d /dev/loop0

