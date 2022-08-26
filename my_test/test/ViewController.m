//
//  ViewController.m
//  test
//
//  Created by jiangzedong on 2020/11/30.
//

#import "ViewController.h"
#import <objc/runtime.h>
#include "fishhook.h"
#import "NSAttributedString+TYText.h"
#import "TYTextAttachment.h"
#import <mach-o/dyld.h>
#import "Simple.h"
#import "NSTimer+Block.h"
#import <CoreText/CoreText.h>
#import "ZDCoreTextView.h"

typedef struct {
    NSMutableString *str;
    NSArray *arr;
} MyStruct;

NS_INLINE UIColor *hexColor(uint64_t hex,double alpha) {
    double red = ((hex & 0xFF0000) >> 16)/255.0;
    double green = ((hex & 0xFF00) >> 8)/255.0;
    double blue = (hex & 0xFF)/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

static UITapGestureRecognizer *tap;

@protocol TestProtocol <NSObject>

@property (nonatomic, copy) NSString *name;

@end

@interface NSObject (Foo)
+(void)foo;
//-(void)foo;
@end

@implementation NSObject (Foo)
- (void)foo {
    NSLog(@"IMP: -[NSObject (Foo) foo]");
}
//+ (void)foo {
//    NSLog(@"IMP: -[NSObject.new (Foo) foo]");
//}
@end

@interface TS : UIScrollView

@property (nonatomic, assign) NSInteger sIdentfier;
@property (nonatomic, assign) BOOL containedInside;
@property (nonatomic, assign) CGPoint hitPoint;

@end

@implementation TS

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    NSLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer:%ld",self.sIdentfier);
//    if ([self isNeedFailAvailableAction:gestureRecognizer]) {
//        return YES;
//    }
//    return NO;
//
//}

- (BOOL)isNeedFailAvailableAction:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.contentOffset.y <= 0) {
        if (gestureRecognizer == self.panGestureRecognizer) {
            CGPoint velocity = [self.panGestureRecognizer velocityInView:self.panGestureRecognizer.view];
            if(velocity.y > 0) {
                return YES;
            }
        }
        
    }
    return NO;
}

//- (BOOL)

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"gestureRecognizerShouldBegin:%ld",self.sIdentfier);
//    if (self.sIdentfier == 1) {
//        return self.containedInside;
//    }
    
//    if (self.sIdentfier == 1) {
//        if (CGRectContainsPoint(self.frame, self.hitPoint)) {
//            return YES;
//        } else {
//            return NO;
//        }
//    }
//    return NO;
//    if ([self isNeedFailAvailableAction:gestureRecognizer]) {
//        return NO;
//    }
    return YES;
 
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return self.sIdentfier == 1;
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"TS:%ld",self.sIdentfier);
    self.hitPoint = point;
//    if (self.sIdentfier == 1) {
//        if (CGRectContainsPoint(self.frame, point)) {
//            self.containedInside = YES;
//        } else {
//            self.containedInside = NO;
//        }
//    }
    return [super hitTest:point withEvent:event];
}

@end

@interface MyView : UIView

//- (void)jump:(NSString *)str;
@end

@implementation MyView

- (void)jump:(NSString *)str
{
    NSLog(@"jump%@",str);
}

@end


@interface TestView : MyView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger index;

@end

@implementation TestView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"TestView touch%ld",self.index);
    
}

//MARK: use Imp call
- (void)jump:(NSString *)str
{
    if ([str isEqualToString:@"高"]) {
//        Method method = class_getInstanceMethod([MyView class], @selector(jump:));
//        IMP imp = method_getImplementation(method);
//        ((void (*)(id, SEL,NSString *))imp)(self, @selector(jump:),@"高");
        
        SEL sel = @selector(jump:);
        IMP imp = [MyView instanceMethodForSelector:sel];
        ((void (*) (id,SEL,NSString *))imp)(self,sel,@"高");
        return;
    }
    NSLog(@"子类的jump");
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame] ) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
        tap.cancelsTouchesInView = NO;
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"hitTest:+++++:%ld",self.index);
    return [super hitTest:point withEvent:event];
//    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizerShouldBegin:+++++:%ld",self.index);
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == tap || [touch.gestureRecognizers containsObject:tap]) {
        NSLog(@"shouldReceiveTouch:非当前view手势");
    }
    NSLog(@"shouldReceiveTouch:+++++:%ld",self.index);
//    if (self.index > 5) {
//        return NO;
//    }
    return YES;
}

- (void)tapView
{
    NSLog(@"[%d]+++++:%ld",__LINE__,self.index);
    
//    SEL sel = @selector(jump:);
//    IMP imp = [super methodForSelector:sel];
//    id obj = self.superclass;
////    ((void(*)(id,SEL,UIColor *))imp)(self,sel,UIColor.redColor);
//    ((void (*) (id,SEL,NSString *))imp)(obj,sel,@"高");
    
//    [self jump:@"高"];
}

@end

@interface NSString (nilBlockTest)

- (NSString * (^) (void))localText;

@end

@implementation NSString (nilBlockTest)

- (NSString *(^)(void))localText
{
    return ^NSString *{
        return self;
    };
}

@end

@interface MyLoadView : UIView

@end

@implementation MyLoadView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"loadView touch");
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"loadView hitTest");
    return [super hitTest:point withEvent:event];
}

@end



