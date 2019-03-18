//
//  pqueue.c
//  http://rosettacode.org/wiki/Priority_queue#C
//

#include "pqueue.h"

void push(pqueue_heap *heap, int priority, void *data) {
    if (heap->len + 1 >= heap->size) {
        heap->size = heap->size ? heap->size * 2 : 4;
        heap->nodes = (pqueue_node *)realloc(heap->nodes, heap->size * sizeof (pqueue_node));
    }
    int i = heap->len + 1;
    int j = i / 2;
    while (i > 1 && heap->nodes[j].priority > priority) {
        heap->nodes[i] = heap->nodes[j];
        i = j;
        j = j / 2;
    }
    heap->nodes[i].priority = priority;
    heap->nodes[i].data = data;
    heap->len++;
}

void * pop(pqueue_heap *heap) {
    int i, j, k;
    if (!heap->len) {
        return NULL;
    }
    char *data = heap->nodes[1].data;
    
    heap->nodes[1] = heap->nodes[heap->len];
    
    heap->len--;
    
    i = 1;
    while (i != heap->len + 1) {
        k = heap->len + 1;
        j = 2 * i;
        if (j <= heap->len && heap->nodes[j].priority < heap->nodes[k].priority) {
            k = j;
        }
        if (j + 1 <= heap->len && heap->nodes[j + 1].priority < heap->nodes[k].priority) {
            k = j + 1;
        }
        heap->nodes[i] = heap->nodes[k];
        i = k;
    }
    return data;
}
