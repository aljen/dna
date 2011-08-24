#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyñski, 2011

VERSION = '0.0.1'
APPNAME = 'dna-os'
REVISION = ''

top = '.'
out = 'build'

def options(opt):
  from waflib.Tools.compiler_c import c_compiler
  from waflib.Tools.compiler_cxx import cxx_compiler
  c_compiler['win32'] = ['dna_gcc']
  cxx_compiler['win32'] = ['dna_gxx']
  opt.load('compiler_c compiler_cxx')

def configure(conf):
  conf.load('compiler_c compiler_cxx')

def build(bld):
  pass
