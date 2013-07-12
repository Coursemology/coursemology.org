# Online Python Tutor
# https://github.com/pgbovine/OnlinePythonTutor/
#
# Copyright (C) 2010-2013 Philip J. Guo (philip@pgbovine.net)
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# This is the meat of the Online Python Tutor back-end.  It implements a
# full logger for Python program execution (based on pdb, the standard
# Python debugger imported via the bdb module), printing out the values
# of all in-scope data structures after each executed instruction.



import sys
import bdb # the KEY import here!
import re
import traceback
import types

is_python3 = (sys.version_info[0] == 3)

if is_python3:
  import io as cStringIO
else:
  import cStringIO
import pg_encoder


# TODO: not threadsafe:

# upper-bound on the number of executed lines, in order to guard against
# infinite loops
MAX_EXECUTED_LINES = 1000

DEBUG = False
# DEBUG = True

BREAKPOINT_STR = '#break'

CLASS_RE = re.compile('class\s+')


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


# whitelist of module imports
ALLOWED_STDLIB_MODULE_IMPORTS = ('math', 'random', 'datetime',
                          'functools', 'operator', 'string',
                          'collections', 're', 'json',
                          'heapq', 'bisect')

# whitelist of custom modules to import into OPT
# (TODO: support modules in a subdirectory, but there are various
# logistical problems with doing so that I can't overcome at the moment,
# especially getting setHTML, setCSS, and setJS to work in the imported
# modules.)
# CUSTOM_MODULE_IMPORTS = ('callback_module',
#                          'ttt_module',
#                          'html_module',
#                          'watch_module',
#                          'bintree_module',
#                          'GChartWrapper')
CUSTOM_MODULE_IMPORTS = ()


# PREEMPTIVELY import all of these modules, so that when the user's
# script imports them, it won't try to do a file read (since they've
# already been imported and cached in memory). Remember that when
# the user's code runs, resource.setrlimit(resource.RLIMIT_NOFILE, (0, 0))
# will already be in effect, so no more files can be opened.
#
# NB: All modules in CUSTOM_MODULE_IMPORTS will be imported, warts and
# all, so they better work on Python 2 and 3!
for m in ALLOWED_STDLIB_MODULE_IMPORTS + CUSTOM_MODULE_IMPORTS:
  __import__(m)


# Restrict imports to a whitelist
def __restricted_import__(*args):
  if args[0] in ALLOWED_STDLIB_MODULE_IMPORTS + CUSTOM_MODULE_IMPORTS:
    imported_mod = BUILTIN_IMPORT(*args)

    if args[0] in CUSTOM_MODULE_IMPORTS:
      # add special magical functions to custom imported modules
      setattr(imported_mod, 'setHTML', setHTML)
      setattr(imported_mod, 'setCSS', setCSS)
      setattr(imported_mod, 'setJS', setJS)

    return imported_mod
  else:
    raise ImportError('{0} not supported'.format(args[0]))


# Support interactive user input by:
#
# 1. running the entire program up to a call to raw_input (or input in py3),
# 2. bailing and returning a trace ending in a special 'raw_input' event,
# 3. letting the web frontend issue a prompt to the user to grab a string,
# 4. RE-RUNNING the whole program with that string added to input_string_queue,
# 5. which should bring execution to the next raw_input call (if
#    available), or to termination.
# Repeat until no more raw_input calls are encountered.
# Note that this is mad inefficient, but is simple to implement!
#
# TODO: To make this technique more deterministic,
#       save away and restore the random seed.

# queue of input strings passed from either raw_input or mouse_input
input_string_queue = []

class RawInputException(Exception):
  pass

def raw_input_wrapper(prompt=''):
  if input_string_queue:
    return input_string_queue.pop(0)
  raise RawInputException(prompt)

class MouseInputException(Exception):
  pass

def mouse_input_wrapper(prompt=''):
  if input_string_queue:
    return input_string_queue.pop(0)
  raise MouseInputException(prompt)



# blacklist of builtins
BANNED_BUILTINS = ['reload', 'open', 'compile',
                   'file', 'eval', 'exec', 'execfile',
                   'exit', 'quit', 'help',
                   'dir', 'globals', 'locals', 'vars']
# Peter says 'apply' isn't dangerous, so don't ban it

# ban input() in Python 2 since it does an eval!
# (Python 3 input is Python 2 raw_input, so we're okay)
if not is_python3:
  BANNED_BUILTINS.append('input')


IGNORE_VARS = set(('__user_stdout__', '__builtins__', '__name__', '__exception__', '__doc__', '__package__'))

