//
//  pqueue.c
//  http://rosettacode.org/wiki/Priority_queue#C
//

#include "pqueue.h"

extern pqueue_node * pqueue_node_new(int priority, void *data) {
    pqueue_node *node = malloc(sizeof(pqueue_node));
    node->priority = priority;
    node->data = data;
    return node;
}

extern void pqueue_node_free(pqueue_node *node) {
    if (node) {
        node->priority = 0;
        node->data = NULL;
        free(node);
    }
}

extern pqueue_heap * pqueue_heap_new(unsigned int size) {
    pqueue_heap *heap = malloc(sizeof(pqueue_heap));
    heap->size = size;
    if (heap->size > 0) {
        heap->nodes = malloc(heap->size * sizeof (pqueue_node));
    } else {
        heap->nodes = NULL;
    }
    heap->used = 0;
    return heap;
}

extern void pqueue_heap_free(pqueue_heap *heap) {
    if (heap) {
        if (heap->nodes) {
            free(heap->nodes);
            heap->nodes = NULL;
        }
        heap->size = 0;
        heap->used = 0;
        free(heap);
    }
}

void pqueue_heap_push(pqueue_heap *heap, int priority, void *data) {
    if (heap->used >= heap->size) {
        heap->size = heap->size ? heap->size * 2 : 4;
        heap->nodes = (pqueue_node *)realloc(heap->nodes, heap->size * sizeof (pqueue_node));
    }
    int i = heap->used;
    int j = (i - 1) / 2;
    while (i > 0 && heap->nodes[j].priority > priority) {
        heap->nodes[i] = heap->nodes[j];
        i = j;
        j = (j - 1) / 2;
    }
    heap->nodes[i].priority = priority;
    heap->nodes[i].data = data;
    heap->used++;
}

void * pqueue_heap_pop(pqueue_heap *heap) {
    if (heap->used == 0) {
        return NULL;
    }
    
    char *data = heap->nodes[0].data;
    heap->nodes[0] = heap->nodes[heap->used - 1];
    heap->used--;
    
    int i = 0, j, k;
    while (i != heap->used) {
        k = heap->used;
        j = 2 * i + 1;
        if (j <= heap->used && heap->nodes[j].priority < heap->nodes[k].priority) {
            k = j;
        }
        if (j + 1 <= heap->used && heap->nodes[j + 1].priority < heap->nodes[k].priority) {
            k = j + 1;
        }
        heap->nodes[i] = heap->nodes[k];
        i = k;
    }
    
    return data;
}