typedef NS_ENUM(NSUInteger,WBSVArcShapeDirect) {
    WBSVArcShapeDirectRight = 1,
    WBSVArcShapeDirectLeft
};

@interface WBSVArcShapeGradientView : UIView

@property (nonatomic, strong) UIBezierPath *shapePath;
@property (nonatomic, assign) CGFloat radius;

@end

@implementation WBSVArcShapeGradientView

- (void)generateLayer:(WBSVArcShapeDirect)direct
{
    _radius = 550;
    BOOL isRight = direct == WBSVArcShapeDirectRight;
    NSArray *colorArr = @[(__bridge id)hexColor(0x0000FF,0.5).CGColor,
                          (__bridge id)hexColor(0x87CEFA,1.0).CGColor];
    CAGradientLayer *_gradientLeftLayer = [[CAGradientLayer alloc] init];
    _gradientLeftLayer.colors = colorArr;
    _gradientLeftLayer.startPoint = CGPointMake(isRight ? 0:1, 0);
    _gradientLeftLayer.endPoint   = CGPointMake(isRight ? 1:0, 0);
    [self.layer addSublayer:_gradientLeftLayer];
    _gradientLeftLayer.frame = self.bounds;
    
    CAShapeLayer *shaperLayer = [[CAShapeLayer alloc] init];
    shaperLayer.strokeColor = UIColor.redColor.CGColor;
    shaperLayer.fillColor = UIColor.clearColor.CGColor;
    shaperLayer.lineWidth = 30.0;
    [self.layer addSublayer:shaperLayer];
    
    _gradientLeftLayer.mask = shaperLayer;
    
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGFloat binaryHeight = height/2.0;
    
    CGFloat midWidth = sqrt(pow(self.radius, 2) - pow(binaryHeight, 2)) - (self.radius - width);
    //self.radius = sqrt(pow(binaryHeight,2)+pow(midWidth, 2));
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (NO) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(midWidth, 0)];
        [path addArcWithCenter:CGPointMake(-(self.radius - width), binaryHeight) radius:self.radius startAngle:atan(-binaryHeight/midWidth) endAngle:atan(binaryHeight/midWidth) clockwise:YES];
        [path addLineToPoint:CGPointMake(midWidth, height)];
        [path addLineToPoint:CGPointMake(0, height)];
    } else {
        path.lineWidth = 30.0;
        [path moveToPoint:CGPointMake(width - midWidth, 0)];
        [path addLineToPoint:CGPointMake(width, 0)];
        [path addLineToPoint:CGPointMake(width, height)];
        [path addLineToPoint:CGPointMake(width - midWidth, height)];
        [path addArcWithCenter:CGPointMake(self.radius, binaryHeight)
                        radius:self.radius
                    startAngle:M_PI - atan(binaryHeight/(self.radius-(width - midWidth)))
                      endAngle:M_PI + atan(binaryHeight/(self.radius-(width - midWidth)))
                     clockwise:YES];
    }
    [path closePath];
    self.shapePath = path;
    shaperLayer.path = path.CGPath;
    
    
    shaperLayer.frame = _gradientLeftLayer.bounds;
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        if (isRight) {
//            [path moveToPoint:CGPointMake(0, 0)];
//            [path addLineToPoint:CGPointMake(midWidth, 0)];
//            [path addArcWithCenter:CGPointMake(0, binaryHeight) radius:sqrtf(binaryHeight*binaryHeight+midWidth*midWidth) startAngle:atan(-binaryHeight/midWidth) endAngle:atan(binaryHeight/midWidth) clockwise:YES];
//            [path addLineToPoint:CGPointMake(midWidth, height)];
//            [path addLineToPoint:CGPointMake(0, height)];
//        } else {
//            //按顺序添加
//            [path moveToPoint:CGPointMake(width - midWidth, 0)];
//            [path addLineToPoint:CGPointMake(width, 0)];
//            [path addLineToPoint:CGPointMake(width, height)];
//            [path addLineToPoint:CGPointMake(width - midWidth, height)];
//            [path addArcWithCenter:CGPointMake(width, binaryHeight) radius:sqrtf(binaryHeight*binaryHeight+midWidth*midWidth) startAngle:atan(binaryHeight/midWidth) endAngle:atan(-binaryHeight/midWidth) clockwise:YES];
//        }
//        [path closePath];
//
//        self.shapePath = path;
//        shaperLayer.path = path.CGPath;
//
//
//        shaperLayer.frame = _gradientLeftLayer.bounds;
//    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    BOOL contained = [_shapePath containsPoint:[touch locationInView:self]];
    if (contained) {
        NSLog(@"在弧形区域内");
    } else {
        NSLog(@"在弧形区域外");
    }
}

@end

#define WBTry(exp) {\
    @try {\
        exp\
    } @catch (NSException *exception) {\
        return nil;\
    } @finally {\
        \
    }\
}

@interface ViewController () <TestProtocol,UIScrollViewDelegate,CAAnimationDelegate>
{
    BOOL _loopOut;
    UISlider *_slider;
    UIScrollView *sc;
    BOOL _forceLandscape;
    MyStruct _mStruct;
}
@property (nonatomic, strong) UIView *v1;
@property (nonatomic, strong) UIView *v2;
@property (nonatomic, strong) UIView *orv;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ViewController

@synthesize name;

- (void)testInt:(int *)a {
    *a = 132618;
}

#define metamacro_concat_(A, B) A ## B

#define metamacro_concat(A, B) \
        metamacro_concat_(A, B)


