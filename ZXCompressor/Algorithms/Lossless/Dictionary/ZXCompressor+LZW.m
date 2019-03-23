//
// ZXCompressor+LZW.m
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

#import "ZXCompressor+LZW.h"
#import "bitbyte.h"
#import "hashtable.h"

@implementation ZXCompressor (LZW)

const int kLZWCodeBase = 256;
const int kLZWDictSize = 4096;

+ (void)compressUsingLZW:(const unsigned int)dictionarySize
              readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
             writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
              completion:(void (^)(void))completion {
    // 调整词典大小
    unsigned int tableSize = dictionarySize < kLZWDictSize ? kLZWDictSize : dictionarySize;
    // 编码字节数, 根据词典的大小(tableSize)决定
    unsigned int codeSize = size_in_bytes(tableSize);
    // 前缀缓冲区大小(动态分配)
    unsigned int prefixSize = kLZWCodeBase;
    // 前缀缓冲区
    unsigned char *prefix = malloc(prefixSize);
    memset(prefix, 0, prefixSize);
    // 前缀缓冲区当前长度
    unsigned int length = 0; // for prefix
    // 符号字节数
    unsigned int symbolSize = sizeof(unsigned char);
    // 符号缓冲区
    unsigned char symbol = 0;
    // 字典编码
    unsigned int code;
    unsigned int code_nbo = 0; // 网络字节序
    unsigned int output_len = 0;
    unsigned int i,j,k;
    // 初始化字典
    hashtable *table = hashtable_new(tableSize);
    for (k = 0; k < kLZWCodeBase; k++) {
        hashtable_set_node(table, &k, symbolSize, &k, codeSize);
    }
    // 开始处理数据
    for (i = 0; ; i++) {
        // 读入数据
        j = readBuffer ? readBuffer(&symbol, symbolSize, i) : 0;
        if (j == 0) {
            // 输出最后的编码
            if (length > 0) {
                if (writeBuffer) {
                    writeBuffer((unsigned char *)&code_nbo, codeSize);
                }
            }
            break;
        }
        // 扩展前缀缓冲区
        if (length + symbolSize >= prefixSize) {
            prefixSize *= 2;
            prefix = realloc(prefix, prefixSize);
        }
        // 复制符号到前缀缓冲区，组成新的前缀
        memcpy(&prefix[length++], &symbol, symbolSize);
        // 查找编码
        hashnode *node = hashtable_get_node(table, prefix, length);
        // 找到编码
        if (node) {
            code = 0;
            memcpy(&code, node->value->data, node->value->length);
            // 网络字节序
            code_nbo = 0;
            host_to_network_byte_order(&code_nbo, &code, codeSize);
        } else {
            // 输出编码
            if (writeBuffer) {
                writeBuffer((unsigned char *)&code_nbo, codeSize);
                output_len += codeSize;
            }
            // 没找到，加入词典
            if (table->used < table->size) {
                hashtable_set_node(table, prefix, length, &table->used, codeSize);
            } else {
                // 清空词典
                hashtable_free(table);
                table = hashtable_new(tableSize);
                for (k = 0; k < kLZWCodeBase; k++) {
                    hashtable_set_node(table, &k, symbolSize, &k, codeSize);
                }
            }
            // 重置前缀缓冲区
            memset(prefix, 0, prefixSize);
            // 复制符号到前缀缓冲区
            length = 0;
            memcpy(&prefix[length++], &symbol, symbolSize);
            // 网络字节序
            code = symbol;
            code_nbo = 0;
            host_to_network_byte_order(&code_nbo, &code, codeSize);
        }
    }
    // 释放资源
    hashtable_free(table);
    free(prefix);
    // 完成
    if (completion) {
        completion();
    }
}

+ (void)decompressUsingLZW:(const unsigned int)dictionarySize
                readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
               writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                completion:(void (^)(void))completion {
    // 调整词典大小
    unsigned int tableSize = dictionarySize < kLZWDictSize ? kLZWDictSize : dictionarySize;
    // 编码字节数, 根据词典的大小(tableSize)决定
    unsigned int codeSize = size_in_bytes(tableSize);
    // 前缀缓冲区大小(动态分配)
    unsigned int prefixSize = kLZWCodeBase;
    // 前缀缓冲区
    unsigned char *prefix = malloc(prefixSize);
    memset(prefix, 0, prefixSize);
    // 前缀缓冲区当前长度
    unsigned int length = 0; // for prefix
    // 字符字节数
    unsigned int symbolSize = sizeof(unsigned char);
    // 字典编码
    unsigned int code;
    unsigned int code_nbo = 0; // 网络字节序
    unsigned int output_len = 0;
    unsigned int i,j,k;
    bool reset = false;
    // 初始化字典
    hashtable * table = hashtable_new(tableSize);
    for (k = 0; k < kLZWCodeBase; k++) {
        hashtable_set_node(table, &k, codeSize, &k, symbolSize);
    }
    // 开始处理数据
    for (i = 0; ; i += codeSize) {
        // 读入数据
        code_nbo = 0;
        j = readBuffer ? readBuffer(&code_nbo, codeSize, i) : 0;
        if (j < codeSize) {
            break;
        }
        // 主机字节序
        code = 0;
        network_to_host_byte_order(&code, &code_nbo, codeSize);
        // 查找编码
        hashnode *node = hashtable_get_node(table, &code, codeSize);
        // 跳过第一个编码
        if (length > 0) {
            // 复制到前缀缓冲区
            if (node) {
                memcpy(&prefix[length++], node->value->data, symbolSize);
            } else {
                memcpy(&prefix[length++], &prefix[0], symbolSize);
            }
            // 加入词典
            if (table->used < table->size) {
                hashtable_set_node(table, &table->used, codeSize, prefix, length);
            } else {
                reset = true;
            }
            // 重新查找
            if (node == NULL) {
                node = hashtable_get_node(table, &code, codeSize);
            }
        }
        // 输出数据
        if (writeBuffer) {
            writeBuffer(node->value->data, node->value->length);
            output_len += node->value->length;
        }
        // 超出范围，清空词典
        if (reset) {
            reset = false;
            hashtable_free(table);
            table = hashtable_new(tableSize);
            for (k = 0; k < kLZWCodeBase; k++) {
                hashtable_set_node(table, &k, codeSize, &k, symbolSize);
            }
        }
        // 扩展前缀缓冲区
        if (node->value->length > prefixSize) {
            prefixSize = MAX(prefixSize * 2, node->value->length);
            prefix = realloc(prefix, prefixSize);
        }
        // 重置前缀缓冲区
        memset(prefix, 0, prefixSize);
        length = 0;
        // 复制到前缀缓冲区
        memcpy(&prefix[length], node->value->data, node->value->length);
        length += node->value->length;
    }
    // 释放资源
    hashtable_free(table);
    free(prefix);
    // 完成
    if (completion) {
        completion();
    }
}

@end

