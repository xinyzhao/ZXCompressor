//
// hashtable.h
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

#ifndef hashtable_h
#define hashtable_h

#include <stdio.h>

typedef struct hashdata_struct {
    void *data;
    int length;
} *hashdata, _hashdata;

typedef struct hashnode_struct {
    struct hashdata_struct *key;
    struct hashdata_struct *value;
    struct hashnode_struct *next;
} *hashnode, _hashnode;

typedef struct hashtable_struct {
    int size;
    int used;
    struct hashnode_struct *node;
} *hashtable, _hashtable;

extern hashdata hashdata_new(const void *data, int len);
extern void hashdata_free(hashdata data);

extern hashnode hashnode_new(const void *key, int key_len, const void *value, int val_len);
extern void hashnode_free(hashnode node);
extern void hashnode_set_key(hashnode node, const void *key, int key_len);
extern void hashnode_set_value(hashnode node, const void *value, int val_len);

extern hashtable hashtable_new(int size);
extern void hashtable_free(hashtable table);
extern void hashtable_set_node(hashtable table, const void *key, int key_len, const void *value, int val_len);
extern hashnode hashtable_get_node(hashtable table, const void *key, int key_len);
extern void hashtable_remove_node(hashtable table, const void *key, int key_len);

#endif /* hashtable_h */
