//
//  NSAttributedString+TextKit.m
//  ZDKit
//
//  Created by jiangzedong on 2022/7/23.
//

#import "NSAttributedString+TextKit.h"

#define zd_setParagraphStyleProperty(_property_,_range_) \
[self enumerateAttribute:NSParagraphStyleAttributeName inRange:_range_ options:kNilOptions usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {\
    NSMutableParagraphStyle *style = nil;\
    if (!value) {\
        style = [[NSMutableParagraphStyle alloc]init];\
        if (style._property_ == _property_) {\
            return ;\
        }\
    } else {\
        if (value._property_ == _property_) {\
        return ;\
        }\
        if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {\
            style = (NSMutableParagraphStyle *)value;\
        }else {\
            style = [value mutableCopy];\
        }\
    }\
    style._property_ = _property_;\
    [self zd_addParagraphStyle:style range:subRange];\
}];\

@implementation NSAttributedString (TextKit)

- (id)zd_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range {
    if (!attrName || self.length == 0) {
        return nil;
    }
    
    if (index >= self.length) {
#ifdef DEBUG
        NSLog(@"%s: attribute %@'s index out of range!",__FUNCTION__,attrName);
#endif
        return nil;
    }
    return [self attribute:attrName atIndex:index longestEffectiveRange:range inRange:NSMakeRange(0, self.length)];
}

@end

@implementation NSMutableAttributedString (TextKit)

#pragma mark - Add Attribute

- (void)zd_addAttribute:(NSString *)attrName value:(id)value range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    if (!value || [NSNull isEqual:value]) {
        [self removeAttribute:attrName range:range];
        return;
    }
    [self addAttribute:attrName value:value range:range];
}

- (void)zd_removeAttribute:(NSString *)attrName range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    [self removeAttribute:attrName range:range];
}

- (void)setZd_font:(UIFont *)font {
    [self zd_addFont:font range:NSMakeRange(0, self.length)];
}
- (void)zd_addFont:(UIFont *)font range:(NSRange)range {
    [self zd_addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setZd_color:(UIColor *)color {
    [self zd_addColor:color range:NSMakeRange(0, self.length)];
}
- (void)zd_addColor:(UIColor *)color range:(NSRange)range {
    [self zd_addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setZd_backgroundColor:(UIColor *)backgroundColor {
    [self zd_addBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}
- (void)zd_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self zd_addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)setZd_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    [self zd_addParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}
- (void)zd_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self zd_addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)setZd_lineSpacing:(CGFloat)lineSpacing {
    [self zd_addLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}
- (void)zd_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    zd_setParagraphStyleProperty(lineSpacing,range);
}

- (void)setZd_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self zd_addParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}
- (void)zd_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    zd_setParagraphStyleProperty(paragraphSpacing,range);
}

- (void)setZd_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self zd_addParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}
- (void)zd_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    zd_setParagraphStyleProperty(paragraphSpacingBefore,range);
}

- (void)setZd_alignment:(NSTextAlignment)alignment {
    [self zd_addAlignment:alignment range:NSMakeRange(0, self.length)];
}
- (void)zd_addAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    zd_setParagraphStyleProperty(alignment,range);
}

- (void)setZd_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self zd_addFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}
- (void)zd_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    zd_setParagraphStyleProperty(firstLineHeadIndent,range);
}

- (void)setZd_headIndent:(CGFloat)headIndent {
    [self zd_addHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}
- (void)zd_addHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    zd_setParagraphStyleProperty(headIndent,range);
}

- (void)setZd_tailIndent:(CGFloat)tailIndent {
    [self zd_addTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}
- (void)zd_addTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    zd_setParagraphStyleProperty(tailIndent,range);
}

- (void)setZd_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self zd_addLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}
- (void)zd_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    zd_setParagraphStyleProperty(lineBreakMode,range);
}

- (void)setZd_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self zd_addMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)zd_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    zd_setParagraphStyleProperty(minimumLineHeight,range);
}

- (void)setZd_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self zd_addMinimumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)zd_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    zd_setParagraphStyleProperty(maximumLineHeight,range);
}

- (void)setZd_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self zd_addBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}
- (void)zd_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    zd_setParagraphStyleProperty(baseWritingDirection,range);
}

