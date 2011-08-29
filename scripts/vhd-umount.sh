#!/bin/bash
# $1 - mnt point
fusermount -u $1
sleep 1
losetup -d /dev/loop0

