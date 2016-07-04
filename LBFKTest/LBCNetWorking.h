//
//  LBCNetWorking.h
//  LBFKTest
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface LBCNetWorking : NSObject

/**
 *[AFNetWorking]的operationManager对象
 */
@property (nonatomic, strong) AFHTTPSessionManager* operationManager;
/**
 *当前的请求operation队列
 */
@property (nonatomic, strong) NSOperationQueue* operationQueue;
/**
 *当前下载operation队列
 */
@property (nonatomic, strong) NSOperationQueue* downLoadQueue;
/**
 *当前下载的任务
 */
@property (nonatomic, strong) NSURLSessionDataTask *currentDownLoadTask;
/**
 *功能: 创建CMRequest的对象方法
 */
+ (instancetype)request;
/**
 *功能：GET请求
 *参数：(1)请求的url: urlString
 *     (2)请求成功调用的Block: success
 *     (3)请求失败调用的Block: failure
 */
- (void)GET:(NSString *)URLString
    success:(void (^)(LBCNetWorking *request, NSString* responseString))success
    failure:(void (^)(LBCNetWorking *request, NSError *error))failure;

/**
 *功能：POST请求
 *参数：(1)请求的url: urlString
 *     (2)POST请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)POST:(NSString *)URLString
  parameters:(NSDictionary*)parameters
     success:(void (^)(LBCNetWorking *request, NSString* responseString))success
     failure:(void (^)(LBCNetWorking *request, NSError *error))failure;


- (void)downLoad:(NSString *)URLString andMaxTask:(int)maxTask
    success:(void (^)(LBCNetWorking *request, NSString* responseString))success
           progress:(void (^)(NSProgress *downloadProgress,NSString *sizeString,NSString *speedString))progress
    failure:(void (^)(LBCNetWorking *request, NSError *error))failure;

/**
 *取消当前请求队列的所有请求
 */
- (void)cancelAllOperations;
@end
