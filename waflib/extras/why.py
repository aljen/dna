#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/svn/docs/wafbook/single.html#_obtaining_the_waf_file

from waflib import Task,Utils,Logs,Errors
def signature(self):
	try:return self.cache_sig
	except AttributeError:pass
	self.m=Utils.md5()
	self.m.update(self.hcode)
	id_sig=self.m.digest()
	self.sig_explicit_deps()
	exp_sig=self.m.digest()
	self.sig_vars()
	var_sig=self.m.digest()
	if self.scan:
		try:
			imp_sig=self.sig_implicit_deps()
		except Errors.TaskRescan:
			return self.signature()
	ret=self.cache_sig=self.m.digest()+id_sig+exp_sig+var_sig
	return ret
Task.Task.signature=signature
old=Task.Task.runnable_status
def runnable_status(self):
	ret=old(self)
	if ret==Task.RUN_ME:
		try:
			old_sigs=self.generator.bld.task_sigs[self.uid()]
		except:
			Logs.debug("task: task must run as no previous signature exists")
		else:
			new_sigs=self.cache_sig
			def v(x):
				return Utils.to_hex(x)
			Logs.debug("Task %r"%self)
			msgs=['Task must run','* Task code','* Source file or manual dependency','* Configuration data variable']
			tmp='task: -> %s: %s %s'
			for x in range(len(msgs)):
				l=len(Utils.SIG_NIL)
				a=new_sigs[x*l:(x+1)*l]
				b=old_sigs[x*l:(x+1)*l]
				if(a!=b):
					Logs.debug(tmp%(msgs[x].ljust(35),v(a),v(b)))
					if x>0:
						break
	return ret
Task.Task.runnable_status=runnable_status
