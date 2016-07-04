//
//  LBCNetWorking.m
//  LBFKTest
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import "LBCNetWorking.h"

@implementation LBCNetWorking

+ (instancetype)request {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.operationManager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(LBCNetWorking *, NSString *))success
    failure:(void (^)(LBCNetWorking *, NSError *))failure {
    
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    [self.operationManager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"%@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *responseJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"[CMRequest]: %@",responseJson);
        success(self,responseJson);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"[CMRequest]: %@",error.localizedDescription);
        failure(self,error);
    }];
    
    //    [self.operationManager GET:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    //                    parameters:nil
    //                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                           NSString *responseJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    //                           NSLog(@"[CMRequest]: %@",responseJson);
    //                           success(self,responseJson);
    //                       }
    //                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                           NSLog(@"[CMRequest]: %@",error.localizedDescription);
    //
    //                           failure(self,error);
    //                       }];
}

- (void)POST:(NSString *)URLString
  parameters:(NSDictionary*)parameters
     success:(void (^)(LBCNetWorking *request, NSString* responseString))success
     failure:(void (^)(LBCNetWorking *request, NSError *error))failure{
    
    self.operationQueue = self.operationManager.operationQueue;
    self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.operationManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString* responseJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        responseJson = [responseJson stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        responseJson = [responseJson stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        NSLog(@"[CMRequest]: %@",responseJson);
        success(self,responseJson);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"[CMRequest]: %@",error.localizedDescription);
        failure(self,error);
        
    }];
    
    //    [self.operationManager POST:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    //                     parameters:parameters
    //                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                            NSString* responseJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
    //                            NSLog(@"[CMRequest]: %@",responseJson);
    //
    //                            NSDictionary *dict = [responseJson objectFromJSONString];
    //                            NSLog(@"dict------%@",dict);
    //                            success(self,responseJson);
    //                        }
    //                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
    //                            NSLog(@"[CMRequest]: %@",error.localizedDescription);
    //                            failure(self,error);
    //                        }];
    
}

-(void)downLoad:(NSString *)URLString andMaxTask:(int)maxTask success:(void (^)(LBCNetWorking *, NSString *))success progress:(void (^)(NSProgress *, NSString *, NSString *))progress failure:(void (^)(LBCNetWorking *, NSError *))failure{
    // 获得NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 获得下载任务
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // 文件将来存放的真实路径
        NSString *file = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        // 剪切location的临时文件到真实路径
        NSFileManager *mgr = [NSFileManager defaultManager];
        [mgr moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
    }];
    [task resume];
}

-(void)cancelDownLoad{
    [self.currentDownLoadTask cancel];
}

- (void)cancelAllOperations{
    
    [self.operationQueue cancelAllOperations];
}
@end
