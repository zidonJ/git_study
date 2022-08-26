//
//  NSTimer+Block.m
//  test
//
//  Created by jiangzedong on 2022/1/12.
//

#import "NSTimer+Block.h"

extern void runAfter(NSTimer *__strong*rtimer, float duration ,void (^ptimer) (void)) {
    [*rtimer invalidate];
    if (duration<=0 && ptimer) {
        ptimer();
        return;
    }
    *rtimer = [NSTimer j_timerWithTimeInterval:duration repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (ptimer) {
            ptimer();
            [timer invalidate];
            timer = nil;
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:*rtimer forMode:NSDefaultRunLoopMode];
}

extern void cancel_delayed_block(JDelayedBlockHandle delayedHandle) {
    if (nil == delayedHandle) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        delayedHandle(YES);
    });
}

extern JDelayedBlockHandle j_perform_block_after_delay(float seconds, dispatch_block_t block) {
    if (block == nil) {
        return nil;
    }
    
    __block dispatch_block_t blockToExecute = [block copy];
    __block JDelayedBlockHandle delayHandleCopy = nil;
    
    JDelayedBlockHandle delayHandle = ^(BOOL cancel) {
        if (!cancel && blockToExecute) {
            blockToExecute();
        }
        
        blockToExecute = nil;
        delayHandleCopy = nil;
    };
    delayHandleCopy = [delayHandle copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (nil != delayHandleCopy) {
            delayHandleCopy(NO);
        }
    });
    
    return delayHandleCopy;
}


@implementation NSTimer (LBlock)

+ (NSTimer *)j_timerWithTimeInterval:(NSTimeInterval)interval
                               repeats:(BOOL)repeats
                                 block:(void (^)(NSTimer *))block {
    return [self timerWithTimeInterval:interval
                                target:self
                              selector:@selector(wbl_blockInvoke:)
                              userInfo:[block copy]
                               repeats:repeats];
}

+ (void)wbl_blockInvoke:(NSTimer *)timer {
    void(^block)(NSTimer *) = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end
