//
//  JQ_block_detector.m
//  JQ_detection
//
//  Created by 吕佳骐 on 2021/5/14.
//

#import "JQ_block_detector.h"
#import <mach/mach.h>
#import <pthread/pthread.h>
#import "BSBacktraceLogger.h"

static int CALLSTACK_SIG = 200123;
static NSTimeInterval detector_interval = 1;

/// singal回调方法
static void thread_singal_handler(int sig) {
    NSLog(@"主线程捕获信号: %d", sig);
    if (sig != CALLSTACK_SIG) {
        return;
    }
    NSLog(@"%@",NSThread.callStackSymbols);
    return;
}

static void install_signal_handler() {
    signal(CALLSTACK_SIG, thread_singal_handler);
}

@interface JQ_block_detector()

@property(nonatomic,strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL start;

@end

static pthread_t main_thread_id;

@implementation JQ_block_detector

+ (void)load {
    main_thread_id = pthread_self();
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static JQ_block_detector *block_detector = nil;
    dispatch_once(&onceToken, ^{
        block_detector = [[JQ_block_detector alloc] init];
    });
    return block_detector;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.lvjiaqi.block_detection_queue", NULL);
    }
    return self;
}

-(void)run{
    //install_signal_handler();
    dispatch_async(self.queue, ^{
        if (self.start) {
            return;
        }
        self.start = YES;
        dispatch_queue_t queue = self.queue;
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC,  0);
        dispatch_source_set_event_handler(self.timer, ^{
            [self pingMainThread];
        });
        dispatch_resume(self.timer);
    });
}

-(void)pingMainThread{
    //pthread_kill(main_thread_id, CALLSTACK_SIG);
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(sem);
    });
    intptr_t res = dispatch_semaphore_wait(sem, dispatch_walltime(NULL, detector_interval* NSEC_PER_SEC));
    if (res != 0) {
        BSLOG_MAIN
        NSLog(@"main thread block");
    }else{
        NSLog(@"main thread OK");
    }
    
}

@end
