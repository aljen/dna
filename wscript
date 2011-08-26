#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

from waflib.extras import dna

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
  if bld.cmd == 'run':
    dna.run_bochs(bld)
  elif bld.cmd == 'mount':
    dna.vhd_mount(bld)
  elif bld.cmd == 'umount':
    dna.vhd_umount(bld)
  else:
    bld.add_pre_fun(dna.vhd_mount)
    bld.add_post_fun(dna.vhd_umount)
    bld.recurse('src')
