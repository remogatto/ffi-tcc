$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'ffi-tcc'

include TCC

class MyStruct < FFI::ManagedStruct
  layout \
  :a, :int
  def self.allocate
    self.new(LibC.malloc(self.size))
  end
  def self.release
    LibC.free(self)
  end
end

PrintStruct = <<EOC
typedef struct MyStruct
{
    int a;
} MyStruct_t;

void print_struct(MyStruct_t *mystruct)
{
    printf("mystruct.foo -> %d\n", mystruct->a);
}
EOC

def get_method(state, name, args, return_type)
  TCC.module_eval <<EOE
    callback(:cb, [#{args.map {|arg| ":#{arg}"}.join(',')}], :#{return_type})
    attach_function :tcc_get_symbol, [:pointer, :pointer], :cb
EOE
  TCC.tcc_get_symbol(state, name)
end

state = tcc_new
tcc_compile_string(state, PrintStruct)

size = tcc_relocate(state, nil)
mem = LibC.malloc(size)
tcc_relocate(state, mem)

func = get_method(state, 'print_struct', [ :pointer ], :void)

mystruct = MyStruct.allocate
mystruct[:a] = 10
func = tcc_get_symbol(state, 'print_struct')
func.call(mystruct)








