//
//  LockViewController.m
//  test
//
//  Created by jiangzedong on 2022/1/18.
//

#import "LockViewController.h"
#import "Lock.h"
#import "Thread.h"

static dispatch_queue_t _localJournalQueue;

@interface TM : NSObject

@property (nonatomic, assign) NSInteger index;

@end

@implementation TM



@end

@interface LockViewController ()

@property (nonatomic, strong) Lock *lockScene;

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
#if 1
    for (NSInteger i = 0; i<100000; i++) {
        dispatch_async([LockViewController queue], ^{
            for (NSInteger i = 0; i<1000; i++) {
                    NSLog(@"11");
            }
        });
    }
#else
    extern NSOperationQueue *opQueue(void);
    extern void asyncRun(void);
    
    asyncRun();
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.lockScene deadLock1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self.lockScene consumer];
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self.lockScene producer];
//    });
//    [self.lockScene mutex];
//    [self.lockScene conditionLockTest];
    
//    NSLog(@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
    
    
}


- (Lock *)lockScene
{
    if (!_lockScene) {
        _lockScene = [[Lock alloc] init];
    }
    return _lockScene;
}

+ (dispatch_queue_t)queue
{
    if (!_localJournalQueue) {
        _localJournalQueue = dispatch_queue_create("WBSVLocalJournal", DISPATCH_QUEUE_SERIAL);
    }
    return _localJournalQueue;
}

@end
