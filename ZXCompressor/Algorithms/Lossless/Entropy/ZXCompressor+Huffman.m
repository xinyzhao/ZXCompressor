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

const int kHuffmanDataSize = 256;

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
    // temp
    int i,j,k,l;
    // data
    unsigned int data_size = sizeof(huffman_data) * kHuffmanDataSize;
    huffman_data *data = malloc(data_size);
    memset(data, 0, data_size);
    for (i = 0; ; i += bufferSize) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        for (j = 0; j < readed; j++) {
            k = buffer[j];
            data[k].weight++;
        }
        if (readed < bufferSize) {
            break;
        }
    }
    // freq
    unsigned int freq_size = sizeof(unsigned int) * kHuffmanDataSize;
    unsigned int *freq = malloc(freq_size);
    memset(freq, 0, freq_size);
    for (i = 0; i < kHuffmanDataSize; i++) {
        data[i].symbol = i;
        freq[i] = data[i].weight;
    }
    // write input size and freq info
    if (writeBuffer) {
        writeBuffer(&inputSize, sizeof(inputSize));
        writeBuffer(freq, freq_size);
    }
    // huffman tree
    huffman_tree *tree = huffman_tree_new(data, kHuffmanDataSize);
    // encoding
    for (i = 0; ; i += bufferSize) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        for (j = 0; j < readed; j++) {
            k = buffer[j];
            huffman_node *node = &tree[k];
            // extend
            if (BITS_TO_BYTES(length + node->code->used) > outputSize) {
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
    // read buffer
    unsigned char *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    // output buffer
    unsigned int outputSize = bufferSize;
    unsigned char *output = malloc(outputSize);
    memset(output, 0, outputSize);
    // symbol size
    unsigned int symbolSize = sizeof(unsigned char);
    // input offset in bytes
    unsigned int offset = 0;
    // output length in bits
    unsigned int length = 0;
    // read length in bytes
    unsigned int readed = 0;
    // writed length in bytes
    unsigned int writed = 0;
    // temp
    int i,j,k,l;
    // origin input size
    unsigned int originSize = 0;
    if (readBuffer) {
        readed = readBuffer(&originSize, sizeof(originSize), offset);
        offset += readed;
    }
    // freq
    unsigned int freq_size = sizeof(unsigned int) * kHuffmanDataSize;
    unsigned int *freq = malloc(freq_size);
    memset(freq, 0, freq_size);
    if (readBuffer) {
        readed = readBuffer(freq, freq_size, offset);
        offset += readed;
    }
    // data
    unsigned int data_size = sizeof(huffman_data) * kHuffmanDataSize;
    huffman_data *data = malloc(data_size);
    memset(data, 0, data_size);
    for (i = 0; i < kHuffmanDataSize; i++) {
        data[i].symbol = i;
        data[i].weight = freq[i];
    }
    // huffman tree
    huffman_tree *tree = huffman_tree_new(data, kHuffmanDataSize);
    huffman_node *node = huffman_tree_root(tree);
    // decoding
    for (i = offset; ; ) {
        readed = readBuffer ? readBuffer(buffer, bufferSize, i) : 0;
        if (readed == 0) {
            break;
        }
        i += readed;
        // bits
        k = BYTES_TO_BITS(readed);
        for (j = 0; j < k; j++) {
            // next
            l = bit_get(buffer, j);
            if (l == 0) {
                node = node->lchild;
            } else {
                node = node->rchild;
            }
            // leaf
            if (node->lchild == NULL && node->rchild == NULL) {
                memcpy(&output[length], &node->data->symbol, symbolSize);
                length += symbolSize;
                writed += symbolSize;
                // output
                if (length >= outputSize) {
                    if (writeBuffer) {
                        writeBuffer(output, length);
                    }
                    // clear
                    memset(output, 0, outputSize);
                    length = 0;
                }
                // done
                if (writed >= originSize) {
                    break;
                }
                // reset
                node = huffman_tree_root(tree);
            }
        }
        // ended
        if (readed < bufferSize) {
            break;
        }
    }
    // ended
    if (length > 0) {
        if (writeBuffer) {
            writeBuffer(output, length);
        }
    }
    // free
    huffman_tree_free(tree);
    free(data);
    free(freq);
    free(output);
    free(buffer);
    // 完成
    if (completion) {
        completion();
    }
}

@end
