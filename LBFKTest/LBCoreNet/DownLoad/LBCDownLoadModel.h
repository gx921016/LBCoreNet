//
//  LBCDownLoadModel.h
//  LBCoreKit
//
//  Created by macbookpro gao on 16/7/3.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
typedef enum {
    LBCDownloadStateRunning = 0,     /** 下载中 */
    LBCDownloadStateSuspended,     /** 下载暂停 */
    LBCDownloadStateCompleted,     /** 下载完成 */
    LBCDownloadStateCanceled,     /** 取消下载 */
    LBCDownloadStateFailed         /** 下载失败 */
}LBCDownloadState;
@interface LBCDownLoadModel : NSObject
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) long long allLength;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, copy)NSString *fileName;

@property (nonatomic, copy) void (^ProcessHandle)(CGFloat progress,NSString *sizeString,NSString *speedString);
@property (nonatomic, copy) void (^FailureHandle)(NSError *error);

@property (nonatomic, copy) void (^CompetionHandle)();
@end
