//
//  NSAttributedString+TextKit.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (TextKit)

- (id)zd_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range;

@end

@interface NSMutableAttributedString (TextKit)

- (void)zd_addAttribute:(NSString *)attrName value:(id)value range:(NSRange)range;

- (void)zd_removeAttribute:(NSString *)name range:(NSRange)range;

@property (nonatomic, strong, readwrite, nullable) UIFont *zd_font;
@property (nonatomic, strong, readwrite, nullable) UIColor *zd_color;
@property (nonatomic, strong, readwrite, nullable) UIColor *zd_backgroundColor;
// paragraphStyle
@property (nonatomic, strong, readwrite, nullable) NSParagraphStyle *zd_paragraphStyle;
@property (nonatomic, assign, readwrite) CGFloat zd_lineSpacing;
@property (nonatomic, assign, readwrite) CGFloat zd_paragraphSpacing;
@property (nonatomic, assign, readwrite) CGFloat zd_paragraphSpacingBefore;
@property (nonatomic, assign, readwrite) NSTextAlignment zd_alignment;
@property (nonatomic, assign, readwrite) CGFloat zd_firstLineHeadIndent;
@property (nonatomic, assign, readwrite) CGFloat zd_headIndent;
@property (nonatomic, assign, readwrite) CGFloat zd_tailIndent;
@property (nonatomic, assign, readwrite) NSLineBreakMode zd_lineBreakMode;
@property (nonatomic, assign, readwrite) CGFloat zd_minimumLineHeight;
@property (nonatomic, assign, readwrite) CGFloat zd_maximumLineHeight;
@property (nonatomic, assign, readwrite) NSWritingDirection zd_baseWritingDirection;
@property (nonatomic, assign, readwrite) CGFloat zd_lineHeightMultiple;
@property (nonatomic, assign, readwrite) float zd_hyphenationFactor;
@property (nonatomic, assign, readwrite) CGFloat zd_defaultTabInterval;

@property (nonatomic, assign, readwrite) CGFloat zd_characterSpacing;
@property (nonatomic, assign, readwrite) NSUnderlineStyle zd_lineThroughStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *zd_lineThroughColor;
@property (nonatomic, assign, readwrite) NSInteger zd_characterLigature;
@property (nonatomic, assign, readwrite) NSUnderlineStyle zd_underLineStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *zd_underLineColor;
@property (nonatomic, assign, readwrite) CGFloat zd_strokeWidth;
@property (nonatomic, strong, readwrite, nullable) UIColor *zd_strokeColor;
@property (nonatomic, strong, readwrite, nullable) NSShadow *zd_shadow;
@property (nonatomic, strong, readwrite, nullable) id zd_link;
@property (nonatomic, assign, readwrite) CGFloat zd_baseline;
@property (nonatomic, assign, readwrite) CGFloat zd_obliqueness;
@property (nonatomic, assign, readwrite) CGFloat zd_expansion;

#pragma mark - Add Attribute At Range

/**
 add text font
 @discussion 添加文本字体
 */
- (void)zd_addFont:(UIFont *)font range:(NSRange)range;

/**
 add text color
 @discussion 添加文本颜色
 */
- (void)zd_addColor:(UIColor *)color range:(NSRange)range;

/**
 add text background color
 @discussion 添加文本背景色
 */
- (void)zd_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range;

/**
 add text paragraph style
 @discussion 添加文本段落格式
 */
- (void)zd_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

/**
 add text paragraph line spacing
 @discussion 添加文本段落行高
 */
- (void)zd_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 add text paragraph bottom spacing
 @discussion 添加文本段落底部间距
 */
- (void)zd_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;

/**
 add text paragraph top spacing
 @discussion 添加文本段落顶部间距
 */
- (void)zd_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range ;

/**
 add text paragraph alignment
 @discussion 添加段落文本对齐
 */
- (void)zd_addAlignment:(NSTextAlignment)alignment range:(NSRange)range;

/**
 add text paragraph firstLineHeadIndent
 @discussion 添加段落文本首行缩进
 */
- (void)zd_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

/**
 add text paragraph headIndent
 @discussion 添加段落文本首部缩进
 */
- (void)zd_addHeadIndent:(CGFloat)headIndent range:(NSRange)range;

/**
 add text paragraph tailIndent
 @discussion 添加段落文本尾部缩进
 */
- (void)zd_addTailIndent:(CGFloat)tailIndent range:(NSRange)range;

/**
 add text paragraph lineBreakMode
 @discussion 添加段落文本断行方式
 */
- (void)zd_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

/**
 add text paragraph minimumLineHeight
 @discussion 添加段落文本最小行高
 */
- (void)zd_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

/**
 add text paragraph maximumLineHeight
 @discussion 添加段落文本最大行高
 */
- (void)zd_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

/**
 add text paragraph writingDirection
 @discussion 添加段落文本书写方法
 */
- (void)zd_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;

/**
 add text paragraph lineHeightMultiple
 @discussion 添加段落文本可变行高,乘因数
 */
- (void)zd_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;

/**
 add text paragraph hyphenationFactor
 @discussion 添加段落文本连字符属性
 */
- (void)zd_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

/**
 add text paragraph defaultTabInterval(\t)
 @discussion 添加段落文本制表符(\t)间隔
 */
- (void)zd_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range;

/**
 add text character or letter space
 @discussion 添加文本字间距
 */
- (void)zd_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range;

/**
 add text line through style
 @discussion 添加文本删除线
 */
- (void)zd_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 add text line through color
 @discussion 添加文本删除线颜色
 */
- (void)zd_addLineThroughColor:(UIColor *)color range:(NSRange)range;

/**
 add text under line style
 @discussion 添加文本下划线
 */
- (void)zd_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 add text under line color
 @discussion 添加文本下划线颜色
 */
- (void)zd_addUnderLineColor:(UIColor *)color range:(NSRange)range;

/**
 add text character ligature
 @discussion 添加文本连字符
 @discussion default 1 ,1: default ligatures, 0: no ligatures
 */
- (void)zd_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range;

/**
 add text stroke color
 @discussion 添加文本边框颜色
 @discussion defalut text color
 */
- (void)zd_addStrokeColor:(UIColor *)color range:(NSRange)range;

/**
 add text stroke width
 @discussion 添加文本边框宽度
 */
- (void)zd_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range;

/**
 add text shadow
 @discussion 添加文本阴影
 */
- (void)zd_addShadow:(NSShadow *)shadow range:(NSRange)range;

/**
 add text attachment
 @discussion 添加文本附件
 */
- (void)zd_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range;

/**
 add text link
 @discussion 添加文本链接
 */
- (void)zd_addLink:(id)link range:(NSRange)range;

/**
 add text base line offset see UIBaselineAdjustment
 @discussion 添加文本基线偏移值
 */
- (void)zd_addBaseline:(CGFloat)baseline range:(NSRange)range;

/**
 add text writing direction
 @discussion 添加文本书写方向
 */
- (void)zd_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range;

/**
 add text obliqueness
 @discussion 添加文本字形倾斜度
 */
- (void)zd_addObliqueness:(CGFloat)obliqueness range:(NSRange)range;

/**
 add text expansion
 @discussion 添加文本字横向拉伸
 */
- (void)zd_addExpansion:(CGFloat)expansion range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
