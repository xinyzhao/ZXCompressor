//
//  ZXCAlgorithm.c
//  ZXCompressorDemo
//
//  Created by xyz on 2019/3/7.
//  Copyright © 2019 xyz. All rights reserved.
//

#include "ZXCAlgorithm.h"

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
