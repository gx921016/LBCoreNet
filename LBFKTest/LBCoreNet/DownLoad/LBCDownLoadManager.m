//
//  LBCDownLoadManager.m
//  LBCoreKit
//
//  Created by macbookpro gao on 16/7/3.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import "LBCDownLoadManager.h"
#import "LBCDownLoad.h"
@interface LBCDownLoadManager()

@property (nonatomic, strong)NSMutableArray *queueMtArray;

@property (nonatomic, strong)NSMutableDictionary *taskDic;

@end
@implementation LBCDownLoadManager

#pragma mark -         -------- 初始化 -------
static LBCDownLoadManager *downLoadManager=nil;

+(instancetype)shredManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downLoadManager=[[LBCDownLoadManager alloc]init];
    });
    return downLoadManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxTask = 2;
    }
    return self;
}

#pragma mark -         -------- lazyLoad -------
-(NSMutableArray *)queueMtArray{
    if (!_queueMtArray) {
        _queueMtArray = [NSMutableArray array];
    }
    return _queueMtArray;
}
-(NSMutableDictionary *)taskDic{
    if (!_taskDic) {
        _taskDic = [NSMutableDictionary dictionary];
    }
    return _taskDic;
}

#pragma mark -         -------- 方法 -------
-(void)downLoad:(NSString *)URLString fileName:(NSString *)fileName progress:(void (^)(CGFloat, NSString*, NSString *))progressBlock success:(void (^)(NSString *))successBlock failure:(void (^)(NSError *))failureBlock{
    if (self.taskDic.count>self.maxTask) {
        NSDictionary *dict=@{@"urlString":URLString,
                             @"fileName":fileName,
                             @"process":progressBlock,
                             @"completion":successBlock,
                             @"failure":failureBlock};
        [self.queueMtArray addObject:dict];
        return;
    }
    LBCDownLoad *downLoad = [LBCDownLoad downloader];
    @synchronized(self){
        [self.taskDic setObject:downLoad forKey:URLString];
    }
    [downLoad downloadWithUrlString:URLString
                             toFileName:fileName
                            process:progressBlock
                         completion:successBlock
                            failure:failureBlock];
    
}


-(CGFloat)getDownLoadProgressWithUrl:(NSString *)url{
     LBCDownLoad *downloader=[LBCDownLoad downloader];
   return [downloader progressWithUrl:url];
}

/**
 *  暂停下载任务
 *
 *  @param url 下载的链接
 */
-(void)suspendDownloadTask:(NSString *)url
{
    LBCDownLoad *downloader=[self.taskDic objectForKey:url];
    [downloader cancelWithUrl:url];
    @synchronized (self) {
        [self.taskDic removeObjectForKey:url];
    }
    if(self.queueMtArray.count>0){
        NSDictionary *first=[self.queueMtArray objectAtIndex:0];
        [self downLoad:
         first[@"urlString"] fileName:
         first[@"fileName"] progress:
         first[@"process"] success:
         first[@"completion"] failure:
         first[@"failure"]];
        //从排队对列中移除一个下载任务
        [self.queueMtArray removeObjectAtIndex:0];
    }
}

- (void)removeAllFileData{
    LBCDownLoad *downloader= [LBCDownLoad downloader];
    [downloader removeAllFileData];
    [self.taskDic removeAllObjects];
    [self.queueMtArray removeAllObjects];
}

@end
