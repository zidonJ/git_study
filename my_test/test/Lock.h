//
//  Lock.h
//  test
//
//  Created by jiangzedong on 2022/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Lock : NSObject

- (void)mutex;

- (void)deadLock1;

// 条件锁
- (void)producer;
- (void)consumer;
- (void)conditionLockTest;

@end

NS_ASSUME_NONNULL_END
