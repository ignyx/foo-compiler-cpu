all: build

build:
	flex lang.l
	yacc lang.y --header=lang.tab.h --output=lang.tab.c
	gcc -o main.o lang.tab.c lex.yy.c



clean:
	rm *.yy.c *.tab.c *.tab.h *.o

