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
#import "ZXCompressor+LZW.h"
#import "ZXCompressor+Huffman.h"

@implementation ZXCompressor

#define LZ77_WINDOW_SIZE        256
#define LZ77_BUFFER_SIZE        256
#define LZSS_WINDOW_SIZE        4096
#define LZSS_BUFFER_SIZE        256
#define LZ78_DICT_SIZE          65536
#define LZW_DICT_SIZE           65536
#define HUFFMAN_BUFFER_SIZE     4096

+ (void)compressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion {
    // 输入数据
    const unsigned char *input = data.bytes;
    unsigned int inputSize = (unsigned int)data.length;
    // 输出数据
    NSMutableData *output = [[NSMutableData alloc] init];
    // 按不同算法处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [ZXCompressor compressUsingLZ77:LZ77_WINDOW_SIZE
                                 bufferSize:LZ77_BUFFER_SIZE
                                 readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                     unsigned int bufSize = MIN(length, inputSize - offset);
                                     if (bufSize > 0) {
                                         memcpy(&buffer[0], &input[offset], bufSize);
                                     }
                                     return bufSize;
                                 } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [ZXCompressor compressUsingLZSS:LZSS_WINDOW_SIZE
                                 bufferSize:LZSS_BUFFER_SIZE
                                 readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                     unsigned int bufSize = MIN(length, inputSize - offset);
                                     if (bufSize > 0) {
                                         memcpy(&buffer[0], &input[offset], bufSize);
                                     }
                                     return bufSize;
                                 } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [ZXCompressor compressUsingLZ78:LZ78_DICT_SIZE
                                 readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                     unsigned int bufSize = MIN(length, inputSize - offset);
                                     if (bufSize > 0) {
                                         memcpy(&buffer[0], &input[offset], bufSize);
                                     }
                                     return bufSize;
                                 } writeBuffer:^(const void *buffer, const unsigned int length) {
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
        case kZXCAlgorithmLZW:
        {
            [ZXCompressor compressUsingLZW:LZW_DICT_SIZE
                                readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                    unsigned int bufSize = MIN(length, inputSize - offset);
                                    if (bufSize > 0) {
                                        memcpy(&buffer[0], &input[offset], bufSize);
                                    }
                                    return bufSize;
                                } writeBuffer:^(const void *buffer, const unsigned int length) {
                                    [output appendBytes:buffer length:length];
                                } completion:^{
#ifdef DEBUG
                                    NSLog(@"[LZW] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)output.length, (output.length / (double)inputSize) * 100, (int)(inputSize - output.length));
#endif
                                    if (completion) {
                                        completion([output copy]);
                                    }
                                }];
            break;
        }
        case kZXCAlgorithmHuffman:
        {
            [ZXCompressor compressUsingHuffman:HUFFMAN_BUFFER_SIZE
                                     inputSize:inputSize
                                    readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                        unsigned int bufSize = MIN(length, inputSize - offset);
                                        if (bufSize > 0) {
                                            memcpy(&buffer[0], &input[offset], bufSize);
                                        }
                                        return bufSize;
                                    } writeBuffer:^(const void *buffer, const unsigned int length) {
                                        [output appendBytes:buffer length:length];
                                    } completion:^{
#ifdef DEBUG
                                        NSLog(@"[Huffman] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)output.length, (output.length / (double)inputSize) * 100, (int)(inputSize - output.length));
#endif
                                        if (completion) {
                                            completion([output copy]);
                                        }
                                    }];
            break;
        }
        default:
            NSLog(@"%s unsupported algorithm %d", __func__, algorithm);
            break;
    }
}