#define metamacro_argcount(...) \
        metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
 
#define metamacro_at(N, ...) \
        metamacro_concat(metamacro_at, N)(__VA_ARGS__)

#define metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
        metamacro_concat(metamacro_foreach_cxt, metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

#define TestBlock(block)\
if (block) {\
    !block?:block(123);\
}

//MARK:  弧度转角度
#define Radians_To_Degrees(radians) ((radians) * (180.0 / M_PI))
//MARK:  角度转弧度
#define Degrees_To_Radians(angle) ((angle) / 180.0 * M_PI)



//MARK: Actions
- (void)tap
{
    NSLog(@"触发了手势");
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(100, 15, 20, 20)];
//    v.backgroundColor = UIColor.redColor;
//    [_slider.subviews[0] insertSubview:v atIndex:2];
//
//    CGFloat sin90 = sin(Degrees_To_Radians(90));
//    CGFloat cos90 = cos(Degrees_To_Radians(90));
//    NSLog(@"%f-%f",sin90,cos90);
//    self.view.transform = CGAffineTransformMake(cos(Degrees_To_Radians(60)), sin(Degrees_To_Radians(60)), -sin(Degrees_To_Radians(60)), cos(Degrees_To_Radians(60)), 10, 10);
    
    
    //10   150 125 110
    UIView *v = [self.view viewWithTag:100];
    
    CGFloat scale = 0.1;
    CGFloat x = v.frame.size.width/2 - v.frame.size.width*scale/2;
    CGFloat y = v.frame.size.height/2 - v.frame.size.height*scale/2;
    
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        v.alpha = 0;
        v.transform = CGAffineTransformMake(scale, 0, 0, scale, -x, y);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
            v.alpha = 1;
            v.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
    
//    Class cls = [self class];
//    [cls panAction];
}

- (void)panAction
{
    sc.frame = CGRectMake(0, sc.frame.origin.y + 5,self.view.frame.size.width, self.view.frame.size.height);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)clickButton
{
    NSLog(@"131321321");
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    if (strcmp(@encode(void), "v") == 0) {
//    } else if (strcmp(@encode(NSObject *), "@") == 0 || strcmp(@encode(Class), "#") == 0) {
//    } else {
//    }
//
//    NSMethodSignature* methodSig = [self methodSignatureForSelector:@selector(testTry)];
//    const char* retType = [methodSig methodReturnType];
//    if (strcmp(retType, "v") == 0) {
//        NSLog(@"返回值类型:%s",retType);
//    }
//    [NSObject foo];
//    [NSObject.new foo];
//    _loopOut = YES;

//    [self corner_shadow];
//    [self testKitTest];
//    [self threadKeepAlive];
//    [self progressTest];
//    [self progressTest];
//    [self sliderTest];
//    [self scrollPanTest];
//    [self test_uicontrol];
//    [self touch_gesture_conflict];
//    [self testButton];
//    [self optionsView];
//    NSString *str = @"234";
//    NSLog(@"%@",str);
//    [self gestureSequence];
//    dylibCheck();
//    dispatch_queue_t queue = dispatch_queue_create("manyThread", DISPATCH_QUEUE_SERIAL);
//    for (int i = 0; i<20; i++) {
//        dispatch_async(queue, ^{
//            NSLog(@"---:%@",NSThread.currentThread);
//        });
//    }
//    [self jumpVC];
//    [self addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew) context:nil];
    
//    [self drawAArcShapeArea];
//    [self testSet];
//    [self springAnimation];
//    [self testKeyPath];
//    [self twoScrollView];
//    [self testCoreText];
//    [self testStruct];
//    [self menuController];
}

- (void)menuController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.arrowDirection = UIMenuControllerArrowDown;//UIMenuControllerArrowLeft
        CGRect rect = CGRectMake(100, 100, 100, 100);
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    });
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSLog(@"%@",NSStringFromSelector(action));
    
    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(paste:)) {
        return YES;
    }
    
    return NO;
}

//监听事情需要对应的方法 冒号之后传入的是UIMenuController
- (void)cut:(UIMenuController *)menu
{
    NSLog(@"%s %@", __func__, menu);
}

- (void)copy:(UIMenuController *)menu
{
    NSLog(@"%s %@", __func__, menu);
}

- (void)paste:(UIMenuController *)menu
{
    NSLog(@"%s %@", __func__, menu);
}

- (void)testStruct
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"1"];
    [array addObject:@"2"];
    [array addObject:@"3"];
    NSMutableString *str = [@"take me to your heart" mutableCopy];
    
    _mStruct.str = str;
    _mStruct.arr = array;
    
    void (^test) (MyStruct s) = ^(MyStruct s) {
        s.str = @"213".mutableCopy;
        s.arr = [@[@"a",@"b",@"c"] mutableCopy];
        NSLog(@"%@-%@",s.str,s.arr);
    };
    test(_mStruct);
    NSLog(@"%@-%@",_mStruct.str,_mStruct.arr);
}


