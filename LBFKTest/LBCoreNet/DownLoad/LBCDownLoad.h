//
//  LBCDownLoad.h
//  LBCoreKit
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "LBCDownLoadModel.h"
//下载过程中回调的代码块，3个参数分别为：下载进度、已下载部分大小/文件大小构成的字符串(如:1.15M/5.27M)、
//以及文件下载速度字符串(如:512Kb/s)
typedef void (^ProcessHandle)(CGFloat progress,NSString *sizeString,NSString *speedString);
typedef void (^CompletionHandle)();
typedef void (^FailureHandle)(NSError *error);

@interface LBCDownLoad : NSObject

//下载过程中回调的代码块，会多次调用。
@property(nonatomic,copy,readonly)ProcessHandle process;
//下载完成回调的代码块
@property(nonatomic,copy,readonly)CompletionHandle completion;
//下载失败的回调代码块
@property(nonatomic,copy,readonly)FailureHandle failure;


+(instancetype)downloader;
/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调的代码块，会多次调用
 *  @param  completion      下载完成回调的代码块
 *  @param  failure         下载失败的回调代码块
 */
-(void)downloadWithUrlString:(NSString *)urlString
                      toFileName:(NSString *)fileName
                     process:(ProcessHandle)process
                  completion:(CompletionHandle)completion
                     failure:(FailureHandle)failure;

/*
-(void)downLoad:(NSString *)URLString resume:(BOOL)resume progress:(void (^)(CGFloat progress, NSUInteger size, NSString *speedString))progressBlock state:(void(^)(LBCDownloadState state))stateBlack;
*/

/**
 *  删除本地数据
 *
 *  @param url 下载链接
 */
- (void)removeFileDataWithUrl:(NSString*)url;

/**
 *  清空
 */
- (void)removeAllFileData;

/**
 *  总大小
 *
 *  @param  url 下载链接
 */
- (NSUInteger)allLengthWithUrl:(NSString*)url;

/**
 *  进度
 *
 *  @param  url 下载链接
 */
- (CGFloat)progressWithUrl:(NSString*)url;

/**
 *  开始
 *
 *  @param  url 下载链接
 */
- (void)resumeWithUrl:(NSString*)url;

/**
 *  暂停
 *
 *  @param  url 下载链接
 */
- (void)suspendWithUrl:(NSString*)url;

/**
 *  取消
 *
 *  @param  url 下载链接
 */
- (void)cancelWithUrl:(NSString*)url;

/**
 *  已经下载的本地数据
 *
 *  @param  url 下载链接
 */
- (NSData *)downloadedDataWithUrl:(NSString*)url;
@end
