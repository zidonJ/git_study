//
//  NSTimer+Block.h
//  test
//
//  Created by jiangzedong on 2022/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 一段时间后执行
/// @param rtimer 定时器
/// @param duration 时间
extern void runAfter(NSTimer *__strong _Nonnull* _Nonnull rtimer, float duration ,void (^_Nullable ptimer) (void));

typedef void(^JDelayedBlockHandle)(BOOL cancel);
extern void cancel_delayed_block(JDelayedBlockHandle delayedHandle);


/// 一段时间后执行
/// @param seconds 秒
/// @param block 回调
extern JDelayedBlockHandle j_perform_block_after_delay(float seconds, dispatch_block_t block);

@interface NSTimer (Block)

+ (NSTimer *)j_timerWithTimeInterval:(NSTimeInterval)interval
                               repeats:(BOOL)repeats
                                 block:(void(^)(NSTimer *))block;

@end

NS_ASSUME_NONNULL_END
