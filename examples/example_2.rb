$LOAD_PATH.unshift 'lib'
require 'ffi-tcc'

include TCC

# This proc is used within the C fragment
Add = Proc.new { |a, b| a + b } 

# The C fragment
Fibonacci = <<EOP
int fib(int n)
{
    if (n <= 2)
        return 1;
    else
        return add(fib(n-1), fib(n-2)); // add function is defined in ruby
}

int func(int n)
{
    printf("fib(%d) = %d\n", n, fib(n));
    return 0;
}
EOP

def add_method(state, method, name, args, return_type)
  TCC.module_eval <<EOE
    attach_function :tcc_add_symbol, [:pointer, :pointer, callback([#{args.map {|arg| ":#{arg}"}.join(',')}], :#{return_type}) ], :int
EOE
  TCC.tcc_add_symbol(state, name, method)
end

def get_method(state, name, args, return_type)
  TCC.module_eval <<EOE
    callback(:cb, [#{args.map {|arg| ":#{arg}"}.join(',')}], :#{return_type})
    attach_function :tcc_get_symbol, [:pointer, :pointer], :cb
EOE
  TCC.tcc_get_symbol(state, name)
end

state = tcc_new
tcc_compile_string(state, Fibonacci)

add_method state, Add, 'add', [ :int, :int ], :int

size = tcc_relocate(state, nil)
mem = LibC.malloc(size)
tcc_relocate(state, mem)

func = get_method state, 'func', [ :int ], :int
func.call(10)

LibC.free(mem)







