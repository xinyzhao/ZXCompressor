//
//  ZXCompressorDemoTests.m
//  ZXCompressorDemoTests
//
//  Created by xyz on 2019/3/7.
//  Copyright © 2019 xyz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZXCompressor.h"
#import "huffman.h"

@interface ZXCompressorDemoTests : XCTestCase

@end

@implementation ZXCompressorDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    NSArray *algorithms = @[@(kZXCAlgorithmHuffman)];//, @(kZXCAlgorithmLZ77), @(kZXCAlgorithmLZ78), @(kZXCAlgorithmLZSS), @(kZXCAlgorithmLZW)];
//    NSArray *prefixes = @[@"huffman"];//@"lz77", @"lz78", @"lzss", @"lzw"];
//    for (int i = 0; i < algorithms.count; i++) {
//        ZXCAlgorithm algorithm = (ZXCAlgorithm)[algorithms[i] intValue];
//        NSString *prefix = prefixes[i];
//        for (int j = 0; j < 6; j++) {
//            NSString *path = [NSString stringWithFormat:@"/Users/xyz/test/%d.txt", j];
//            NSString *file1 = [NSString stringWithFormat:@"/Users/xyz/test/%@_file_%d+.txt", prefix, j];
//            [ZXCompressor compressFileAtPath:path toPath:file1 usingAlgorithm:algorithm completion:^(NSError *error) {
//                if (error) {
//                    NSLog(@"%@", error.localizedDescription);
//                } else {
//                    NSString *file2 = [NSString stringWithFormat:@"/Users/xyz/test/%@_file_%d-.txt", prefix, j];
//                    [ZXCompressor decompressFileAtPath:file1 toPath:file2 usingAlgorithm:algorithm completion:^(NSError *error) {
//                        if (error) {
//                            NSLog(@"%@", error.localizedDescription);
//                        }
//                    }];
//                }
//            }];
//        }
//    }
    
    // A:10, B:11, C:010, D:011, E:00
    const int size = 5;
    char symbols[size] = {'A', 'B', 'C', 'D', 'E'};
    int weights[size] = {8, 10, 3, 4, 5};
    huffman_data *data = malloc(sizeof(huffman_data) * size);
    for (int i = 0; i < size; i++) {
        huffman_data *obj = &data[i];
        obj->symbol = symbols[i];
        obj->weight = weights[i];
    }
    huffman_tree *tree = huffman_tree_new(data, size);
    huffman_tree_free(tree);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
