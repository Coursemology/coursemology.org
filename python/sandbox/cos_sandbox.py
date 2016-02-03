# Code adapted from Online Python Tutor
# https://github.com/pgbovine/OnlinePythonTutor/


import sys
import types


# TODO: use the 'six' package to smooth out Py2 and Py3 differences
is_python3 = (sys.version_info[0] == 3)

if is_python3:
	import io as cStringIO
else:
	import cStringIO



# simple sandboxing scheme:
#
# - use resource.setrlimit to deprive this process of ANY file descriptors
#   (which will cause file read/write and subprocess shell launches to fail)
# - restrict user builtins and module imports
#   (beware that this is NOT foolproof at all ... there are known flaws!)
#
# ALWAYS use defense-in-depth and don't just rely on these simple mechanisms
try:
	import resource
	resource_module_loaded = True
except ImportError:
	# Google App Engine doesn't seem to have the 'resource' module
	resource_module_loaded = False


# From http://coreygoldberg.blogspot.com/2009/05/python-redirect-or-turn-off-stdout-and.html
class NullDevice():
		def write(self, s):
				pass


# These could lead to XSS or other code injection attacks, so be careful:
__html__ = None
def setHTML(htmlStr):
	global __html__
	__html__ = htmlStr

__css__ = None
def setCSS(cssStr):
	global __css__
	__css__ = cssStr

__js__ = None
def setJS(jsStr):
	global __js__
	__js__ = jsStr


# ugh, I can't figure out why in Python 2, __builtins__ seems to
# be a dict, but in Python 3, __builtins__ seems to be a module,
# so just handle both cases ... UGLY!
if type(__builtins__) is dict:
	BUILTIN_IMPORT = __builtins__['__import__']
else:
	assert type(__builtins__) is types.ModuleType
	BUILTIN_IMPORT = __builtins__.__import__

USER_ALLOWED_MODULE_IMPORTS = (('urllib.request', {}, {}, ['urlopen']),
								('urllib.parse', {}, {}, ['urlsplit']))


# whitelist of module imports
ALLOWED_STDLIB_MODULE_IMPORTS = ('math', 'random', 'datetime',
													'functools', 'itertools', 'operator', 'string',
													'collections', 're', 'json', 'csv','copy','copyreg', 'autograde_runes',
													'engine','hungry_games_classes','hungry_games','simulation',
													'heapq', 'bisect','inspect','__future__', 'generic_arith_min',
													'encodings.idna', 'encodings', 'urllib', 'urllib.error', 'buses', 'uuid',
													'autograde_hi_graph', 'hi_graph')

# whitelist of custom modules to import into OPT
# (TODO: support modules in a subdirectory, but there are various
# logistical problems with doing so that I can't overcome at the moment,
# especially getting setHTML, setCSS, and setJS to work in the imported
# modules.)
CUSTOM_MODULE_IMPORTS = ()
# CUSTOM_MODULE_IMPORTS = ('callback_module',
#                          'ttt_module',
#                          'html_module',
#                          #'watch_module', # 'import sys' might be troublesome
#                          'bintree_module',
#                          'htmlexample_module',
#                          'GChartWrapper',
#                          'matrix',
#                          'htmlFrame')


# PREEMPTIVELY import all of these modules, so that when the user's
# script imports them, it won't try to do a file read (since they've
# already been imported and cached in memory). Remember that when
# the user's code runs, resource.setrlimit(resource.RLIMIT_NOFILE, (0, 0))
# will already be in effect, so no more files can be opened.
#
# NB: All modules in CUSTOM_MODULE_IMPORTS will be imported, warts and
# all, so they better work on Python 2 and 3!
for m in ALLOWED_STDLIB_MODULE_IMPORTS + CUSTOM_MODULE_IMPORTS:
	try:
		__import__(m)
	except:
		pass

for m in USER_ALLOWED_MODULE_IMPORTS:
	try:
		__import__(*m)
	except:
		pass

# Restrict imports to a whitelist
def __restricted_import__(name, globals=None, locals=None, fromlist=(), level=0):
	# return BUILTIN_IMPORT(name, globals, locals, fromlist, level)

	imported_mod = None
	if fromlist and len(fromlist) > 0:
		for m in USER_ALLOWED_MODULE_IMPORTS:
			if name in m and (set(fromlist).issubset(set(m[3])) or fromlist in [('*',), ['*']]):
				imported_mod = BUILTIN_IMPORT(name, globals, locals, fromlist, level)


	#handle import of subdirectory

	if name in ALLOWED_STDLIB_MODULE_IMPORTS + CUSTOM_MODULE_IMPORTS:
		imported_mod = BUILTIN_IMPORT(name, globals, locals, fromlist, level)

	if imported_mod:

		if name in CUSTOM_MODULE_IMPORTS:
			# add special magical functions to custom imported modules
			setattr(imported_mod, 'setHTML', setHTML)
			setattr(imported_mod, 'setCSS', setCSS)
			setattr(imported_mod, 'setJS', setJS)

		# somewhat weak protection against imported modules that contain one
		# of these troublesome builtins. again, NOTHING is foolproof ...
		# just more defense in depth :)
		for mod in ('sys', 'posix', 'gc'):
			if hasattr(imported_mod, mod):
				delattr(imported_mod, mod)

		return imported_mod
	else:
		raise ImportError('{0} not supported'.format(name))


