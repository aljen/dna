#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/svn/docs/wafbook/single.html#_obtaining_the_waf_file

import os,sys
from waflib import TaskGen,Utils,Utils,Runner,Options,Build,Errors
from waflib.Logs import debug,warn,info,error
from waflib.TaskGen import extension,taskgen_method,before_method,after_method,feature
from waflib.Configure import conf
FRAG='''
#include <Python.h>
#ifdef __cplusplus
extern "C" {
#endif
	void Py_Initialize(void);
	void Py_Finalize(void);
#ifdef __cplusplus
}
#endif
int main()
{
   Py_Initialize();
   Py_Finalize();
   return 0;
}
'''
INST='''
import sys, py_compile
py_compile.compile(sys.argv[1], sys.argv[2], sys.argv[3])
'''
def process_py(self,node):
	try:
		if not self.bld.is_install:
			return
	except:
		return
	if not getattr(self,'install_path',None):
		self.install_path='${PYTHONDIR}'
	def inst_py(ctx):
		install_from=getattr(self,'install_from',None)
		if install_from:
			install_from=self.path.find_dir(install_from)
		install_pyfile(self,node,install_from)
	self.bld.add_post_fun(inst_py)
def install_pyfile(self,node,install_from=None):
	from_node=install_from or node.parent
	tsk=self.bld.install_as(self.install_path+'/'+node.path_from(from_node),node,postpone=False)
	path=tsk.get_install_path()
	if self.bld.is_install<0:
		info("+ removing byte compiled python files")
		for x in'co':
			try:
				os.remove(path+x)
			except OSError:
				pass
	if self.bld.is_install>0:
		try:
			st1=os.stat(path)
		except:
			error('The python file is missing, this should not happen')
		for x in['c','o']:
			do_inst=self.env['PY'+x.upper()]
			try:
				st2=os.stat(path+x)
			except OSError:
				pass
			else:
				if st1.st_mtime<=st2.st_mtime:
					do_inst=False
			if do_inst:
				lst=(x=='o')and[self.env['PYFLAGS_OPT']]or[]
				(a,b,c)=(path,path+x,tsk.get_install_path(destdir=False)+x)
				argv=self.env['PYTHON']+lst+['-c',INST,a,b,c]
				info('+ byte compiling %r'%(path+x))
				ret=Utils.subprocess.Popen(argv).wait()
				if ret:
					raise Errors.WafError('py%s compilation failed %r'%(x,path))
def feature_py(self):
	pass
def init_pyext(self):
	if not getattr(self,'install_path',None):
		self.install_path='${PYTHONARCHDIR}'
	self.uselib=self.to_list(getattr(self,'uselib',[]))
	if not'PYEXT'in self.uselib:
		self.uselib.append('PYEXT')
	self.env['cshlib_PATTERN']=self.env['cxxshlib_PATTERN']=self.env['pyext_PATTERN']
def init_pyembed(self):
	self.uselib=self.to_list(getattr(self,'uselib',[]))
	if not'PYEMBED'in self.uselib:
		self.uselib.append('PYEMBED')
def get_python_variables(conf,variables,imports=['import sys']):
	program=list(imports)
	program.append('')
	for v in variables:
		program.append("print(repr(%s))"%v)
	os_env=dict(os.environ)
	try:
		del os_env['MACOSX_DEPLOYMENT_TARGET']
	except KeyError:
		pass
	try:
		out=conf.cmd_and_log(conf.env.PYTHON+['-c','\n'.join(program)],env=os_env)
	except Errors.WafError:
		conf.fatal('The distutils module is unusable: install "python-devel"?')
	return_values=[]
	for s in out.split('\n'):
		s=s.strip()
		if not s:
			continue
		if s=='None':
			return_values.append(None)
		elif s[0]=="'"and s[-1]=="'":
			return_values.append(s[1:-1])
		elif s[0].isdigit():
			return_values.append(int(s))
		else:break
	return return_values
