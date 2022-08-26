//
//  GestureViewController.m
//  test
//
//  Created by jiangzedong on 2022/1/6.
//

#import "GestureViewController.h"

@interface GestureViewController ()

@end

@implementation GestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{

    NSLog(@"1");
    NSLog(@"2");
    NSLog(@"3");
    NSLog(@"4");
    NSLog(@"5");
    CGPoint point = [pan velocityInView:pan.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateRecognized:
            NSLog(@"UIGestureRecognizerStateRecognized\n速度X:%f--y:%f\n",point.x,point.y);
            break;
        case UIGestureRecognizerStateBegan:
            NSLog(@"UIGestureRecognizerStateBegan\n速度X:%f--y:%f",point.x,point.y);
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"UIGestureRecognizerStateChanged\n速度X:%f--y:%f",point.x,point.y);
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"UIGestureRecognizerStateCancelled\n速度X:%f--y:%f",point.x,point.y);
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            NSLog(@"UIGestureRecognizerStateFailed\n速度X:%f--y:%f",point.x,point.y);
            break;
            
        default:
            break;
    }
}

@end
