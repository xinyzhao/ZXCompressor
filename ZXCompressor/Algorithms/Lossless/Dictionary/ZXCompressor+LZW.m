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
#import "hashtable.h"

@implementation ZXCompressor (LZW)

#define LZW_CODE_BASE    256
#define LZW_DICT_SIZE    4096

+ (void)compressUsingLZW:(const uint32_t)dictionarySize
              readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
             writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
              completion:(void (^)(void))completion {
    // 调整词典大小
    uint32_t tableSize = dictionarySize < LZW_DICT_SIZE ? LZW_DICT_SIZE : dictionarySize;
    // 编码字节数, 根据词典的大小(tableSize)决定
    uint32_t codeSize = size_in_bytes(tableSize);
    // 符号字节数
    uint32_t symbolSize = sizeof(uint8_t);
    // 前缀缓冲区大小(动态分配)
    uint32_t prefixSize = 2;
    // 符号缓冲区
    uint8_t symbol = 0;
    // 前缀缓冲区
    uint8_t *prefix = malloc(prefixSize);
    memset(prefix, 0, prefixSize);
    // 前缀缓冲区当前长度
    uint32_t length = 0; // for prefix
    // 初始化字典
    hashtable table = hashtable_new(tableSize);
    for (uint32_t c = 0; c < LZW_CODE_BASE; c++) {
        hashtable_set_node(table, &c, symbolSize, &c, codeSize);
    }
    // 字典编码
    uint32_t code;
    uint32_t code_nbo = 0; // 网络字节序
    uint32_t code_next = LZW_CODE_BASE; // 下个编码
    // 开始处理数据
    for (uint32_t offset = 0; ; offset++) {
        // 读入数据
        uint32_t read = readBuffer ? readBuffer(&symbol, symbolSize, offset) : 0;
        if (read == 0) {
            // 输出最后的编码
            if (length > 0) {
                if (writeBuffer) {
                    writeBuffer((uint8_t *)&code_nbo, codeSize);
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
        code = 0;
        hashnode node = hashtable_get_node(table, prefix, length);
        if (node) {
            memcpy(&code, node->value->data, node->value->length);
        }
        // 找到编码
        if (code > 0) {
            // 网络字节序
            code_nbo = 0;
            host_to_network_byte_order(&code_nbo, &code, codeSize);
            // 查找最长匹配
            continue;
        } else if (table->used < table->size) {
            // 没找到，加入词典
            hashtable_set_node(table, prefix, length, &code_next, codeSize);
            code_next++;
        } else {
            // 超出范围，清空词典
            hashtable_free(table);
            table = hashtable_new(tableSize);
            for (uint32_t c = 0; c < LZW_CODE_BASE; c++) {
                hashtable_set_node(table, &c, symbolSize, &c, codeSize);
            }
            code_next = LZW_CODE_BASE;
        }
        // 输出编码
        if (writeBuffer) {
            writeBuffer((uint8_t *)&code_nbo, codeSize);
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
    // 释放资源
    hashtable_free(table);
    free(prefix);
    // 完成
    if (completion) {
        completion();
    }
}

+ (void)decompressUsingLZW:(const uint32_t)dictionarySize
                readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
               writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                completion:(void (^)(void))completion {
    // 调整词典大小
    uint32_t tableSize = dictionarySize < LZW_DICT_SIZE ? LZW_DICT_SIZE : dictionarySize;
    // 编码字节数, 根据词典的大小(tableSize)决定
    uint32_t codeSize = size_in_bytes(tableSize);
    // 前缀缓冲区大小(动态分配)
    uint32_t prefixSize = 2;
    // 前缀缓冲区
    uint8_t *prefix = malloc(prefixSize);
    memset(prefix, 0, prefixSize);
    // 前缀缓冲区当前长度
    uint32_t length = 0; // for prefix
    // 初始化字典
    hashtable table = hashtable_new(tableSize);
    for (uint32_t c = 0; c < LZW_CODE_BASE; c++) {
        hashtable_set_node(table, &c, codeSize, &c, 1);
    }
    // 字典编码
    uint32_t code;
    uint32_t code_nbo = 0; // 网络字节序
    uint32_t code_next = LZW_CODE_BASE; // 下个编码
    // 开始处理数据
    for (uint32_t offset = 0; ; offset += codeSize) {
        // 读入数据
        code_nbo = 0;
        uint32_t read = readBuffer ? readBuffer((uint8_t *)&code_nbo, codeSize, offset) : 0;
        if (read < codeSize) {
            break;
        }
        // 主机字节序
        code = 0;
        network_to_host_byte_order(&code, &code_nbo, codeSize);
        // 查找编码
        hashnode node = hashtable_get_node(table, &code, codeSize);
        // 跳过Root(第一个)编码
        if (length > 0) {
            // 扩展前缀缓冲区
            if (length + 1 > prefixSize) {
                prefixSize *= 2;
                prefix = realloc(prefix, prefixSize);
            }
            // 复制到前缀缓冲区
            if (node) {
                memcpy(&prefix[length++], node->value->data, 1);
            } else {
                memcpy(&prefix[length++], &prefix[0], 1);
            }
            // 加入词典
            if (table->used < table->size) {
                hashtable_set_node(table, &code_next, codeSize, prefix, length);
                code_next++;
            } else {
                // 超出范围，清空词典
                hashtable_free(table);
                table = hashtable_new(tableSize);
                for (uint32_t c = 0; c < LZW_CODE_BASE; c++) {
                    hashtable_set_node(table, &c, codeSize, &c, 1);
                }
                code_next = LZW_CODE_BASE;
            }
        }
        // 重新查找
        if (node == NULL) {
            node = hashtable_get_node(table, &code, codeSize);
            assert(node);
        }
        // 扩展前缀缓冲区
        if (node->value->length > prefixSize) {
            prefixSize = MAX(prefixSize * 2, node->value->length + node->value->length % 2);
            prefix = realloc(prefix, prefixSize);
        }
        // 重置前缀缓冲区
        memset(prefix, 0, prefixSize);
        length = 0;
        // 复制到前缀缓冲区
        memcpy(&prefix[length], node->value->data, node->value->length);
        length += node->value->length;
        // 输出数据
        if (writeBuffer) {
            writeBuffer(node->value->data, node->value->length);
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

@end

