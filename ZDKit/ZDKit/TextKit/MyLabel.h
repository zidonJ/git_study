//
//  MyLabel.h
//  ZDKit
//
//  Created by jiangzedong on 2022/7/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDTextRender;

@interface MyLabel : UIView

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong, nullable) ZDTextRender *textRender;

@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;


@property (nonatomic, strong) NSAttributedString *truncation; /// 截断

@end

NS_ASSUME_NONNULL_END
