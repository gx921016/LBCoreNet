//
//  ViewController.m
//  LBFKTest
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import "ViewController.h"
#import "ASProgressPopUpView.h"
#import "LBCoreNet/DownLoad/LBCDownLoadManager.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
NSString *URL = @"http://baobab.wdjcdn.com/1455782903700jy.mp4";
NSString *URL1 = @"http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar";
@interface ViewController ()
@property (strong, nonatomic) ASProgressPopUpView *progressView1;

@property (strong, nonatomic) UIButton *downLoadBtn1;

@property (strong, nonatomic) UILabel *speedLabel1;

@property (strong, nonatomic) UILabel *sizeLabel1;

@property (strong, nonatomic) ASProgressPopUpView *progressView2;

@property (strong, nonatomic) UIButton *downLoadBtn2;

@property (strong, nonatomic) UILabel *speedLabel2;

@property (strong, nonatomic) UIButton *removeBtn;

@property (strong, nonatomic) UILabel *sizeLabel2;
@end

@implementation ViewController

#pragma mark - lazyLoad
-(ASProgressPopUpView *)progressView1{
    if (!_progressView1) {
        _progressView1 = [ASProgressPopUpView new];
        _progressView1.popUpViewCornerRadius = 10.0;
        _progressView1.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        [_progressView1 showPopUpViewAnimated:YES];
        _progressView1.progress = [[LBCDownLoadManager shredManager]getDownLoadProgressWithUrl:URL];
        
    }
    return _progressView1;
}

-(ASProgressPopUpView *)progressView2{
    if (!_progressView2) {
        _progressView2 = [ASProgressPopUpView new];
        _progressView2.popUpViewCornerRadius = 10.0;
        _progressView2.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        [_progressView2 showPopUpViewAnimated:YES];
        _progressView2.progress = [[LBCDownLoadManager shredManager]getDownLoadProgressWithUrl:URL1];
    }
    return _progressView2;
}

-(UIButton *)downLoadBtn1{
    if (!_downLoadBtn1) {
        _downLoadBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn1 setTitleColor:[UIColor grayColor] forState:0];
        [_downLoadBtn1 setTitle:@"开始" forState:0];
        [_downLoadBtn1 setTitle:@"暂停" forState:UIControlStateSelected];
        @weakify(self);
        [[_downLoadBtn1 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self click1:x];
        }];
    }
    return _downLoadBtn1;
}
-(UILabel *)sizeLabel1{
    if (!_sizeLabel1) {
        _sizeLabel1 = [UILabel new];
        _sizeLabel1.font = [UIFont systemFontOfSize:12];
    }
    return _sizeLabel1;
}

-(UILabel *)sizeLabel2{
    if (!_sizeLabel2) {
        _sizeLabel2= [UILabel new];
        _sizeLabel2.font = [UIFont systemFontOfSize:12];
    }
    return _sizeLabel2;
}

-(UIButton *)downLoadBtn2{
    if (!_downLoadBtn2) {
        _downLoadBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn2 setTitleColor:[UIColor grayColor] forState:0];
        [_downLoadBtn2 setTitle:@"开始" forState:0];
        [_downLoadBtn2 setTitle:@"暂停" forState:UIControlStateSelected];
        @weakify(self);
        [[_downLoadBtn2 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self click2:x];
        }];
    }
    return _downLoadBtn2;
}

-(UIButton *)removeBtn{
    if (!_removeBtn) {
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeBtn.backgroundColor = [UIColor orangeColor];
        [_removeBtn setTitle:@"清除" forState:0];
        _removeBtn.layer.cornerRadius = 5.f;
        @weakify(self);
        [[_removeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self removeAll:x];
        }];
        
    }
    return _removeBtn;
}

-(UILabel *)speedLabel1{
    if (!_speedLabel1) {
        _speedLabel1 = [UILabel new];
        _speedLabel1.font = [UIFont systemFontOfSize:13];
    }
    return _speedLabel1;
}

