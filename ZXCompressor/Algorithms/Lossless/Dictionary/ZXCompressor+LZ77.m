//
// ZXCompressor+LZ77.m
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

#import "ZXCompressor+LZ77.h"
#import "bitbyte.h"

@implementation ZXCompressor (LZ77)

+ (void)compressUsingLZ77:(const unsigned int)windowSize
               bufferSize:(const unsigned int)bufferSize
               readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
              writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
               completion:(void (^)(void))completion {
    // 偏移字节数, 根据滑动窗口的大小(windowSize)决定
    unsigned int offsetSize = size_in_bytes(windowSize);
    // 长度字节数, 根据前向缓冲区的大小(bufferSize)决定
    unsigned int lengthSize = size_in_bytes(bufferSize);
    // 符号字节数
    unsigned int symbolSize = sizeof(unsigned char);
    // 短语字节数(编码后的字节数)
    unsigned int phraseSize = offsetSize + lengthSize + symbolSize;
    // 初始化滑动窗口+前向缓冲区+短语编码区
    unsigned char *window = malloc(windowSize);
    unsigned char *buffer = malloc(bufferSize);
    unsigned char *phrase = malloc(phraseSize);
    memset(window, 0, windowSize);
    memset(buffer, 0, bufferSize);
    memset(phrase, 0, phraseSize);
    // 开始处理数据
    unsigned char symbol;
    unsigned int offset, length;
    unsigned int offset_n, length_n; // 网络字节序
    for (unsigned int cursor = 0; ; ) {
        // 填充前向缓冲区
        unsigned int bufSize = readBuffer ? readBuffer(buffer, bufferSize, cursor) : 0;
        if (bufSize == 0) {
            break;
        }
        // 查找短语
        offset = windowSize > cursor ? windowSize - cursor : 0;
        unsigned int winSize = windowSize - offset;
        symbol = search_bytes(&window[offset], winSize, buffer, bufSize, &offset, &length);
        // 转换偏移量相对于前向缓冲区反向
        if (length > 0) {
            offset = winSize - offset;
        }
        // 网络字节序
        offset_n = length_n = 0;
        host_to_network_byte_order(&offset_n, &offset, offsetSize);
        host_to_network_byte_order(&length_n, &length, lengthSize);
        // 设置偏移量
        memcpy(&phrase[0], &offset_n, offsetSize);
        // 设置长度
        memcpy(&phrase[offsetSize], &length_n, lengthSize);
        // 设置符号
        memcpy(&phrase[offsetSize + lengthSize], &symbol, symbolSize);
        // 复制短语到输出缓冲区
        if (writeBuffer) {
            writeBuffer(phrase, phraseSize);
        }
        // 标记长度加上符号的长度
        length += symbolSize;
        // 滑动窗口数据左移
        memmove(&window[0], &window[length], windowSize - length);
        // 复制前向缓冲区数据到滑动窗口
        memmove(&window[windowSize - length], &buffer[0], length);
        // 更新数据指针位置
        cursor += length;
    }
    // 释放资源
    free(phrase);
    free(buffer);
    free(window);
    // 完成
    if (completion) {
        completion();
    }
}

+ (void)decompressUsingLZ77:(const unsigned int)windowSize
                 bufferSize:(const unsigned int)bufferSize
                 readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
                writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                 completion:(void (^)(void))completion {
    // 偏移字节数, 根据滑动窗口的大小(windowSize)决定
    unsigned int offsetSize = size_in_bytes(windowSize);
    // 长度字节数, 根据前向缓冲区的大小(bufferSize)决定
    unsigned int lengthSize = size_in_bytes(bufferSize);
    // 符号字节数
    unsigned int symbolSize = sizeof(unsigned char);
    // 短语字节数(编码后的字节数)
    unsigned int phraseSize = offsetSize + lengthSize + symbolSize;
    // 初始化滑动窗口+前向缓冲区+短语编码区
    unsigned char *window = malloc(windowSize);
    unsigned char *buffer = malloc(bufferSize);
    unsigned char *phrase = malloc(phraseSize);
    memset(window, 0, windowSize);
    memset(buffer, 0, bufferSize);
    memset(phrase, 0, phraseSize);
    // 开始处理数据
    unsigned char symbol;
    unsigned int offset, length;
    unsigned int offset_n, length_n; // 网络字节序
    for (unsigned int cursor = 0; ; cursor += phraseSize) {
        // 读取短语
        unsigned int bufSize = readBuffer ? readBuffer(phrase, phraseSize, cursor) : 0;
        if (bufSize != phraseSize) {
            break;
        }
        // 重置
        symbol = 0;
        offset = length = 0;
        offset_n = length_n = 0;
        // 解析短语
        memcpy(&offset_n, &phrase[0], offsetSize);
        memcpy(&length_n, &phrase[offsetSize], lengthSize);
        memcpy(&symbol, &phrase[offsetSize + lengthSize], symbolSize);
        // 主机字节序
        network_to_host_byte_order(&offset, &offset_n, offsetSize);
        network_to_host_byte_order(&length, &length_n, lengthSize);
        // 复制短语到缓冲区
        memset(buffer, 0, bufferSize);
        if (length > 0) {
            // 转换偏移量相对于滑动窗口正向
            offset = windowSize - offset;
            // 复制短语数据到缓冲区
            memcpy(buffer, &window[offset], length);
        }
        // 复制符号到缓冲区
        memcpy(&buffer[length], &symbol, symbolSize);
        // 输出长度=标记长度+符号长度
        length += symbolSize;
        // 滑动窗口数据左移
        memmove(&window[0], &window[length], windowSize - length);
        // 复制前向缓冲区数据到滑动窗口
        memmove(&window[windowSize - length], &buffer[0], length);
        // 输出数据
        if (writeBuffer) {
            writeBuffer(buffer, length);
        }
    }
    // 释放资源
    free(phrase);
    free(buffer);
    free(window);
    // 完成
    if (completion) {
        completion();
    }
}

@end
