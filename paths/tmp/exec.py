# Generates a JSON trace that is compatible with the js/pytutor.js frontend

import sys, pg_sandbox, json
from optparse import OptionParser

# To make regression tests work consistently across platforms,
# standardize display of floats to 3 significant figures
#
# Trick from:
# http://stackoverflow.com/questions/1447287/format-floats-with-standard-json-module
json.encoder.FLOAT_REPR = lambda f: ('%.3f' % f)

def json_finalizer(input_code, output_trace):
  ret = dict(trace=output_trace)
  json_output = json.dumps(ret, indent=INDENT_LEVEL)
  return json_output

parser = OptionParser(usage="Generate JSON trace for pytutor")
parser.add_option('-m', '--memory', default=2, action='store',
        help='memory limit')
parser.add_option('-t', '--time', default=1, action='store',
        help='time limit')

(options, args) = parser.parse_args()
INDENT_LEVEL = 2

fin = sys.stdin if args[0] == "-" else open(args[0])
# print(pg_sandbox.exec_script_str(fin.read(), options.time, options.memory, json_finalizer))
print(pg_sandbox.exec_script_str(fin.read(),int(options.time),int(options.memory),json_finalizer))