- (void)testCoreText
{
    ZDCoreTextView *ctv = [[ZDCoreTextView alloc] initWithFrame:CGRectMake(10, 150, self.view.width - 20, 400)];
    [self.view addSubview:ctv];
}
TS *s1;
TS *s2;
- (void)twoScrollView
{
    s1 = [[TS alloc] initWithFrame:CGRectMake(10, 100, 300, 500)];
    s1.backgroundColor = UIColor.yellowColor;
    s1.contentSize = CGSizeMake(300, 2000);
    s1.scrollEnabled = NO;
    s1.sIdentfier = 100;
    s1.delegate = self;
    s1.showsVerticalScrollIndicator = YES;
    [self.view addSubview:s1];

    s2 = [[TS alloc] initWithFrame:CGRectMake(20, 20, 100, 200)];
    s2.backgroundColor = UIColor.blueColor;
    s2.contentSize = CGSizeMake(100, 500);
    s2.sIdentfier = 1;
    s2.delegate = self;
    s2.showsVerticalScrollIndicator = YES;
    [s1 addSubview:s2];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [s1.panGestureRecognizer requireGestureRecognizerToFail:s2.panGestureRecognizer];
    if (scrollView == s2) {
        s1.scrollEnabled = NO;
    } else {
        s1.scrollEnabled = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    s1.scrollEnabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    s1.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    s1.scrollEnabled = YES;
}

#define keypath1(PATH) \
(((void)(NO && ((void)PATH, NO)), strchr(# PATH, '.') + 1))

#define AnimationKeyPath(KeyPath) \
(strchr(# KeyPath, '.') + 1)

#define AnimationKeyPath(KeyPath) \
(strchr(# KeyPath, '.') + 1)
- (void)testKeyPath
{
//    printf("%s\n", AnimationKeyPath(Hello.china.shanghai));
    NSLog(@"%s:---\n",AnimationKeyPath(self.view.bounds.size.width));
}

- (void)testSet
{
    NSMutableSet *set = [NSMutableSet set];
    NSString *str = @"123";
    
    [set addObject:str];
    
    str = @"1234";
    [set addObject:str];
    NSLog(@"%@",set);
}

- (void)drawAArcShapeArea
{
    
    //创建一个View
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 200, 200)];
    maskView.backgroundColor = [UIColor grayColor];
    maskView.alpha = 0.8;
    [self.view addSubview:maskView];
    
    maskView.center = self.view.center;
    
    self.v1 = maskView;
    
    //贝塞尔曲线 画一个带有圆角的矩形
    UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, maskView.width - 20, maskView.height - 20) cornerRadius:15];
    //贝塞尔曲线 画一个圆形

    // 创建矩形
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:CGRectMake(maskView.width/2.0 - 25, maskView.height/2.0 - 25, 50, 50)];
    [bpath appendPath:circlePath];

    //        [bpath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(160, 300, 100, 100) cornerRadius:15]];
    //创建一个CAShapeLayer 图层
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bpath.CGPath;
    shapeLayer.fillColor = UIColor.greenColor.CGColor;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    //添加图层蒙板
    //    [self.view.layer addSublayer:shapeLayer];
    //    shapeLayer.position = CGPointMake(0, 0);
    maskView.layer.mask = shapeLayer;
    
//    self.view.backgroundColor = UIColor.lightGrayColor;
//
//    WBSVArcShapeGradientView *asgView = [[WBSVArcShapeGradientView alloc] initWithFrame:CGRectMake(10, 140, 140, self.view.width)];
//    asgView.clipsToBounds = NO;
//    [asgView generateLayer:(WBSVArcShapeDirectLeft)];
//    [self.view addSubview:asgView];
    
}

- (void)jumpVC
{
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button addTarget:self action:@selector(jumpvcAction) forControlEvents:(UIControlEventTouchUpInside)];
    button.backgroundColor = UIColor.greenColor;
    button.frame = CGRectMake(200, 500, 100, 100);
    [self.view addSubview:button];
}

- (void)jumpvcAction
{
    id jvc = [NSClassFromString(@"JumpViewController") new];
    [self.navigationController pushViewController:jvc animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"%@",change);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
        return UIStatusBarStyleDarkContent;
    }
      
    //设置是否隐藏
    - (BOOL)prefersStatusBarHidden {
    //    [super prefersStatusBarHidden];
        return NO;
    }
      
    //设置隐藏动画
    - (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
        return UIStatusBarAnimationNone;
    }

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                         name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}


void dylibCheck(void) {
    uint32_t count = _dyld_image_count();
    for(uint32_t i = 0; i < count; i++) {
        const char *dyld = _dyld_get_image_name(i);
        NSLog(@"++++++++++:%s",dyld);
    }
}

- (void)optionsView
{
    UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
    v.frame = CGRectMake(100, 100, 100, 100);
    v.backgroundColor = UIColor.redColor;
    [self.view addSubview:v];
    v.clipsToBounds = YES;
    
    CALayer *layer = [[CALayer alloc] init];
    layer.backgroundColor = UIColor.greenColor.CGColor;
    [v.layer addSublayer:layer];
    layer.frame = v.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:v.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft
                                                         cornerRadii:CGSizeMake(10, 10)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = v.bounds;
    maskLayer.path = maskPath.CGPath;
    maskLayer.strokeColor = UIColor.purpleColor.CGColor;
    maskLayer.fillColor = UIColor.lightGrayColor.CGColor;
    v.layer.mask = maskLayer;
}

+ (UIImage *)resizeWithImage:(UIImage *)image {
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)
                                 resizingMode:UIImageResizingModeStretch];
}

