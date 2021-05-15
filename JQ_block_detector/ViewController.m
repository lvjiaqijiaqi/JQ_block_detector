//
//  ViewController.m
//  JQ_block_detector
//
//  Created by 吕佳骐 on 2021/5/14.
//

#import "ViewController.h"
#import "JQ_block_detector.h"

@interface ViewController ()

@property(nonatomic,strong) UIButton *actionButtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JQ_block_detector shareInstance] run];
    self.actionButtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButtn.frame = CGRectMake(0, 100, 200, 50);
    [self.actionButtn setTitle:@"执行卡顿任务" forState:UIControlStateNormal];
    [self.actionButtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.actionButtn addTarget:self action:@selector(blockTask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButtn];
}

-(void)blockTask{
    sleep(2);
}

@end
