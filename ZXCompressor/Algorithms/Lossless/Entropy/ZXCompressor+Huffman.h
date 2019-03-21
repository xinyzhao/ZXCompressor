//
// ZXCompressor+Huffman.h
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

#import "ZXCompressor.h"

@interface ZXCompressor (Huffman)

/**
 Compress the data/file using by Huffman coding algorithm
 
 @param bufferSize The input buffer size
 @param inputSize The input data/file size
 @param readBuffer The input block, start at 'offset' in the input data, read 'length'(max) bytes to 'buffer'
 @param writeBuffer The output block
 @param completion The completion block
 */
+ (void)compressUsingHuffman:(const unsigned int)bufferSize
                   inputSize:(const unsigned int)inputSize
                  readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
                 writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                  completion:(void (^)(void))completion;

/**
 Decompress the data/file using by Huffman coding algorithm
 
 @param bufferSize The input buffer size
 @param readBuffer The input block, start at 'offset' in the input data, read 'length'(max) bytes to 'buffer'
 @param writeBuffer The output block,
 @param completion The completion block
 */
+ (void)decompressUsingHuffman:(const unsigned int)bufferSize
                    readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
                   writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                    completion:(void (^)(void))completion;

@end
