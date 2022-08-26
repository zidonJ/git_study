//
//  Thread.h
//  test
//
//  Created by jiangzedong on 2021/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSOperationQueue *opQueue(void);
extern void asyncRun(void);

@interface Thread : NSObject

- (void)pthreadTest;

@end

NS_ASSUME_NONNULL_END
