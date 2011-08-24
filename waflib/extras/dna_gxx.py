#! /usr/bin/env python
# encoding: utf-8
# Based on Tools/gxx.py
# Artur Wyszyñski, 2011

import os, sys
from waflib import Configure, Options, Utils
from waflib.extras import dna, dna_ar
from waflib.Tools import ccroot
from waflib.Configure import conf

def find_dna_gxx(conf):
  root = conf.find_crosstools_root()
  root = os.path.join(root, 'bin')
  cxx = conf.find_program('x86_64-pc-dna-g++', var='CXX', path_list = root)
  cxx = conf.cmd_to_list(cxx)
  conf.get_cc_version(cxx, gcc = True)
  conf.env.CXX_NAME = 'gcc'
  conf.env.CXX = cxx

def dna_gxx_common_flags(conf):
  v = conf.env
  v['CXX_SRC_F'] = []
  v['CXX_TGT_F'] = ['-c','-o']
  if not v['LINK_CXX']: v['LINK_CXX'] = v['CXX']
  v['CXXLNK_SRC_F'] = []
  v['CXXLNK_TGT_F'] = ['-o']
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
  v['cxxprogram_PATTERN'] = '%s'
  v['CXXFLAGS_cxxshlib'] = ['-fPIC']
  v['LINKFLAGS_cxxshlib'] = ['-shared']
  v['cxxshlib_PATTERN'] = 'lib%s.so'
  v['LINKFLAGS_cxxstlib'] = ['-Wl,-Bstatic']
  v['cxxstlib_PATTERN'] = 'lib%s.a'

def configure(conf):
  conf.find_dna_gxx()
  conf.find_dna_ar()
  conf.dna_gxx_common_flags()
  conf.cxx_load_tools()
  conf.cxx_add_flags()
  conf.link_add_flags()

conf(find_dna_gxx)
conf(dna_gxx_common_flags)
