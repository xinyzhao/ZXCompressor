//
//  ZXCompressorDemoTests.m
//  ZXCompressorDemoTests
//
//  Created by xyz on 2019/3/7.
//  Copyright © 2019 xyz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZXCompressor.h"

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
    ZXCAlgorithm algorithm = kZXCAlgorithmLZSS;
//    NSString *prefix = @"lzss";
    //
    for (int i = 0; i < 6; i++) {
        NSString *path = [NSString stringWithFormat:@"/Users/xyz/test/%d.txt", i];
        //
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        [ZXCompressor compressData:data usingAlgorithm:algorithm completion:^(NSData *data) {
//            if (data) {
//                NSString *data1 = [NSString stringWithFormat:@"/Users/xyz/test/%@_data_%d+.txt", prefix, i];
//                NSString *data2 = [NSString stringWithFormat:@"/Users/xyz/test/%@_data_%d-.txt", prefix, i];
//                [data writeToFile:data1 atomically:YES];
//                //
//                [ZXCompressor decompressData:data usingAlgorithm:algorithm completion:^(NSData *data) {
//                    if (data) {
//                        [data writeToFile:data2 atomically:YES];
//                    }
//                }];
//            }
        }];
        
        //
//        NSString *file1 = [NSString stringWithFormat:@"/Users/xyz/test/%@_file_%d+.txt", prefix, i];
//        NSString *file2 = [NSString stringWithFormat:@"/Users/xyz/test/%@_file_%d-.txt", prefix, i];
//        [ZXCompressor compressFileAtPath:path toPath:file1 usingAlgorithm:algorithm completion:^(NSError *error) {
//            if (error == nil) {
//                [ZXCompressor decompressFileAtPath:file1 toPath:file2 usingAlgorithm:algorithm completion:^(NSError *error) {
//                    if (error == nil) {
//                    }
//                }];
//            }
//        }];
        
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
