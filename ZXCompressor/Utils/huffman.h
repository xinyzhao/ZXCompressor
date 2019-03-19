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

/* huffman code */
typedef struct huffman_code {
    uint8_t *bits;
    uint8_t size;
    uint8_t used;
} huffman_code;

/* huffman tree */
typedef struct huffman_node {
    struct huffman_node *parent;
    struct huffman_node *lchild;
    struct huffman_node *rchild;
    uint8_t symbol;
    int weight; //freq
    struct huffman_code *code;
} huffman_node;

extern huffman_code * huffman_code_new(uint8_t size);
extern void huffman_code_free(huffman_code *code);
extern void huffman_code_next(huffman_code *code, int state);

extern huffman_node * huffman_node_new(void);
extern void huffman_node_free(huffman_node *node);

extern void huffman_tree_build(const char *symbols, const int *weights, const int size);
extern void huffman_code_build(huffman_node *node, huffman_code *code);

#endif /* huffman_h */