- (void)testButton
{
//    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
//    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    [button setImage:[UIImage imageNamed:@"video_common_vote_prompt_title"] forState:(UIControlStateNormal)];
//    button.backgroundColor = UIColor.clearColor;
//    button.frame = CGRectMake(10, 100, 55, 26);
//    [self.view addSubview:button];

    
//    UIButton *button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    UIImage *image = [[self class] resizeWithImage:[UIImage imageNamed:@"video_common_vote_prompt_background"]];
//    [button1 setBackgroundImage:image forState:(UIControlStateNormal)];
//    [button1 setTitle:@"节假日该学习还是该娱乐？  " forState:(UIControlStateNormal)];
//    [button1 setTitleColor:UIColor.redColor forState:(UIControlStateNormal)];
//    button1.titleLabel.font = [UIFont systemFontOfSize:17];
//    CGSize size = [button1 sizeThatFits:CGSizeMake(1000, 26)];
//    button1.frame = CGRectMake(65, 100, size.width, 26);
//    [button1 addTarget:self action:@selector(clickButton1) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.view addSubview:button1];
    
    self.view.backgroundColor = UIColor.lightGrayColor;
    
    UIButton *left = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIImage *imgLeft = [UIImage imageNamed:@"svideo_ad_button_white"];
    [left setImage:imgLeft forState:(UIControlStateNormal)];
    left.frame = CGRectMake(10, 100, 144, 34);
    [left addTarget:self action:@selector(specialBtnLeftAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:left];
    
    UIButton *right = [UIButton buttonWithType:(UIButtonTypeCustom)];
    
    UIImage *imgRight = [UIImage imageNamed:@"svideo_ad_button_white2"];
    [right setImage:imgRight forState:(UIControlStateNormal)];
    right.frame = CGRectMake(left.right - 4, 100, 144, 34);
    [right addTarget:self action:@selector(specialBtnRightAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:right];
    
//    UIView *v = [[UIView alloc] initWithFrame:button1.frame];
//    v.backgroundColor = UIColor.greenColor;
//    v.userInteractionEnabled = NO;
//    [self.view addSubview:v];
}

- (void)specialBtnLeftAction
{
    NSLog(@"left");
}
- (void)specialBtnRightAction
{
    NSLog(@"right");
}


NSInteger count = 0;

- (void)clickButton1
{
    if (count >= 1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    }
    count += 1;
    NSLog(@"阻挡");
}

- (void)test_uicontrol
{
    UIControl *trol = [[UIControl alloc] initWithFrame:self.view.bounds];
    trol.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:trol];
    
    [trol addTarget:self action:@selector(toucTown) forControlEvents:(UIControlEventTouchDown)];
    [trol addTarget:self action:@selector(toucUp) forControlEvents:(UIControlEventTouchUpInside)];
    [trol addTarget:self action:@selector(toucMoved) forControlEvents:(UIControlEventValueChanged)];
}

- (void)toucTown
{
    NSLog(@"123");
}

- (void)toucUp
{
    NSLog(@"123");
}

- (void)toucMoved
{
    NSLog(@"123");
}

- (void)corner_shadow
{
    UIView *shadowLayer = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    shadowLayer.layer.shadowColor = UIColor.blackColor.CGColor;
    shadowLayer.layer.shadowRadius = 5;
    shadowLayer.layer.shadowOpacity = 0.5;
    shadowLayer.layer.shadowOffset = CGSizeZero;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shadowLayer.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    shadowLayer.layer.shadowPath = path.CGPath;
    [self.view addSubview:shadowLayer];
    
    UIImageView *imagev = [[UIImageView alloc] init];
    imagev.image = [UIImage imageNamed:@"22"];
    imagev.frame = CGRectMake(100, 200, 100, 100);
    imagev.layer.masksToBounds = YES;
    imagev.layer.cornerRadius = 5;
    imagev.layer.shadowOpacity = 1;
    imagev.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:imagev];
    
    
//    CALayer *cornerLayer = [CALayer layer];
//    cornerLayer.frame = imagev.bounds;
////    cornerLayer.anchorPoint = imagev.layer.anchorPoint;
////    cornerLayer.position = imagev.layer.position;
//    cornerLayer.backgroundColor = UIColor.clearColor.CGColor;
//
//    // 任意圆角
//    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:imagev.bounds
//                                           byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)].CGPath;
//    CAShapeLayer *lay = [CAShapeLayer layer];
//    lay.path = path;
//    cornerLayer.mask = lay;
//    [imagev.layer addSublayer:cornerLayer];
}

- (void)springAnimation
{
    self.view.backgroundColor = UIColor.lightGrayColor;
    
    // 缩放动画
//    CABasicAnimation * scaleAnim = [CABasicAnimation animation];
//    scaleAnim.keyPath = @"transform.scale";
//    scaleAnim.fromValue = @0.1;
//    scaleAnim.toValue = @1;
//    scaleAnim.duration = 2;
//    // 透明度动画
//    CABasicAnimation *opacityAnim=[CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnim.fromValue= @1;
//    opacityAnim.toValue= @0.1;
//    opacityAnim.duration= 2;
    
    
    
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 110, 36)];
    v1.backgroundColor = UIColor.whiteColor;
    v1.alpha = 0;
    v1.layer.cornerRadius = 18;
    v1.layer.masksToBounds = YES;
    [self.view addSubview:v1];
    self.v1 = v1;

    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    v2.backgroundColor = UIColor.whiteColor;
    v2.alpha = 0;
    v2.layer.cornerRadius = 13;
    v2.layer.masksToBounds = YES;
    [self.view addSubview:v2];
    self.v2 = v2;

    UIView *orv = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 100, 26)];
    orv.layer.cornerRadius = 13;
    orv.layer.masksToBounds = YES;
    orv.backgroundColor = UIColor.blueColor;
    [self.view addSubview:orv];
    self.orv = orv;

    v1.center = orv.center;
    v2.center = orv.center;
    
    
}

