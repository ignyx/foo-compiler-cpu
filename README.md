# Foolang

C-style language.

```bash
make clean
make
./main.out # implicitly with test.foo as arg
./interpreter.o test.foo.bytecode
```

Features:
- [X] Parser
- [X] Syntax analyzer
- [X] Symbol table
- [X] Perf: reuse allocated immediates where possible, to reduce `COP` instructions
- [X] Multi-var declarations: `const foo, bar = (-1e5 - 3) * 3;`
- [X] Output human-readable ASM and bytecode
- [ ] Practical error handling
- [ ] Enhanced error handling
- [X] if/while
- [ ] Function calling
- [X] Pointers (add `LOAD`/`STORE` instructions)
- [X] Interpreter (for coded version, supports branching)
- [ ] Cross-assembler