def get_user_stdout(frame):
  return frame.f_globals['__user_stdout__'].getvalue()


class PGLogger(bdb.Bdb):

    def __init__(self, timeLimit, memoryLimit, finalizer_func, disable_security_checks=False):
        bdb.Bdb.__init__(self)
        self.mainpyfile = ''
        self._wait_for_mainpyfile = 0

        self.timeLimit = timeLimit

        self.memoryLimit = memoryLimit * 1000000

        self.disable_security_checks = disable_security_checks

        # if True, then displays ALL stack frames that have ever existed
        # rather than only those currently on the stack (and their
        # lexical parents)
        self.cumulative_mode = False

        # if True, then render certain primitive objects as heap objects
        self.render_heap_primitives = False

        # if True, then don't render any data structures in the trace,
        # and show only outputs
        self.show_only_outputs = True

        # a function that takes the output trace as a parameter and
        # processes it
        self.finalizer_func = finalizer_func

        # each entry contains a dict with the information for a single
        # executed line
        self.trace = []

        # if this is true, don't put any more stuff into self.trace
        self.done = False

        # if this is non-null, don't do any more tracing until a
        # 'return' instruction with a stack gotten from
        # get_stack_code_IDs() that matches wait_for_return_stack
        self.wait_for_return_stack = None

        #http://stackoverflow.com/questions/2112396/in-python-in-google-app-engine-how-do-you-capture-output-produced-by-the-print
        self.GAE_STDOUT = sys.stdout

        self.STDERROR = sys.stderr

        # Key:   function object
        # Value: parent frame
        self.closures = {}

        # set of function objects that were defined in the global scope
        self.globally_defined_funcs = set()

        # Key: frame object
        # Value: monotonically increasing small ID, based on call order
        self.frame_ordered_ids = {}
        self.cur_frame_id = 1

        # List of frames to KEEP AROUND after the function exits.
        # If cumulative_mode is True, then keep ALL frames in
        # zombie_frames; otherwise keep only frames where
        # nested functions were defined within them.
        self.zombie_frames = []

        # set of elements within zombie_frames that are also
        # LEXICAL PARENTS of other frames
        self.parent_frames_set = set()

        # all globals that ever appeared in the program, in the order in
        # which they appeared. note that this might be a superset of all
        # the globals that exist at any particular execution point,
        # since globals might have been deleted (using, say, 'del')
        self.all_globals_in_order = []

        # very important for this single object to persist throughout
        # execution, or else canonical small IDs won't be consistent.
        self.encoder = pg_encoder.ObjectEncoder(self.render_heap_primitives)

        self.executed_script = None # Python script to be executed!

        # if there is at least one line that ends with BREAKPOINT_STR,
        # then activate "breakpoint mode", where execution should stop
        # ONLY at breakpoint lines.
        self.breakpoints = []

        self.prev_lineno = -1 # keep track of previous line just executed

    # unused ...
    #def reset(self):
    #    bdb.Bdb.reset(self)
    #    self.forget()


    def forget(self):
        self.lineno = None
        self.stack = []
        self.curindex = 0
        self.curframe = None

    def setup(self, f, t):
        self.forget()
        self.stack, self.curindex = self.get_stack(f, t)
        self.curframe = self.stack[self.curindex][0]

    # should be a reasonably unique ID to match calls and returns:
    def get_stack_code_IDs(self):
        return [id(e[0].f_code) for e in self.stack]

    def user_line(self, frame):
        """This function is called when we stop or break at this line."""
        if self.done: return

        if self._wait_for_mainpyfile:
            if (self.canonic(frame.f_code.co_filename) != "<string>" or
                frame.f_lineno <= 0):
                return
            self._wait_for_mainpyfile = 0
        self.interaction(frame, None, 'step_line')

    def user_return(self, frame, return_value):
        """This function is called when a return trap is set here."""
        if self.done: return

        frame.f_locals['__return__'] = return_value
        self.interaction(frame, None, 'return')

    def user_exception(self, frame, exc_info):
        """This function is called if an exception occurs,
        but only if we are to stop at or just below this level."""
        if self.done: return

        exc_type, exc_value, exc_traceback = exc_info
        frame.f_locals['__exception__'] = exc_type, exc_value
        if type(exc_type) == type(''):
            exc_type_name = exc_type
        else: exc_type_name = exc_type.__name__

        if exc_type_name == 'RawInputException':
          self.trace.append(dict(event='raw_input', prompt=exc_value.args[0]))
          self.done = True
        elif exc_type_name == 'MouseInputException':
          self.trace.append(dict(event='mouse_input', prompt=exc_value.args[0]))
          self.done = True
        else:
          self.interaction(frame, exc_traceback, 'exception')

    # General interaction function

    def interaction(self, frame, traceback, event_type):
        self.setup(frame, traceback)
        tos = self.stack[self.curindex]
        top_frame = tos[0]
        lineno = tos[1]

        # debug ...
        '''
        print >> sys.stderr, '=== STACK ==='
        for (e,ln) in self.stack:
          print >> sys.stderr, e.f_code.co_name + ' ' + e.f_code.co_filename + ' ' + str(ln)
        print >> sys.stderr, "top_frame", top_frame.f_code.co_name
        print >> sys.stderr
        '''


        # don't trace inside of ANY functions that aren't user-written code
        # (e.g., those from imported modules -- e.g., random, re -- or the
        # __restricted_import__ function in this file)
        #
        # empirically, it seems like the FIRST entry in self.stack is
        # the 'run' function from bdb.py, but everything else on the
        # stack is the user program's "real stack"

        # Look only at the "topmost" frame on the stack ...

        # it seems like user-written code has a filename of '<string>',
        # but maybe there are false positives too?
        if self.canonic(top_frame.f_code.co_filename) != '<string>':
          return
        # also don't trace inside of the magic "constructor" code
        if top_frame.f_code.co_name == '__new__':
          return
        # or __repr__, which is often called when running print statements
        if top_frame.f_code.co_name == '__repr__':
          return


        if self.show_only_outputs:
          trace_entry = dict(line=lineno,
                             event=event_type,
                             func_name=tos[0].f_code.co_name,
                             globals={},
                             ordered_globals=[],
                             stack_to_render=[],
                             heap={},
                             stdout=get_user_stdout(tos[0]))
        else:
          trace_entry = dict(line=lineno,
                             event=event_type,
                             func_name=tos[0].f_code.co_name,
                             globals=encoded_globals,
                             ordered_globals=ordered_globals,
                             stack_to_render=stack_to_render,
                             heap=self.encoder.get_heap(),
                             stdout=get_user_stdout(tos[0]))

        # TODO: refactor into a non-global
        global __html__, __css__, __js__
        if __html__:
          trace_entry['html_output'] = __html__
        if __css__:
          trace_entry['css_output'] = __css__
        if __js__:
          trace_entry['js_output'] = __js__

        # if there's an exception, then record its info:
        if event_type == 'exception':
          # always check in f_locals
          exc = frame.f_locals['__exception__']
          trace_entry['exception_msg'] = exc[0].__name__ + ': ' + str(exc[1])


        # append to the trace only the breakpoint line and the next
        # executed line, so that if you set only ONE breakpoint, OPT shows
        # the state before and after that line gets executed.
        append_to_trace = True

        if append_to_trace:
          self.trace.append(trace_entry)

        if len(self.trace) >= MAX_EXECUTED_LINES:
          self.trace.append(dict(event='instruction_limit_reached', exception_msg='(stopped after ' + str(MAX_EXECUTED_LINES) + ' steps to prevent possible infinite loop)'))
          self.force_terminate()

        self.forget()


    def _runscript(self, script_str):
        self.executed_script = script_str
        self.executed_script_lines = self.executed_script.splitlines()

        for (i, line) in enumerate(self.executed_script_lines):
          line_no = i + 1
          if line.endswith(BREAKPOINT_STR):
            self.breakpoints.append(line_no)


        # When bdb sets tracing, a number of call and line events happens
        # BEFORE debugger even reaches user's code (and the exact sequence of
        # events depends on python version). So we take special measures to
        # avoid stopping before we reach the main script (see user_line and
        # user_call for details).
        self._wait_for_mainpyfile = 1


        # ok, let's try to sorta 'sandbox' the user script by not
        # allowing certain potentially dangerous operations.
        user_builtins = {}

        # ugh, I can't figure out why in Python 2, __builtins__ seems to
        # be a dict, but in Python 3, __builtins__ seems to be a module,
        # so just handle both cases ... UGLY!
        if type(__builtins__) is dict:
          builtin_items = __builtins__.items()
        else:
          assert type(__builtins__) is types.ModuleType
          builtin_items = []
          for k in dir(__builtins__):
            builtin_items.append((k, getattr(__builtins__, k)))

        for (k, v) in builtin_items:
          if k in BANNED_BUILTINS:
            continue
          elif k == '__import__':
            user_builtins[k] = __restricted_import__
          else:
            if k == 'raw_input':
              user_builtins[k] = raw_input_wrapper
            elif k == 'input' and is_python3:
              # Python 3 input() is Python 2 raw_input()
              user_builtins[k] = raw_input_wrapper
            else:
              user_builtins[k] = v

        user_builtins['mouse_input'] = mouse_input_wrapper

        # TODO: we can disable these imports here, but a crafty user can
        # always get a hold of them by importing one of the external
        # modules, so there's no point in trying security by obscurity
        user_builtins['setHTML'] = setHTML
        user_builtins['setCSS'] = setCSS
        user_builtins['setJS'] = setJS

        user_stdout = cStringIO.StringIO()

        sys.stdout = user_stdout
        user_globals = {"__name__"    : "__main__",
                        "__builtins__" : user_builtins,
                        "__user_stdout__" : user_stdout}

        try:
          # enforce resource limits RIGHT BEFORE running script_str

          # set ~200MB virtual memory limit AND a 5-second CPU time
          # limit (tuned for Webfaction shared hosting) to protect against
          # memory bombs such as:
          #   x = 2
          #   while True: x = x*x
          if resource_module_loaded and (not self.disable_security_checks):
            resource.setrlimit(resource.RLIMIT_AS, (self.memoryLimit, self.memoryLimit))
            resource.setrlimit(resource.RLIMIT_CPU, (self.timeLimit, self.timeLimit))

            # protect against unauthorized filesystem accesses ...
            resource.setrlimit(resource.RLIMIT_NOFILE, (0, 0)) # no opened files allowed

            # VERY WEIRD. If you activate this resource limitation, it
            # ends up generating an EMPTY trace for the following program:
            #   "x = 0\nfor i in range(10):\n  x += 1\n   print x\n  x += 1\n"
            # (at least on my Webfaction hosting with Python 2.7)
            #resource.setrlimit(resource.RLIMIT_FSIZE, (0, 0))  # (redundancy for paranoia)

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
            del sys.modules['sys']

          self.run(script_str, user_globals, user_globals)
        # sys.exit ...
        except SystemExit:
          #sys.exit(0)
          raise bdb.BdbQuit
        except:
          if DEBUG:
            traceback.print_exc()

          trace_entry = dict(event='uncaught_exception')

          (exc_type, exc_val, exc_tb) = sys.exc_info()
          if hasattr(exc_val, 'lineno'):
            trace_entry['line'] = exc_val.lineno
          if hasattr(exc_val, 'offset'):
            trace_entry['offset'] = exc_val.offset

          trace_entry['exception_msg'] = type(exc_val).__name__ + ": " +  str(exc_val)

          # SUPER SUBTLE! if this exact same exception has already been
          # recorded by the program, then DON'T record it again as an
          # uncaught_exception
          already_caught = False
          for e in self.trace:
            if e['event'] == 'exception' and e['exception_msg'] == trace_entry['exception_msg']:
              already_caught = True
              break

          if not already_caught:
            if not self.done:
              self.trace.append(trace_entry)

          raise bdb.BdbQuit # need to forceably STOP execution


    def force_terminate(self):
      #self.finalize()
      raise bdb.BdbQuit # need to forceably STOP execution


    def finalize(self):
      sys.stdout = self.GAE_STDOUT # very important!

      assert len(self.trace) <= (MAX_EXECUTED_LINES + 1)

      # don't do this anymore ...
      '''
      # filter all entries after 'return' from '<module>', since they
      # seem extraneous:
      res = []
      for e in self.trace:
        res.append(e)
        if e['event'] == 'return' and e['func_name'] == '<module>':
          break
      '''

      res = self.trace

      # if the SECOND to last entry is an 'exception'
      # and the last entry is return from <module>, then axe the last
      # entry, for aesthetic reasons :)
      if len(res) >= 2 and \
         res[-2]['event'] == 'exception' and \
         res[-1]['event'] == 'return' and res[-1]['func_name'] == '<module>':
        res.pop()

      self.trace = res



      return self.finalizer_func(self.executed_script, self.trace[-1])


import json


def exec_script_str(script_str, timeLimit, memoryLimit,finalizer_func):
  logger = PGLogger(timeLimit,memoryLimit,finalizer_func, disable_security_checks=False)

  # TODO: refactor these NOT to be globals
  
  global __html__, __css__, __js__
  __html__, __css__, __js__ = None, None, None

  try:
    logger._runscript(script_str)
  except bdb.BdbQuit:
    pass
  finally:
    return logger.finalize()
