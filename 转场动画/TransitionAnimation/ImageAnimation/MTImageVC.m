//
//  MTImageVC.m
//  ImageAnimation
//
//  Created by 姜泽东 on 2017/9/6.
//  Copyright © 2017年 MaiTian. All rights reserved.
//

#import "MTImageVC.h"
#import "MTVCTransitonProtocol.h"
#import "MTVCAnimationTransition.h"

#pragma mark Constants

#pragma mark - Class Extension

@interface MTImageVC ()<MTVCTransitonProtocol>
{
    CGFloat _panBeginScaleX;
    CGFloat _panBeginScaleY;
    CGRect transitionImageViewFrame;
    UIScreenEdgePanGestureRecognizer *_interactiveTransitionRecognizer;
}
@property (nonatomic,strong) UIImageView *ttImgView;
@property (nonatomic,strong) MTVCAnimationTransition *ani;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MTImageVC


#pragma mark - Properties

#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)viewDidLoad {
    
    // Call base implementation.
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    self.imgView.userInteractionEnabled = YES;
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.imgView addGestureRecognizer:_pan];

    _ani = [MTVCAnimationTransition new];
    [_ani setRelyPanGesture:_pan];
    self.transitioningDelegate = _ani;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    transitionImageViewFrame = self.imgView.frame;
}

#pragma mark - Private Methods

#pragma mark -- Actions


- (CGRect)imageFrame
{
    return self.imgView.frame;
}

- (UIView *)imageTargetView
{
    return self.imgView;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:self.imgView];
    CGFloat scale = 1 - ABS(point.y) / self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        

    }else if (pan.state == UIGestureRecognizerStateChanged) {

        
        CGFloat tx = point.x;
        CGFloat ty = point.y;
        
        self.imgView.transform = CGAffineTransformScale(self.imgView.transform, scale, scale);
        self.imgView.transform = CGAffineTransformTranslate(self.imgView.transform, tx, ty);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [pan velocityInView:self.imgView];
        if (ABS(velocity.y)>200 || self.imgView.transform.a < 0.6) {
            [self dismissViewControllerAnimated:YES completion:nil];
//            [self.navigationController popViewControllerAnimated:YES];
        }else {
            
            [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:0 animations:^{
                self.imgView.frame = self->transitionImageViewFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }
    
    [pan setTranslation:CGPointZero inView:self.imgView];
}

- (IBAction)back:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.transitioningDelegate = nil;
    NSLog(@"%@",[self class]);
}

@end
