//
//  pqueue.h
//  http://rosettacode.org/wiki/Priority_queue#C
//

#ifndef pqueue_h
#define pqueue_h

#include <stdlib.h>

typedef struct pqueue_node {
    int priority;
    void *data;
} pqueue_node;

typedef struct pqueue_heap {
    pqueue_node *nodes;
    unsigned int size;
    unsigned int used;
} pqueue_heap;

extern pqueue_node * pqueue_node_new(int priority, void *data);
extern void pqueue_node_free(pqueue_node *node);

extern pqueue_heap * pqueue_heap_new(unsigned int size);
extern void pqueue_heap_free(pqueue_heap *heap);

extern void pqueue_heap_push(pqueue_heap *heap, int priority, void *data);
extern void * pqueue_heap_pop(pqueue_heap *heap);

#endif /* pqueue_h */
