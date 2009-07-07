$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'ffi-tcc'

include TCC

Program_1 = <<EOP
int func()
{
    printf("Hello World!\\n");
    return 0;
}
EOP

def compile(c_program, *args)
  argc = args.size
  argv = FFI::MemoryPointer.new(:pointer, argc)
  argv.write_array_of_pointer(args.map {|arg| FFI::MemoryPointer.from_string(arg.to_s)})
  state = tcc_new
  tcc_set_output_type(state, TCC_OUTPUT_DLL)
  tcc_compile_string(state, c_program)
  tcc_output_file(state, 'example_4.so')
end

compile(Program_1)

module MyLib
  extend FFI::Library
  ffi_lib './example_4.so'
  attach_function :func, [], :int
end

MyLib.func





