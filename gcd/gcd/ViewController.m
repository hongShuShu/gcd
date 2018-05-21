//
//  ViewController.m
//  gcd
//
//  Created by xhwl on 2018/5/21.
//  Copyright © 2018年 红蜀黍. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

/**
 同步和异步作用：能不能开线程
    同步在当前线程中执行任务，不开线程
    异步在新线程中执行任务，开线程
 并发和串行作用：任务的执行方式
    并发是多个任务同时执行
    串行是任务顺序执行，一个接一个
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self asyncMain];
}
//  B  C   F   A   D   E   G
- (void)test_progress {
    /**
     主队列：专门负责调度主线程度的任务，没有办法开辟新的线程。所以，在主队列下的任务不管是异步任务还是同步任务都不会开辟线程，任务只会在主线程顺序执行。
     
     主队列异步任务：现将任务放在主队列中，但是不是马上执行，等到主队列中的其它所有除我们使用代码添加到主队列的任务的任务都执行完毕之后才会执行我们使用代码添加的任务。
     */
    // 主队列异步   不开线程，顺序执行
    dispatch_async(dispatch_get_main_queue(), ^{  // 添加到任务队列，所以肯定是在当前方法执行完毕后调用
        NSLog(@"A = %@",[NSThread currentThread]);
    });
    
    //  主线程执行
    NSLog(@"B = %@",[NSThread currentThread]); // 第一
    
    //  全局队列本质是一个并发队列    后台优先级
    dispatch_queue_t que_tmp = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //  并发同步  不开，顺序执行
    dispatch_sync(que_tmp, ^{ // 第二
        NSLog(@"C = %@",[NSThread currentThread]);
    });
    
    //  并发异步  开多个线程 无序执行
    dispatch_async(que_tmp, ^{  // 异步执行
        NSLog(@"D = %@",[NSThread currentThread]);
    });
    
    //  主队列异步   不开线程，添加任务，顺序执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"E = %@",[NSThread currentThread]);   // E在A之后
    });
    
    // 当前调用此方法的函数执行完毕后,selector方法才会执行
    // 因此G肯定在F之后
    [self performSelector:@selector(method) withObject:nil afterDelay:0.0]; // G是最后一个
    NSLog(@"F = %@",[NSThread currentThread]); // 第三
}
- (void)method {
    NSLog(@"G = %@",[NSThread currentThread]);
}

#pragma mark - demo
// 主队列同步:主队列和主线程互相等待，造成“死锁”
- (void)syncMain {
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        NSLog(@"1-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3-----%@", [NSThread currentThread]);
    });
}
// 主队列异步:不开线程，在当前线程顺序执行
- (void)asyncMain {
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        NSLog(@"1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3-----%@", [NSThread currentThread]);
    });
}

// 串行同步:在当前线程顺序执行
- (void)syncSerial {
    dispatch_queue_t queue = dispatch_queue_create("hongShuShu", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        NSLog(@"1-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3-----%@", [NSThread currentThread]);
    });
}

// 串行异步:开新线程，在新线程顺序执行
- (void)asyncSerial {
    dispatch_queue_t queue = dispatch_queue_create("hongShuShu", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3-----%@", [NSThread currentThread]);
    });
}

// 并发同步:不开线程，在当前线程顺序执行
- (void)syncConcurrent {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{
        NSLog(@"1-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2-----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3-----%@", [NSThread currentThread]);
    });
}

// 并发异步:开多个线程，无序执行
- (void)asyncConcurrent {
    // 全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"1-----%@", [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"2-----%@", [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"3-----%@", [NSThread currentThread]);
        }
    });
}





@end
