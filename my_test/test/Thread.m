//
//  Thread.m
//  test
//
//  Created by jiangzedong on 2021/11/25.
//

#import "Thread.h"
#include <pthread/pthread.h>
#include <pthread/sched.h>
#include <string.h>

//开关处理
static NSMutableDictionary<NSString *,NSNumber *> *_zdabDict;
static dispatch_queue_t _sv_ab_queue;
static dispatch_semaphore_t _sv_ab_semaphore;
NS_INLINE BOOL wb_getZdAB(NSString *ab, BOOL(^noExist)(void)) {
    if (!ab) {
        return NO;
    }
    if (!_sv_ab_queue) {
        _sv_ab_queue = dispatch_queue_create("zdab", DISPATCH_QUEUE_SERIAL);
    }
    if (!_sv_ab_semaphore) {
        _sv_ab_semaphore = dispatch_semaphore_create(0);
    }
    if (!_zdabDict) {
        _zdabDict = NSMutableDictionary.dictionary;
    }
    __block BOOL exist = NO;
    dispatch_async(_sv_ab_queue, ^{
        NSNumber *num = [_zdabDict objectForKey:ab];
        if (!num) {//值为空 说明不存在key
            exist = noExist();//值只从ab获取一次 防止多次获取值变化
            [_zdabDict setObject:@(exist) forKey:ab];
        } else {
            exist = num.boolValue;
        }
        dispatch_semaphore_signal(_sv_ab_semaphore);
    });
    dispatch_semaphore_wait(_sv_ab_semaphore, DISPATCH_TIME_FOREVER);
    return exist;
}


static NSOperationQueue *_opQueue;

NSOperationQueue *opQueue(void) {
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc] init];
        _opQueue.maxConcurrentOperationCount = 1; // -1 无限制,1 串行, >1并行
    }
    return _opQueue;
}

@interface MyOperation : NSOperation

@end

@implementation MyOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start {
    self.finished = NO;
    self.executing = YES;
    // Do nothing but keep running
    
    [self excutSomthing];
}

- (void)excutSomthing
{
    for (int i =0; i<100; i++) {
        NSLog(@"这是一段经典的旋律:%@",NSThread.currentThread);
    }
    [self complete];
}

- (void)complete
{
    self.finished = YES;
    self.executing = NO;
}

- (void)cancel {
    if (self.isFinished) return;
    [super cancel];

}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)cancel:(id)token {
    [self cancel];
    return YES;
}


@end

void asyncRun(void) {
    for (int i = 0; i<1000000; i++) {
        MyOperation *op = [[MyOperation alloc] init];
        [opQueue() addOperation:op];
    }
}

using namespace std;
static pthread_t s_working_thread = 0;

@interface Thread ()

@end

@implementation Thread

- (void)pthreadTest
{
    __prepare_working_thread();
}

struct thread_TestData{
    int  thread_id;
    NSString *message;
};
struct thread_TestData thread_Test;

bool __prepare_working_thread() {
    int ret;
    
    pthread_attr_t tattr;
    sched_param param;

    /* initialized with default attributes */
    ret = pthread_attr_init(&tattr);

    /* safe to get existing scheduling param */
    ret = pthread_attr_getschedparam(&tattr, &param);

    /* set the highest priority; others are unchanged */
    param.sched_priority = MAX(sched_get_priority_max(SCHED_RR), param.sched_priority);

    /* setting the new scheduling param */
    ret = pthread_attr_setschedparam(&tattr, &param);

    thread_Test.message = @"pthread_test";
    thread_Test.thread_id = 1;
    if (pthread_create(&s_working_thread, &tattr, studyPthreadMethond, &thread_Test) == KERN_SUCCESS) {
        pthread_detach(s_working_thread);
        return true;
    } else {
        return false;
    }
}

void *studyPthreadMethond(void *threadData)
{
    struct thread_TestData *getData;
    getData = (struct thread_TestData *)threadData;
    NSLog(@"test %p", getData);
    int threadID = getData->thread_id;
    NSLog(@"threadID = %d message=%@-----%@",threadID,getData->message,NSThread.currentThread);
    pthread_exit(NULL);
    return NULL;
}

@end

@interface ZDLockSafeDictionary:NSMutableDictionary{
    pthread_rwlock_t lock;
    dispatch_queue_t concurrent_queue;
}

@end

// 多读单写模型
@implementation ZDLockSafeDictionary

- (id)init {
    self = [super init];
    if (self) {
      //初始化读写锁
      pthread_rwlock_init(&lock,NULL);
      // 通过宏定义 DISPATCH_QUEUE_CONCURRENT 创建一个并发队列
      concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)objectForKey:(id)aKey {
    //加读锁
    pthread_rwlock_rdlock(&lock);
    id obj = [self objectForKey:aKey];
    pthread_rwlock_unlock(&lock);
    return obj;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    //加写锁
    pthread_rwlock_wrlock(&lock);
    [super setObject:obj forKey:key];
    pthread_rwlock_unlock(&lock);
}

@end


//MARK: mutialbe read single write
@interface ZDSafeDictionary:NSMutableDictionary
{
    dispatch_queue_t concurrent_queue;
}

@end

// 多读单写模型
@implementation ZDSafeDictionary

- (id)init {
    self = [super init];
    if (self) {
        concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    __block id obj;
    dispatch_sync(concurrent_queue, ^{
        obj = [self objectForKey:key];
    });
    return obj;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    dispatch_barrier_async(concurrent_queue, ^{
        [self setObject:obj forKey:key];
    });
}

@end
