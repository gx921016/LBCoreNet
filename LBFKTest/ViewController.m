//
//  ViewController.m
//  LBFKTest
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import "ViewController.h"
#import "LBCoreKit/LBCoreKit/LBCoreNet/DownLoad/LBCDownLoad.h"
NSString *URL = @"http://baobab.wdjcdn.com/1455782903700jy.mp4";
@interface ViewController (){
    UILabel *_label1;
    UILabel *_label2;
    UIButton *_button1;
    UIButton *_button2;
    UIProgressView *_pv1;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 50, 50)];
    label1.text = [NSString stringWithFormat:@"%.2f",[[LBCDownLoad sharedInstance]progressWithUrl:URL]];
    label1.textColor = [UIColor blackColor];
    [self.view addSubview:label1];
    _label1 = label1;
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(50, 90, 200, 50)];
    label2.textColor = [UIColor blackColor];
    [self.view addSubview:label2];
    _label2 = label2;
    UIProgressView *pv1 = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), 50, 200, 30)];
    pv1.progressTintColor = [UIColor blueColor];
    pv1.progress = [[LBCDownLoad sharedInstance]progressWithUrl:URL];
    [self.view addSubview:pv1];
    _pv1 = pv1;
    UIButton *button1 = [[UIButton alloc]init];
    button1.frame = CGRectMake(CGRectGetMaxX(pv1.frame), 30, 50, 50);
    [button1 setTitleColor:[UIColor orangeColor] forState:0];
    [button1 setTitle:@"开始" forState:0];
    [button1 setTitle:@"停止" forState:UIControlStateSelected];
    [button1 addTarget:self action:@selector(click1:) forControlEvents:(UIControlEventTouchUpInside)];
    _button1 = button1;
    [self.view addSubview:button1];
    
    UIButton *rBtn3 = [[UIButton alloc]init];
    rBtn3.backgroundColor = [UIColor orangeColor];
    rBtn3.frame = CGRectMake(200, 200, 50, 30);
    [rBtn3 setTitle:@"清空" forState:(UIControlStateNormal)];
    [self.view addSubview:rBtn3];
    [rBtn3 addTarget:self action:@selector(removeAll:) forControlEvents:(UIControlEventTouchUpInside)];
}


- (NSString *)getText:(CGFloat)progress {
    NSString *scaleStr = [NSString stringWithFormat:@"%.2f",progress];
    return scaleStr;
}
- (void)click1:(UIButton *)button {
    button.selected = !button.selected;
    [[LBCDownLoad sharedInstance]   downLoad:URL
                                      resume:button.selected
                                    progress:^(CGFloat progress, NSUInteger size, NSString *speedString) {
                                        NSLog(@"下载进度: %f",progress);
                                        NSLog(@"已下载： %lu",(unsigned long)size);
                                        NSLog(@"下载速度： %@",speedString);
                                        _pv1.progress = progress;
                                        _label1.text = [NSString stringWithFormat:@"%.2f",progress];
                                        _label2.text = [NSString stringWithFormat:@"%@",speedString];
                                    } state:^(LBCDownloadState state) {
                                        switch (state) {
                                                //下载中
                                            case LBCDownloadStateRunning:
                                            {
                                                
                                            }
                                                break;
                                                //下载暂停
                                            case LBCDownloadStateSuspended:
                                            {
                                                
                                            }
                                                break;
                                                //下载完成
                                            case LBCDownloadStateCompleted:
                                            {
                                                
                                            }
                                                break;
                                                //取消下载
                                            case LBCDownloadStateCanceled:
                                            {
                                                
                                            }
                                                break;
                                                //下载失败
                                            case LBCDownloadStateFailed:
                                            {
                                                
                                            }
                                                break;
                                                
                                                
                                            default:
                                                break;
                                        }
                                    }];
}

- (void)removeAll:(UIButton *)button {
    _label1.text = @"0.00";
    _pv1.progress = 0;
    _label2.text = @"0.0kb/s";
    _button1.selected = NO;
    _button2.selected = NO;
    [[LBCDownLoad sharedInstance] removeAllFileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
