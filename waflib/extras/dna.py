#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyñski, 2011

import os, sys
from waflib.Configure import conf

@conf
def find_crosstools_root(conf):
  if not 'DNA_CROSSTOOLS' in conf.environ:
    conf.fatal('DNA_CROSSTOOLS is not set!')
  return conf.environ['DNA_CROSSTOOLS']

@conf
def vhd_create(conf):
  image = conf.path.make_node(conf.env.TARGET_DISK_IMAGE).abspath()
  print('If a window pops up when creating VHD and is asking you to format a partition, cancel it!')
  conf.start_msg('Creating VHD disk')
  conf.end_msg('%s (%s MB)' % (image, conf.env.TARGET_DISK_SIZE))
  cmd = ('%s %s %s %s' % (conf.env.VHD_CREATE, image, conf.env.TARGET_DISK_SIZE, conf.env.TARGET_DISK_MOUNT))
  conf.exec_command(cmd)

def vhd_mount(bld):
  image = bld.path.make_node(bld.env.TARGET_DISK_IMAGE).abspath()
  if not os.path.isfile(image):
    bld.fatal('Can\'t find VHD disk %s!' % image)
  cmd = ('%s %s %s' % (bld.env.VHD_MOUNT, image, bld.env.TARGET_DISK_MOUNT))
  bld.exec_command(cmd)

def vhd_umount(bld):
  image = bld.path.make_node(bld.env.TARGET_DISK_IMAGE).abspath()
  if not os.path.isfile(image):
    bld.fatal('Can\'t find VHD disk %s!' % image)
  cmd = ('%s %s' % (bld.env.VHD_UMOUNT, image))
  bld.exec_command(cmd)

def options(opt):
  pass

def configure(conf):
  conf.env.CROSSTOOLS_ROOT = conf.find_crosstools_root()
  bin = os.path.join(conf.env.CROSSTOOLS_ROOT, 'bin')
  scripts = os.path.join(conf.path.abspath(), 'scripts')

  cc = conf.find_program('x86_64-pc-dna-gcc', var = 'TARGET_CC', path_list = bin)
  cc = conf.cmd_to_list(cc)
  conf.get_cc_version(cc, gcc = True)
  conf.env.TARGET_CC = cc

  cxx = conf.find_program('x86_64-pc-dna-g++', var = 'TARGET_CXX', path_list = bin)
  cxx = conf.cmd_to_list(cxx)
  conf.get_cc_version(cxx, gcc = True)
  conf.env.TARGET_CXX = cxx

  ar = conf.find_program('x86_64-pc-dna-ar', var = 'TARGET_AR', path_list = bin)
  ar = conf.cmd_to_list(ar)
  conf.env.TARGET_AR = ar
  conf.env.TARGET_ARFLAGS = 'rcs'

  ld = conf.find_program('x86_64-pc-dna-ld', var = 'TARGET_LD', path_list = bin)
  ld = conf.cmd_to_list(ld)
  conf.env.TARGET_LD = ld
  
  create = conf.find_program('vhd-create', var = 'VHD_CREATE', path_list = scripts)
  conf.env.VHD_CREATE = create

  mount = conf.find_program('vhd-mount', var = 'VHD_MOUNT', path_list = scripts)
  conf.env.VHD_MOUNT = mount

  umount = conf.find_program('vhd-umount', var = 'VHD_UMOUNT', path_list = scripts)
  conf.env.VHD_UMOUNT = umount

  conf.env.TARGET_DISK_IMAGE = 'disk.vhd'
  conf.env.TARGET_DISK_SIZE = 256
  conf.env.TARGET_DISK_MOUNT = 'Z'

  conf.vhd_create()
