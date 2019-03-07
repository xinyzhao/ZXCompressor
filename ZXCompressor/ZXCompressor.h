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

#import "ZXCAlgorithm.h"

/**
 ZXCompressor
 */
@interface ZXCompressor : NSObject

/**
 Compress data using specified algorithm

 @param data Uncompressed data
 @param algorithm Compression algorithm, see ZXCAlgorithm
 @param completion Callback when completed
 */
+ (void)compressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion;

/**
 Compress file using specified algorithm

 @param source Uncompressed source file
 @param target Compressed target file
 @param algorithm Compression algorithm, see ZXCAlgorithm
 @param completion Callback when completed
 */
+ (void)compressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion;

/**
 Decompress data using specified algorithm

 @param data Compressed data
 @param algorithm Compression algorithm, see ZXCAlgorithm
 @param completion Callback when completed
 */
+ (void)decompressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion;

/**
 Decompress file using specified algorithm

 @param source Compressed source file
 @param target Decompressed target file
 @param algorithm Compression algorithm, see ZXCAlgorithm
 @param completion Callback when completed
 */
+ (void)decompressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion;

@end
