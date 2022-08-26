//
//  ZDAttribute.m
//  ZDKit
//
//  Created by jiangzedong on 2022/7/23.
//

#import "ZDAttribute.h"
#import "NSAttributedString+TextKit.h"

@implementation NSAttributedString (ZDAttribute)

- (ZDAttribute *)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range {
    return [self zd_attribute:kTextAttributeName atIndex:index longestEffectiveRange:range];
}

@end

@implementation NSMutableAttributedString (ZDAttribute)

- (void)addTextAttribute:(ZDAttribute *)textAttribute range:(NSRange)range {
    NSDictionary *attributes = textAttribute.attributes;
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [self zd_addAttribute:key value:value range:range];
    }];
    [self zd_addAttribute:textAttribute.attributeName value:textAttribute range:range];
}

@end

@implementation ZDAttribute

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        _attributes = attributes ? [[NSMutableDictionary alloc] initWithDictionary:attributes] : [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - getter && setter

- (NSString *)attributeName {
    return kTextAttributeName;
}

- (UIColor *)color {
    return _attributes[NSForegroundColorAttributeName];
}
- (void)setColor:(UIColor *)color {
    ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
}

- (UIFont *)font {
    return _attributes[NSFontAttributeName];
}
- (void)setFont:(UIFont *)font {
    ((NSMutableDictionary *)_attributes)[NSFontAttributeName] = font;
}

- (UIColor *)backgroundColor {
    return _attributes[NSBackgroundColorAttributeName];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    ((NSMutableDictionary *)_attributes)[NSBackgroundColorAttributeName] = backgroundColor;
}

- (NSUnderlineStyle)underLineStyle {
    return [_attributes[NSUnderlineStyleAttributeName] integerValue];
}
- (void)setUnderLineStyle:(NSUnderlineStyle)underLineStyle {
    ((NSMutableDictionary *)_attributes)[NSUnderlineStyleAttributeName] = @(underLineStyle);
}

- (UIColor *)underLineColor {
    return _attributes[NSUnderlineColorAttributeName];
}
- (void)setUnderLineColor:(UIColor *)underLineColor {
    ((NSMutableDictionary *)_attributes)[NSUnderlineColorAttributeName] = underLineColor;
}

- (NSUnderlineStyle)lineThroughStyle {
    return [_attributes[NSStrikethroughStyleAttributeName] integerValue];
}
- (void)setLineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughStyleAttributeName] = @(lineThroughStyle);
}

- (UIColor *)lineThroughColor {
    return _attributes[NSStrikethroughColorAttributeName];
}
- (void)setLineThroughColor:(UIColor *)lineThroughColor {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughColorAttributeName] = lineThroughColor;
}

- (CGFloat)strokeWidth {
    return [_attributes[NSStrokeWidthAttributeName] floatValue];
}
- (void)setStrokeWidth:(CGFloat)strokeWidth {
     ((NSMutableDictionary *)_attributes)[NSStrokeWidthAttributeName] = @(strokeWidth);
}

- (UIColor *)strokeColor {
    return _attributes[NSStrokeColorAttributeName];
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = strokeColor;
}

- (NSShadow *)shadow {
    return _attributes[NSShadowAttributeName];
}
- (void)setShadow:(NSShadow *)shadow {
    ((NSMutableDictionary *)_attributes)[NSShadowAttributeName] = shadow;
}

@end
