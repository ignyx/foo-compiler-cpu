# Foolang

C-style language.

```bash
make clean
make
./compiler.o examples/test.foo
./interpreter.o examples/test.foo.bytecode
xxd examples/test.foo.bytecode # For the curious

# Cross-assemble to CPU ISA in VHDL-compatible format
./compiler.o examples/test_cross.foo
./cross_assembler.o examples/test_cross.foo.bytecode

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
- [x] Cross-assembler
- [x] Checked for memleaks using `valgrind` at each push

CPU Features:

- [x] All specified assembly instructions
- [x] Data hazards
- [ ] PRI LED output
- [ ] FPGA demo
- [ ] Jumps
- [ ] Function calling instructions and registers

## Design process

### Code modularity

The compiler code was designed into multiple bricks, for separation of concerns and code re-use.
For example, the `asm_table` structure is used in the compiler, interpreter and cross-assembler.

```bash
.
├── cpu/ # Xilinx Vivado project & VHDL code
├── examples/ # Example foo code to test the compiler on
├── .github/workflows/test.yml # Auto compile and check memleaks
├── asm_table.c
├── asm_table.h # Structure handling output assembly instructions
├── cross_assembler.c
├── interpreter.c
├── lang.h
├── lang.l # Lexical analyser
├── lang.y # Syntax analyser
├── main.c # Compiler main
├── Makefile
├── math.h # util
├── README.md # This file, the report
├── symbol_table.c
└── symbol_table.h # Structure handling symbols and address allocations
```

Similarly, the processor VHDL code is broken up into multiple components, allowing for better readability and testing.

### Incremental testing

The code was tested as often as practical, to ensure the changes produce the expected behavior.
For the compiler, it meant building often and parsing/compiling on test files from `./examples/`.
For the processor, it meant many behavioral simulations and periodic synthesis (catches errors that behavioral simulations can miss).

This allowed catching errors early before they pile up.

A Github Actions workflow ensures code compiles and runs without memleaks at every push.

### Refactoring for readability

Variables and functions are named and renamed to allow the code reader to easily understand _what_ the code does.
Comments provide the _why_. Prefixes allow identifying which component it is about (eg. `st_` -> Symbol table).

Enums and constants are used to give meaning to numeric values (eg. `ASM_ADD`, `ST_TABLE_INIT_SIZE`).

## Cross-Assembler (`./cross_assembler.c`)

The compiler outputs a memory-oriented assembly, while the CPU uses a register-oriented ISA.

It reads the bytecode into an `asm_table` and prints cross-assembled CPU assembly to `stdout`.

### Simple version

I wrote a first straightforward implementation that `LOAD`/`STORE`s values for each instruction.
It leads to useless `LOAD`/`STORE` and multi-cycle data-hazards. I ordered instructions to minimize
data hazards and reduce average cycle count per instruction.

This implementation defeats the purpose of having a register-oriented CPU.

My CPU `LOAD`/`STORE` reads the address from a register, so I must `AFC` the address.
A simpler optimization could be to reuse the `AFC`ed addresses between instructions.

Doesn't support `JMP`/`JMPF` because the CPU doesn't.

### Thougts about further optimization

I thought about using a register->memory mapping with an LRU eviction policy
but it isn't sufficient.

Goals:

- Reduce memory accesses by utilizing all registers
- Reduce instruction count
- Prevent data hazards
- Remain compliant with expected output behavior

Care must be taken with jump instructions because references must remain
valid. Care must be taken with values handled with pointers: `LOAD` can read
from a hard-to-predict address and `STORE` can write anywhere. This `LOAD`/`STORE`
behavior requires us to commit all changes to memory.

I designed but didn't implement the following idea. A first forward pass:

- checks whether the code contains `LOAD` or `STORE` instructions.
  If none are present, we don't need to commit all changes to memory.
- stores up to which instruction a value is needed (either last used before overwritten or if before a jump)

Second forward pass outputs instructions.
It stores values in registers, and adds `STORE` memory commits to a queue.
The queue is flushed when the following instruction is a `LOAD`, `STORE` or jump,
when a register is about to be overwritten, or when we expect a data hazard.
