//
// ZXCompressor.h
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
    kZXCAlgorithmLZ77,
    kZXCAlgorithmLZSS,
    
    kZXCAlgorithmLZ78,
    kZXCAlgorithmLZW,
    
    kZXCAlgorithmArithmeticCoding,
    kZXCAlgorithmHuffmanCoding,
    
    kZXCAlgorithmBWT,
    kZXCAlgorithmPPM,
    kZXCAlgorithmRLE,
    
} ZXCAlgorithm;

/**
 ZXCompressor
 
 注意：在读取和写入压缩数据时，注意大端(Big Endian)与小端(Little Endian)的问题，
 因为OSX/iOS系统和网络字节序一致，所以不用转换。
 */
@interface ZXCompressor : NSObject

+ (void)compressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion;

+ (void)compressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion;

+ (void)decompressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion;

+ (void)decompressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion;

@end
