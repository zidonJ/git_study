//
//  MyLabel.m
//  ZDKit
//
//  Created by jiangzedong on 2022/7/19.
//

#import "MyLabel.h"
#import "ZDAsyncRender.h"
#import "ZDTextRender.h"

@interface MyLabel () <ZDAsyncLayerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singTap;
@property (nonatomic, strong) NSTextStorage *currentStorage;

@end

@implementation MyLabel

+ (Class)layerClass {
    return ZDAsyncLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureLabel];
    }
    return self;
}

#pragma mark - Configure

- (void)configureLabel {
    
    ((ZDAsyncLayer *)self.layer).displaysAsynchronously = YES;
    ((ZDAsyncLayer *)self.layer).asyncDelegate = self;
    
    _singTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singTap:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:_singTap];
}

- (void)_clearLayerContent {
    if ([self asyncLayer].displaysAsynchronously) {
        self.layer.contents = nil;
    }
}

- (void)_setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)_createRender
{
    if (!_textRender) {
        _textRender = [[ZDTextRender alloc] initWithTextStorage:self.currentStorage size:self.frame.size];
    }
}

- (void)_setLayoutNeedUpdate {
    [self _createRender];
    [self _clearLayerContent];
    [self _setLayoutNeedRedraw];
}

- (void)judgePoint:(CGPoint)point
{
    NSInteger index = [self.textRender characterIndexForPoint:point];
}

#pragma mark - Action
- (void)singTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    [self judgePoint:point];
}

#pragma mark - setter getter

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(self.frame.size, oldSize)) {
        [self _clearLayerContent];
        [self _setLayoutNeedRedraw];
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (!_text) {
        return;
    }
    _textRender.font = font;
    [self _setLayoutNeedUpdate];
}

- (void)setText:(NSString *)text
{
    if (_text == text || [_text isEqualToString:text]) return;
    _text = text;
    _currentStorage = [[NSTextStorage alloc] initWithString:_text];
    [self _setLayoutNeedUpdate];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (_attributedText == attributedText || [_attributedText isEqualToAttributedString:attributedText]) {
        return;
    }
    _attributedText = attributedText;
    _currentStorage = [[NSTextStorage alloc] initWithAttributedString:_attributedText];
    [self _setLayoutNeedUpdate];
}

- (void)setTruncation:(NSAttributedString *)truncation
{
    _truncation = truncation;
    [self _setLayoutNeedRedraw];
}

- (ZDAsyncLayer *)asyncLayer
{
    return (ZDAsyncLayer *)self.layer;
}

#pragma mark - ZDAsyncLayerDelegate
- (ZDAsyncLayerDisplayTask *)newAsyncDisplayTask {
    
    __weak typeof(self) ws = self;
    ZDAsyncLayerDisplayTask *task = [[ZDAsyncLayerDisplayTask alloc] init];
    
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        
    };
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        __strong typeof(ws) self = ws;
//        [self.text drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:UIColor.blueColor}];
//        [self.attributedText drawAtPoint:CGPointZero];
        if (isCancelled()) {
            return;
        }
        self.textRender.lineBreakMode = self.lineBreakMode;
        self.textRender.numberOfLines = self.numberOfLines;
//        self.textRender.size = size;
        [self.textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
    
    };
    return task;
}

@end