static CAAnimationGroup *_sg;

- (void)springAni
{
    self.view.backgroundColor = UIColor.lightGrayColor;
    self.orv.alpha = 0.5;
//    self.orv.backgroundColor = hexColor(0xFF00FF, 0.3); // hexColor(0xFF00FF, 0.3)
    CGFloat oriWidth = self.orv.width;
    CGFloat oriHeight = self.orv.height;
    CGFloat oriLeft = self.orv.x;
    CGFloat oriTop = self.orv.y;

    // 创建矩形
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:self.orv.frame byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(oriHeight/2.0, oriHeight/2.0)];

    //        [bpath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(160, 300, 100, 100) cornerRadius:15]];
    //创建一个CAShapeLayer 图层
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = circlePath.CGPath;
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = UIColor.whiteColor.CGColor;
    
    UIBezierPath *shapeOut = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(oriLeft-25, oriTop-25, oriWidth+50, oriHeight+50) byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(oriHeight/2.0 + 25.0, oriHeight/2.0+25.0)];
    
    UIBezierPath *shapeIn = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(oriLeft, oriTop, oriWidth, oriHeight) byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(oriHeight/2.0 + 25.0, oriHeight/2.0+25.0)];

    [shapeOut appendPath:shapeIn];
    
    CAShapeLayer *shapeLayerMask = [CAShapeLayer layer];
    shapeLayerMask.path = shapeOut.CGPath;
    shapeLayerMask.fillColor = UIColor.purpleColor.CGColor;
    shapeLayerMask.strokeColor = UIColor.redColor.CGColor;
    shapeLayerMask.fillRule = kCAFillRuleEvenOdd;
    
//    [self.view.layer insertSublayer:shapeLayer below:self.orv.layer];
    [self.view.layer addSublayer:shapeLayer];
//    shapeLayer.frame = self.orv.frame;
    shapeLayer.mask = shapeLayerMask;
    
//    [self.view.layer addSublayer:shapeLayerMask];
    
//    return;
    CAKeyframeAnimation *animationshape = [[CAKeyframeAnimation alloc] init];
    animationshape.keyPath = @"lineWidth";
    animationshape.values = @[@(2), @(20), @(2)];
    animationshape.keyTimes = @[@0, @0.7,@1.0];
    animationshape.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animationshape.animations = @[animationr,animation,animationy,opacity];
//    animationshape.removedOnCompletion = NO;
//    animationshape.fillMode = kCAFillModeForwards;
//    animationshape.duration = 2.5;
//    animationshape.repeatCount = FLT_MAX;
//    [shapeLayer addAnimation:animationshape forKey:@"234"];
    
    CAKeyframeAnimation *animationshapeColor = [[CAKeyframeAnimation alloc] init];
    animationshapeColor.keyPath = @"strokeColor";
    animationshapeColor.values = @[(__bridge  id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
                                   (__bridge  id)[UIColor colorWithWhite:1.0 alpha:0.3].CGColor,
                                   (__bridge  id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
    animationshapeColor.keyTimes = @[@0, @0.7,@1.0];
    animationshapeColor.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *_groupsShape = [CAAnimationGroup animation];
    _groupsShape.animations = @[animationshape,animationshapeColor];
    _groupsShape.removedOnCompletion = NO;
    _groupsShape.fillMode = kCAFillModeForwards;
    _groupsShape.duration = 2.5;
    _groupsShape.repeatCount = 1;
    _groupsShape.delegate = self;
    [shapeLayer addAnimation:_groupsShape forKey:@"inside"];
    
    
    return;
    
    CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
    animation.keyPath = @"bounds.size.width";
    animation.values = @[@(oriWidth + 10.0), @(oriWidth + 30.0), @(oriWidth + 10.0)];
    animation.keyTimes = @[@0, @0.7,@1.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CAKeyframeAnimation *animationy = [[CAKeyframeAnimation alloc] init];
    animationy.keyPath = @"bounds.size.height";
    animationy.values = @[@(oriHeight + 10.0), @(oriHeight + 30.0), @(oriHeight + 10.0)];
    animationy.keyTimes = @[@0, @0.7,@1.0];
    animationy.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


    CAKeyframeAnimation *animationr = [[CAKeyframeAnimation alloc] init];
    animationr.keyPath = @"cornerRadius";//bounds.size
    animationr.values = @[@(18.0), @(28.0), @(18.0)];
    animationr.keyTimes = @[@0, @0.7,@1.0];
    animationr.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


    CAKeyframeAnimation *opacity = [[CAKeyframeAnimation alloc] init];
    opacity.keyPath = @"opacity";
    opacity.values = @[@0, @0.3, @0.3, @0];
    opacity.keyTimes = @[@0, @0.3, @0.7, @1.0];
    opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    // 创建动画组
    CAAnimationGroup *_groups =[CAAnimationGroup animation];
    _groups.animations = @[animationr,animation,animationy,opacity];
    _groups.removedOnCompletion = NO;
    _groups.fillMode = kCAFillModeForwards;
    _groups.duration = 2.5;
    _groups.repeatCount = FLT_MAX;
    [self.v1.layer addAnimation:_groups forKey:@"ani"];
    
    CAKeyframeAnimation *animationInside = [[CAKeyframeAnimation alloc] init];
    animationInside.keyPath = @"bounds.size.width"; // transform.scale.x 
    animationInside.values = @[@(oriWidth), @(oriWidth + 13.0), @(oriWidth)];
    animationInside.keyTimes = @[@0, @0.7,@1.0];
    animationInside.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CAKeyframeAnimation *animationyInside = [[CAKeyframeAnimation alloc] init];
    animationyInside.keyPath = @"bounds.size.height";
    animationyInside.values = @[@(oriHeight), @(oriHeight + 13.0), @(oriHeight)];
    animationyInside.keyTimes = @[@0, @0.7,@1.0];
    animationyInside.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


    CAKeyframeAnimation *animationrInside = [[CAKeyframeAnimation alloc] init];
    animationrInside.keyPath = @"cornerRadius";
    animationrInside.values = @[@(13.0), @(18.0), @(13.0)];
    animationrInside.keyTimes = @[@0, @0.7,@1.0];
    animationrInside.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];


    CAKeyframeAnimation *opacityInside = [[CAKeyframeAnimation alloc] init];
    opacityInside.keyPath = @"opacity";
    opacityInside.values = @[@0, @0.3, @0.3, @0];
    opacityInside.keyTimes = @[@0, @0.25, @0.75, @1.0];
    opacityInside.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    // 内
    CAAnimationGroup *_groupsInside = [CAAnimationGroup animation];
    _groupsInside.animations = @[animationInside,animationyInside,animationrInside,opacityInside];
    _groupsInside.removedOnCompletion = NO;
    _groupsInside.fillMode = kCAFillModeForwards;
    _groupsInside.duration = 2.5;
    _groupsInside.repeatCount = FLT_MAX;
    [self.v2.layer addAnimation:_groupsInside forKey:@"inside"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"123");
}

- (void)testKitTest
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 300, 300, 300)];
    label.attributedText = [self addAttribuetedString];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [self.view addSubview:label];
}

