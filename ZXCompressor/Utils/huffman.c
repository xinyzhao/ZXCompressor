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

huffman_data * huffman_data_new(int symbol, int weight) {
    huffman_data *data = malloc(sizeof(huffman_data));
    data->symbol = symbol;
    data->weight = weight;
    return data;
}

void huffman_data_free(huffman_data *data) {
    if (data) {
        free(data);
    }
}

huffman_code * huffman_code_new(int size) {
    huffman_code *code = malloc(sizeof(huffman_code));
    if (code) {
        code->size = size;
        if (code->size > 0) {
            size = BITS_TO_BYTES(code->size);
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

void huffman_code_push(huffman_code *code, int state) {
    if (code->used + 1 > code->size) {
        int old = BITS_TO_BYTES(code->size);
        code->size = code->size ? code->size * 2 : 8;
        int new = BITS_TO_BYTES(code->size);
        code->bits = realloc(code->bits, new);
        memset(&code->bits[old], 0, new - old);
    }
    bit_set(code->bits, code->used++, state);
}

int huffman_code_pop(huffman_code *code) {
    if (code && code->bits && code->used) {
        return bit_get(code->bits, --code->used);
    }
    return -1;
}


void huffman_code_make(huffman_node *node, huffman_code *code) {
    // right child is 0
    if (node->lchild) {
        huffman_code_push(code, 0);
        huffman_code_make(node->lchild, code);
    }
    // right child is 1
    if (node->rchild) {
        huffman_code_push(code, 1);
        huffman_code_make(node->rchild, code);
    }
    // leaf node
    if (node->lchild == NULL && node->rchild == NULL) {
        node->code = huffman_code_new(code->size);
        int size = BITS_TO_BYTES(code->size);
        memcpy(node->code->bits, code->bits, size);
        node->code->used = code->used;
        // printf
//#ifdef DEBUG
//        if (node->data->weight > 0) {
//            printf("0x%02X:", node->data->symbol);
//            for (int i = 0; i < code->used; i++) {
//                printf("%d", bit_get(code->bits, i));
//            }
//            printf("\n");
//        }
//#endif
    }
    // out recursive
    code->used--;
}

huffman_node * huffman_node_new(huffman_data *data) {
    huffman_node *node = malloc(sizeof(huffman_node));
    node->data = malloc(sizeof(huffman_data));
    memset(node->data, 0, sizeof(huffman_data));
    node->code = malloc(sizeof(huffman_code));
    memset(node->code, 0, sizeof(huffman_code));
    if (data) {
        memcpy(node->data, node->data, sizeof(huffman_data));
    }
    return node;
}

void huffman_node_free(huffman_node *node) {
    if (node) {
        if (node->data) {
            free(node->data);
            node->data = NULL;
        }
        if (node->code) {
            free(node->code);
            node->code = NULL;
        }
        free(node);
    }
}

huffman_tree * huffman_tree_new(huffman_data *data, const int size) {
    // size
    int leaf_size = size;
    int tree_size = leaf_size * 2 - 1;
    // tree
    huffman_tree *tree = malloc(sizeof(huffman_tree) * tree_size);
    memset(tree, 0, sizeof(huffman_tree) * tree_size);
    // leaf
    pqueue_heap *heap = pqueue_heap_new(tree_size);
    for (int i = 0; i < leaf_size; i++) {
        huffman_node *node = &tree[i];
        huffman_data *_data = &data[i];
        node->data = huffman_data_new(_data->symbol, _data->weight);
        pqueue_heap_push(heap, node->data->weight, node);
    }
    // node
    for (int i = leaf_size; i < tree_size; i++) {
        huffman_node *node = &tree[i];
        node->parent = NULL;
        node->lchild = pqueue_heap_pop(heap);
        node->lchild->parent = node;
        node->rchild = pqueue_heap_pop(heap);
        node->rchild->parent = node;
        node->data = huffman_data_new(0, node->lchild->data->weight + node->rchild->data->weight);
        pqueue_heap_push(heap, node->data->weight, node);
    }
    // code
    huffman_node *node = pqueue_heap_pop(heap);
    huffman_code *code = huffman_code_new(leaf_size);
    huffman_code_make(node, code);
    // free
    huffman_code_free(code);
    pqueue_heap_free(heap);
    //
    return tree;
}

void huffman_tree_free(huffman_tree *tree) {
    huffman_node_free(tree);
}

huffman_node * huffman_tree_root(huffman_tree *tree) {
    huffman_node *node = tree;
    while (node->parent) {
        node = node->parent;
    }
    return node;
}
