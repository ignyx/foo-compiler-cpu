#include "lang.h"
#include <stdio.h>

int main(void) {
  FILE* in = fopen("test.foo", "r");
  compile(in, stdout, stdout, stderr);
  fclose(in);
  return 0;
}
