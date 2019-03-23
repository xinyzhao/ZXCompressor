//
//  bitbyte.c
//  ZXCompressorDemo
//
//  Created by xyz on 2019/3/19.
//  Copyright © 2019 xyz. All rights reserved.
//

#include "bitbyte.h"

int bit_get(const unsigned char *bits, int pos) {
    unsigned char mask = 0x80;
    for (int i = 0; i < (pos % 8); i++) {
        mask = mask >> 1;
    }
    return (((mask & bits[(int)(pos / 8)]) == mask) ? 1 : 0);
}

void bit_set(unsigned char *bits, int pos, int state) {
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

int size_in_bits(unsigned int size) {
    return log(size) / log(2);
}

int size_in_bytes(unsigned int size) {
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

void host_to_network_byte_order(void *target, const void *source, unsigned int length) {
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

void network_to_host_byte_order(void *target, const void *source, unsigned int length) {
    host_to_network_byte_order(target, source, length);
}

char search_bytes(const unsigned char *buffer, const unsigned int buffer_len, const unsigned char *bytes, const unsigned int bytes_len, unsigned int *offset, unsigned int *length) {
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
