# Foolang

C-style language.

```bash
make clean
make
./compiler.o examples/test.foo
./interpreter.o examples/test.foo.bytecode
xxd examples/test.foo.bytecode # For the curious

# Build with -O3, typically for benchmarking the interpreter
make speed

# Test for memleaks during an execution
valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 ./compiler.o examples/test.foo
valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 ./interpreter.o examples/test.foo.bytecode
```

Compiler Features:

- [x] Multi-var declarations: `const foo, bar = (-1e5 - 3) * 3;`
- [x] if/while
- [x] Comparison operators
- [x] Pointers (added `LOAD`/`STORE` instructions)
- [ ] Function calling
- [x] Perf: reuse allocated immediates where possible, to reduce `COP` instructions
- [x] Output human-readable ASM and bytecode
- [x] Practical error handling (display line number)
- [x] Basic error recovery
- [x] Bytecode interpreter (supports all compiler features)
- [ ] Cross-assembler
- [x] Checked for memleaks using `valgrind` at each push
