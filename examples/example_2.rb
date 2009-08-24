$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'ffi-tcc'

include TCC

# This Function object is used within the C fragment
Add = FFI::Function.new(:int, [ :int, :int]) { |a, b| a + b } 

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

state = tcc_new
tcc_compile_string(state, Fibonacci)

TCC.tcc_add_symbol(state, 'add', Add)

size = tcc_relocate(state, nil)
mem = LibC.malloc(size)
tcc_relocate(state, mem)

func = FFI::Function.new(:int, [ :int ], TCC.tcc_get_symbol(state, 'func'))
func.call(10)

LibC.free(mem)







