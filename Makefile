all: build

build:
	flex lang.l
	yacc lang.y --header=lang.tab.h --output=lang.tab.c
	gcc -g -Wall -Wno-unused-function -o compiler.o lex.yy.c lang.tab.c symbol_table.c asm_table.c main.c
	gcc -g -Wall -Wno-unused-function -o interpreter.o asm_table.c interpreter.c
	gcc -g -Wall -Wno-unused-function -o cross_compiler.o asm_table.c cross_compiler.c

speed:
	flex lang.l
	yacc lang.y --header=lang.tab.h --output=lang.tab.c
	gcc -O3 -Wall -Wno-unused-function -o main.o lex.yy.c lang.tab.c symbol_table.c asm_table.c main.c
	gcc -O3 -Wall -Wno-unused-function -o interpreter.o asm_table.c interpreter.c
	gcc -O3 -Wall -Wno-unused-function -o cross_compiler.o asm_table.c cross_compiler.c

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.o *.bytecode examples/*.bytecode

