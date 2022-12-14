//
//  MetalImageView.m
//  MetalImage
//
//  Created by David.Dai on 2018/11/29.
//

#import "MetalImageView.h"

@interface MetalImageView()
@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) dispatch_queue_t displayQueue;
@property (nonatomic, strong) MetalImageTarget *renderTarget;
@property (nonatomic, strong) UIColor *metalBackgroundColor;
@end

@implementation MetalImageView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    _metalLayer = [[CAMetalLayer alloc] init];
    _metalLayer.device = [MetalImageDevice shared].device;
    _metalLayer.pixelFormat = [MetalImageDevice shared].pixelFormat;
    _metalLayer.framebufferOnly = YES;
    _metalLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:_metalLayer];
    
    _displayQueue = dispatch_queue_create("com.MetalImage.DisplayView", DISPATCH_QUEUE_SERIAL);
    _renderTarget = [[MetalImageTarget alloc] initWithDefaultLibraryWithVertex:kMetalImageDefaultVertex
                                                                      fragment:kMetalImageDefaultFragment];
    _renderTarget.fillMode = MetalImageContentModeScaleAspectFill;
    _renderTarget.size = CGSizeMake(self.metalLayer.frame.size.width * [UIScreen mainScreen].scale,
                                    self.metalLayer.frame.size.height * [UIScreen mainScreen].scale);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.metalLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGSize desSize = CGSizeMake(self.metalLayer.frame.size.width * [UIScreen mainScreen].scale,
                                self.metalLayer.frame.size.height * [UIScreen mainScreen].scale);
    
    if (!CGSizeEqualToSize(self.renderTarget.size, desSize)) {
        self.renderTarget.size = desSize;
    }
}

- (MetalImageContentMode)fillMode {
    return _renderTarget.fillMode;
}

- (void)setFillMode:(MetalImageContentMode)fillMode {
    _renderTarget.fillMode = fillMode;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.metalBackgroundColor = backgroundColor;
}

#pragma mark - Target Protocol
- (void)receive:(MetalImageResource *)resource withTime:(CMTime)time {
    if (!resource || resource.type != MetalImageResourceTypeImage) {
        return;
    }
    
    [resource.renderProcess commitRender];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.displayQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        @autoreleasepool {
            id <CAMetalDrawable> drawable = [strongSelf.metalLayer nextDrawable];
            if (drawable) {
                // View???Alpha??????layer???opaque????????????????????????Pieline???Blend
                MTLClearColor color = [strongSelf getMTLbackgroundColor];
                if (strongSelf.metalLayer.opaque && color.alpha != 1.0) {
                    strongSelf.metalLayer.opaque = NO;
                } else if (!strongSelf.metalLayer.opaque && color.alpha == 1.0) {
                    strongSelf.metalLayer.opaque = YES;
                }
                
                strongSelf.renderTarget.renderPassDecriptor.colorAttachments[0].texture = [drawable texture];
                strongSelf.renderTarget.renderPassDecriptor.colorAttachments[0].clearColor = color;
                [strongSelf.renderTarget updateCoordinateIfNeed:resource.texture];// ????????????????????????????????????????????????????????????
                
                id <MTLCommandBuffer> commandBuffer = [[MetalImageDevice shared].commandQueue commandBuffer];
                [commandBuffer enqueue];
                id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:strongSelf.renderTarget.renderPassDecriptor];
                [strongSelf renderToCommandEncoder:renderEncoder withResource:resource];
                [commandBuffer presentDrawable:drawable];
                [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
                    [[MetalImageDevice shared].textureCache cacheTexture:resource.texture];
                }];
                [commandBuffer commit];
            }
        }
    });
}

- (MTLClearColor)getMTLbackgroundColor {
    CGFloat components[4];
    [self.metalBackgroundColor getRed:components green:components + 1 blue:components + 2 alpha:components + 3];
    return MTLClearColorMake(components[0], components[1], components[2], components[3]);
}

#pragma mark - Render Process
- (void)renderToCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder withResource:(MetalImageResource *)resource {
#if DEBUG
    renderEncoder.label = NSStringFromClass([self class]);
    [renderEncoder pushDebugGroup:@"Display Draw"];
#endif
    
    [renderEncoder setRenderPipelineState:_renderTarget.pielineState];
    [renderEncoder setVertexBuffer:_renderTarget.position offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_renderTarget.textureCoord offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:resource.texture.metalTexture atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
#if DEBUG
    [renderEncoder popDebugGroup];
#endif
    [renderEncoder endEncoding];
}

@end
