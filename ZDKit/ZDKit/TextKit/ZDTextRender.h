//
//  ZDRender.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDTextRender : NSObject

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage size:(CGSize)size;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

@property (nonatomic, assign) CGSize size;

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange;
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange;

- (NSInteger)characterIndexForPoint:(CGPoint)point;
- (void)drawTextAtPoint:(CGPoint)point;
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

@end

NS_ASSUME_NONNULL_END
