#include "symbol_table.h"
#include "stdio.h"
#include "stdlib.h"
#include <assert.h>
#include <string.h>

#define ST_TABLE_INIT_SIZE 2

void st_init_table(struct st_table *table) {
  table->locals = malloc(ST_TABLE_INIT_SIZE * sizeof(struct st_entry));
  table->locals_size = ST_TABLE_INIT_SIZE;
  table->locals_count = 0;
  table->depth = 0;
}

void st_free_table(struct st_table *table) {
  free(table->locals);
  // TODO free names
}

static struct st_entry *st_get_top(struct st_table *table) {
  assert(table->locals_count > 0);
  return &(table->locals[table->locals_count - 1]);
}

uint32_t st_alloc_imm(struct st_table *table) {
  if (table->locals_count >= table->locals_size) {
    // Increase array size
    table->locals = realloc(table->locals,
                            (table->locals_size * 2) * sizeof(struct st_entry));
    assert(table->locals != NULL);
    table->locals_size = table->locals_size * 2;
  }

  table->locals[table->locals_count].name = NULL;
  table->locals[table->locals_count].addr = table->locals_count;
  table->locals[table->locals_count].type = ST_IMMEDIATE;
  table->locals[table->locals_count].depth = table->depth;

  return table->locals_count++;
}

void st_become_type(struct st_table *table, enum st_entry_type type,
                    char *name) {
  struct st_entry *top = st_get_top(table);
  assert(top->type == ST_IMMEDIATE);

  top->name = name;
  top->type = type;
}

struct st_entry *st_find(struct st_table *table, char *name) {
  int found = 0;
  struct st_entry *entry = NULL;
  int i = 0;

  while (!found && i < table->locals_count) {
    if (table->locals[i].name == NULL) {
      i++;
      continue;
    }

    if (strcmp(table->locals[i].name, name) == 0) {
      found = 1;
      entry = &(table->locals[i]);
    }
    i++;
  }

  return entry;
}

void st_printf(struct st_table *table) {
  printf("Table locals_count=%d locals_size=%d depth=%d\n", table->locals_count,
         table->locals_size, table->depth);
  for (int i = 0; i < table->locals_count; i++) {
    printf("i=%d\t", i);
    switch (table->locals[i].type) {
    case ST_IMMEDIATE:
      printf("type=IMM\n");
      break;
    case ST_CONST:
      printf("type=CONST depth=%d name=\"%s\"\n", table->locals[i].depth,
             table->locals[i].name);
      break;
    case ST_VAR:
      printf("type=VAR   depth=%d name=\"%s\"\n", table->locals[i].depth,
             table->locals[i].name);
      break;
    }
  }
}

void st_free_top(struct st_table *table) {
  assert(st_get_top(table)->type == ST_IMMEDIATE);
  table->locals_count--;
}

void st_increase_depth(struct st_table *table) { table->depth++; }

void st_decrease_depth_free(struct st_table *table) {
  table->depth--;
  while (table->locals_count > 0 && st_get_top(table)->depth > table->depth) {
    // finding an immediate means it wasn't freed when it was supposed to...
    // st_printf(table);
    assert(st_get_top(table)->type != ST_IMMEDIATE);
    table->locals_count--;
  }
}
