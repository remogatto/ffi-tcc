$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'ffi-tcc'

include TCC

Program_1 = <<EOP
int main()
{
    printf("Hello World!\n");
    return 0;
}
EOP

Program_2 = <<EOP
int fib(n)
{
    if (n <= 2)
        return 1;
    else
        return fib(n-1) + fib(n-2);
}

int main(int argc, char **argv)
{
    int n;
    n = atoi(argv[0]);
    printf("fib(%d) = %d\n", n, fib(n, 2));
    return 0;
}
EOP

def compile_and_evaluate(c_program, *args)
  argc = args.size
  argv = FFI::MemoryPointer.new(:pointer, argc)
  argv.write_array_of_pointer(args.map {|arg| FFI::MemoryPointer.from_string(arg.to_s)})
  state = tcc_new
  tcc_compile_string(state, c_program)
  tcc_run(state, argc, argv)
end

compile_and_evaluate(Program_1)
compile_and_evaluate(Program_2, 10)





