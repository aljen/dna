#! /usr/bin/env python
# encoding: utf-8
# Based on Tools/ar.py

import os
from waflib.Configure import conf
from waflib.extras import dna

def find_dna_ar(conf):
  conf.load('dna_ar')

def configure(conf):
  root = conf.find_crosstools_root()
  root = os.path.join(root, 'bin')
  conf.find_program('x86_64-pc-dna-ar', var='AR', path_list = root)
  conf.env.ARFLAGS='rcs'

conf(find_dna_ar)