+ (void)compressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion {
    // 错误信息
    NSError *error = nil;
    // 输入文件
    NSFileHandle *input = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:source] error:&error];
    unsigned int inputSize = (unsigned int)[input seekToEndOfFile];
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
            [self compressUsingLZ77:LZ77_WINDOW_SIZE
                         bufferSize:LZ77_BUFFER_SIZE
                         readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                             unsigned int bufSize = MIN(length, inputSize - offset);
                             if (bufSize > 0) {
                                 [input seekToFileOffset:offset];
                                 NSData *data = [input readDataOfLength:bufSize];
                                 memcpy(buffer, data.bytes, bufSize);
                             }
                             return bufSize;
                         } writeBuffer:^(const void *buffer, const unsigned int length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             unsigned int outputSize = (unsigned int)[output seekToEndOfFile];
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
            [self compressUsingLZSS:LZ77_WINDOW_SIZE
                         bufferSize:LZ77_BUFFER_SIZE
                         readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                             unsigned int bufSize = MIN(length, inputSize - offset);
                             if (bufSize > 0) {
                                 [input seekToFileOffset:offset];
                                 NSData *data = [input readDataOfLength:bufSize];
                                 memcpy(buffer, data.bytes, bufSize);
                             }
                             return bufSize;
                         } writeBuffer:^(const void *buffer, const unsigned int length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             unsigned int outputSize = (unsigned int)[output seekToEndOfFile];
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
            [self compressUsingLZ78:LZ78_DICT_SIZE
                         readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                             unsigned int bufSize = MIN(length, inputSize - offset);
                             if (bufSize > 0) {
                                 [input seekToFileOffset:offset];
                                 NSData *data = [input readDataOfLength:bufSize];
                                 memcpy(buffer, data.bytes, bufSize);
                             }
                             return bufSize;
                         } writeBuffer:^(const void *buffer, const unsigned int length) {
                             [output writeData:[NSData dataWithBytes:buffer length:length]];
                         } completion:^{
#ifdef DEBUG
                             unsigned int outputSize = (unsigned int)[output seekToEndOfFile];
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
        case kZXCAlgorithmLZW:
        {
            [self compressUsingLZW:LZW_DICT_SIZE
                        readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                            unsigned int bufSize = MIN(length, inputSize - offset);
                            if (bufSize > 0) {
                                [input seekToFileOffset:offset];
                                NSData *data = [input readDataOfLength:bufSize];
                                memcpy(buffer, data.bytes, bufSize);
                            }
                            return bufSize;
                        } writeBuffer:^(const void *buffer, const unsigned int length) {
                            [output writeData:[NSData dataWithBytes:buffer length:length]];
                        } completion:^{
#ifdef DEBUG
                            unsigned int outputSize = (unsigned int)[output seekToEndOfFile];
                            NSLog(@"[LZW] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)outputSize, (outputSize / (double)inputSize) * 100, (int)(inputSize - outputSize));
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
        case kZXCAlgorithmHuffman:
        {
            [self compressUsingHuffman:HUFFMAN_BUFFER_SIZE
                             inputSize:inputSize
                            readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                unsigned int bufSize = MIN(length, inputSize - offset);
                                if (bufSize > 0) {
                                    [input seekToFileOffset:offset];
                                    NSData *data = [input readDataOfLength:bufSize];
                                    memcpy(buffer, data.bytes, bufSize);
                                }
                                return bufSize;
                            } writeBuffer:^(const void *buffer, const unsigned int length) {
                                [output writeData:[NSData dataWithBytes:buffer length:length]];
                            } completion:^{
#ifdef DEBUG
                                unsigned int outputSize = (unsigned int)[output seekToEndOfFile];
                                NSLog(@"[Huffman] input: %d bytes, output: %d bytes, compression ratio %.f%%, saving %d bytes", (int)inputSize, (int)outputSize, (outputSize / (double)inputSize) * 100, (int)(inputSize - outputSize));
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
            NSLog(@"%s unsupported algorithm %d", __func__, algorithm);
            break;
    }
}

+ (void)decompressData:(NSData *)data usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSData *data))completion {
    // 输入数据
    const unsigned char *input = data.bytes;
    unsigned int inputSize = (unsigned int)data.length;
    // 输出数据
    NSMutableData *output = [[NSMutableData alloc] init];
    // 开始处理数据
    switch (algorithm) {
        case kZXCAlgorithmLZ77:
        {
            [self decompressUsingLZ77:LZ77_WINDOW_SIZE
                           bufferSize:LZ77_BUFFER_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   memcpy(&buffer[0], &input[offset], bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [self decompressUsingLZSS:LZ77_WINDOW_SIZE
                           bufferSize:LZ77_BUFFER_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   memcpy(&buffer[0], &input[offset], bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [self decompressUsingLZ78:LZ78_DICT_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   memcpy(&buffer[0], &input[offset], bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
        case kZXCAlgorithmLZW:
        {
            [self decompressUsingLZW:LZW_DICT_SIZE
                          readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                              unsigned int bufSize = MIN(length, inputSize - offset);
                              if (bufSize > 0) {
                                  memcpy(&buffer[0], &input[offset], bufSize);
                              }
                              return bufSize;
                          } writeBuffer:^(const void *buffer, const unsigned int length) {
                              [output appendBytes:buffer length:length];
                          } completion:^{
#ifdef DEBUG
                              NSLog(@"[LZW] input: %d bytes, output: %d bytes", (int)inputSize, (int)output.length);
#endif
                              if (completion) {
                                  completion([output copy]);
                              }
                          }];
            break;
        }
        case kZXCAlgorithmHuffman:
        {
            [self decompressUsingHuffman:HUFFMAN_BUFFER_SIZE
                              readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                  unsigned int bufSize = MIN(length, inputSize - offset);
                                  if (bufSize > 0) {
                                      memcpy(&buffer[0], &input[offset], bufSize);
                                  }
                                  return bufSize;
                              } writeBuffer:^(const void *buffer, const unsigned int length) {
                                  [output appendBytes:buffer length:length];
                              } completion:^{
#ifdef DEBUG
                                  NSLog(@"[Huffman] input: %d bytes, output: %d bytes", (int)inputSize, (int)output.length);
#endif
                                  if (completion) {
                                      completion([output copy]);
                                  }
                              }];
            break;
        }
        default:
            NSLog(@"%s unsupported algorithm %d", __func__, algorithm);
            break;
    }
}

+ (void)decompressFileAtPath:(NSString *)source toPath:(NSString *)target usingAlgorithm:(ZXCAlgorithm)algorithm completion:(void(^)(NSError *error))completion {
    // 错误信息
    NSError *error = nil;
    // 输入文件
    NSFileHandle *input = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:source] error:&error];
    unsigned int inputSize = (unsigned int)[input seekToEndOfFile];
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
            [self decompressUsingLZ77:LZ77_WINDOW_SIZE
                           bufferSize:LZ77_BUFFER_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               [input seekToFileOffset:offset];
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   NSData *data = [input readDataOfLength:bufSize];
                                   memcpy(buffer, data.bytes, bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [self decompressUsingLZSS:LZ77_WINDOW_SIZE
                           bufferSize:LZ77_BUFFER_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               [input seekToFileOffset:offset];
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   NSData *data = [input readDataOfLength:bufSize];
                                   memcpy(buffer, data.bytes, bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
            [self decompressUsingLZ78:LZ78_DICT_SIZE
                           readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                               [input seekToFileOffset:offset];
                               unsigned int bufSize = MIN(length, inputSize - offset);
                               if (bufSize > 0) {
                                   NSData *data = [input readDataOfLength:bufSize];
                                   memcpy(buffer, data.bytes, bufSize);
                               }
                               return bufSize;
                           } writeBuffer:^(const void *buffer, const unsigned int length) {
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
        case kZXCAlgorithmLZW:
        {
            [self decompressUsingLZW:LZW_DICT_SIZE
                          readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                              [input seekToFileOffset:offset];
                              unsigned int bufSize = MIN(length, inputSize - offset);
                              if (bufSize > 0) {
                                  NSData *data = [input readDataOfLength:bufSize];
                                  memcpy(buffer, data.bytes, bufSize);
                              }
                              return bufSize;
                          } writeBuffer:^(const void *buffer, const unsigned int length) {
                              [output writeData:[NSData dataWithBytes:buffer length:length]];
                          } completion:^{
#ifdef DEBUG
                              NSLog(@"[LZW] input: %d bytes, output: %d bytes", (int)inputSize, (int)[output seekToEndOfFile]);
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
        case kZXCAlgorithmHuffman:
        {
            [self decompressUsingHuffman:HUFFMAN_BUFFER_SIZE
                              readBuffer:^const unsigned int(void *buffer, const unsigned int length, const unsigned int offset) {
                                  [input seekToFileOffset:offset];
                                  unsigned int bufSize = MIN(length, inputSize - offset);
                                  if (bufSize > 0) {
                                      NSData *data = [input readDataOfLength:bufSize];
                                      memcpy(buffer, data.bytes, bufSize);
                                  }
                                  return bufSize;
                              } writeBuffer:^(const void *buffer, const unsigned int length) {
                                  [output writeData:[NSData dataWithBytes:buffer length:length]];
                              } completion:^{
#ifdef DEBUG
                                  NSLog(@"[Huffman] input: %d bytes, output: %d bytes", (int)inputSize, (int)[output seekToEndOfFile]);
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
            NSLog(@"%s unsupported algorithm %d", __func__, algorithm);
            break;
    }
}

@end


