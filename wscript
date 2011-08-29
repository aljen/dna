#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

import os
from waflib.extras import dna
from waflib import Scripting, Utils, Options, Context

VERSION = '0.0.1'
APPNAME = 'dna-os'
REVISION = ''

top = '.'
out = 'build'


def options(opt):
  opt.load('dna')


def configure(conf):
  conf.load('dna')


def build(bld):
  print('cmd: %s' % bld.cmd)
  if bld.cmd == 'run':
    dna.run_bochs(bld)
  elif bld.cmd == 'debug':
    dna.debug_bochs(bld)
  elif bld.cmd == 'mount':
    dna.vhd_mount(bld)
  elif bld.cmd == 'umount':
    dna.vhd_umount(bld)
  else:
    bld.add_pre_fun(dna.vhd_mount)
    bld.add_post_fun(dna.vhd_umount)
    bld.recurse('src')


def clean(bld):
  print('clean ????')


def distclean(bld):
  mounted = False
  if os.path.isdir(bld.path.make_node(out).abspath()):
    mnt = bld.path.make_node('mnt').abspath()
    if Options.platform == 'linux':
      vhd_umount = 'vhd-umount.sh'
      df = bld.cmd_and_log('df', output = Context.STDOUT, quiet = Context.BOTH)
      if mnt in df:
        mounted = True
        df = df.split('\n')
        for line in df:
          if mnt in line:
            mount_point = line.strip().split(' ')[-1]
    else:
      vhd_umount = 'vhd-umount.bat'
      bld.fatal('Implement ;)')

  if mounted == True:
    umount = bld.path.make_node('scripts' + os.sep + vhd_umount).abspath()
    cmd = '%s %s' % (umount, mount_point)
    bld.exec_command(cmd)
  Scripting.distclean(bld)

