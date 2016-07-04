//
//  LBCDownLoad.m
//  LBCoreKit
//
//  Created by ZED-3 on 16/7/1.
//  Copyright © 2016年 LonelyBanana. All rights reserved.
//

#import "LBCDownLoad.h"
//typedef void (^ProcessHandle)(CGFloat progress,NSString *sizeString,NSString *speedString);
//typedef void (^CompletionHandle)();
//typedef void (^FailureHandle)(NSError *error);

@interface LBCDownLoad ()<NSURLSessionTaskDelegate>{
    NSInteger       _lastSize;
    NSInteger       _growth;
    NSTimer         *_timer;
    NSString        *_fileName;
}

@property (nonatomic, strong) NSMutableDictionary *downloadDic;

@property (nonatomic, strong) NSURLSession *LBCSession;

@property (nonatomic, copy)NSString *url_string;

@end
@implementation LBCDownLoad

-(void)getGrowthSize
{
    NSInteger size=[self getFileDownloadedLength:self.url_string.hash];
    if (size>0) {
        _growth=size-_lastSize;
        _lastSize=size;
    }
}

static LBCDownLoad *_myDownload;
+ (LBCDownLoad *)sharedInstance {
    if (!_myDownload) {
        _myDownload = [[self alloc]init];
    }
    return _myDownload;
}

/**
 * 获取对象的类方法
 */
+(instancetype)downloader
{
    return [[[self class] alloc]init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getGrowthSize) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (CGFloat)progressWithUrl:(NSString*)url {
    self.url_string = url;
    NSUInteger loadedLength = [self getFileDownloadedLength:[url hash]];
    
    NSUInteger allLength = [self getAllLength:[url hash]];
//    NSLog(@"loaded:%lud  all:%lud",loadedLength,allLength);
    if (allLength == 0) {
        return 0.0;
    }
    return (double)loadedLength / allLength;
}

- (void)resumeWithUrl:(NSString*)url {
    LBCDownLoadModel *lc_D = [self.downloadDic valueForKey:@(url.hash).stringValue];
    if (lc_D) {
        [lc_D.task resume];
    }
}

- (void)suspendWithUrl:(NSString*)url {
    LBCDownLoadModel *lc_D = [self.downloadDic valueForKey:@(url.hash).stringValue];
    if (lc_D) {
        [lc_D.task suspend];
        //        lc_D.stateBlock(LBCDownloadStateSuspended);
    }
}

- (void)cancelWithUrl:(NSString*)url{
    LBCDownLoadModel *lc_D = [self.downloadDic valueForKey:@(url.hash).stringValue];
    if (lc_D) {
        [lc_D.task cancel];
        if(_timer)
        {
            [_timer invalidate];
        }
        //        lc_D.stateBlock(LBCDownloadStateCanceled);
    }
}

- (NSData *)downloadedDataWithUrl:(NSString*)url {
    return [self getFileDownloadedData:url.hash];
}

- (void)removeAllFileData {
    NSString *fullPath = [self getCachDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil];
    [self.downloadDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, LBCDownLoadModel *lc_D, BOOL *stop) {
        if (lc_D) {
            [lc_D.task suspend];
            lc_D.ProcessHandle(0.0,[self filesSize:self.url_string],@"0.0kb/s");
            [self.downloadDic removeObjectForKey:key];
        }
    }];
}

