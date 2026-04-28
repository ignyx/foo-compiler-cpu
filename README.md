# Foolang

C-style language.

```bash
make clean
make
./main.out test.foo
./interpreter.o test.foo.bytecode

# Build with -O3, typically for benchmarking the interpreter
make speed

# Test for memleaks during an execution
valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 ./main.o test.foo
valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 ./interpreter.o test.foo.bytecode
```

Features:
- [X] Parser
- [X] Syntax analyzer
- [X] Symbol table
- [X] Perf: reuse allocated immediates where possible, to reduce `COP` instructions
- [X] Multi-var declarations: `const foo, bar = (-1e5 - 3) * 3;`
- [X] Output human-readable ASM and bytecode
- [X] Practical error handling (display line number)
- [X] Basic error recovery
- [X] if/while
- [ ] Function calling
- [X] Pointers (add `LOAD`/`STORE` instructions)
- [X] Interpreter (for coded version, supports all compiler features)
- [ ] Cross-assembler
- [X] Checked for memleaks using `valgrind` at each push