- (void)threadKeepAlive
{
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
        _queue = dispatch_queue_create("wbzdab", DISPATCH_QUEUE_SERIAL);
    }
    __block NSInteger a = 1;
    dispatch_async(_queue, ^{
        for (int i = 0; i<1000; i++) {
            if (i == 100) {
                dispatch_semaphore_signal(self.semaphore);
            }
            if (i < 110) {
                NSLog(@"%d",i);
            }
        }
    });
    if (a != 100) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"完成");
    NSDate *currentDate = [NSDate date];
    //    BOOL timeout = NO;
    //    do {
    //
    //        timeout = ![[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:currentDate];
    //        NSLog(@"23465465464666546546464654");
    //
    //    } while (_loopOut && !timeout);
        
        
    //    CFRunLoopStop(CFRunLoopGetCurrent());
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"ffff");
        }];
        do {
            [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[currentDate dateByAddingTimeInterval:3]];
        } while (self->_loopOut);
    });
}

- (void)tapView
{
    NSLog(@"controller view taped");
}

- (void)gestureSequence
{
    //1
//    for (int i = 0; i<10; i++) {
//        TestView *v1 = [[TestView alloc] init];
//        v1.index = i + 5;
//        v1.backgroundColor = UIColor.yellowColor;
//        v1.frame = CGRectMake(10, 100, 50, 50);
//        [self.view addSubview:v1];
//    }
//    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
//    tap.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tap];
//
//    //2
    UIView *beforeView = nil;
    for (int i = 0; i<10; i++) {
        TestView *v1 = [[TestView alloc] init];
        v1.index = i + 5;
        v1.backgroundColor = UIColor.yellowColor;
        if (v1.index != 0) {
            v1.userInteractionEnabled = NO;
        }
//        if (beforeView) {
//            v1.frame = beforeView.bounds;
//            [beforeView addSubview:v1];
//        } else {
            v1.frame = CGRectMake(10, 100, 50, 50);
            [self.view addSubview:v1];
//        }
        if (v1.index == 14) {
//            v1.userInteractionEnabled = NO;
        }
        beforeView = v1;
    }
    
//    TestView *tv = [[TestView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
//    tv.backgroundColor = UIColor.greenColor;
//    [self.view addSubview:tv];


//    MyLoadView *lv = [[MyLoadView alloc] initWithFrame:beforeView.bounds];
//    lv.backgroundColor = UIColor.redColor;
//    [beforeView addSubview:lv];
    
    
//    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 100, 100)];
//    cv.userInteractionEnabled = NO;
//    cv.backgroundColor = UIColor.greenColor;
//    [self.view addSubview:cv];
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInteractionEnabledTest)];
//    [self.view addGestureRecognizer:tap];
}

- (void)userInteractionEnabledTest
{
    NSLog(@"userInteractionEnabledTest");
}

//- (void)loadView {
//    [super loadView];
//    self.view = MyLoadView.new;
//}

- (void)touch_gesture_conflict
{
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.tag = 100;
    btn.backgroundColor = UIColor.greenColor;
    btn.frame = CGRectMake(100, 500, 100, 100);
    [btn addTarget:self action:@selector(hahahahahaha) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(99, 0, 1, self.view.frame.size.height)];
    line.backgroundColor = UIColor.redColor;
    [self.view addSubview:line];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)sliderTest
{
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 100, 200, 50)];
    [_slider setThumbImage:[UIImage imageNamed:@"33"] forState:UIControlStateNormal];
    [self.view addSubview:_slider];
    _slider.value = 0.5;
}