def check_python_headers(conf):
	if not conf.env['CC_NAME']and not conf.env['CXX_NAME']:
		conf.fatal('load a compiler first (gcc, g++, ..)')
	if not conf.env['PYTHON_VERSION']:
		conf.check_python_version()
	env=conf.env
	pybin=conf.env.PYTHON
	if not pybin:
		conf.fatal('could not find the python executable')
	v='prefix SO LDFLAGS LIBDIR LIBPL INCLUDEPY Py_ENABLE_SHARED MACOSX_DEPLOYMENT_TARGET LDSHARED CFLAGS'.split()
	try:
		lst=conf.get_python_variables(["get_config_var('%s') or ''"%x for x in v],['from distutils.sysconfig import get_config_var'])
	except RuntimeError:
		conf.fatal("Python development headers not found (-v for details).")
	vals=['%s = %r'%(x,y)for(x,y)in zip(v,lst)]
	conf.to_log("Configuration returned from %r:\n%r\n"%(pybin,'\n'.join(vals)))
	dct=dict(zip(v,lst))
	x='MACOSX_DEPLOYMENT_TARGET'
	if dct[x]:
		conf.env[x]=conf.environ[x]=dct[x]
	env['pyext_PATTERN']='%s'+dct['SO']
	all_flags=dct['LDFLAGS']+' '+dct['LDSHARED']+' '+dct['CFLAGS']
	conf.parse_flags(all_flags,'PYEMBED')
	conf.parse_flags(all_flags,'PYEXT')
	result=None
	for name in('python'+env['PYTHON_VERSION'],'python'+env['PYTHON_VERSION'].replace('.','')):
		if not result and env['LIBPATH_PYEMBED']:
			path=env['LIBPATH_PYEMBED']
			conf.to_log("\n\n# Trying default LIBPATH_PYEMBED: %r\n"%path)
			result=conf.check(lib=name,uselib='PYEMBED',libpath=path,mandatory=False,msg='Checking for library %s in LIBPATH_PYEMBED'%name)
		if not result and dct['LIBDIR']:
			path=[dct['LIBDIR']]
			conf.to_log("\n\n# try again with -L$python_LIBDIR: %r\n"%path)
			result=conf.check(lib=name,uselib='PYEMBED',libpath=path,mandatory=False,msg='Checking for library %s in LIBDIR'%name)
		if not result and dct['LIBPL']:
			path=[dct['LIBPL']]
			conf.to_log("\n\n# try again with -L$python_LIBPL (some systems don't install the python library in $prefix/lib)\n")
			result=conf.check(lib=name,uselib='PYEMBED',libpath=path,mandatory=False,msg='Checking for library %s in python_LIBPL'%name)
		if not result:
			path=[os.path.join(dct['prefix'],"libs")]
			conf.to_log("\n\n# try again with -L$prefix/libs, and pythonXY name rather than pythonX.Y (win32)\n")
			result=conf.check(lib=name,uselib='PYEMBED',libpath=path,mandatory=False,msg='Checking for library %s in $prefix/libs'%name)
		if result:
			break
	if result:
		env['LIBPATH_PYEMBED']=path
		env.append_value('LIB_PYEMBED',[name])
	else:
		conf.to_log("\n\n### LIB NOT FOUND\n")
	if(Utils.is_win32 or sys.platform.startswith('os2')or sys.platform=='darwin'or dct['Py_ENABLE_SHARED']):
		env['LIBPATH_PYEXT']=env['LIBPATH_PYEMBED']
		env['LIB_PYEXT']=env['LIB_PYEMBED']
	num='.'.join(env['PYTHON_VERSION'].split('.')[:2])
	conf.find_program(['python%s-config'%num,'python-config-%s'%num,'python%sm-config'%num],var='PYTHON_CONFIG',mandatory=False)
	includes=[]
	if conf.env.PYTHON_CONFIG:
		for incstr in conf.cmd_and_log([conf.env.PYTHON_CONFIG,'--includes']).strip().split():
			if(incstr.startswith('-I')or incstr.startswith('/I')):
				incstr=incstr[2:]
			if incstr not in includes:
				includes.append(incstr)
		conf.to_log("Include path for Python extensions ""(found via python-config --includes): %r\n"%(includes,))
		env['INCLUDES_PYEXT']=includes
		env['INCLUDES_PYEMBED']=includes
	else:
		conf.to_log("Include path for Python extensions ""(found via distutils module): %r\n"%(dct['INCLUDEPY'],))
		env['INCLUDES_PYEXT']=[dct['INCLUDEPY']]
		env['INCLUDES_PYEMBED']=[dct['INCLUDEPY']]
	if env['CC_NAME']=='gcc':
		env.append_value('CFLAGS_PYEMBED',['-fno-strict-aliasing'])
		env.append_value('CFLAGS_PYEXT',['-fno-strict-aliasing'])
	if env['CXX_NAME']=='gcc':
		env.append_value('CXXFLAGS_PYEMBED',['-fno-strict-aliasing'])
		env.append_value('CXXFLAGS_PYEXT',['-fno-strict-aliasing'])
	try:
		conf.check(header_name='Python.h',define_name='HAVE_PYTHON_H',uselib='PYEMBED',fragment=FRAG,errmsg='Could not find the python development headers')
	except conf.errors.ConfigurationError:
		conf.check_cfg(path=conf.env.PYTHON_CONFIG,package='',uselib_store='PYEMBED',args=['--cflags','--libs'])
		conf.check(header_name='Python.h',define_name='HAVE_PYTHON_H',msg='Getting the python flags from python-config',uselib='PYEMBED',fragment=FRAG,errmsg='Could not find the python development headers elsewhere')
