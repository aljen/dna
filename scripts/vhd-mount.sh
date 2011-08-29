#!/bin/bash
# $1 - disk name
# $2 - mnt point
losetup /dev/loop0 -o 512 $1
sleep 1
fuseext2 -o rw+ /dev/loop0 $2
