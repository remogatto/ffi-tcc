$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'ffi-tcc'

include TCC

def error_func(opaque, msg)
  raise msg
end

state = tcc_new
tcc_set_error_func(state, nil, method(:error_func))
tcc_compile_string(state, "void boom() { boom }")
tcc_delete(state)





