#include <stdint.h>

#ifndef SYMBOL_TABLE

enum st_entry_type { ST_CONST, ST_VAR, ST_IMMEDIATE };

struct st_entry {
  char *name; // NULL when st_entry_type is ST_IMMEDIATE
  uint32_t addr;
  enum st_entry_type type;
  uint32_t depth;
};

struct st_table {
  struct st_entry *locals;
  uint32_t locals_count; // Stack pointer
  uint32_t locals_size;  // Initially at 10, increased dynamically.
  uint32_t depth;        // Initially at 0. Used to free out-of-scope entries
};

void st_init_table(struct st_table *table);
void st_free_table(struct st_table *table);
void st_printf(struct st_table *table);

/** Allocate immediate value.
  @returns Address
*/
uint32_t st_alloc_imm(struct st_table *table);

/** Changes the type of the top immediate.
  Used to reuse an immediate when declaring a var/const.
  Takes ownership of name.
*/
void st_become_type(struct st_table *table, enum st_entry_type type,
                    char *name);

/** Find entry with name.
  @returns NULL if not found. Pointer is valid until stack frame is dropped.
*/
struct st_entry *st_find(struct st_table *table, char *name);

/** Return top entry */
struct st_entry *st_get_top(struct st_table *table);

/** Free top entry. Only apply to immediates.
 */
void st_free_top(struct st_table *table);

/** Increase depth by 1. Future entries will have their depth increased */
void st_increase_depth(struct st_table *table);

/** Decrease depth by 1. Deeper entries will be freed */
void st_decrease_depth_free(struct st_table *table);

#endif
