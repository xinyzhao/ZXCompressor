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
#include <string.h>
#include "pqueue.h"

void huffman_build_tree(void) {
    //
    const int leaf_size = 5;
    int tree_size = leaf_size * 2 - 1;
    // tree
    huffman_tree *tree = malloc(sizeof(huffman_tree) * tree_size);
    memset(tree, 0, sizeof(huffman_tree) * tree_size);
    // freq
    char symbols[leaf_size] = {'A', 'B', 'C', 'D', 'E'};
    int weights[leaf_size] = {8, 10, 3, 4, 5};
    // 10,11,010,011,00
    for (int i = 0; i < leaf_size; i++) {
        huffman_leaf *leaf = &tree[i];
        leaf->symbol = symbols[i];
        leaf->weight = weights[i];
    }
    printf("----origin:\n");
    for (int i = 0; i < leaf_size; i++) {
        printf("%c:%d, ", tree[i].symbol, tree[i].weight);
    }
    printf("\n----end\n");
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
    char *buf = malloc(leaf_size);
    int len = 0;
    huffman_code *codes = malloc(sizeof(huffman_code) * leaf_size);
    for (int i = 0; i < leaf_size; i++) {
        huffman_node *node = &tree[i];
        huffman_code *code = &codes[i];
        code->symbol = node->symbol;
        //
        memset(buf, 0, leaf_size);
        len = 0;
        while (node->parent) {
            if (node->parent->lchild == node) {
                buf[len++] = '0';
            } else {
                buf[len++] = '1';
            }
            node = node->parent;
        }
        //
        printf("%c - ", code->symbol);
        for (int i = len - 1; i >= 0; i--) {
            printf("%c", buf[i]);
        }
        printf("\n");
    }
    free(buf);
    //
    pqueue_heap_free(heap);
    free(tree);
}
