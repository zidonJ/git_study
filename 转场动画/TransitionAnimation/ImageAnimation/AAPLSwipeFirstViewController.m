/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The initial view controller for the Swipe demo.
 */

#import "AAPLSwipeFirstViewController.h"
#import "AAPLSwipeTransitionDelegate.h"
#import "AAPLSwipeSecondViewController.h"

@interface AAPLSwipeFirstViewController ()
{
    UIScreenEdgePanGestureRecognizer *_interactiveTransitionRecognizer;
}
@property (nonatomic, strong) AAPLSwipeTransitionDelegate *customTransitionDelegate;
@property (nonatomic, strong) UIViewController *vc;
@end


@implementation AAPLSwipeFirstViewController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//| ----------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *back = [UIButton buttonWithType:(UIButtonTypeCustom)];
    back.backgroundColor = UIColor.lightGrayColor;
    [back setTitle:@"返回" forState:(UIControlStateNormal)];
    [back addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
    back.frame = CGRectMake(10, 100, 100, 50);
    [self.view addSubview:back];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _vc = [AAPLSwipeSecondViewController new];
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    AAPLSwipeTransitionDelegate *transitionDelegate = self.customTransitionDelegate;

    transitionDelegate.gestureRecognizer = nil;
    
    transitionDelegate.targetEdge = UIRectEdgeRight;
    _vc.transitioningDelegate = transitionDelegate;
    _vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:_vc animated:true completion:nil];
}


- (AAPLSwipeTransitionDelegate *)customTransitionDelegate {
    
    if (_customTransitionDelegate == nil)
        _customTransitionDelegate = [[AAPLSwipeTransitionDelegate alloc] init];
    
    return _customTransitionDelegate;
}

#pragma mark -
#pragma mark Unwind Actions

@end
