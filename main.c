#include "lang.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s <code.foo>\n", argv[0]);
    return 1;
  }

  FILE *in = fopen(argv[1], "rb");
  if (in == NULL) {
    perror("couldn't open input file");
    return 1;
  }

  char extension[] = ".bytecode";
  char *out_bytecode_name = malloc(strlen(argv[1]) + strlen(extension) + 1);
  strcpy(out_bytecode_name, argv[1]);
  strcat(out_bytecode_name, extension);
  FILE *out_bytecode = fopen(out_bytecode_name, "wb");
  if (out_bytecode == NULL) {
    perror("couldn't open output file");
    return 1;
  }

  compile(in, stdout, out_bytecode, stderr);

  fclose(in);
  fclose(out_bytecode);

  fprintf(stderr, "Bytecode written to %s\n", out_bytecode_name);
  free(out_bytecode_name);
  return 0;
}
