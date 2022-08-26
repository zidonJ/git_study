//
//  ZDDispatchQueuePool.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDSentinel : NSObject


@property (readonly) int32_t value;

- (int32_t)increase;

@end

@interface ZDDispatchQueuePool : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

@property (nullable, nonatomic, readonly) NSString *name;

- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end

extern dispatch_queue_t ZDDispatchQueueGetForQOS(NSQualityOfService qos);

NS_ASSUME_NONNULL_END
