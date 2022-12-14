//
//  MetalImageMovieWriter.m
//  MetalImage
//
//  Created by David.Dai on 2018/12/13.
//

#import "MetalImageMovieWriter.h"

@interface MetalImageMovieWriter()
@property (nonatomic, strong) dispatch_queue_t writerQueue;
@property (nonatomic, strong) NSURL *storageUrl;
@property (nonatomic, assign) CGSize renderSize;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelbufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput *imageWirterInput;
@property (nonatomic, strong) AVAssetWriterInput *audioWriterInput;
@property (nonatomic, assign) AVFileType fileType;

@property (nonatomic, assign) BOOL imageWriteFinish;
@property (nonatomic, assign) BOOL audioWriteFinish;
@property (nonatomic, assign) BOOL appendImageFirst;
@property (nonatomic, assign) BOOL haveAppedImage;

@property (nonatomic, assign) CMTime lastImageTime;
@property (nonatomic, assign) CMTime lastAudioTime;

@property (nonatomic, strong) MetalImageTarget *renderTarget;
@property (nonatomic, strong) MetalImageResource *backgroundTextureResource;
@property (nonatomic, assign) CGSize lastBackgroundSise;
@property (nonatomic, strong) id<MTLBuffer> backgroundPostionBuffer;
@end

@implementation MetalImageMovieWriter

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithStorageUrl:(NSURL *)storageUrl size:(CGSize)size {
    if (self = [super init]) {
        _storageUrl = storageUrl;
        _renderSize = size;
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    _writerQueue = dispatch_queue_create("com.MetalImage.MovieWriter", DISPATCH_QUEUE_SERIAL);
    _backgroundType = MetalImagContentBackgroundColor;
    _fileType = AVFileTypeQuickTimeMovie;
    
    _lastImageTime = kCMTimeZero;
    _lastAudioTime = kCMTimeZero;
    _appendImageFirst = YES;
    _haveAppedImage = NO;
    
    _renderTarget = [[MetalImageTarget alloc] initWithDefaultLibraryWithVertex:kMetalImageDefaultVertex
                                                                      fragment:kMetalImageDefaultFragment
                                                                   enableBlend:NO];
    _renderTarget.size = _renderSize;
    
    _renderTarget.fillMode = MetalImageContentModeScaleAspectFill;
    _lastBackgroundSise = CGSizeZero;
    
    [self initAssetWriter];
    [self initImageWirterInput];
}

- (MetalImageContentMode)fillMode {
    return _renderTarget.fillMode;
}

- (void)setFillMode:(MetalImageContentMode)fillMode {
    _renderTarget.fillMode = fillMode;
}

- (void)setHaveAudioTrack:(BOOL)haveAudioTrack {
    if (haveAudioTrack && _assetWriter.status == AVAssetWriterStatusUnknown) {
        [self initAudioWriterInput];
    }
}

- (UIColor *)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = [UIColor blackColor];
    }
    return _backgroundColor;
}

- (id<MetalImageRender>)backgroundFilter {
    if (!_backgroundFilter) {
        _backgroundFilter = (id<MetalImageRender>)([[MetalImageFilter alloc] init]);
    }
    return _backgroundFilter;
}

- (AVAssetWriterStatus)status {
    return self.assetWriter.status;
}

- (void)initAssetWriter {
    NSError *error = nil;
    _assetWriter = [[AVAssetWriter alloc] initWithURL:_storageUrl fileType:_fileType error:&error];
    if (error != nil) {
        assert(false);
        NSLog(@"%@ Asset Writer ???????????? :%@", [self class], error);
    }
    _assetWriter.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 1000);// ????????????????????????, ??????????????????
}

- (void)initImageWirterInput {
    CGSize outputSize = _renderSize;
    
    NSString *codec = AVVideoCodecH264;
    if (@available(iOS 11.0, *)) {
        codec = AVVideoCodecHEVC;
    }
    NSDictionary *frameEncoderSettings =@{ AVVideoCodecKey  :   codec,
                                           AVVideoWidthKey  :   @(outputSize.width),
                                           AVVideoHeightKey :   @(outputSize.height)};
    _imageWirterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:frameEncoderSettings];
    _imageWirterInput.expectsMediaDataInRealTime = false;
    
    NSDictionary *pixelBufferAttributes = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                            (__bridge NSString *)kCVPixelBufferWidthKey           : @(outputSize.width),
                                            (__bridge NSString *)kCVPixelBufferHeightKey          : @(outputSize.height)};
    
    _pixelbufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_imageWirterInput
                                                                                           sourcePixelBufferAttributes:pixelBufferAttributes];
    
    if([_assetWriter canAddInput:_imageWirterInput]) {
        [_assetWriter addInput:_imageWirterInput];
    }
}

