#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

import os, sys

def main():
    argc = len(sys.argv)
    if (argc < 3):
        print 'Usage: %s <disk.vhd> <mnt point>' % sys.argv[0]
        sys.exit(1)

    image_name = sys.argv[1]
    mnt_point = sys.argv[2]

    df = os.popen('df').read()
    if mnt_point in df:
        print ' (already mounted)'
        sys.exit(0)
    else:
        cmd = 'losetup /dev/loop0 -o 512 %s' % image_name
        os.system(cmd)
        cmd = 'sleep 1'
        os.system(cmd)
        cmd = 'fuseext2 -o rw+ /dev/loop0 %s' % mnt_point
        os.system(cmd)
        print ''

if __name__ == "__main__":
    main()