def sandbox():
	a_method_that_should_not_be_seen = open

	def open_wrapper(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None):
		if file in ['impossible.txt', 'fail.txt']:
			if is_python3:
				return a_method_that_should_not_be_seen(file, mode, buffering, encoding, errors, newline, closefd, opener)
			else:
				return a_method_that_should_not_be_seen(file, mode, buffering)

		if is_python3:
			return a_method_that_should_not_be_seen(file, 'r', buffering, encoding, errors, newline, closefd, opener)
		else:
			return a_method_that_should_not_be_seen(file, 'r', buffering)

	BANNED_BUILTINS = ['reload', 'compile',
										'file', 'eval', 'exec', 'execfile',
										'exit', 'quit', 'help','globals', 'locals']

	if type(__builtins__) is dict:
		builtin_items = __builtins__.items()
	else:
		assert type(__builtins__) is types.ModuleType
		builtin_items = []
		for k in dir(__builtins__):
			builtin_items.append((k, getattr(__builtins__, k)))

	for (k, v) in builtin_items:
		if k in BANNED_BUILTINS:
			setattr(__builtins__, k, None)
			# continue
		elif k == '__import__':
			__builtins__.__import__ = __restricted_import__

	setattr(__builtins__,'setHTML', setHTML)
	setattr(__builtins__,'setCSS', setCSS)
	setattr(__builtins__,'setJS', setJS)
	setattr(__builtins__, 'open', open_wrapper)
	# user_builtins['mouse_input'] = mouse_input_wrapper
	# user_builtins['open'] = open_wrapper
	# TODO: we can disable these imports here, but a crafty user can
	# always get a hold of them by importing one of the external
	# modules, so there's no point in trying security by obscurity

def resource_limit():
	if resource_module_loaded:
		resource.setrlimit(resource.RLIMIT_AS, (200000000, 200000000))
		resource.setrlimit(resource.RLIMIT_CPU, (3, 3))

		# protect against unauthorized filesystem accesses ...
		# resource.setrlimit(resource.RLIMIT_NOFILE, (0, 0)) # no opened files allowed

		# VERY WEIRD. If you activate this resource limitation, it
		# ends up generating an EMPTY trace for the following program:
		#   "x = 0\nfor i in range(10):\n  x += 1\n   print x\n  x += 1\n"
		# (at least on my Webfaction hosting with Python 2.7)
		#resource.setrlimit(resource.RLIMIT_FSIZE, (0, 0))  # (redundancy for paranoia)

		# The posix module is a built-in and has a ton of OS access
		# facilities ... if you delete those functions from
		# sys.modules['posix'], it seems like they're gone EVEN IF
		# someone else imports posix in a roundabout way. Of course,
		# I don't know how foolproof this scheme is, though.
		# (It's not sufficient to just "del sys.modules['posix']";
		#  it can just be reimported without accessing an external
		#  file and tripping RLIMIT_NOFILE, since the posix module
		#  is baked into the python executable, ergh. Actually DON'T
		#  "del sys.modules['posix']", since re-importing it will
		#  refresh all of the attributes. ergh^2)
		for a in dir(sys.modules['posix']):
			delattr(sys.modules['posix'], a)
		# do the same with os
		for a in dir(sys.modules['os']):
			# 'path' is needed for __restricted_import__ to work
			# and 'stat' is needed for some errors to be reported properly
			if a not in ('path', 'stat', '__builtins__','environ'):
				delattr(sys.modules['os'], a)
		# ppl can dig up trashed objects with gc.get_objects()
		import gc
		for a in dir(sys.modules['gc']):
			delattr(sys.modules['gc'], a)
		del sys.modules['gc']

		# sys.modules contains an in-memory cache of already-loaded
		# modules, so if you delete modules from here, they will
		# need to be re-loaded from the filesystem.
		#
		# Thus, as an extra precaution, remove these modules so that
		# they can't be re-imported without opening a new file,
		# which is disallowed by resource.RLIMIT_NOFILE
		#
		# Of course, this isn't a foolproof solution by any means,
		# and it might lead to UNEXPECTED FAILURES later in execution.
		del sys.modules['os']
		del sys.modules['os.path']
		del sys.modules['sys']


resource_limit()
sandbox()
