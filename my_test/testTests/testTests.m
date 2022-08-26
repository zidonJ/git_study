//
//  testTests.m
//  testTests
//
//  Created by jiangzedong on 2021/11/25.
//

#import <XCTest/XCTest.h>
#import "Thread.h"

@interface testTests : XCTestCase

@end

@implementation testTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSArray *arr = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    [arr enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%ld,%@",idx,obj);
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
