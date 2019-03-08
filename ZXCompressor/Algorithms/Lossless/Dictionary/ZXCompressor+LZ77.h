//
// ZXCompressor+LZ77.h
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

/**
 ZXCompressor (LZ77)
 */
@interface ZXCompressor (LZ77)

/**
 Compress the data/file using by LZ77 algorithm

 @param windowSize The sliding window size
 @param bufferSize The lookAheadBuffer size
 @param readBuffer The input block
 @param writeBuffer The output block
 @param completion The completion block
 */
+ (void)compressUsingLZ77:(const uint32_t)windowSize
               bufferSize:(const uint32_t)bufferSize
               readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
              writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
               completion:(void (^)(void))completion;

/**
 Decompress the data/file using by LZ77 algorithm
 
 @param windowSize The sliding window size
 @param bufferSize The lookAheadBuffer size
 @param readBuffer The input block
 @param writeBuffer The output block
 @param completion The completion block
 */
+ (void)decompressUsingLZ77:(const uint32_t)windowSize
                 bufferSize:(const uint32_t)bufferSize
                 readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
                writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                 completion:(void (^)(void))completion;

@end
