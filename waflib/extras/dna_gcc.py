#! /usr/bin/env python
# encoding: utf-8
# Based on Tools/gcc.py
# Artur Wyszyñski, 2011

import os, sys
from waflib import Configure, Options, Utils
from waflib.extras import dna, dna_ar
from waflib.Tools import ccroot
from waflib.Configure import conf

def find_dna_gcc(conf):
  root = conf.find_crosstools_root()
  root = os.path.join(root, 'bin')
  cc = conf.find_program('x86_64-pc-dna-gcc', var='CC', path_list = root)
  cc = conf.cmd_to_list(cc)
  conf.get_cc_version(cc, gcc = True)
  conf.env.CC_NAME = 'gcc'
  conf.env.CC = cc

def dna_gcc_common_flags(conf):
  v = conf.env
  v['CC_SRC_F'] = []
  v['CC_TGT_F'] = ['-c','-o']
  if not v['LINK_CC']: v['LINK_CC'] = v['CC']
  v['CCLNK_SRC_F'] = []
  v['CCLNK_TGT_F'] = ['-o']
  v['CPPPATH_ST'] = '-I%s'
  v['DEFINES_ST'] = '-D%s'
  v['LIB_ST'] = '-l%s'
  v['LIBPATH_ST'] = '-L%s'
  v['STLIB_ST'] = '-l%s'
  v['STLIBPATH_ST'] = '-L%s'
  v['RPATH_ST'] = '-Wl,-rpath,%s'
  v['SONAME_ST'] = '-Wl,-h,%s'
  v['SHLIB_MARKER'] = '-Wl,-Bdynamic'
  v['STLIB_MARKER'] = '-Wl,-Bstatic'
  v['cprogram_PATTERN'] = '%s'
  v['CFLAGS_cshlib'] = ['-fPIC']
  v['LINKFLAGS_cshlib'] = ['-shared']
  v['cshlib_PATTERN'] = 'lib%s.so'
  v['LINKFLAGS_cstlib'] = ['-Wl,-Bstatic']
  v['cstlib_PATTERN'] = 'lib%s.a'

def configure(conf):
  conf.find_dna_gcc()
  conf.find_dna_ar()
  conf.dna_gcc_common_flags()
  conf.cc_load_tools()
  conf.cc_add_flags()
  conf.link_add_flags()

conf(find_dna_gcc)
conf(dna_gcc_common_flags)
