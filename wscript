#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyñski, 2011

VERSION = '0.0.1'
APPNAME = 'dna-os'
REVISION = ''

top = '.'
out = 'build'

from waflib.extras import dna

def options(opt):
  opt.load('compiler_c compiler_cxx dna')

def configure(conf):
  conf.load('compiler_c compiler_cxx dna')

def build(bld):
  bld.add_pre_fun(dna.vhd_mount)
  bld.add_post_fun(dna.vhd_umount)
