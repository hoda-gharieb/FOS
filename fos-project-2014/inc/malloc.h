#ifndef FOS_INC_MALLOC_H
#define FOS_INC_MALLOC_H 1

void *malloc(uint32 size);
void free(void* virtual_address);
void *realloc(void *virtual_address, uint32 new_size);
void* expand(void* va, int new_size);

#endif
