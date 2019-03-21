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

+ (void)compressUsingHuffman:(const unsigned int)bufferSize
                   inputSize:(const unsigned int)inputSize
                  readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
                 writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                  completion:(void (^)(void))completion {
    // read buffer
    unsigned char *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    // output
    unsigned int outputSize = bufferSize;
    unsigned char *output = malloc(outputSize);
    memset(output, 0, outputSize);
    // read length in bytes
    unsigned int readed;
    // output length in bits
    unsigned int length = 0;
    // symbol size
    int symbolSize = 256;
    // temp
    int i,j,k,l;
    // data
    int freq_max = 0;
    huffman_data *data = malloc(sizeof(huffman_data) * symbolSize);
    memset(data, 0, sizeof(huffman_data) * symbolSize);
    for (i = 0; ; i += bufferSize) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        for (j = 0; j < readed; j++) {
            k = buffer[j];
            data[k].weight++;
            // freq max
            if (freq_max < data[k].weight) {
                freq_max = data[k].weight;
            }
        }
        if (readed < bufferSize) {
            break;
        }
    }
    // freq
    int *freq = malloc(sizeof(int) * symbolSize);
    memset(freq, 0, sizeof(int) * symbolSize);
    for (i = 0; i < symbolSize; i++) {
        data[i].symbol = i;
        freq[i] = data[i].weight;
    }
    // write input size and freq info
    if (writeBuffer) {
        writeBuffer(&inputSize, sizeof(inputSize));
        writeBuffer(&freq[0], sizeof(freq[0]) * symbolSize);
    }
    // huffman tree
    huffman_tree *tree = huffman_tree_new(data, symbolSize);
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
            if (BITS_TO_BYTES(length + node->code->size) > outputSize) {
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
    free(freq);
    free(data);
    free(output);
    free(buffer);
    // completion
    if (completion) {
        completion();
    }
}

+ (void)decompressUsingHuffman:(const unsigned int)bufferSize
                    readBuffer:(const unsigned int (^)(void *buffer, const unsigned int length, const unsigned int offset))readBuffer
                   writeBuffer:(void (^)(const void *buffer, const unsigned int length))writeBuffer
                    completion:(void (^)(void))completion {
    
}

@end
