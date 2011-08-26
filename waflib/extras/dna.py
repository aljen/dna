#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

import os, sys, struct, array, uuid, time
from waflib import Task, Utils
from waflib.Build import BuildContext
from waflib.Configure import conf
from waflib.Tools.ccroot import link_task

# vhd creation based on vhd specification from microsoft
def calculate_chs(total_sectors):
  max_cylinders = 65535
  max_heads = 16
  max_sectors_per_track1 = 255
  max_sectors_per_track2 = 63
  max_total_sectors1 = max_cylinders * max_heads * max_sectors_per_track1
  max_total_sectors2 = max_cylinders * max_heads * max_sectors_per_track2

  sectors = total_sectors
  cylinders = 0
  heads = 0
  sectors_per_track = 0
  cylinder_times_heads = 0

  if sectors > max_total_sectors1:
    sectors = max_total_sectors1

  if sectors >= max_total_sectors2:
    sectors_per_track = 255
    heads = 16
    cylinder_times_heads = sectors / sectors_per_track
  else:
    sectors_per_track = 17
    cylinder_times_heads = sectors / sectors_per_track
    
    heads = (cylinder_times_heads + 1023) / 1024
    
    if heads < 4:
      heads = 4
    
    if (cylinder_times_heads >= (heads * 1024)) or (heads > 16):
      sectors_per_track = 31
      heads = 16
      cylinder_times_heads = sectors / sectors_per_track
    
    if cylinder_times_heads >= (heads * 1024):
      sectors_per_track = 63
      heads = 16
      cylinder_times_heads = sectors / sectors_per_track

  cylinders = cylinder_times_heads / heads

  return (cylinders, heads, sectors_per_track)

@conf
def find_crosstools_root(conf):
  if not 'DNA_CROSSTOOLS' in conf.environ:
    conf.fatal('DNA_CROSSTOOLS is not set!')
  return conf.environ['DNA_CROSSTOOLS']

@conf
def vhd_create(conf):
  if os.path.isfile(conf.env.TARGET_DISK_PATH):
    return

  conf.start_msg('Creating VHD disk')

  vhd_footer_size = 512
  sector_size = 512
  vhd_be_format = '>8sIIQI4sI4sQQHBBIi16sB427s'
  vhd_be_format_size = struct.calcsize(vhd_be_format)

  requested_image_size = conf.env.TARGET_DISK_SIZE * 1024 * 1024
  requested_total_sectors = requested_image_size / sector_size

  cylinders, heads, sectors_per_track = calculate_chs(requested_total_sectors)

  image_size = cylinders * sector_size * heads * sectors_per_track
  image_total_sectors = image_size / sector_size

#  print('Requested image size: %d KB' % (requested_image_size / 1024))
#  print('Rounded image size  : %d KB' % (image_size / 1024))
#  print('Total sectors       : %d' % image_total_sectors)
#  print('Cylinders           : %d' % cylinders)
#  print('Heads               : %d' % heads)
#  print('Sectors per track   : %d' % sectors_per_track)

  seconds_now = time.mktime(time.localtime())
  seconds_start = time.mktime(time.strptime('1 Jan 00 12', '%d %b %y %H'))
  seconds_since = seconds_now - seconds_start
 
  cookie = 'conectix'
  features = 0x2
  file_format_version = 0x10000
  data_offset = 0xffffffffffffffff
  time_stamp = seconds_since
  creator_application = 'dna '
  creator_version = 0x1000
  creator_host_os = 'DNA '
  original_size = image_size - vhd_footer_size
  current_size = image_size - vhd_footer_size
  disk_geometry_cylinder = cylinders
  disk_geometry_heads = heads
  disk_geometry_cylinder_sectors_per_track = sectors_per_track
  disk_type = 2
  checksum = 0
  unique_id = uuid.uuid4().bytes
  saved_state = 0
  reserved = ''

  vhd_footer = struct.pack(vhd_be_format, cookie, features, file_format_version,
    data_offset, time_stamp, creator_application, creator_version,
    creator_host_os, original_size, current_size, disk_geometry_cylinder,
    disk_geometry_heads, disk_geometry_cylinder_sectors_per_track, disk_type,
    checksum, unique_id, saved_state, reserved)

  bytes_array = array.array('B', vhd_footer)
  for i in range(len(vhd_footer)):
    checksum = checksum + bytes_array[i]
  old_checksum = checksum
  checksum = ~checksum

  vhd_footer = struct.pack(vhd_be_format, cookie, features, file_format_version,
    data_offset, time_stamp, creator_application, creator_version,
    creator_host_os, original_size, current_size, disk_geometry_cylinder,
    disk_geometry_heads, disk_geometry_cylinder_sectors_per_track, disk_type,
    checksum, unique_id, saved_state, reserved)