- (void)removeAllLength:(NSString *)url {
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:@(url.hash).stringValue]) {
        [dic removeObjectForKey:@(url.hash).stringValue];
        [dic writeToFile:path atomically:YES];
    }
}
#pragma mark - lazyLoad
// 获得NSURLSession对象
-(NSURLSession *)LBCSession{
    if (!_LBCSession) {
        //创建config对象
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //创建session对象，并添加到主队列中
        _LBCSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _LBCSession;
}

- (NSMutableDictionary *)downloadDic {
    if (!_downloadDic) {
        _downloadDic = [[NSMutableDictionary alloc]init];
    }
    return _downloadDic;
}

#pragma mark - 下载方法
/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调的代码块，会多次调用
 *  @param  completion      下载完成回调的代码块
 *  @param  failure         下载失败的回调代码块
 */
-(void)downloadWithUrlString:(NSString *)urlString toFileName:(NSString *)fileName process:(ProcessHandle)process completion:(CompletionHandle)completion failure:(FailureHandle)failure{
    if(urlString&&fileName)
    {
        self.url_string=urlString;
        _fileName=fileName;
        _process=process;
        _completion=completion;
        _failure=failure;
        //判断是否已经下载完成
        if ([self getAllLength:urlString.hash]==[self getFileDownloadedLength:urlString.hash]&&[self getFileDownloadedLength:urlString.hash]>0) {
            LBCDownLoadModel *lbcModel = [self.downloadDic valueForKey:@(urlString.hash).stringValue];
            if (completion) {
                completion();
            }
            if (process) {
                process(1.0,[self filesSize:urlString],@"0kb/s");
            }
            return;
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:urlString.hash]];
        [request setValue:range forHTTPHeaderField:@"Range"];
        // 创建一个Data任务
        NSURLSessionDataTask *task = [self.LBCSession dataTaskWithRequest:request];
        // 设置下载任务的唯一标示
        [task setValue:@(urlString.hash) forKeyPath:@"taskIdentifier"];
        LBCDownLoadModel *lbc_download = [[LBCDownLoadModel alloc]init];
        lbc_download.task = task;
        lbc_download.fileName = fileName;
        lbc_download.ProcessHandle = process;
        lbc_download.CompetionHandle = completion;
        lbc_download.FailureHandle = failure;
        [self.downloadDic setValue:lbc_download forKey:@(urlString.hash).stringValue];
        [task resume];
        
    }
}

//-(NSURLSessionDataTask*)downLoad:(NSString *)URLString resume:(BOOL)resume progress:(void (^)(CGFloat, NSUInteger, NSString *))progressBlock state:(void (^)(LBCDownloadState))stateBlack{
//
//    self.url = URLString;
//    //判断是否已经下载完成
//    if ([self getAllLength:URLString.hash]==[self getFileDownloadedLength:URLString.hash]&&[self getFileDownloadedLength:URLString.hash]>0) {
//        LBCDownLoadModel *lbcModel = [self.downloadDic valueForKey:@(URLString.hash).stringValue];
//        if (stateBlack) {
//            stateBlack(LBCDownloadStateCompleted);
//        }
//        if (progressBlock) {
//            progressBlock(1.0,[self getFileDownloadedLength:URLString.hash],@"0kb/s");
//        }
//        return lbcModel.task;
//    }
//    //判断是否正在下载中的任务 （暂停和继续）
//    if ([self.downloadDic valueForKey:@(URLString.hash).stringValue]) {
//        LBCDownLoadModel *lbcModel = [self.downloadDic valueForKey:@(URLString.hash).stringValue];
//        if (resume) {
//            [lbcModel.task resume];
//
//        }else {
//            [lbcModel.task suspend];
//            if (lbcModel.stateBlock) {
//                lbcModel.stateBlock(LBCDownloadStateSuspended);
//            }
//
//        }
//        return lbcModel.task;
//    }
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
//    // 设置请求头
//    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:URLString.hash]];
//    [request setValue:range forHTTPHeaderField:@"Range"];
//    // 创建一个Data任务
//    NSURLSessionDataTask *task = [self.LBCSession dataTaskWithRequest:request];
//    // 设置下载任务的唯一标示
//    [task setValue:@(URLString.hash) forKeyPath:@"taskIdentifier"];
//    LBCDownLoadModel *lbc_download = [[LBCDownLoadModel alloc]init];
//    lbc_download.task = task;
//    lbc_download.progressBlock = progressBlock;
//    lbc_download.stateBlock = stateBlack;
//    [self.downloadDic setValue:lbc_download forKey:@(URLString.hash).stringValue];
//    if (resume) {
//        [task resume];
//    }
//    return task;
//}

// 创建文件名
- (NSString *)createFileName:(NSInteger )urlHash {
    return [NSString stringWithFormat:@"LCDownload%ld",(long)urlHash];
}
// 创建缓存路径
- (NSString *)createCachePath:(NSInteger )urlHash {
    
    NSString *fileName = _fileName;//[self createFileName:urlHash];
    NSString *fullPath = [self getCachFileDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:fullPath]){
    [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:NULL];
   
    NSString *path = [fullPath stringByAppendingPathComponent:fileName];
    
    return path;
}

- (NSUInteger)getAllLength:(NSInteger)urlHash {
    
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:[NSString stringWithFormat:@"%lud",urlHash]]) {
        return ((NSNumber *)[dic valueForKey:[NSString stringWithFormat:@"%lud",urlHash]]).unsignedIntegerValue;
    }
    return 0;
}

- (NSMutableDictionary *)getFileAllLengthDic {
    NSString *path = [self getFileAllLengthPath];
    return [[NSMutableDictionary alloc]initWithContentsOfFile:path];
}

