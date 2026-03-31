#include <stdio.h>
#include "asm_table.h"

int main() {
  FILE* in = fopen("test.foo.bytecode", "rb");
  if (in == NULL) {
    perror("couldn't open file");
    return 1;
  }

  struct asm_table table;
  asm_init_table(&table);

  asm_read_bytecode(in, &table);
  asm_fprintf(stdout, &table);

  fclose(in);
  asm_free_table(&table);
  return 0;
}
