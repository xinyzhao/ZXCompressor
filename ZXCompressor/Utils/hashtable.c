//
// hashtable.c
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

#include "hashtable.h"
#include "hash.h"

hashdata * hashdata_new(const void *data, int len) {
    if (data && len > 0) {
        hashdata * hd = malloc(sizeof(hashdata));
        hd->data = malloc(len);
        hd->length = len;
        memcpy(hd->data, data, len);
        return hd;
    }
    return NULL;
}

void hashdata_free(hashdata * data) {
    if (data) {
        if (data->data) {
            free(data->data);
            data->data = NULL;
        }
        free(data);
    }
}

hashnode * hashnode_new(const void *key, int key_len, const void *value, int val_len) {
    hashnode * node = malloc(sizeof(hashnode));
    node->key = hashdata_new(key, key_len);
    node->value = hashdata_new(value, val_len);
    node->next = NULL;
    return node;
}

void hashnode_free(hashnode * node) {
    if (node) {
        if (node->key) {
            hashdata_free(node->key);
            node->key = NULL;
        }
        if (node->value) {
            hashdata_free(node->value);
            node->value = NULL;
        }
        free(node);
    }
}

void hashnode_set_key(hashnode * node, const void *key, int key_len) {
    if (node->key) {
        hashdata_free(node->key);
    }
    node->key = hashdata_new(key, key_len);
}

void hashnode_set_value(hashnode * node, const void *value, int val_len) {
    if (node->value) {
        hashdata_free(node->value);
    }
    node->value = hashdata_new(value, val_len);
}

hashtable * hashtable_new(int size) {
    hashtable * ht = malloc(sizeof(hashtable));
    ht->size = size;
    ht->node = malloc(sizeof(hashnode) * size);
    memset(ht->node, 0, sizeof(hashnode) * size);
    return ht;
}

void hashtable_free(hashtable * table) {
    if (table) {
        if (table->node) {
            for (int i = 0; i < table->size; i++) {
                hashnode * node = &table->node[i];
                while (node->next) {
                    hashnode * next = node->next;
                    node->next = next->next;
                    hashnode_free(next);
                }
            }
            free(table->node);
            table->node = NULL;
        }
        free(table);
    }
}

void hashtable_set_node(hashtable * table, const void *key, int key_len, const void *value, int val_len) {
    hashnode * node = hashtable_get_node(table, key, key_len);
    if (node == NULL) {
        unsigned int i = simple_hash(key, key_len) % table->size;
        node = &table->node[i];
        if (node->key == NULL) {
            hashnode_set_key(node, key, key_len);
            hashnode_set_value(node, value, val_len);
            table->used++;
        } else { // conflict
            node = hashnode_new(key, key_len, value, val_len);
            node->next = table->node[i].next;
            table->node[i].next = node;
            table->used++;
        }
    } else {
        // update value
        hashnode_set_value(node, value, val_len);
    }
}

hashnode * hashtable_get_node(hashtable * table, const void *key, int key_len) {
    unsigned int i = simple_hash(key, key_len) % table->size;
    for (hashnode * node = &table->node[i]; node != NULL; node = node->next) {
        if (node->key && node->key->length == key_len && (memcmp(key, node->key->data, key_len) == 0)) {
            return node;
        }
    }
    return NULL;
}
