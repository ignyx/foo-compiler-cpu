#include "stdlib.h"
#include "stdio.h"
#include "symbol_table.h"
#include <string.h>


#define ST_TABLE_INIT_SIZE 10

void st_init_table(struct st_table* table) {
  table->locals = malloc(ST_TABLE_INIT_SIZE * sizeof(struct st_entry));
  table->locals_size = ST_TABLE_INIT_SIZE;
  table->locals_count = 0;
}

void st_free_table(struct st_table* table) {
  free(table->locals);
}

/** Allocate local entry.
  For ST_IMMEDIATE, name isn't used.
  Takes ownership of name.
  @returns Address
*/
uint32_t st_alloc_local(struct st_table* table, enum st_entry_type type, char* name) {
  if (table->locals_count >= table->locals_size) {
    // Increase array size
    struct st_entry* new_arr = malloc((table->locals_size + ST_TABLE_INIT_SIZE) * sizeof(struct st_entry));
    memcpy(table->locals, new_arr, table->locals_size);
    free(table->locals);
    table->locals = new_arr;
    table->locals_size = table->locals_size + ST_TABLE_INIT_SIZE;
  }

  table->locals[table->locals_count].name = name;
  table->locals[table->locals_count].addr = table->locals_count;
  table->locals[table->locals_count].type = type;
  
  return table->locals_count++;
}

uint32_t st_alloc_const(struct st_table* table, char* name) {
  return st_alloc_local(table, ST_CONST, name);
}

uint32_t st_alloc_var(struct st_table* table, char* name) {
  return st_alloc_local(table, ST_VAR, name);
}

uint32_t st_alloc_imm(struct st_table* table) {
  return st_alloc_local(table, ST_IMMEDIATE, NULL);
}

struct st_entry* st_find(struct st_table* table, char* name) {
  int found = 0;
  struct st_entry* entry = NULL;
  int i = 0;

  while (!found && i < table->locals_count) {
    if (table->locals[i].name == NULL) continue;

    if (strcmp(table->locals[i].name, name) == 0) {
      found = 1;
      entry = &(table->locals[i]);
    }
  }

  return entry;
}

void st_printf(struct st_table* table) {
  printf("Table locals_count=%d locals_size=%d\n", table->locals_count, table->locals_size);
  for (int i = 0; i < table->locals_count; i++) {
    printf("i=%d\t", i);
    switch (table->locals[i].type) {
      case ST_IMMEDIATE:
        printf("type=IMM\n");
        break;
      case ST_CONST:
        printf("type=CONST name=\"%s\"\n", table->locals[i].name);
        break;
      case ST_VAR:
        break;
        printf("type=VAR   name=\"%s\"\n", table->locals[i].name);
    }
  }
}
