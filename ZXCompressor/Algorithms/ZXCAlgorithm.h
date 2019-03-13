//
// ZXCAlgorithm.h
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

#import <Foundation/Foundation.h>

/* ZXCAlgorithm */
typedef enum {
    kZXCAlgorithmLZ77 = 0, // Lempel–Ziv 1977
    kZXCAlgorithmLZSS, // Lempel–Ziv–Storer–Szymanski
    
    kZXCAlgorithmLZ78, // Lempel–Ziv 1978
    kZXCAlgorithmLZW, // Lempel–Ziv–Welch
    
    kZXCAlgorithmArithmetic, // Arithmetic coding
    kZXCAlgorithmHuffman, // Huffman coding
    
    kZXCAlgorithmBWT, // Burrows–Wheeler transform
    kZXCAlgorithmPPM, // Prediction by partial matching
    kZXCAlgorithmRLE, // Run-length encoding
    
} ZXCAlgorithm;

/**
 需要多少二进制位(bits)才能表示指定的大小(Size)
 
 @param size 指定的大小(bytes)
 @return 二进制位数
 */
extern uint32_t size_in_bits(uint32_t size);

/**
 需要多少字节(bytes)才能表示指定的大小(Size)
 
 @param size 指定的大小(bytes)
 @return 字节数量
 */
extern uint32_t size_in_bytes(uint32_t size);

/**
 获取主机字节序

 @return ture 为小端字节序(Little Endian), false 为大端字节序(Big Ending)
 */
extern bool host_byte_order(void);

/**
 主机字节序转换为网络字节序
 
 @param target 主机字节
 @param source 网络字节
 @param length 字节长度
 */
extern void host_to_network_byte_order(void *target, void *source, int length);

/**
 网络字节序转换为主机字节序
 
 @param target 主机字节
 @param source 网络字节
 @param length 字节长度
 */
extern void network_to_host_byte_order(void *target, void *source, int length);

/**
 匹配符号(前向缓冲区)和短语(滑动窗口)
 
 @param window 滑动窗口
 @param windowSize 滑动窗口大小
 @param buffer 前向缓冲区
 @param bufferSize 前向缓冲区大小
 @param offset 匹配成功后, 短语在滑动窗口中的偏移量, 否则为0
 @param length 匹配成功后, 短语的长度
 @return 返回下一个未匹配的符号
 */
extern uint8_t matching_window_buffer(const uint8_t *window, const uint32_t windowSize, const uint8_t *buffer, const uint32_t bufferSize, uint32_t *offset, uint32_t *length);

