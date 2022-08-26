//
//  ABCD.m
//  test
//
//  Created by jiangzedong on 2020/11/30.
//

#import "ABCD.h"

@interface ABCD ()

@property (nonatomic, copy) void (^doBlock) (void);

@end

@implementation ABCD


- (instancetype)init
{
    if (self = [super init]) {
        self.doBlock = ^{
            NSLog(@"%@",self.description);
        };
    }
    return self;
}

- (void)myLog:(NSString *)str {
    NSLog(@"234");
}

@end
