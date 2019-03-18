//
//  pqueue.h
//  http://rosettacode.org/wiki/Priority_queue#C
//

#ifndef pqueue_h
#define pqueue_h

#include <stdio.h>

typedef struct pqueue_node {
    int priority;
    void *data;
} pqueue_node;

typedef struct pqueue_heap {
    pqueue_node *nodes;
    unsigned int size;
    unsigned int len;
} pqueue_heap;

extern void push(pqueue_heap *heap, int priority, void *data);
extern void * pop(pqueue_heap *heap);

#endif /* pqueue_h */
