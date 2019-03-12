//
// ZXCAlgorithm.c
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

#import "ZXCAlgorithm.h"

uint32_t size_in_bits(uint32_t size) {
    return log(size) / log(2);
}

uint32_t size_in_bytes(uint32_t size) {
    uint32_t bits = size_in_bits(size);
    uint32_t bytes = bits / 8;
    if (bits % 8 > 0) {
        bytes += 1;
    }
    return bytes;
}

bool host_byte_order(void) {
    unsigned char byte = (char)0xAABB;
    return byte == 0xBB; // 0xAA is Big Endian, 0xBB is Little Endian
}

void host_to_network_byte_order(void *target, void *source, int length) {
    if (host_byte_order()) {
        for (int i = 0; i < length; i++) {
            memcpy(&target[i], &source[length - i - 1], 1);
        }
    } else {
        for (int i = 0; i < length; i++) {
            memcpy(&target[i], &source[i], 1);
        }
    }
}

void network_to_host_byte_order(void *target, void *source, int length) {
    host_to_network_byte_order(target, source, length);
}

uint8_t matching_window_buffer(const uint8_t *window, const uint32_t windowSize, const uint8_t *buffer, const uint32_t bufferSize, uint32_t *offset, uint32_t *length) {
    // 初始化
    uint8_t symbol = buffer[0];
    *offset = 0;
    *length = 0;
    //
    for (uint32_t off = 1; off < windowSize; off++) {
        uint32_t win = off;
        uint32_t buf = 0;
        uint32_t len = 0;
        // 开始匹配
        while (win < windowSize && buf < bufferSize - 1) {
            // 不匹配, 中断
            if (window[win] != buffer[buf]) {
                break;
            }
            // 匹配, 继续
            win++;
            buf++;
            len++;
        }
        // 最长匹配
        if (len > *length) {
            *offset = off;
            *length = len;
            symbol = buffer[buf];
        }
    }
    return symbol;
}