- (void)setZd_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self zd_addLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}
- (void)zd_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    zd_setParagraphStyleProperty(lineHeightMultiple,range);
}

- (void)setZd_hyphenationFactor:(float)hyphenationFactor {
    [self zd_addHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}
- (void)zd_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    zd_setParagraphStyleProperty(hyphenationFactor,range);
}

- (void)setZd_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self zd_addDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}
- (void)zd_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    zd_setParagraphStyleProperty(defaultTabInterval,range);
}

- (void)setZd_characterSpacing:(CGFloat)characterSpacing {
    [self zd_addCharacterSpacing:characterSpacing range:NSMakeRange(0, self.length)];
}
- (void)zd_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range {
    [self zd_addAttribute:NSKernAttributeName value:@(characterSpacing) range:range];
}

- (void)setZd_lineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    [self zd_addLineThroughStyle:lineThroughStyle range:NSMakeRange(0, self.length)];
}
- (void)zd_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self zd_addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

- (void)setZd_lineThroughColor:(UIColor *)lineThroughColor {
    [self zd_addLineThroughColor:lineThroughColor range:NSMakeRange(0, self.length)];
}
- (void)zd_addLineThroughColor:(UIColor *)color range:(NSRange)range {
    [self zd_addAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

- (void)setZd_underLineStyle:(NSUnderlineStyle)underLineStyle {
    [self zd_addUnderLineStyle:underLineStyle range:NSMakeRange(0, self.length)];
}
- (void)zd_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self zd_addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

- (void)setZd_underLineColor:(UIColor *)underLineColor {
    [self zd_addUnderLineColor:underLineColor range:NSMakeRange(0, self.length)];
}
- (void)zd_addUnderLineColor:(UIColor *)color range:(NSRange)range {
    [self zd_addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

- (void)setZd_characterLigature:(NSInteger)characterLigature {
    [self zd_addCharacterLigature:characterLigature range:NSMakeRange(0, self.length)];
}
- (void)zd_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range {
    [self zd_addAttribute:NSLigatureAttributeName value:@(characterLigature) range:range];
}

- (void)setZd_strokeColor:(UIColor *)strokeColor {
    [self zd_addStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}
- (void)zd_addStrokeColor:(UIColor *)color range:(NSRange)range {
    [self zd_addAttribute:NSStrokeColorAttributeName value:color range:range];
}

- (void)setZd_strokeWidth:(CGFloat)strokeWidth {
    [self zd_addStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}
- (void)zd_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range {
    [self zd_addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth) range:range];
}

- (void)setZd_shadow:(NSShadow *)shadow {
    [self zd_addShadow:shadow range:NSMakeRange(0, self.length)];
}
- (void)zd_addShadow:(NSShadow *)shadow range:(NSRange)range {
    [self zd_addAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)zd_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    [self zd_addAttribute:NSAttachmentAttributeName value:attachment range:range];
}

- (void)setZd_link:(id)link {
    [self zd_addLink:link range:NSMakeRange(0, self.length)];
}
- (void)zd_addLink:(id)link range:(NSRange)range {
    [self zd_addAttribute:NSLinkAttributeName value:link range:range];
}

- (void)setZd_baseline:(CGFloat)baseline {
    [self zd_addBaseline:baseline range:NSMakeRange(0, self.length)];
}
- (void)zd_addBaseline:(CGFloat)baseline range:(NSRange)range {
    [self zd_addAttribute:NSBaselineOffsetAttributeName value:@(baseline) range:range];
}

- (void)zd_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range {
    [self zd_addAttribute:NSWritingDirectionAttributeName value:@(writingDirection) range:range];
}

- (void)setZd_obliqueness:(CGFloat)obliqueness {
    [self zd_addObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}
- (void)zd_addObliqueness:(CGFloat)obliqueness range:(NSRange)range {
    [self zd_addAttribute:NSObliquenessAttributeName value:@(obliqueness) range:range];
}

- (void)setZd_expansion:(CGFloat)expansion {
    [self zd_addExpansion:expansion range:NSMakeRange(0, self.length)];
}
- (void)zd_addExpansion:(CGFloat)expansion range:(NSRange)range {
    [self zd_addAttribute:NSExpansionAttributeName value:@(expansion) range:range];
}

@end