def check_python_version(conf,minver=None):
	assert minver is None or isinstance(minver,tuple)
	pybin=conf.env['PYTHON']
	if not pybin:
		conf.fatal('could not find the python executable')
	cmd=pybin+['-c','import sys\nfor x in sys.version_info: print(str(x))']
	debug('python: Running python command %r'%cmd)
	lines=conf.cmd_and_log(cmd).split()
	assert len(lines)==5,"found %i lines, expected 5: %r"%(len(lines),lines)
	pyver_tuple=(int(lines[0]),int(lines[1]),int(lines[2]),lines[3],int(lines[4]))
	result=(minver is None)or(pyver_tuple>=minver)
	if result:
		pyver='.'.join([str(x)for x in pyver_tuple[:2]])
		conf.env['PYTHON_VERSION']=pyver
		if'PYTHONDIR'in conf.environ:
			pydir=conf.environ['PYTHONDIR']
		else:
			if Utils.is_win32:
				(python_LIBDEST,pydir)=conf.get_python_variables(["get_config_var('LIBDEST') or ''","get_python_lib(standard_lib=0, prefix=%r) or ''"%conf.env['PREFIX']],['from distutils.sysconfig import get_config_var, get_python_lib'])
			else:
				python_LIBDEST=None
				(pydir,)=conf.get_python_variables(["get_python_lib(standard_lib=0, prefix=%r) or ''"%conf.env['PREFIX']],['from distutils.sysconfig import get_python_lib'])
			if python_LIBDEST is None:
				if conf.env['LIBDIR']:
					python_LIBDEST=os.path.join(conf.env['LIBDIR'],"python"+pyver)
				else:
					python_LIBDEST=os.path.join(conf.env['PREFIX'],"lib","python"+pyver)
		if'PYTHONARCHDIR'in conf.environ:
			pyarchdir=conf.environ['PYTHONARCHDIR']
		else:
			(pyarchdir,)=conf.get_python_variables(["get_python_lib(plat_specific=1, standard_lib=0, prefix=%r) or ''"%conf.env['PREFIX']],['from distutils.sysconfig import get_python_lib'])
			if not pyarchdir:
				pyarchdir=pydir
		if hasattr(conf,'define'):
			conf.define('PYTHONDIR',pydir)
			conf.define('PYTHONARCHDIR',pyarchdir)
		conf.env['PYTHONDIR']=pydir
		conf.env['PYTHONARCHDIR']=pyarchdir
	pyver_full='.'.join(map(str,pyver_tuple[:3]))
	if minver is None:
		conf.msg('Checking for python version',pyver_full)
	else:
		minver_str='.'.join(map(str,minver))
		conf.msg('Checking for python version',pyver_tuple,">= %s"%(minver_str,)and'GREEN'or'YELLOW')
	if not result:
		conf.fatal('The python version is too old, expecting %r'%(minver,))
PYTHON_MODULE_TEMPLATE='''
import %s
print(1)
'''
def check_python_module(conf,module_name):
	conf.start_msg('Python module %s'%module_name)
	try:
		conf.cmd_and_log(conf.env['PYTHON']+['-c',PYTHON_MODULE_TEMPLATE%module_name])
	except:
		conf.end_msg(False)
		conf.fatal('Could not find the python module %r'%module_name)
	conf.end_msg(True)
def configure(conf):
	try:
		conf.find_program('python',var='PYTHON')
	except conf.errors.ConfigurationError:
		warn("could not find a python executable, setting to sys.executable '%s'"%sys.executable)
		conf.env.PYTHON=sys.executable
	if conf.env.PYTHON!=sys.executable:
		warn("python executable '%s' different from sys.executable '%s'"%(conf.env.PYTHON,sys.executable))
	conf.env.PYTHON=conf.cmd_to_list(conf.env.PYTHON)
	v=conf.env
	v['PYCMD']='"import sys, py_compile;py_compile.compile(sys.argv[1], sys.argv[2])"'
	v['PYFLAGS']=''
	v['PYFLAGS_OPT']='-O'
	v['PYC']=getattr(Options.options,'pyc',1)
	v['PYO']=getattr(Options.options,'pyo',1)
def options(opt):
	opt.add_option('--nopyc',action='store_false',default=1,help='Do not install bytecode compiled .pyc files (configuration) [Default:install]',dest='pyc')
	opt.add_option('--nopyo',action='store_false',default=1,help='Do not install optimised compiled .pyo files (configuration) [Default:install]',dest='pyo')

extension('.py')(process_py)
feature('py')(feature_py)
feature('pyext')(init_pyext)
before_method('propagate_uselib_vars','apply_link')(init_pyext)
before_method('propagate_uselib_vars')(init_pyembed)
feature('pyembed')(init_pyembed)
conf(get_python_variables)
conf(check_python_headers)
conf(check_python_version)
conf(check_python_module)