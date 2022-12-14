//
//  MetalImageConvolutionFilter.m
//  MetalImage
//
//  Created by David.Dai on 2019/4/1.
//

#import "MetalImageConvolutionFilter.h"
typedef struct MetalImageConvolitionParameter {
    float texelWidthOffset;
    float texelHeightOffset;
} MetalImageConvolitionParameter;

@interface MetalImageConvolutionFilter() {
    const float *_kernelWeights;
    MetalImageConvolitionParameter _param;
}
@property (assign, nonatomic) NSUInteger kernelHeight;
@property (assign, nonatomic) NSUInteger kernelWidth;
@property (nonatomic, assign) CGSize lastSize;
@end

@implementation MetalImageConvolutionFilter

+ (instancetype)filterWithKernelWidth:(NSUInteger)kernelWidth
                         kernelHeight:(NSUInteger)kernelHeight
                              weights:(const float *)kernelWeights {
    if (!kernelWeights || kernelWidth % 2 == 0 || kernelHeight % 2 == 0 || kernelHeight != kernelWidth) {
        return nil;
    }
    
    MetalImageConvolutionFilter *filter = [[MetalImageConvolutionFilter alloc] initWithKernelWidth:kernelWidth
                                                                                      kernelHeight:kernelHeight
                                                                                           weights:kernelWeights];
    return filter;
}

- (instancetype)initWithKernelWidth:(NSUInteger)kernelWidth
                       kernelHeight:(NSUInteger)kernelHeight
                            weights:(const float *)kernelWeights {
    if (self = [super init]) {
        _kernelWidth = kernelWidth;
        _kernelHeight = kernelHeight;
        _kernelWeights = kernelWeights;
        
        [self switchRenderPiplineWithVertex:[[self class] vertexShaderWithKernelWidth:_kernelWidth kernelHeight:_kernelHeight]
                                   fragment:[[self class] fragmentShaderWithKernelWidth:_kernelWidth kernelHeight:_kernelHeight weights:_kernelWeights]];
    }
    return self;
}

- (void)switchRenderPiplineWithVertex:(NSString *)vertex fragment:(NSString *)fragment {
    NSError *error = nil;
    id<MTLLibrary> library = [[MetalImageDevice shared].device newLibraryWithSource:[NSString stringWithFormat:@"%@ \n %@", vertex, fragment]
                                                                            options:nil
                                                                              error:&error];
    if (error) {
        assert(!"????????????????????????");
        return;
    }
    
    MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    descriptor.vertexFunction = [library newFunctionWithName:@"convolitionVertex"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"convolitionFragment"];
    descriptor.colorAttachments[0].pixelFormat = [MetalImageDevice shared].pixelFormat;
    
    self.target.pielineState = [[MetalImageDevice shared].device newRenderPipelineStateWithDescriptor:descriptor
                                                                                                error:&error];
    if (error) {
        assert(!"????????????????????????");
        return;
    }
}

#pragma mark -
- (void)encodeToCommandBuffer:(id<MTLCommandBuffer>)commandBuffer withResource:(MetalImageResource *)resource {
    if (MetalImageResourceTypeImage != resource.type) {
        return;
    }
    
    CGSize targetSize = CGSizeEqualToSize(self.target.size, CGSizeZero) ? resource.renderProcess.targetSize : self.target.size;
    MetalImageTexture *targetTexture = [[MetalImageDevice shared].textureCache fetchTexture:targetSize
                                                                                pixelFormat:resource.texture.metalTexture.pixelFormat];
    targetTexture.orientation = resource.texture.orientation;
    self.target.renderPassDecriptor.colorAttachments[0].texture = targetTexture.metalTexture;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self.target.renderPassDecriptor];
    [self renderToCommandEncoder:renderEncoder withResource:resource];
    [renderEncoder endEncoding];
    [resource.renderProcess swapTexture:targetTexture];
}

