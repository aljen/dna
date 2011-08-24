#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyñski, 2011

import os, sys
from waflib.Configure import conf

def find_crosstools_root(conf):
  if not 'DNA_CROSSTOOLS' in conf.environ:
    conf.fatal('DNA_CROSSTOOLS is not set!')
  return conf.environ['DNA_CROSSTOOLS']

conf(find_crosstools_root)
