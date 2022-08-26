//
//  ZDCoreTextView.m
//  test
//
//  Created by jiangzedong on 2022/6/23.
//

#import "ZDCoreTextView.h"
#import <CoreText/CoreText.h>

NS_INLINE long getNumberOfLinesWithText(NSMutableAttributedString *text,float width) {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
    CGMutablePathRef Path = CGPathCreateMutable();
    CGPathAddRect(Path, NULL ,CGRectMake(0 , 0 , width, INT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
    CFArrayRef rows = CTFrameGetLines(frame);
    long numberOfLines = CFArrayGetCount(rows);
    CFRelease(frame);
    CGPathRelease(Path);
    CFRelease(framesetter);
    return numberOfLines;
}

/*
 - CTFrame可以想象成画布, 画布的大小范围由CGPath决定
 - CTFrame由很多CTLine组成, CTLine表示为一行
 - CTLine由多个CTRun组成, CTRun相当于一行中的多个块, 但是CTRun不需要你自己创建, 由NSAttributedString的属性决定, 系统自动生成。每个CTRun对应不同属性。
 - CTFramesetter是一个工厂, 创建CTFrame, 一个界面上可以有多个CTFrame
 - CTFrame就是一个基本画布，然后一行一行绘制。 CoreText会自动根据传入的NSAttributedString属性创建CTRun，包括字体样式，颜色，间距等
 */

@interface ZDCoreTextView () {
    
    CTFramesetterRef _framesetter;
    CTFrameRef _ctframe;
    CGMutablePathRef _path;
}

@end

@implementation ZDCoreTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.lightGrayColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self configCtframe];
    //[self ctFrame];
    [self ctLine];
}

- (CTFrameRef)configCtframe
{
    NSString *str = @"xXHhofiyYI这是一段中文，前面是大小写,脑袋都是你，心理都是你，小小的爱在大城里好甜蜜。hiding rain and snow trying to forget but i wont't let go,take me to your heart,take me to your soul,give me your hand before i old.";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    [attributedString addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, str.length)];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:UIColor.blueColor} range:NSMakeRange(0, str.length)];
    NSRange range = [str rangeOfString:@"hiding rain and snow trying to forget but i wont't let go"];
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:20],
                           NSForegroundColorAttributeName:UIColor.greenColor};
    [attributedString addAttributes:dict range:range];
    
    if (!_path) {
        _path = CGPathCreateMutable();
        CGPathAddRect(_path, NULL, self.bounds);
    }
    if (!_framesetter) {
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    }
    if (!_ctframe) {
        _ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [attributedString length]), _path, NULL);
    }
    return _ctframe;
}

- (void)ctFrame
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(_ctframe,context);
    
    CFRelease(_ctframe);
    CFRelease(_path);
    CFRelease(_framesetter);
}

- (void)ctRun
{
    
}

- (void)ctLine
{
    CFArrayRef lines = CTFrameGetLines(_ctframe);
    long numberOfLines = CFArrayGetCount(lines);
    // 3.获得每一行的origin, CoreText的origin是在字形的baseLine处的, 请参考字形图
    CGPoint lineOrigins[numberOfLines];
    for (int i = 0; i<numberOfLines; i++) {
        lineOrigins[i] = CGPointZero;
    }
    CTFrameGetLineOrigins(_ctframe, CFRangeMake(0, 0), lineOrigins);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // 4.遍历每一行进行绘制
    for (int i=0; i<numberOfLines; i++) {
        CGPoint point = lineOrigins[i];
        const void * line = CFArrayGetValueAtIndex(lines, i); // 内包含多个CTRun
        NSLog(@"%@",(__bridge id)CTRunGetAttributes(line));
        CGContextSetTextPosition(context, point.x, point.y);
        CTLineDraw(line, context);
    }
}

- (void)ctGlyphInfo
{
    
}

@end
