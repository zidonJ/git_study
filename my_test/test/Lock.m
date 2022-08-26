//
//  Lock.m
//  test
//
//  Created by jiangzedong on 2022/1/18.
//

#import "Lock.h"
#include<pthread.h>

typedef struct ct_sum
{
    int sum;
    pthread_mutex_t mutex;
}ct_sum;

static NSLock *_slock;

static pthread_mutex_t mutex;
static int sum = 0;

@interface Lock ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSRecursiveLock *recursiveLock;
@property (nonatomic, strong) NSConditionLock *conditionLock;
@property (nonatomic, strong) NSCondition *condition;

@end

@implementation Lock

- (instancetype)init
{
    if (self = [super init]) {
        _slock = [[NSLock alloc] init];
    }
    return self;
}

void * add1(void * cnt) {
    
    NSLog(@"lock1:%d",pthread_mutex_lock(&mutex));
    int i;
    for(i=0; i<500; i++) {
        sum+=1;
        NSLog(@"mutex:%d",sum);
    }
    pthread_mutex_unlock(&mutex);
    pthread_exit(NULL);
    return 0;
}

void * add2(void *cnt) {

    NSLog(@"lock2:%d",pthread_mutex_lock(&mutex));
    int i;
    cnt= (ct_sum*)cnt;
    for(i=500; i<1000; i++) {
        sum+=1;
        NSLog(@"mutex:%d",sum);
    }
    pthread_mutex_unlock(&mutex);
    pthread_exit(NULL);
    return 0;
}

//MARK: 互斥锁
// 使用两个线程把sum 加到100
- (void)mutex
{
    pthread_t ptid1,ptid2;
    ct_sum cnt;
    pthread_mutex_init(&mutex,NULL);
    cnt.sum=0;
    pthread_create(&ptid1,NULL,add1,&cnt);
    pthread_create(&ptid2,NULL,add2,&cnt);
    
//    pthread_mutex_lock(&(cnt.lock));
//    printf("sum %d\n",cnt.sum);
//    pthread_mutex_unlock(&(cnt.lock));
//    pthread_join(ptid1,NULL);
//    pthread_join(ptid2,NULL);
//    pthread_mutex_destroy(&(cnt.lock));
}
//MARK: 递归锁


//MARK: 自旋锁


//MARK: 信号量


//MARK: 条件锁
static NSInteger _count = 0;
- (void)producer {
    while (YES) {
        [self.conditionLock lock];
        _count++;
        NSLog(@"have something:%ld",_count);
        [self.conditionLock unlockWithCondition:1];
    }
}

- (void)consumer {
    while (YES) {
        [self.conditionLock lockWhenCondition:1];
        
        _count--;
        NSLog(@"use something:%ld",_count);
        [self.conditionLock unlockWithCondition:0];
    }
}

- (void)conditionLockTest
{
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:2];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       [conditionLock lockWhenCondition:1];
       NSLog(@"线程1");
       [conditionLock unlockWithCondition:0];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [conditionLock lockWhenCondition:2];
       NSLog(@"线程2");
       [conditionLock unlockWithCondition:1];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [conditionLock lock];
       NSLog(@"线程3");
       [conditionLock unlock];
    });
}


//MARK: 死锁
/*
 一般情况下，如果同一个线程先后两次调用lock，在第二次调用时，由于锁已经被占用，该线程会挂起等待别的线程释放锁，然而锁正是被自己占用着的，该线程又被挂起而没有机会释放锁，因此就永远处于挂起等待状态了，这叫做死锁（Deadlock）。
 另一种：若线程A获得了锁1，线程B获得了锁2，这时线程A调用lock试图获得锁2，结果是需要挂起等待线程B释放锁2，而这时线程B也调用lock试图获得锁1，结果是需要挂起等待线程A释放锁1，于是线程A和B都永远处于挂起状态了。
 */

//死锁场景1
- (void)deadLock1
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMethod) object:nil];
    [thread start];
}

- (void)threadMethod
{
    [self.lock lock];
    for (int i = 0;i < 100; i++) {
        NSLog(@"%d",i);
        if (i == 50) {
            [self threadMethod];
        }
    }
    [self.lock unlock];
}

//死锁场景2
- (void)deadLock2
{
    
}

//MARK: getter
- (NSLock *)lock
{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (NSRecursiveLock *)recursiveLock
{
    if (!_recursiveLock) {
        _recursiveLock = [[NSRecursiveLock alloc] init];
    }
    return _recursiveLock;
}

- (NSConditionLock *)conditionLock
{
    if (!_conditionLock) {
        _conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    return _conditionLock;
}


@end
