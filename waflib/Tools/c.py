#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/svn/docs/wafbook/single.html#_obtaining_the_waf_file

from waflib import TaskGen,Task,Utils
from waflib.Tools import c_preproc
from waflib.Tools.ccroot import link_task,stlink_task
def c_hook(self,node):
	return self.create_compiled_task('c',node)
class c(Task.Task):
	run_str='${CC} ${ARCH_ST:ARCH} ${CFLAGS} ${CPPFLAGS} ${FRAMEWORKPATH_ST:FRAMEWORKPATH} ${CPPPATH_ST:INCPATHS} ${DEFINES_ST:DEFINES} ${CC_SRC_F}${SRC} ${CC_TGT_F}${TGT}'
	vars=['CCDEPS']
	ext_in=['.h']
	scan=c_preproc.scan
Task.classes['cc']=cc=c
class cprogram(link_task):
	run_str='${LINK_CC} ${CCLNK_SRC_F}${SRC} ${CCLNK_TGT_F}${TGT[0].abspath()} ${RPATH_ST:RPATH} ${FRAMEWORKPATH_ST:FRAMEWORKPATH} ${FRAMEWORK_ST:FRAMEWORK} ${ARCH_ST:ARCH} ${STLIB_MARKER} ${STLIBPATH_ST:STLIBPATH} ${STLIB_ST:STLIB} ${SHLIB_MARKER} ${LIBPATH_ST:LIBPATH} ${LIB_ST:LIB} ${LINKFLAGS}'
	ext_out=['.bin']
	vars=['LINKDEPS']
	inst_to='${BINDIR}'
	chmod=Utils.O755
class cshlib(cprogram):
	inst_to='${LIBDIR}'
class cstlib(stlink_task):
	pass

TaskGen.extension('.c')(c_hook)