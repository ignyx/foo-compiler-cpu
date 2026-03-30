# Foolang

C-style language.

```bash
make clean
make
./main.out
```

Features:
- [X] Parser
- [X] Syntax analyzer
- [X] Symbol table
- [X] Perf: reuse allocated immediates where possible, to reduce `COP` instructions
- [X] Multi-var declarations: `const foo, bar = (-1e5 - 3) * 3;`
- [ ] Output human readable ASM and coded version
- [ ] Practical error handling
- [ ] Enhanced error handling
- [ ] if/while
- [ ] Function calling
- [ ] Pointers (add `LOAD`/`STORE` instructions`)
- [ ] Interpreter (for coded version, supports branching)
- [ ] Cross-assembler
