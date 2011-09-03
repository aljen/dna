#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

import os, sys

def main():
    argc = len(sys.argv)
    if (argc < 2):
        print 'Usage: %s <mnt point>' % sys.argv[0]
        sys.exit(1)

    mnt_point = sys.argv[1]

    df = os.popen('df').read()
    if not mnt_point in df:
        print ' (not mounted)'
        sys.exit(0)
    else:
        cmd = 'fusermount -u %s' % mnt_point
        os.system(cmd)
        cmd = 'sleep 1'
        os.system(cmd)
        cmd = 'losetup -d /dev/loop0'
        os.system(cmd)
        print ''

if __name__ == "__main__":
    main()

