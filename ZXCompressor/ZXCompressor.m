//
// ZXCompressor.m
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
#import "ZXCompressor+LZ77.h"
#import "ZXCompressor+LZSS.h"
#import "ZXCompressor+LZ78.h"

@implementation ZXCompressor

#define kWindowSize(n)      (n < 4096 ? 256 : 4096)
#define kBufferSize(n)      (256)
#define kDictionarySize(n)  (256)

+ (void)compressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion {
    // 输入数据
    const uint8_t *input = data.bytes;
    uint32_t inputSize = (uint32_t)data.length;
    // 输出数据
    NSMutableData *output = [[NSMutableData alloc] init];
    // 按不同算法处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [ZXCompressor compressUsingLZ77:kWindowSize(inputSize)
                                 bufferSize:kBufferSize(inputSize)
                                 readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                                     uint32_t bufSize = MIN(length, inputSize - offset);
                                     memcpy(&buffer[0], &input[offset], bufSize);
                                     return bufSize;
                                 } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                                     [output appendBytes:buffer length:length];
                                 } completion:^{
#ifdef DEBUG
                                     NSLog(@"[LZ77] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)output.length, (output.length / (double)inputSize) * 100, (int)(inputSize - output.length));
#endif
                                     if (completion) {
                                         completion([output copy]);
                                     }
                                 }];
            break;
        }
        case kZXCAlgorithmLZSS:
        {
            [ZXCompressor compressUsingLZSS:kWindowSize(inputSize)
                                 bufferSize:kBufferSize(inputSize)
                                 readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                                     uint32_t bufSize = MIN(length, inputSize - offset);
                                     memcpy(&buffer[0], &input[offset], bufSize);
                                     return bufSize;
                                 } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                                     [output appendBytes:buffer length:length];
                                 } completion:^{
#ifdef DEBUG
                                     NSLog(@"[LZSS] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)output.length, (output.length / (double)inputSize) * 100, (int)(inputSize - output.length));
#endif
                                     if (completion) {
                                         completion([output copy]);
                                     }
                                 }];
            break;
        }
        case kZXCAlgorithmLZ78:
        {
            [ZXCompressor compressUsingLZ78:kDictionarySize(inputSize)
                                 readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                                     uint32_t bufSize = MIN(length, inputSize - offset);
                                     memcpy(&buffer[0], &input[offset], bufSize);
                                     return bufSize;
                                 } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                                     [output appendBytes:buffer length:length];
                                 } completion:^{
#ifdef DEBUG
                                     NSLog(@"[LZ78] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)output.length, (output.length / (double)inputSize) * 100, (int)(inputSize - output.length));
#endif
                                     if (completion) {
                                         completion([output copy]);
                                     }
                                 }];
            break;
        }
        default:
            break;
    }
}

+ (void)compressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion {
    // 错误信息
    NSError *error = nil;
    // 输入文件
    NSFileHandle *input = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:source] error:&error];
    uint32_t inputSize = (uint32_t)[input seekToEndOfFile];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    [input seekToFileOffset:0];
    // 输出文件
    [target writeToFile:target atomically:YES encoding:NSASCIIStringEncoding error:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    NSFileHandle *output = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:target] error:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    [output truncateFileAtOffset:0];
    // 开始处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [self compressUsingLZ77:kWindowSize(inputSize)
                         bufferSize:kBufferSize(inputSize)
                         readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                             uint32_t bufSize = MIN(length, inputSize - offset);
                             [input seekToFileOffset:offset];
                             NSData *data = [input readDataOfLength:bufSize];
                             memcpy(buffer, data.bytes, bufSize);
                             return bufSize;
                         } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             uint32_t outputSize = (uint32_t)[output seekToEndOfFile];
                             NSLog(@"[LZ77] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)outputSize, (outputSize / (double)inputSize) * 100, (int)(inputSize - outputSize));
#endif
                             [input closeFile];
                             [output closeFile];
                             //
                             if (completion) {
                                 completion(nil);
                             }
                         }];
            break;
        }
        case kZXCAlgorithmLZSS:
        {
            [self compressUsingLZSS:kWindowSize(inputSize)
                         bufferSize:kBufferSize(inputSize)
                         readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                             uint32_t bufSize = MIN(length, inputSize - offset);
                             [input seekToFileOffset:offset];
                             NSData *data = [input readDataOfLength:bufSize];
                             memcpy(buffer, data.bytes, bufSize);
                             return bufSize;
                         } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             uint32_t outputSize = (uint32_t)[output seekToEndOfFile];
                             NSLog(@"[LZSS] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)outputSize, (outputSize / (double)inputSize) * 100, (int)(inputSize - outputSize));
#endif
                             [input closeFile];
                             [output closeFile];
                             //
                             if (completion) {
                                 completion(nil);
                             }
                         }];
            break;
        }
        case kZXCAlgorithmLZ78:
        {
            [self compressUsingLZ78:kDictionarySize(inputSize)
                         readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                             uint32_t bufSize = MIN(length, inputSize - offset);
                             [input seekToFileOffset:offset];
                             NSData *data = [input readDataOfLength:bufSize];
                             memcpy(buffer, data.bytes, bufSize);
                             return bufSize;
                         } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             uint32_t outputSize = (uint32_t)[output seekToEndOfFile];
                             NSLog(@"[LZ78] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)outputSize, (outputSize / (double)inputSize) * 100, (int)(inputSize - outputSize));
#endif
                             [input closeFile];
                             [output closeFile];
                             //
                             if (completion) {
                                 completion(nil);
                             }
                         }];
            break;
        }
        default:
            break;
    }
}

