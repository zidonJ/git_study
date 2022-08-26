//
//  JumpViewController.m
//  test
//
//  Created by jiangzedong on 2022/2/24.
//

#import "JumpViewController.h"
#import "NSTimer+Block.h"
#import "CollectionViewController.h"

@interface JumpViewController ()

@property (nonatomic, strong) NSTimer *tm;

@end

@implementation JumpViewController

- (void)dealloc
{
    [self.tm invalidate];
    self.tm = nil;
    NSLog(@"[%@ 释放]",self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //NSTimer *timer = nil;
    
    __weak typeof(self) ws = self;
    runAfter(&_tm, 4, ^{
        __strong typeof(ws) ss = ws;
        NSLog(@"定时器%@",ss);
//        NSLog(@"定时器");
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(ws) ss = ws;
//        NSLog(@"dispatch_after");
        NSLog(@"dispatch_after:%@",ss);
    });
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CollectionViewController *vc = [CollectionViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
