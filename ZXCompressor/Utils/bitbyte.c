//
//  bitbyte.c
//  ZXCompressorDemo
//
//  Created by xyz on 2019/3/19.
//  Copyright © 2019 xyz. All rights reserved.
//

#include "bitbyte.h"

int bit_get(const uint8_t *bits, int pos) {
    unsigned char mask = 0x80;
    for (int i = 0; i < (pos % 8); i++) {
        mask = mask >> 1;
    }
    return (((mask & bits[(int)(pos / 8)]) == mask) ? 1 : 0);
}

void bit_set(uint8_t *bits, int pos, int state) {
    unsigned char mask = 0x80;
    for (int i = 0; i < (pos % 8); i++) {
        mask = mask >> 1;
    }
    if (state) {
        bits[pos/8] = bits[pos/8] | mask;
    } else {
        bits[pos/8] = bits[pos/8] & (~mask);
    }
    return;
}

int size_in_bits(uint32_t size) {
    return log(size) / log(2);
}

int size_in_bytes(uint32_t size) {
    int bits = size_in_bits(size);
    int bytes = bits / 8;
    if (bits % 8 > 0) {
        bytes += 1;
    }
    return bytes;
}

int host_byte_order(void) {
    unsigned char byte = (char)0xAABB;
    return byte == 0xBB; // 0xAA is Big Endian, 0xBB is Little Endian
}

void host_to_network_byte_order(void *target, void *source, uint32_t length) {
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

void network_to_host_byte_order(void *target, void *source, uint32_t length) {
    host_to_network_byte_order(target, source, length);
}

char search_bytes(const uint8_t *buffer, const uint32_t buffer_len, const uint8_t *bytes, const uint32_t bytes_len, uint32_t *offset, uint32_t *length) {
    // 初始化
    char byte = bytes[0];
    *offset = 0;
    *length = 0;
    //
    int i,j,k,l;
    for (i = 1; i < buffer_len; i++) {
        j = i;
        k = 0;
        l = 0;
        // 开始匹配
        while (j < buffer_len && k < bytes_len - 1) {
            // 不匹配, 中断
            if (buffer[j] != bytes[k]) {
                break;
            }
            // 匹配, 继续
            j++;
            k++;
            l++;
        }
        // 最长匹配
        if (l > *length) {
            *offset = i;
            *length = l;
            byte = bytes[k];
        }
    }
    return byte;
}