+ (void)decompressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion {
    // 输入数据
    const uint8_t *input = data.bytes;
    uint32_t inputSize = (uint32_t)data.length;
    // 输出数据
    NSMutableData *output = [[NSMutableData alloc] init];
    // 开始处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [self decompressUsingLZ77:kWindowSize(inputSize)
                           bufferSize:kBufferSize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               memcpy(&buffer[0], &input[offset], bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output appendBytes:buffer length:length];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZ77] input: %d bytes, output: %d bytes", (int)inputSize, (int)output.length);
#endif
                               if (completion) {
                                   completion([output copy]);
                               }
                           }];
            break;
        }
        case kZXCAlgorithmLZSS:
        {
            [self decompressUsingLZSS:kWindowSize(inputSize)
                           bufferSize:kBufferSize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               memcpy(&buffer[0], &input[offset], bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output appendBytes:buffer length:length];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZSS] input: %d bytes, output: %d bytes", (int)inputSize, (int)output.length);
#endif
                               if (completion) {
                                   completion([output copy]);
                               }
                           }];
            break;
        }
        case kZXCAlgorithmLZ78:
        {
            [self decompressUsingLZ78:kDictionarySize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               memcpy(&buffer[0], &input[offset], bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output appendBytes:buffer length:length];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZ78] input: %d bytes, output: %d bytes", (int)inputSize, (int)output.length);
#endif
                               if (completion) {
                                   completion([output copy]);
                               }
                           }];
            break;
        }
        default:
            break;
    }
}

+ (void)decompressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion {
    // 错误信息
    NSError *error = nil;
    // 输入文件
    NSFileHandle *input = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:source] error:&error];
    uint32_t inputSize = (uint32_t)[input seekToEndOfFile];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    [input seekToFileOffset:0];
    // 输出文件
    [target writeToFile:target atomically:YES encoding:NSASCIIStringEncoding error:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    NSFileHandle *output = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:target] error:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    [output truncateFileAtOffset:0];
    // 开始处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [self decompressUsingLZ77:kWindowSize(inputSize)
                           bufferSize:kBufferSize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               [input seekToFileOffset:offset];
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               NSData *data = [input readDataOfLength:bufSize];
                               memcpy(buffer, data.bytes, bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output writeData:[NSData dataWithBytes:buffer length:length]];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZ77] input: %d bytes, output: %d bytes", (int)inputSize, (int)[output seekToEndOfFile]);
#endif
                               [input closeFile];
                               [output closeFile];
                               //
                               if (completion) {
                                   completion(nil);
                               }
                           }];
            break;
        }
        case kZXCAlgorithmLZSS:
        {
            [self decompressUsingLZSS:kWindowSize(inputSize)
                           bufferSize:kBufferSize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               [input seekToFileOffset:offset];
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               NSData *data = [input readDataOfLength:bufSize];
                               memcpy(buffer, data.bytes, bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output writeData:[NSData dataWithBytes:buffer length:length]];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZSS] input: %d bytes, output: %d bytes", (int)inputSize, (int)[output seekToEndOfFile]);
#endif
                               [input closeFile];
                               [output closeFile];
                               //
                               if (completion) {
                                   completion(nil);
                               }
                           }];
            break;
        }
        case kZXCAlgorithmLZ78:
        {
            [self decompressUsingLZ78:kDictionarySize(inputSize)
                           readBuffer:^const uint32_t(uint8_t *buffer, const uint32_t length, const uint32_t offset) {
                               [input seekToFileOffset:offset];
                               uint32_t bufSize = MIN(length, inputSize - offset);
                               NSData *data = [input readDataOfLength:bufSize];
                               memcpy(buffer, data.bytes, bufSize);
                               return bufSize;
                           } writeBuffer:^(const uint8_t *buffer, const uint32_t length) {
                               [output writeData:[NSData dataWithBytes:buffer length:length]];
                           } completion:^{
#ifdef DEBUG
                               NSLog(@"[LZ78] input: %d bytes, output: %d bytes", (int)inputSize, (int)[output seekToEndOfFile]);
#endif
                               [input closeFile];
                               [output closeFile];
                               //
                               if (completion) {
                                   completion(nil);
                               }
                           }];
            break;
        }
        default:
            break;
    }
}

@end


