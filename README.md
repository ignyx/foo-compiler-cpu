# Foolang

C-style language.

```bash
make clean
make
./main.out test.foo
./interpreter.o test.foo.bytecode

# Test for memleaks during an execution
valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 ./main.o test.foo
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
- [X] Interpreter (for coded version, supports branching)
- [ ] Cross-assembler
