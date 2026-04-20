all: build

build:
	flex lang.l
	yacc lang.y --header=lang.tab.h --output=lang.tab.c
	gcc -g -Wall -Wno-error=implicit-function-declaration -o main.o lex.yy.c lang.tab.c symbol_table.c asm_table.c main.c
	gcc -g -Wall -o interpreter.o asm_table.c interpreter.c



clean:
	rm *.yy.c *.tab.c *.tab.h *.o