- (void)createFileAllLengthPlist {
    NSString *path = [self getFileAllLengthPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic writeToFile:path atomically:YES];
    }
}

- (NSString *)getFileAllLengthPath {
    NSString *path = [self getCachDirectory];
    path = [path stringByAppendingPathComponent:@"AllLength.plist"];
    return  path;
}
- (NSString *)getCachDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"LBCDownLoadCache/"]];
    
}

- (NSString *)getCachFileDirectory {
    if (self.url_string.hash>0) {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"LBCDownLoadCache/%lud/",self.url_string.hash]];
    }else{
        return [self getCachDirectory];
    }
    
}
// 获取本地已经下载的大小
- (NSUInteger)getFileDownloadedLength:(NSInteger)urlHash {
    NSData *data = [self getFileDownloadedData:urlHash];
    if (data) return data.length;
    return 0.0;
}

- (NSData *)getFileDownloadedData:(NSInteger)urlHash {
    NSString *fullPath = [self getCachFileDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPath]) {
         NSEnumerator *childFilesEnumerator = [[fileManager subpathsAtPath:fullPath] objectEnumerator];
        NSString* fileName;
        NSString* fileAbsolutePath;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            fileAbsolutePath = [fullPath stringByAppendingPathComponent:fileName];
//            folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
        NSData *data = [NSData dataWithContentsOfFile:fileAbsolutePath];
        return data;
    }
    return nil;
}

//单个文件的大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)setAllLength:(NSUInteger)allLength WithTag:(NSUInteger)urlHash {
    [self createFileAllLengthPlist];
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    [dic setValue:@(allLength) forKey:[NSString stringWithFormat:@"%lud",urlHash]];
    [dic writeToFile:path atomically:YES];
}

/**
 * 计算缓存的占用存储大小
 *
 * @prama length  文件大小
 */
+(NSString *)convertSize:(NSInteger)length
{
    if(length<1024)
        return [NSString stringWithFormat:@"%ldB",(long)length];
    else if(length>=1024&&length<1024*1024)
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    else if(length >=1024*1024&&length<1024*1024*1024)
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
}

/**获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
 */
-(NSString *)filesSize:(NSString *)url
{
    NSInteger totalLength=[self getAllLength:url.hash];
    if(totalLength==0)
    {
        return @"0.00K/0.00K";
    }
    NSInteger currentLength=[self getFileDownloadedLength:url.hash];
    
    NSString *currentSize=[LBCDownLoad convertSize:currentLength];
    NSString *totalSize=[LBCDownLoad convertSize:totalLength];
    return [NSString stringWithFormat:@"%@/%@",currentSize,totalSize];
}

#pragma mark Delegate
// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)
response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
//    NSLog(@"%@",response.textEncodingName);
    
    LBCDownLoadModel *lbc_Model = [self.downloadDic valueForKey:@(dataTask.taskIdentifier).stringValue];
    NSUInteger allLength = response.expectedContentLength + [self getFileDownloadedLength:dataTask.taskIdentifier];
    [self setAllLength:allLength WithTag:dataTask.taskIdentifier];
    NSString *fullPath = [self createCachePath:dataTask.taskIdentifier];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fullPath append:YES];
    lbc_Model.stream = stream;
    lbc_Model.allLength = allLength;
    [lbc_Model.stream open];
    completionHandler(NSURLSessionResponseAllow);
}
// 接受数据（会多次调用）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    LBCDownLoadModel *lbc_Model = [self.downloadDic valueForKey:@(dataTask.taskIdentifier).stringValue];
    if (lbc_Model) {
        [lbc_Model.stream write:data.bytes maxLength:data.length];
        CGFloat scale = (double)[self getFileDownloadedLength:dataTask.taskIdentifier] / lbc_Model.allLength;
        if (lbc_Model.ProcessHandle) {
            //计算网速
            NSString *speedString=@"0.00Kb/s";
            NSString *growString=[LBCDownLoad convertSize:_growth];
            speedString=[NSString stringWithFormat:@"%@/s",growString];
            lbc_Model.ProcessHandle(scale,[self filesSize:self.url_string],speedString);
        }
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTaskdidFinishDownloadingToURL:(NSURL *)location{

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    LBCDownLoadModel *lbc_Model = [self.downloadDic valueForKey:@(task.taskIdentifier).stringValue];
    NSLog(@"%@",error);
    if (error==nil) {
        lbc_Model.CompetionHandle();
    }else{
        lbc_Model.FailureHandle(error);
    }
}

@end