- (void)initAudioWriterInput {
    NSDictionary *audioOutputSettings = nil;
    AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
    double sampleRate;
    if ([sharedAudioSession respondsToSelector:@selector(sampleRate)]) {
        [sharedAudioSession setPreferredSampleRate:44100.0 error:nil];
        sampleRate = [sharedAudioSession preferredSampleRate];
    }
    else {
        sampleRate = [[AVAudioSession sharedInstance] sampleRate];
    }
    
    // ??????0, ?????????, 64000??????, 44100?????????, AAC??????????????????
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSData *aclData = [NSData dataWithBytes:&acl length:sizeof(acl)];
    
    audioOutputSettings = @{AVFormatIDKey           : @(kAudioFormatMPEG4AAC),
                            AVNumberOfChannelsKey   : @(1),
                            AVSampleRateKey         : @(sampleRate),
                            AVChannelLayoutKey      : aclData,
                            AVEncoderBitRateKey     : @(64000)};
    
    _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _audioWriterInput.expectsMediaDataInRealTime = YES;
    
    if([_assetWriter canApplyOutputSettings:audioOutputSettings forMediaType:AVMediaTypeAudio]) {
        [_assetWriter addInput:_audioWriterInput];
    }
}

#pragma mark - Writer Control
- (void)startRecording {
    NSError *error = self.assetWriter.error;
    if (self.assetWriter.status == AVAssetWriterStatusCancelled) {
        error = kMetalImageMovieWriterCancelError;
    }
    
    if (_assetWriter.status != AVAssetWriterStatusUnknown) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.startHandle) {
                self.startHandle(error);
            }
            self.startHandle = nil;
        });
        return;
    }
    
    _haveAppedImage = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_writerQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.assetWriter startWriting];
        if (strongSelf.startHandle) {
            strongSelf.startHandle(strongSelf.assetWriter.error);
        }
        strongSelf.startHandle = nil;
    });
}

- (void)cancelRecording {
    NSError *error = self.assetWriter.error;
    if (self.assetWriter.status == AVAssetWriterStatusCancelled) {
        error = kMetalImageMovieWriterCancelError;
    }
    
    if (_assetWriter.status != AVAssetWriterStatusWriting) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self freeRenderResource];
            
            if (self.completeHandle) {
                self.completeHandle(error);
            }
            self.completeHandle = nil;
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_writerQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.assetWriter.status == AVAssetWriterStatusWriting) {
            if (!strongSelf.imageWriteFinish) {
                strongSelf.imageWriteFinish = YES;
                [strongSelf.imageWirterInput markAsFinished];
            }
            if (!strongSelf.audioWriteFinish) {
                strongSelf.audioWriteFinish = YES;
                [strongSelf.audioWriterInput markAsFinished];
            }
        }
        
        [strongSelf.assetWriter cancelWriting];
        [strongSelf freeRenderResource];
    });
}

- (void)finishRecording {
    NSError *error = self.assetWriter.error;
    if (self.assetWriter.status == AVAssetWriterStatusCancelled) {
        error = kMetalImageMovieWriterCancelError;
    }
    
    if (self.assetWriter.status != AVAssetWriterStatusWriting) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self freeRenderResource];
            
            if (self.completeHandle) {
                self.completeHandle(error);
            }
            self.completeHandle = nil;
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_writerQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.assetWriter.status == AVAssetWriterStatusWriting) {
            if (!strongSelf.imageWriteFinish) {
                strongSelf.imageWriteFinish = YES;
                [strongSelf.imageWirterInput markAsFinished];
            }
            if (!strongSelf.audioWriteFinish) {
                strongSelf.audioWriteFinish = YES;
                [strongSelf.audioWriterInput markAsFinished];
            }
        }
        
        // ????????????????????????
        [strongSelf.assetWriter endSessionAtSourceTime:strongSelf.lastImageTime];
        [strongSelf.assetWriter finishWritingWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf freeRenderResource];
                
                if (strongSelf.completeHandle) {
                    strongSelf.completeHandle(nil);
                }
                strongSelf.completeHandle = nil;
            });
        }];
    });
}

- (void)freeRenderResource {
    self.backgroundTextureResource = nil;
    self.backgroundFilter = nil;
    self.backgroundPostionBuffer = nil;
    self.lastBackgroundSise = CGSizeZero;
    [[MetalImageDevice shared].textureCache freeAllTexture];
}

