//
// ZXCompressor+LZSS.m
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

#import "ZXCompressor+LZSS.h"
#import "ZXCompressor+LZ77.h"

@implementation ZXCompressor (LZSS)

+ (void)compressUsingLZSS:(const uint32_t)windowSize
               bufferSize:(const uint32_t)bufferSize
               readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
              writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
               completion:(void (^)(void))completion {
    // 标记字节数
    uint32_t flagsSize = sizeof(uint8_t);
    // 偏移字节数, 根据滑动窗口的大小(windowSize)决定
    uint32_t offsetSize = size_in_bytes(windowSize);
    // 长度字节数, 根据前向缓冲区的大小(bufferSize)决定
    uint32_t lengthSize = size_in_bytes(bufferSize);
    // 符号字节数
    uint32_t symbolSize = sizeof(uint8_t);
    // 短语字节数(编码后的字节数)
    uint32_t phraseSize = flagsSize + (offsetSize + lengthSize) * 8;
#ifdef DEBUG
    NSLog(@"[LZSS] offset/%d bytes, length/%d bytes", offsetSize, lengthSize);
#endif
    // 初始化滑动窗口+前向缓冲区+短语编码区
    uint8_t *window = malloc(windowSize);
    uint8_t *buffer = malloc(bufferSize);
    uint8_t *phrase = malloc(phraseSize);
    memset(window, 0, windowSize);
    memset(buffer, 0, bufferSize);
    memset(phrase, 0, phraseSize);
    // 开始处理数据
    uint8_t flags = 1;
    uint32_t offset, length;
    uint32_t phraseCursor = flagsSize;
    for (uint32_t cursor = 0; ;) {
        // 填充前向缓冲区
        uint32_t bufSize = readBuffer ? readBuffer(buffer, bufferSize, cursor) : 0;
        if (bufSize == 0) {
            // 输出最后不足8个的短语
            if (phraseCursor > 1) {
                if (writeBuffer) {
                    writeBuffer(phrase, phraseCursor);
                }
            }
            break;
        }
        // 查找短语
        uint32_t winCursor = windowSize > cursor ? windowSize - cursor : 0;
        uint32_t winSize = windowSize - winCursor;
        matching_window_buffer(&window[winCursor], winSize, buffer, bufSize, &offset, &length);
        // 设置短语数据
        if (length < offsetSize + lengthSize) {
            // 不用编码，复制符号
            length = symbolSize;
            memcpy(&phrase[phraseCursor], buffer, symbolSize);
            phraseCursor += symbolSize;
            // 设置短语标记
            phrase[0] |= flags;
        } else {
            // 转换偏移量相对于前向缓冲区反向
            offset = winSize - offset;
            // 设置偏移量
            memcpy(&phrase[phraseCursor], &offset, offsetSize);
            phraseCursor += offsetSize;
            // 设置长度
            memcpy(&phrase[phraseCursor], &length, lengthSize);
            phraseCursor += lengthSize;
        }
        // 复制短语到输出缓冲区
        if ((flags <<= 1) == 0) {
            if (writeBuffer) {
                writeBuffer(phrase, phraseCursor);
            }
            // 重置短语
            memset(phrase, 0, phraseSize);
            phraseCursor = flagsSize;
            flags = 1;
        }
        // 滑动窗口数据左移
        memmove(&window[0], &window[length], windowSize - length);
        // 从前向缓冲区中拷贝数据到滑动窗口中
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

+ (void)decompressUsingLZSS:(const uint32_t)windowSize
                 bufferSize:(const uint32_t)bufferSize
                 readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
                writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                 completion:(void (^)(void))completion {
    // 标记字节数
    uint32_t flagsSize = sizeof(uint8_t);
    // 偏移字节数, 根据滑动窗口的大小(windowSize)决定
    uint32_t offsetSize = size_in_bytes(windowSize);
    // 长度字节数, 根据前向缓冲区的大小(bufferSize)决定
    uint32_t lengthSize = size_in_bytes(bufferSize);
    // 符号字节数
    uint32_t symbolSize = sizeof(uint8_t);
    // 短语字节数(编码后的字节数)
    uint32_t phraseSize = flagsSize + (offsetSize + lengthSize) * 8;
#ifdef DEBUG
    NSLog(@"[LZSS] offset/%d bytes, length/%d bytes", offsetSize, lengthSize);
#endif
    // 初始化滑动窗口+前向缓冲区+短语编码区
    uint8_t *window = malloc(windowSize);
    uint8_t *buffer = malloc(bufferSize);
    uint8_t *phrase = malloc(phraseSize);
    memset(window, 0, windowSize);
    memset(buffer, 0, bufferSize);
    memset(phrase, 0, phraseSize);
    // 开始处理数据
    uint16_t flags;
    uint32_t offset, length;
    uint32_t phraseCursor, phraseLength;
    for (uint32_t cursor = 0; ; ) {
        // 复制短语
        phraseLength = readBuffer ? readBuffer(phrase, phraseSize, cursor) : 0;
        if (phraseLength < 1) {
            break;
        }
        // 短语游标
        phraseCursor = 0;
        // 复制短语标记
        flags = 0;
        memcpy(&flags, &phrase[phraseCursor], flagsSize);
        phraseCursor += flagsSize;
        // uses higher byte cleverly  to count eight
        flags |= 0xff00;
        // 解析短语
        while (phraseCursor < phraseLength) {
            // 解析短语数据
            if (flags & 1) {
                memcpy(buffer, &phrase[phraseCursor], symbolSize);
                phraseCursor += symbolSize;
                length = symbolSize;
            } else {
                // 偏移
                offset = 0;
                memcpy(&offset, &phrase[phraseCursor], offsetSize);
                phraseCursor += offsetSize;
                // 长度
                length = 0;
                memcpy(&length, &phrase[phraseCursor], lengthSize);
                phraseCursor += lengthSize;
                // 转换偏移量相对于滑动窗口正向
                offset = windowSize - offset;
                // 从滑动窗口复制数据到缓冲区
                memcpy(buffer, &window[offset], length);
            }
            // 滑动窗口数据左移
            memmove(&window[0], &window[length], windowSize - length);
            // 复制前向缓冲区数据到滑动窗口
            memmove(&window[windowSize - length], &buffer[0], length);
            // 输出数据
            if (writeBuffer) {
                writeBuffer(buffer, length);
            }
            // 更新短语标记
            if (((flags >>= 1) & 256) == 0) {
                break;
            }
        }
        // 更新数据游标
        cursor += phraseCursor;
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