- (void)scrollPanTest
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction)];
    [self.view addGestureRecognizer:pan];
    
    sc = [[TS alloc] initWithFrame:self.view.bounds];
    sc.backgroundColor = UIColor.orangeColor;
    sc.contentSize = CGSizeMake(self.view.frame.size.width, 2000);
    [self.view addSubview:sc];
    
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 200, 200)];
    v.backgroundColor = UIColor.blueColor;
    [sc addSubview:v];
    
    UIPanGestureRecognizer *panOnScroll = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnScrollAction:)];
    [self.view addGestureRecognizer:panOnScroll];
}

- (void)panOnScrollAction:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan locationInView:pan.view];
    NSLog(@"pan on scroll:%f",p.y);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSLog(@"%@",_slider);
}

//- (void)tap __attribute__((__unused__))
//{
//    NSLog(@"触发了手势");
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(100, 15, 20, 20)];
//    v.backgroundColor = UIColor.redColor;
//    [_slider.subviews[0] insertSubview:v atIndex:2];
//}



- (void)hahahahahaha
{
    NSLog(@"点击了按钮");
}

- (NSAttributedString *)addAttribuetedString {
    NSString *str = @"async display http://www.baidu.com ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐🚋🎊😡🚖🚌💖💗💛💙🏨✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊😡🚖🚌💖💗💛💙🏨";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    text.ty_lineSpacing = 2;
    
    TYTextAttachment *attachment = [[TYTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"avatar"];
    attachment.bounds = CGRectMake(0, 0, 60, 60);
    //attachment.verticalAlignment = TYAttachmentAlignmentCenter;
    [text insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:text.length/2];
    
    attachment = [[TYTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"avatar"];
    attachment.size = CGSizeMake(20, 20);
    attachment.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    
    TYTextAttachment *attachmentView = [[TYTextAttachment alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"button" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    attachmentView.view = button;
    attachmentView.view.backgroundColor = [UIColor redColor];
    attachmentView.size = CGSizeMake(60, 20);
    attachmentView.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentView]];
    text.ty_font = [UIFont systemFontOfSize:15];
    text.ty_characterSpacing = 2;
    
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"小小的爱在大城里好甜蜜，念的都是你，全部都是你，小小的爱在大城里只为你倾心"]];
    return text;
}


//MARK:  专门HOOK
+ (void)load{
    
    //在交换代码之前，把所有的runtime代码写完
    
    //基本防护
//    struct rebinding bd;
//    bd.name = "method_exchangeImplementations";
//    bd.replacement = myExchang;
//    bd.replaced=(void *)&exchangeP;
//
//    struct rebinding rebindings[]={bd};
//    rebind_symbols(rebindings, 1);
//
//    //内部用到的交换代码
//    Method old = class_getInstanceMethod(objc_getClass("ViewController"), @selector(jojo));
//    Method new = class_getInstanceMethod(self, @selector(click1Hook));
//    method_exchangeImplementations(old, new);
    
}

- (void)click1Hook{
    NSLog(@"原来APP的hook保留");
}

// 保留原来的交换函数
// exchangeP 指针变量 指向*exchangeP的内容  &exchangeP 指针变量的地址 fishhook修改指针变量的地址 重新绑定
void (*exchangeP)(Method _Nonnull m1, Method _Nonnull m2);

//新的函数
void myExchang(Method _Nonnull m1, Method _Nonnull m2){
    NSLog(@"检测到了HOOK!!!");
    exchangeP(m1,m2);
}

//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return _forceLandscape ? UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    _loopOut = NO;
//    [self jojo];
//    _forceLandscape = YES;
//    [UITabBarController attemptRotationToDeviceOrientation];
//    [UINavigationController attemptRotationToDeviceOrientation];
//    [UIViewController attemptRotationToDeviceOrientation];
    
//    [self springAni];
    
//    [self barrier_async];

//    [self.v1.layer addAnimation:animation forKey:@"12"];
//    self.v1.width += 20;
//    self.v1.height += 20;
//    self.v1.center = self.view.center;
    
}

- (void)barrier_async
{
    //并行操作
    void (^blk1)() = ^{
        NSLog(@"1");
    };
    void (^blk2)() = ^{
        NSLog(@"2");
    };
    void (^blk3)() = ^{
        NSLog(@"3");
    };
    void (^blk4)() = ^{
        NSLog(@"4");
    };
    void (^blk5)() = ^{
        NSLog(@"5");
    };
    void (^blk6)() = ^{
        NSLog(@"6");
    };
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(queue, blk6);
    dispatch_barrier_async(queue, blk5);
    dispatch_barrier_async(queue, blk4);
    dispatch_barrier_async(queue, blk3);
    dispatch_barrier_async(queue, blk2);
    dispatch_barrier_async(queue, blk1);
}

- (NSObject *)testTry {
    
    WBTry([self performSelector:@selector(jojo)];);
    return nil;
}

- (void)jojo {
    NSLog(@"aaaaaaaaa");
}


- (void)jojo1 {
    NSLog(@"bbbbbbbb");
}

@end


@interface MyNavViewController ()

@end

@implementation MyNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end

@implementation MYTabVC

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
