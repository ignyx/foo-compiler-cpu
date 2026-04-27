#include "lang.h"
#include <stdio.h>

int main(void) {
  FILE *in = fopen("test_pointers_2.foo", "r");
  FILE *out_bytecode = fopen("test.foo.bytecode", "wb");
  compile(in, stdout, out_bytecode, stderr);
  fclose(in);
  fclose(out_bytecode);
  return 0;
}