#pragma mark - Target Protocol
- (void)receive:(MetalImageResource *)resource withTime:(CMTime)time {
    if (!resource) {
        return;
    }
    
    // ?????????????????????
    if (_assetWriter.status != AVAssetWriterStatusWriting) {
        if (resource.type == MetalImageResourceTypeImage) {
            [[MetalImageDevice shared].textureCache cacheTexture:resource.texture];
        }
        return;
    }
    
    // ????????????????????????
    if (resource.type == MetalImageResourceTypeImage) {
        [resource.renderProcess commitRender];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_writerQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        @autoreleasepool {
            switch (resource.type) {
                case MetalImageResourceTypeImage:
                    [strongSelf imageProcess:resource time:time];
                    [[MetalImageDevice shared].textureCache cacheTexture:resource.texture];
                    break;
                    
                case MetalImageResourceTypeAudio:
                    if (strongSelf.haveAudioTrack) {
                        [strongSelf audioProcess:resource time:time];
                    }
                    break;
                default:
                    break;
            }
        }
    });
}

#pragma mark - Pixel Write Process
- (void)imageProcess:(MetalImageResource *)resource time:(CMTime)time {
    // ?????????????????????????????????
    if (CMTimeCompare(_lastImageTime, time) != -1) {
        return;
    }
    
    // ????????????????????????
    if (CMTimeCompare(_lastImageTime, kCMTimeZero) == 0) {
        [_assetWriter startSessionAtSourceTime:time];
    }
    _lastImageTime = time;
    
    // ???????????????????????????????????????????????????
    [self imageRenderProcess:resource];
    
    // ?????????????????????CVPixelBufferRef
    __weak typeof(self) weakSelf = self;
    [MetalImageTexture textureCVPixelBufferProcess:resource.texture.metalTexture
                                           process:^(CVPixelBufferRef pixelBuffer) {
                                               CVPixelBufferRef pixel = pixelBuffer;
                                               if (!pixel) {
                                                   return;
                                               }
                                               
                                               CVPixelBufferLockBaseAddress(pixel, 0);
                                               
                                               // ???????????????????????????
                                               while(!weakSelf.imageWirterInput.readyForMoreMediaData && !weakSelf.imageWriteFinish) {
                                                   NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
                                                   [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
                                               }
                                               
                                               NSError *error = nil;
                                               switch (weakSelf.assetWriter.status) {
                                                   case AVAssetWriterStatusWriting: {
                                                       // ???????????????Cancel?????????
                                                       BOOL suceccsed = [weakSelf.pixelbufferAdaptor appendPixelBuffer:pixel withPresentationTime:time];
                                                       if (!suceccsed && weakSelf.assetWriter.status == AVAssetWriterStatusFailed) {
                                                           error = weakSelf.assetWriter.error;
                                                       } else {
                                                           weakSelf.haveAppedImage = YES;
                                                       }
                                                       break;
                                                   }
                                                       
                                                   case AVAssetWriterStatusUnknown:
                                                   case AVAssetWriterStatusCompleted:
                                                   case AVAssetWriterStatusFailed: {
                                                       error = weakSelf.assetWriter.error;
                                                       break;
                                                   }
                                                   case AVAssetWriterStatusCancelled: {
                                                       error = kMetalImageMovieWriterCancelError;
                                                       break;
                                                   }
                                                   default:
                                                       break;
                                               }
                                               
                                               CVPixelBufferUnlockBaseAddress(pixel, 0);
                                               
                                               if (error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (weakSelf.completeHandle) {
                                                           weakSelf.completeHandle(error);
                                                       }
                                                       weakSelf.completeHandle = nil;
                                                   });
                                               }
                                           }];
}

- (void)imageRenderProcess:(MetalImageResource *)resource {
    // ?????????????????????
    if (self.backgroundType == MetalImagContentBackgroundFilter && self.fillMode == MetalImageContentModeScaleAspectFit &&
        (_renderSize.width / _renderSize.height != resource.texture.size.width / resource.texture.size.height)) {
        MetalImageResource *backgroundTextureResource = [resource newResourceFromSelf];
        [self.backgroundFilter renderToResource:backgroundTextureResource];
        self.backgroundTextureResource = backgroundTextureResource;
    }
    
    // ????????????????????????
    MetalImageTexture *targetTexture = [[MetalImageDevice shared].textureCache fetchTexture:_renderSize pixelFormat:resource.texture.metalTexture.pixelFormat];
    targetTexture.orientation = resource.texture.orientation;
    _renderTarget.renderPassDecriptor.colorAttachments[0].texture = targetTexture.metalTexture;      // ??????????????????
    _renderTarget.renderPassDecriptor.colorAttachments[0].clearColor = [self mtlBackgroundColor];    // ???????????????????????????
    [_renderTarget updateCoordinateIfNeed:resource.texture];// ????????????????????????????????????????????????????????????
    
    // ??????
    id <MTLCommandBuffer> commandBuffer = [[MetalImageDevice shared].commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:self.renderTarget.renderPassDecriptor];
    [self renderToCommandEncoder:renderEncoder withResource:resource];
    [renderEncoder endEncoding];
    [resource.renderProcess swapTexture:targetTexture];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    // ??????????????????????????????
    [[MetalImageDevice shared].textureCache cacheTexture:self.backgroundTextureResource.texture];
}

