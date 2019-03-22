//
// huffman.h
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

#ifndef huffman_h
#define huffman_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pqueue.h"

/* huffman data */
typedef struct huffman_data {
    char symbol;
    int weight; //freq
} huffman_data;

/* huffman code */
typedef struct huffman_code {
    unsigned char *bits;
    int size; // in bits
    int used; // in bits
} huffman_code;

/* huffman node */
typedef struct huffman_node {
    struct huffman_node *parent;
    struct huffman_node *lchild;
    struct huffman_node *rchild;
    struct huffman_data *data;
    struct huffman_code *code;
} huffman_node, huffman_tree;

extern huffman_data * huffman_data_new(int symbol, int weight);
extern void huffman_data_free(huffman_data *data);

extern huffman_code * huffman_code_new(int size);
extern void huffman_code_free(huffman_code *code);
extern void huffman_code_push(huffman_code *code, int state);
extern int huffman_code_pop(huffman_code *code);
extern void huffman_code_make(huffman_node *node, huffman_code *code);

extern huffman_node * huffman_node_new(huffman_data *data);
extern void huffman_node_free(huffman_node *node);

extern huffman_tree * huffman_tree_new(huffman_data *data, const int size);
extern void huffman_tree_free(huffman_tree *tree);
extern huffman_node * huffman_tree_root(huffman_tree *tree);

#endif /* huffman_h */