#  print('checksum negated : %d' % checksum)
#  print('checksum original: %d' % old_checksum)
#  print('length           : %d' % len(vhd_footer))

  image = open(conf.env.TARGET_DISK_PATH, 'w')
  image.truncate(image_size)
  image.seek(image_size - vhd_footer_size, os.SEEK_SET)
  image.write(vhd_footer)
  image.close()

  conf.end_msg('%s MB, ext2' % conf.env.TARGET_DISK_SIZE)

@conf
def generate_bochsrc(conf):
  conf.start_msg('Creating bochsrc file')

  vhd_footer_size = 512
  sector_size = 512
  sectors_per_track = 63
  heads = 16
  image_size = os.path.getsize(conf.env.TARGET_DISK_PATH)
  cylinders = image_size / sector_size / sectors_per_track / heads

  serial_log = conf.path.get_bld().make_node('serial.log').abspath()
  bochs_log = conf.path.get_bld().make_node('bochs.log').abspath()

  bochsrc_template = conf.path.find_node('scripts/bochsrc.template')
  content = bochsrc_template.read().format(conf.env.TARGET_DISK_PATH, cylinders, heads, sectors_per_track, serial_log, bochs_log)

  bochsrc = conf.path.get_bld().make_node('dna.bxrc')
  bochsrc.write(content)
  
  conf.end_msg(bochsrc.abspath())
  return bochsrc.abspath()

def run_bochs(bld):
  cmd = '"%s" -q -f "%s"' % (bld.env.BOCHS, bld.env.BOCHSRC)
  bld.exec_command(cmd)

def vhd_mount(bld):
  if not os.path.isfile(bld.env.TARGET_DISK_PATH):
    bld.fatal('Can\'t find VHD disk %s!' % bld.env.TARGET_DISK_PATH)
  cmd = ('%s %s %s' % (bld.env.VHD_MOUNT, bld.env.TARGET_DISK_PATH, bld.env.TARGET_DISK_MOUNT))
  bld.exec_command(cmd)

def vhd_umount(bld):
  if not os.path.isfile(bld.env.TARGET_DISK_PATH):
    bld.fatal('Can\'t find VHD disk %s!' % bld.env.TARGET_DISK_PATH)
  cmd = ('%s %s' % (bld.env.VHD_UMOUNT, bld.env.TARGET_DISK_PATH))
  bld.exec_command(cmd)

def options(opt):
  opt.load('compiler_c compiler_cxx nasm  msvs')
  pass

def configure(conf):
  conf.load('compiler_c compiler_cxx nasm')

  conf.env.CROSSTOOLS_ROOT = conf.find_crosstools_root()
  bin = os.path.join(conf.env.CROSSTOOLS_ROOT, 'bin')
  scripts = os.path.join(conf.path.abspath(), 'scripts')
  
  if not 'BOCHS_ROOT' in conf.environ:
    conf.fatal('Set BOCHS_ROOT to your Bochs installation directory!')
  conf.env.BOCHS_ROOT = conf.environ['BOCHS_ROOT']

  bochs = conf.find_program('bochs', var = 'BOCHS', path_list = [conf.env.BOCHS_ROOT])

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
  
  conf.start_msg('Setting target VHD image path to')
  conf.env.TARGET_DISK_PATH = conf.path.make_node(conf.env.TARGET_DISK_IMAGE).abspath()
  conf.end_msg(conf.env.TARGET_DISK_PATH)

  conf.vhd_create()
  
  conf.env.BOCHSRC = conf.generate_bochsrc()

  conf.start_msg('Setting prefix to')
  conf.env.PREFIX = '%s:\\' % conf.env.TARGET_DISK_MOUNT
  conf.options.prefix = conf.env.PREFIX
  conf.end_msg(conf.env.PREFIX)

class bootloader(link_task):
  run_str = 'cp ${SRC} ${TGT}'
  ext_out = ['.bin']
  inst_to = '${BINDIR}'
  chmod   = Utils.O755

class run(BuildContext):
  cmd = 'run'
