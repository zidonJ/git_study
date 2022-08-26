//
//  ZDRender.m
//  ZDKit
//
//  Created by jiangzedong on 2022/7/21.
//

#import "ZDTextRender.h"
#import "ZDLayoutManager.h"

@interface ZDTextRender ()

@property (nonatomic, assign) CGSize oriSize;
@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) NSRange visibleCharacterRange;
@property (nonatomic, assign) NSRange truncatedCharacterRange;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSTextStorage *textStorageOnRender;

@end

@implementation ZDTextRender

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    return [self initWithTextStorage:textStorage size:CGSizeZero];
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage size:(CGSize)size
{
    if (self = [super init]) {
        _oriSize = size;
        _textStorage = textStorage;
        [self configureRender];
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer {
    if (self = [self initWithTextContainer:textContainer editable:NO]) {
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer editable:(BOOL)editable {
    if (self = [super init]) {
        NSParameterAssert(textContainer.layoutManager);
    }
    return self;
}

- (void)configureRender {
    
    _textContainer = [[NSTextContainer alloc] initWithSize:_oriSize];
    _textContainer.maximumNumberOfLines = 0;
    _textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _layoutManager = [[ZDLayoutManager alloc] init];

    [_textStorage addLayoutManager:_layoutManager];
}

- (NSRange)visibleGlyphRange {
    return [_layoutManager glyphRangeForTextContainer:_textContainer];
}


- (CGRect)textRectForGlyphRange:(NSRange)glyphRange atPiont:(CGPoint)point
{
    if (glyphRange.length == 0) {
        return CGRectZero;
    }
    CGPoint textOffset = point;
    CGRect textBound = _textRect;
//    if (!_onlySetRenderSizeWillGetTextBounds || _editable || CGRectIsEmpty(textBound)) {
//        textBound = [self boundingRectForGlyphRange:glyphRange];
//    }
    CGSize textSize = CGSizeMake(ceil(textBound.size.width), ceil(textBound.size.height));
//    switch (_verticalAlignment) {
//        case TYTextVerticalAlignmentTop:
//            textOffset.y = point.y;
//            break;
//        case TYTextVerticalAlignmentBottom:
//            textOffset.y = (_textContainer.size.height - textSize.height);
//            break;
//        default:
//            textOffset.y = (_textContainer.size.height - textSize.height) / 2.0;
//            break;
//    }
    textBound.origin = textOffset;
    textBound.size = textSize;
    return textBound;
}

//MARK: truncation
- (void)configTextStorageTruncation
{
    NSUInteger truncatedLocation;
    NSInteger glyphIndex = [_layoutManager glyphIndexForCharacterAtIndex:_textStorageOnRender.length - 1];
    if (glyphIndex < 0) {
        return;
    }
    //判断是否有截断
    NSRange truncatedGlyphRange = [_layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
    if (truncatedGlyphRange.location != NSNotFound) { // truncated
        truncatedLocation = truncatedGlyphRange.location;
    } else {
        NSRange visiableGlyphRange = [_layoutManager glyphRangeForTextContainer:self.textContainer];
        if (visiableGlyphRange.length - visiableGlyphRange.location - 1 >= glyphIndex) {
            //no truncation
            return;
        } else {
            truncatedLocation = visiableGlyphRange.length - visiableGlyphRange.location - 1;
        }
    }
}

//MARK: draw
- (void)drawPrepare
{
    //before draw textContainer should be ready all to add to layoutManager
    [_layoutManager addTextContainer:_textContainer];
}

- (void)drawTextAtPoint:(CGPoint)point
{
    [self drawTextAtPoint:point isCanceled:nil];
}

- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled
{
    [self drawPrepare];
    
    NSRange glyphRange1 = [_layoutManager glyphRangeForTextContainer:_textContainer];
    NSRange visibleCharacterRange = [_layoutManager characterRangeForGlyphRange:glyphRange1 actualGlyphRange:NULL];
    
    NSRange truncatedGlyphRange = [_layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:NSMaxRange(visibleCharacterRange)-1];
    _visibleCharacterRange = visibleCharacterRange;
    NSRange truncatedCharacterRange = [_layoutManager characterRangeForGlyphRange:truncatedGlyphRange actualGlyphRange:NULL];
    _truncatedCharacterRange = truncatedCharacterRange;
    
    _textRect = [self textRectForGlyphRange:glyphRange1 atPiont:point];
    
    // drawing text
    __weak typeof(self) weakSelf = self;
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange1 usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) self = weakSelf;
        // draw background
        [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:self.textRect.origin];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
        // draw Glyphs、Attachment、underlines、strikethroughs
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:self.textRect.origin];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
    }];
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    NSRange glyphRange = [_layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [self boundingRectForGlyphRange:glyphRange];
}

- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange {
    return [_layoutManager boundingRectForGlyphRange:glyphRange
                                     inTextContainer:_textContainer];
}

- (NSInteger)characterIndexForPoint:(CGPoint)point {
    if (!CGRectContainsPoint(_textRect, point) && !_editable) {
        return -1;
    }
    CGPoint realPoint = CGPointMake(point.x - _textRect.origin.x, point.y - _textRect.origin.y);
    CGFloat distanceToPoint = 1.0;
    NSUInteger index = [_layoutManager characterIndexForPoint:realPoint inTextContainer:_textContainer fractionOfDistanceBetweenInsertionPoints:&distanceToPoint];
    return distanceToPoint < 1 ? index : -1;
}

//MARK: setter getter
- (void)setTextStorage:(NSTextStorage *)textStorage
{
    _textStorage = textStorage;
    [_textStorage addLayoutManager:_layoutManager];
}

- (void)setSize:(CGSize)size
{
    _size = size;
    if (!CGSizeEqualToSize(_textContainer.size, size)) {
        _textContainer.size = size;
        _textRect = [self boundingRectForGlyphRange:[self visibleGlyphRange]];
    }
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    if (_textContainer.maximumNumberOfLines == numberOfLines) {
        return;
    }
    _textContainer.maximumNumberOfLines = numberOfLines;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_textContainer.lineBreakMode == lineBreakMode) {
        return;
    }
    _textContainer.lineBreakMode = lineBreakMode;
}


@end
