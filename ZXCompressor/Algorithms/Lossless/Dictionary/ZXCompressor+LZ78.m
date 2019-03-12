//
// ZXCompressor+LZ78.m
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

#import "ZXCompressor+LZ78.h"
#import "hashtable.h"

@implementation ZXCompressor (LZ78)

+ (void)compressUsingLZ78:(const uint32_t)tableSize
               readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
              writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
               completion:(void (^)(void))completion {
    // 编码字节数, 根据词典的大小(tableSize)决定
    uint32_t codeSize = size_in_bytes(tableSize);
    // 字符字节数
    uint32_t symbolSize = sizeof(uint8_t);
    // 短语字节数
    uint32_t phraseSize = codeSize + symbolSize;
    // 前缀字节数(预分配)
    uint32_t prefixSize = 2;
    // 前缀缓冲区+
    uint8_t *prefix = malloc(prefixSize);
    memset(prefix, 0, prefixSize);
    uint32_t length = 0; // for prefix
    // 符号缓冲区
    uint8_t *symbol = malloc(symbolSize);
    memset(symbol, 0, symbolSize);
    // 编码缓冲区
    uint8_t *phrase = malloc(phraseSize);
    memset(phrase, 0, phraseSize);
    // 初始化字典
    hashtable table = hashtable_new(tableSize);
    // 字典编码
    uint32_t code;
    uint32_t code_nbo = 0; // 网络字节序
    uint32_t code_next = 1; // 下个编码
    // 开始处理数据
    for (uint32_t offset = 0; ; offset++) {
        // 读入数据
        uint32_t read = readBuffer ? readBuffer(symbol, symbolSize, offset) : 0;
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
        memcpy(&prefix[length++], symbol, symbolSize);
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
            code_next = 1;
        }
        // 设置编码
        memcpy(&phrase[0], &code_nbo, codeSize);
        // 设置字符
        memcpy(&phrase[codeSize], symbol, symbolSize);
        // 重置编码
        code_nbo = 0;
        memset(prefix, 0, prefixSize);
        length = 0;
        // 复制短语到输出缓冲区
        if (writeBuffer) {
            writeBuffer(phrase, phraseSize);
        }
    }
    // 释放资源
    hashtable_free(table);
    free(phrase);
    free(symbol);
    free(prefix);
    // 完成
    if (completion) {
        completion();
    }
}

+ (void)decompressUsingLZ78:(const uint32_t)tableSize
                 readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
                writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                 completion:(void (^)(void))completion {
    // 编码字节数, 根据词典的大小(tableSize)决定
    uint32_t codeSize = size_in_bytes(tableSize);
    // 字符字节数
    uint8_t symbol = 0;
    uint32_t symbolSize = sizeof(symbol);
    // 短语编码区
    uint32_t phraseSize = codeSize + symbolSize;
    uint8_t *phrase = malloc(phraseSize);
    memset(phrase, 0, phraseSize);
    // 输出缓冲区
    uint32_t outputSize = 2;
    uint8_t *output = malloc(outputSize);
    memset(output, 0, outputSize);
    uint32_t length = 0; // for output
    // 初始化字典
    hashtable table = hashtable_new(tableSize);
    // 字典编码
    uint32_t code;
    uint32_t code_nbo = 0; // 网络字节序
    uint32_t code_next = 1; // 下个编码
    // 开始处理数据
    for (uint32_t offset = 0; ; offset += phraseSize) {
        // 读入数据
        uint32_t read = readBuffer ? readBuffer(phrase, phraseSize, offset) : 0;
        if (read < codeSize) {
            break;
        }
        // 解析编码
        code_nbo = 0;
        memcpy(&code_nbo, &phrase[0], codeSize);
        // 解析符号
        memcpy(&symbol, &phrase[codeSize], symbolSize);
        // 主机字节序
        code = 0;
        network_to_host_byte_order(&code, &code_nbo, codeSize);
        // 重置输出缓冲区
        memset(output, 0, outputSize);
        length = 0;
        // 查找编码
        if (code > 0) {
            hashnode node = hashtable_get_node(table, &code, codeSize);
            if (node) {
                // 复制到解码区
                memcpy(&output[length], node->value->data, node->value->length);
                length += node->value->length;
            }
        }
        // 扩展解码缓冲区
        if (length + symbolSize >= outputSize) {
            outputSize *= 2;
            output = realloc(output, outputSize);
        }
        // 复制字符
        if (read == phraseSize) {
            memcpy(&output[length++], &symbol, symbolSize);
        }
        // 加入词典
        if (table->used < tableSize) {
            hashtable_set_node(table, &code_next, codeSize, output, length);
            code_next++;
        } else {
            // 超出范围，清空词典
            hashtable_free(table);
            table = hashtable_new(tableSize);
            code_next = 1;
        }
        // 输出符号
        if (writeBuffer) {
            writeBuffer(output, length);
        }
        // 已完成
        if (read < phraseSize) {
            break;
        }
    }
    // 释放资源
    hashtable_free(table);
    free(output);
    free(phrase);
    // 完成
    if (completion) {
        completion();
    }
}

@end
