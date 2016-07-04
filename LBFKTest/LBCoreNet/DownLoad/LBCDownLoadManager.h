//
//  LBCDownLoadManager.h
//  LBCoreKit
//
//  Created by macbookpro gao on 16/7/3.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface LBCDownLoadManager : NSObject

@property (nonatomic, assign)NSInteger maxTask;

+(instancetype)shredManager;

-(void)downLoad:(NSString *)URLString fileName:(NSString *)fileName progress:(void (^)(CGFloat progress, NSString *sizeString, NSString *speedString))progressBlock success:(void (^)(NSString *filePath))successBlock failure:(void (^)(NSError *error))failureBlock;


/**
 *  暂停下载任务
 *
 *  @param url 下载的链接
 */
-(void)suspendDownloadTask:(NSString *)url;
/**
 *  获取下载任务
 *
 *  @param url 下载的链接
 */
-(CGFloat)getDownLoadProgressWithUrl:(NSString *)url;

/**
 *  取消全部下载任务
 *
 */
- (void)removeAllFileData;
@end