- (void)renderToCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder withResource:(MetalImageResource *)resource {
    if (MetalImageResourceTypeImage != resource.type) {
        return;
    }
    
    CGSize targetSize = CGSizeEqualToSize(self.target.size, CGSizeZero) ? resource.renderProcess.targetSize : self.target.size;
    if (!CGSizeEqualToSize(_lastSize, targetSize)) {
        _param.texelWidthOffset = 1.0 / targetSize.width;
        _param.texelHeightOffset = 1.0 / targetSize.height;
        _lastSize = targetSize;
    }
    
#if DEBUG
    renderEncoder.label = NSStringFromClass([self class]);
    [renderEncoder pushDebugGroup:@"Convolition Draw"];
#endif
    
    [renderEncoder setRenderPipelineState:self.target.pielineState];
    [renderEncoder setVertexBuffer:resource.renderProcess.positionBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:resource.renderProcess.textureCoorBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:resource.texture.metalTexture atIndex:0];
    
    [renderEncoder setVertexBytes:&_param length:sizeof(_param) atIndex:2];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
#if DEBUG
    [renderEncoder popDebugGroup];
#endif
}

#pragma mark - ????????????Shader
+ (NSString *)vertexShaderWithKernelWidth:(NSUInteger)kernelWidth
                             kernelHeight:(NSUInteger)kernelHeight {
    
    // ????????????????????????????????????
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"using namespace metal;\n"];
    [shaderString appendFormat:@"struct ConvolitionVertexIO {\n"];
    [shaderString appendFormat:@"   float4 position [[position]];\n"];
    [shaderString appendFormat:@"   float2 textureCoordinate [[user(texturecoord)]];\n"];
    for (int i = 0; i < kernelWidth; i++) {
        for (int k = 0; k < kernelHeight; k++) {
            [shaderString appendFormat:@"   float2 coordinates_%d_%d;\n", i, k];
        }
    }
    [shaderString appendFormat:@"};\n"];
    
    // ?????????????????????????????????{1.0/width, 1.0/height}
    [shaderString appendFormat:@"struct ConvolitionParameter {\n"];
    [shaderString appendFormat:@"   float texelWidthOffset;\n"];
    [shaderString appendFormat:@"   float texelHeightOffset;\n};\n\n"];
    
    // ?????????????????????
    [shaderString appendFormat:@"vertex ConvolitionVertexIO convolitionVertex(device packed_float2 *position [[buffer(0)]],\n"];
    [shaderString appendFormat:@"                                             device packed_float2 *texturecoord [[buffer(1)]],\n"];
    [shaderString appendFormat:@"                                             constant ConvolitionParameter &para [[buffer(2)]],\n"];
    [shaderString appendFormat:@"                                             uint vid [[vertex_id]]) {\n"];
    [shaderString appendFormat:@"   ConvolitionVertexIO outputVertices;\n"];
    [shaderString appendFormat:@"   outputVertices.position = float4(position[vid], 0, 1.0);\n"];
    [shaderString appendFormat:@"   outputVertices.textureCoordinate = texturecoord[vid];\n"];
    
    // ?????????????????????????????????
    int offset = 0;
    CGPoint kernelIndex = CGPointMake(floor(kernelWidth / 2.0), floor(kernelHeight / 2.0));
    for (int i = 0; i < kernelHeight; i++) {
        for (int k = 0; k < kernelWidth; k++, offset++) {
            int distanceX = k - (int)kernelIndex.x, distanceY = i - (int)kernelIndex.y;
            [shaderString appendFormat:@"   outputVertices.coordinates_%d_%d = texturecoord[vid] + float2(para.texelWidthOffset * %d, para.texelHeightOffset * %d);\n", k, i, distanceX, distanceY];
        }
    }
    [shaderString appendFormat:@"   return outputVertices;\n}\n"];
    
    return shaderString;
}

+ (NSString *)fragmentShaderWithKernelWidth:(NSUInteger)kernelWidth
                               kernelHeight:(NSUInteger)kernelHeight
                                    weights:(const float *)kernelWeights {
    // ?????????????????????
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"fragment half4 convolitionFragment(ConvolitionVertexIO fragmentInput [[stage_in]],\n"];
    [shaderString appendFormat:@"                                   texture2d<half> inputTexture [[texture(0)]]) {\n"];
    [shaderString appendFormat:@"   constexpr sampler quadSampler;\n"];
    [shaderString appendFormat:@"   half4 sum = half4(0.0);\n"];
    
    int offset = 0;
    for (int i = 0; i < kernelHeight; i++) {
        for (int k = 0; k < kernelWidth; k++, offset++) {
            float weight = kernelWeights[offset];
            [shaderString appendFormat:@"   sum += inputTexture.sample(quadSampler, fragmentInput.coordinates_%d_%d) * %f;\n", k, i, weight];
        }
    }
    [shaderString appendFormat:@"   return sum;\n}\n"];
    
    return shaderString;
}
@end
