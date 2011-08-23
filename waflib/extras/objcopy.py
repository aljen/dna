#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/svn/docs/wafbook/single.html#_obtaining_the_waf_file

from waflib.Utils import def_attrs
from waflib import Task
from waflib.TaskGen import feature,after_method
class objcopy(Task.Task):
	run_str='${OBJCOPY} -O ${TARGET_BFDNAME} ${OBJCOPYFLAGS} ${SRC} ${TGT}'
	color='CYAN'
def objcopy(self):
	def_attrs(self,objcopy_bfdname='ihex',objcopy_target=None,objcopy_install_path="${PREFIX}/firmware",objcopy_flags='')
	link_output=self.link_task.outputs[0]
	if not self.objcopy_target:
		self.objcopy_target=link_output.change_ext('.'+self.objcopy_bfdname).name
	task=self.create_task('objcopy',src=link_output,tgt=self.path.find_or_declare(self.objcopy_target))
	task.env.append_unique('TARGET_BFDNAME',self.objcopy_bfdname)
	try:
		task.env.append_unique('OBJCOPYFLAGS',getattr(self,'objcopy_flags'))
	except AttributeError:
		pass
	if self.objcopy_install_path:
		self.bld.install_files(self.objcopy_install_path,task.outputs[0],env=task.env.derive())
def configure(ctx):
	objcopy=ctx.find_program('objcopy',var='OBJCOPY',mandatory=True)

feature('objcopy')(objcopy)
after_method('apply_link')(objcopy)