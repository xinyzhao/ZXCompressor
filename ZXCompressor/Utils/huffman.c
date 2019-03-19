//
// huffman.c
//
// Copyright (c) 2019 Zhao Xin (https://github.com/xinyzhao)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#include "huffman.h"
#include "bitbyte.h"

huffman_code * huffman_code_new(uint8_t size) {
    huffman_code *code = malloc(sizeof(huffman_code));
    if (code) {
        code->size = size;
        if (code->size > 0) {
            size = size / 8 + (size % 8 ? 1 : 0);
            code->bits = malloc(size);
            memset(code->bits, 0, size);
        } else {
            code->bits = NULL;
        }
        code->used = 0;
    }
    return code;
}

void huffman_code_free(huffman_code *code) {
    if (code) {
        if (code->bits) {
            free(code->bits);
            code->bits = NULL;
        }
        free(code);
    }
}

void huffman_code_next(huffman_code *code, int state) {
    if (code->used + 1 > code->size) {
        uint8_t old = code->size / 8 + (code->size % 8 ? 1 : 0);
        code->size = code->size ? code->size * 2 : 8;
        uint8_t new = code->size / 8 + (code->size % 8 ? 1 : 0);
        code->bits = realloc(code->bits, new);
        memset(&code->bits[old], 0, new - old);
    }
    bit_set(code->bits, code->used++, state);
}

huffman_node * huffman_node_new(void) {
    return NULL;
}

void huffman_node_free(huffman_node *node) {
    if (node) {
        if (node->code) {
            huffman_code_free(node->code);
            node->code = NULL;
        }
        free(node);
    }
}

void huffman_tree_build(const char *symbols, const int *weights, const int size) {
    // size
    int leaf_size = size;
    int tree_size = leaf_size * 2 - 1;
    // tree
    huffman_node *tree = malloc(sizeof(huffman_node) * tree_size);
    memset(tree, 0, sizeof(huffman_node) * tree_size);
    // freq
    for (int i = 0; i < leaf_size; i++) {
        huffman_node *leaf = &tree[i];
        leaf->symbol = symbols[i];
        leaf->weight = weights[i];
    }
    // leaf
    pqueue_heap *heap = pqueue_heap_new(tree_size);
    for (int i = 0; i < leaf_size; i++) {
        huffman_node *node = &tree[i];
        pqueue_heap_push(heap, node->weight, node);
    }
    // node
    for (int i = leaf_size; i < tree_size; i++) {
        huffman_node *node = &tree[i];
        node->parent = NULL;
        node->lchild = pqueue_heap_pop(heap);
        node->lchild->parent = node;
        node->rchild = pqueue_heap_pop(heap);
        node->rchild->parent = node;
        node->weight = node->lchild->weight + node->rchild->weight;
        pqueue_heap_push(heap, node->weight, node);
    }
    // code
    huffman_node *node = pqueue_heap_pop(heap);
    huffman_code *code = huffman_code_new(leaf_size);
    huffman_code_build(node, code);
    // free
    huffman_code_free(code);
    pqueue_heap_free(heap);
    free(tree);
}

void huffman_code_build(huffman_node *node, huffman_code *code) {
    // right child is 0
    if (node->lchild) {
        huffman_code_next(code, 0);
        huffman_code_build(node->lchild, code);
    }
    // right child is 1
    if (node->rchild) {
        huffman_code_next(code, 1);
        huffman_code_build(node->rchild, code);
    }
    // leaf node
    if (node->lchild == NULL && node->rchild == NULL) {
        uint8_t size = code->size / 8 + (code->size % 8 ? 1 : 0);
        node->code = huffman_code_new(size);
        memcpy(node->code->bits, code->bits, size);
        node->code->used = code->used;
        // printf
        printf("%c\t", node->symbol);
        for (int i = 0; i < code->used; i++) {
            printf("%d", bit_get(code->bits, i));
        }
        printf("\n");
    }
    // recursive out
    code->used--;
}

