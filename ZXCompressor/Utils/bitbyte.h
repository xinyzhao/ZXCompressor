//
// bitbyte.h
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

#ifndef bitbyte_h
#define bitbyte_h

#include <math.h>
#include <string.h>

/**
 Convert bits to (8-bit) bytes

 @param bits Number of bits
 @return Number of bytes
 */
#define BITS_TO_BYTES(bits) (bits / 8 + (bits % 8 ? 1 : 0))

/**
 Convert (8-bit) bytes to bits

 @param bytes Number of bytes
 @return Number of bits
 */
#define BYTES_TO_BITS(bytes) (bytes * 8)

/**
 获取指定二进制位的值
 
 @param bits 指针
 @param pos 位置
 @return 状态值，0 或 1
 */
extern int bit_get(const unsigned char *bits, int pos);

/**
 设置指定二进制位的值
 
 @param bits 指针
 @param pos 位置
 @param state 状态值，0 或 1
 */
extern void bit_set(unsigned char *bits, int pos, int state);

/**
 需要多少二进制位(bits)才能表示指定的大小(Size)
 
 @param size 指定的大小(bytes)
 @return 二进制位数
 */
extern int size_in_bits(unsigned int size);

/**
 需要多少字节(bytes)才能表示指定的大小(Size)
 
 @param size 指定的大小(bytes)
 @return 字节数量
 */
extern int size_in_bytes(unsigned int size);

/**
 获取主机字节序
 
 @return ture 为小端字节序(Little Endian), false 为大端字节序(Big Ending)
 */
extern int host_byte_order(void);

/**
 主机字节序转换为网络字节序
 
 @param target 主机字节
 @param source 网络字节
 @param length 字节长度
 */
extern void host_to_network_byte_order(void *target, void *source, unsigned int length);

/**
 网络字节序转换为主机字节序
 
 @param target 主机字节
 @param source 网络字节
 @param length 字节长度
 */
extern void network_to_host_byte_order(void *target, void *source, unsigned int length);

/**
 在缓冲区(buffer)中搜索与字节流(bytes)最长的匹配(longest match)
 
 @param buffer 缓冲区
 @param buffer_len 缓冲区长度
 @param bytes 字节流
 @param bytes_len 字节流长度
 @param offset 搜索成功后，在缓冲区中的偏移量
 @param length 搜索成功后，最大匹配长度，否则为0
 @return 返回下一个未匹配的字节
 */
extern char search_bytes(const unsigned char *buffer, const unsigned int buffer_len, const unsigned char *bytes, const unsigned int bytes_len, unsigned int *offset, unsigned int *length);

#endif /* bitbyte_h */