- (void)renderToCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder withResource:(MetalImageResource *)resource {
#if DEBUG
    renderEncoder.label = NSStringFromClass([self class]);
    [renderEncoder pushDebugGroup:@"MovieWriter Draw"];
#endif
    [renderEncoder setRenderPipelineState:_renderTarget.pielineState];
    
    if (self.backgroundType == MetalImagContentBackgroundFilter && self.backgroundTextureResource) {
        if (!CGSizeEqualToSize(resource.texture.size, _renderSize) && !CGSizeEqualToSize(_lastBackgroundSise, _renderSize)) {
            _lastBackgroundSise = CGSizeMake(_renderSize.width, _renderSize.height);
            MetalImageCoordinate positionCoor = [self.backgroundTextureResource.texture texturePositionToSize:_renderSize
                                                                                                  contentMode:MetalImageContentModeScaleAspectFill];
            _backgroundPostionBuffer = [[MetalImageDevice shared].device newBufferWithBytes:&positionCoor length:sizeof(positionCoor) options:0];
        }
        [renderEncoder setVertexBuffer:_backgroundPostionBuffer offset:0 atIndex:0];
        [renderEncoder setVertexBuffer:_renderTarget.textureCoord offset:0 atIndex:1];
        [renderEncoder setFragmentTexture:_backgroundTextureResource.texture.metalTexture atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    }
    
    [renderEncoder setVertexBuffer:_renderTarget.position offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_renderTarget.textureCoord offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:resource.texture.metalTexture atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
#if DEBUG
    [renderEncoder popDebugGroup];
#endif
}

- (MTLClearColor)mtlBackgroundColor {
    if (self.backgroundType != MetalImagContentBackgroundColor) {
        return MTLClearColorMake(0, 0, 0, 1.0);
    }
    
    /**
     *  Writter???????????????????????????Alpha????????????????????????UIColor(RGBA)???????????????RGB
     *  ???????????????????????????????????????BGcolur = 1??????????????????BGcolur =0
     */
    CGFloat rgba[4];
    [self.backgroundColor getRed:rgba green:rgba + 1 blue:rgba + 2 alpha:rgba + 3];
    
    CGFloat bgColur = 0.0;
    CGFloat targetR = bgColur * (1 - rgba[3]) + rgba[0] * rgba[3];
    CGFloat targetG = bgColur * (1 - rgba[3]) + rgba[1] * rgba[3];
    CGFloat targetB = bgColur * (1 - rgba[3]) + rgba[2] * rgba[3];
                                                               
    CGFloat rgbColor[3] = { targetR, targetG, targetB };
    
//    NSLog(@"R:%f, G:%f, B:%f", rgbColor[0], rgbColor[1], rgbColor[2]);
    return MTLClearColorMake(rgbColor[0], rgbColor[1], rgbColor[2], rgba[3]);
}

#pragma mark - Audio Write Process
- (void)audioProcess:(MetalImageResource *)resource time:(CMTime)time {
    // ?????????????????????????????????
    if (CMTimeCompare(_lastAudioTime, time) == 1) {
        return;
    }
    _lastAudioTime = time;
    
    // ????????????????????????????????????
    if (_appendImageFirst && !_haveAppedImage) {
        return;
    }
    
    // ???????????????????????????
    while(!self.audioWriterInput.readyForMoreMediaData && !self.audioWriteFinish) {
        NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
    }
    
    NSError *error = nil;
    switch (self.assetWriter.status) {
        case AVAssetWriterStatusWriting: {
            BOOL suceccsed = [self.audioWriterInput appendSampleBuffer:resource.audioBuffer];
            if (!suceccsed && self.assetWriter.status == AVAssetWriterStatusFailed) {
                error = self.assetWriter.error;
            }
            break;
        }
            
        case AVAssetWriterStatusUnknown:
        case AVAssetWriterStatusCompleted:
        case AVAssetWriterStatusFailed: {
            error = self.assetWriter.error;
            break;
        }
        case AVAssetWriterStatusCancelled: {
            error = kMetalImageMovieWriterCancelError;
            break;
        }
        default:
            break;
    }
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completeHandle) {
                self.completeHandle(error);
            }
            self.completeHandle = nil;
        });
    }
}
@end
