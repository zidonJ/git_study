//
//  ZDAttribute.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDAttribute;

static NSString *const kTextAttributeName = @"ZDTextAttribute";

@interface NSAttributedString (TYTextAttribute)

- (ZDAttribute *__nullable)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

@end


@interface NSMutableAttributedString (TYTextAttribute)

- (void)addTextAttribute:(ZDAttribute *)textAttribute range:(NSRange)range;

@end


@interface ZDAttribute : NSObject

@property (nonatomic, strong , readonly) NSString *attributeName;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

// underline
@property (nonatomic, assign) NSUnderlineStyle underLineStyle;
@property (nonatomic, strong, nullable) UIColor *underLineColor;

// line through
@property (nonatomic, assign) NSUnderlineStyle lineThroughStyle;
@property (nonatomic, strong, nullable) UIColor *lineThroughColor;

// stroke
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong, nullable) UIColor *strokeColor;

// shadow
@property (nonatomic, strong, nullable) NSShadow *shadow;

- (instancetype)initWithAttributes:(nullable NSDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
