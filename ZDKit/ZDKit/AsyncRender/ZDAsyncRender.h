//
//  ZDAsyncRender.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/19.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDAsyncLayerDisplayTask;

@protocol ZDAsyncLayerDelegate <NSObject>

@required
- (ZDAsyncLayerDisplayTask *)newAsyncDisplayTask;

@end

@interface ZDAsyncLayer : CALayer

@property BOOL displaysAsynchronously;
@property (weak) id<ZDAsyncLayerDelegate> asyncDelegate;

@end


@interface ZDAsyncLayerDisplayTask : NSObject

@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