-(UILabel *)speedLabel2{
    if (!_speedLabel2) {
        _speedLabel2 = [UILabel new];
        _speedLabel2.font = [UIFont systemFontOfSize:13];
    }
    return _speedLabel2;
}
#pragma  mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]);
    [self.view addSubview:self.progressView1];
    [self.view addSubview:self.downLoadBtn1];
    [self.view addSubview:self.speedLabel1];
    [self.view addSubview:self.sizeLabel1];
    [self.view addSubview:self.removeBtn];
    [self.view addSubview:self.progressView2];
    [self.view addSubview:self.downLoadBtn2];
    [self.view addSubview:self.speedLabel2];
    [self.view addSubview:self.sizeLabel2];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}
-(void)initDownLoad{
    

}

-(void)updateViewConstraints{
    WS(weakSelf);
    [self.progressView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view).with.offset(-30);
        make.top.equalTo(weakSelf.view).with.offset(150);
        make.width.equalTo(@200);
    }];
    
    [self.downLoadBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.progressView1.mas_right).with.offset(15);
        make.centerY.equalTo(weakSelf.progressView1);
    }];
    
    [self.speedLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.progressView1.mas_left).with.offset(-10);
        make.centerY.equalTo(weakSelf.progressView1);
    }];
    [self.progressView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view).with.offset(-30);
        make.top.equalTo(weakSelf.view).with.offset(270);
        make.width.equalTo(@200);
    }];
    
    [self.downLoadBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.progressView2.mas_right).with.offset(15);
        make.centerY.equalTo(weakSelf.progressView2);
    }];
    
    
    
    [self.speedLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.progressView2.mas_left).with.offset(-10);
        make.centerY.equalTo(weakSelf.progressView2);
    }];
    [self.removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).with.offset(-300);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    [self.sizeLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.downLoadBtn2.mas_top).with.offset(-10);
        make.centerX.equalTo(weakSelf.downLoadBtn2);
    }];
    
    [self.sizeLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.downLoadBtn1.mas_top).with.offset(-10);
        make.centerX.equalTo(weakSelf.downLoadBtn1);
    }];
    
   
    [super updateViewConstraints];
}



- (void)click1:(UIButton *)button {
    
    if (button.selected) {
        [[LBCDownLoadManager shredManager] suspendDownloadTask:URL];
    }else{
        WS(weakSelf);
        [[LBCDownLoadManager shredManager]downLoad:URL fileName:@"1455782903700jy.mp4" progress:^(CGFloat progress, NSString *sizeString, NSString *speedString) {
            weakSelf.progressView1.progress = progress;
            weakSelf.speedLabel1.text = speedString;
            weakSelf.sizeLabel1.text = sizeString;
        } success:^(NSString *filePath) {
            
        } failure:^(NSError *error) {
            
        }];
    }
    button.selected = !button.selected;
}

- (void)click2:(UIButton *)button {
    
    if (button.selected) {
        [[LBCDownLoadManager shredManager] suspendDownloadTask:URL1];
    }else{
        WS(weakSelf);
        [[LBCDownLoadManager shredManager]downLoad:URL1 fileName:@"content.jar" progress:^(CGFloat progress, NSString *sizeString, NSString *speedString) {
            weakSelf.progressView2.progress = progress;
            weakSelf.speedLabel2.text = speedString;
            weakSelf.sizeLabel2.text = sizeString;
        } success:^(NSString *filePath) {
            
        } failure:^(NSError *error) {
            
        }];
    }
    button.selected = !button.selected;
}


- (void)removeAll:(UIButton *)button {
    self.speedLabel1.text = @"0kb/s";
    self.progressView1.progress = 0;
    self.downLoadBtn1.selected = NO;
    self.speedLabel2.text = @"0kb/s";
    self.progressView2.progress = 0;
    self.downLoadBtn2.selected = NO;
    [[LBCDownLoadManager shredManager] removeAllFileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
