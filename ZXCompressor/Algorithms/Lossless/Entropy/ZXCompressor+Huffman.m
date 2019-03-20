//
// ZXCompressor+Huffman.m
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

#import "ZXCompressor+Huffman.h"
#import "huffman.h"
#import "bitbyte.h"

@implementation ZXCompressor (Huffman)

+ (void)compressUsingHuffman:(const uint32_t)bufferSize
                  readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
                 writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                  completion:(void (^)(void))completion {
    // symbol size
    uint32_t symbolSize = 256;
    // huffman file
    huffman_file *file = huffman_file_new(0, symbolSize);
    for (int i = 0; i < symbolSize; i++) {
        huffman_data *data = &file->data[i];
        data->symbol = i;
    }
    // read buffer
    uint8_t *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    // output
    uint32_t outputSize = bufferSize;
    uint8_t *output = malloc(outputSize);
    memset(output, 0, outputSize);
    // read length in bytes
    uint32_t readed;
    // output length in bits
    uint32_t length = 0;
    // temp
    int i,j,k,l;
    // freq
    for (i = 0; ; i += bufferSize) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        for (j = 0; j < readed; j++) {
            k = buffer[j];
            huffman_data *data = &file->data[i];
            data->weight++;
        }
        if (readed < bufferSize) {
            break;
        }
    }
    // huffman tree
    huffman_tree *tree = huffman_tree_new(file->data, file->data_size);
    // huffman coding
    for (i = 0; ; i += bufferSize) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        for (j = 0; j < readed; j++) {
            k = buffer[j];
            huffman_node *node = &tree[k];
            // extend
            if (BITS_TO_BYTES(length) + node->code->size > outputSize) {
                output = realloc(output, outputSize * 2);
                memset(&output[outputSize], 0, outputSize);
                outputSize *= 2;
            }
            // coding
            for (l = 0; l < node->code->used; l++) {
                bit_set(output, l + length, bit_get(node->code->bits, l));
            }
            length += node->code->used;
            // write
            if (length % 8 == 0) {
                if (writeBuffer) {
                    writeBuffer(output, BITS_TO_BYTES(length));
                }
                // reset
                memset(output, 0, outputSize);
                length = 0;
            }
        }
        if (readed < bufferSize) {
            break;
        }
    }
    // ended
    if (length > 0) {
        if (writeBuffer) {
            writeBuffer(output, BITS_TO_BYTES(length));
        }
    }
    // free
    huffman_tree_free(tree);
    free(output);
    free(buffer);
}

+ (void)decompressUsingHuffman:(const uint32_t)bufferSize
                    readBuffer:(const uint32_t (^)(uint8_t *buffer, const uint32_t length, const uint32_t offset))readBuffer
                   writeBuffer:(void (^)(const uint8_t *buffer, const uint32_t length))writeBuffer
                    completion:(void (^)(void))completion {
    
}

@end
