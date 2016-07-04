# LBCoreNet
![孤独的香蕉.png](http://upload-images.jianshu.io/upload_images/2055592-2195e3e75cdebe08.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
***
<h6>因为本人是个巨懒无比，最近我在寻找一个下载的第三方库，可是找了半天木有很完美的，所以只能自己动手写，虽然很懒得写但是为了活命，还是努力的动手了。</h6>
***
>先不废话，首先队列控制还木有实现，但是多任务下载，获取下载进度，获取下载速度，暂停继续都已经OK了。下面是调用，先看看是不是各位老爷们要的。
>

```
[[LBCDownLoad sharedInstance] downLoad:URL
                                      resume:YES
                                    progress:^(CGFloat progress, NSUInteger size, NSString *speedString) {
                                        NSLog(@"下载进度: %f",progress);
                                        NSLog(@"已下载： %lu",(unsigned long)size);
                                        NSLog(@"下载速度： %@",speedString);
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
                                        }
                                    }];
```

><h6>这个是我自己封装的虽然看起来有些蠢，但是还是挺好用的，首先URL就是下载地址，其次```resume```这个参数重要的不行，就是是否开始，所以其实只需要调用这一个方法就够了，```resume```如果为```YES```那么就继续开始下载，反之暂停下载，别的各位老爷您就自己看吧。

***
<h5>接下来说下思路吧，我用的是```NSURLSessionDataTask```来实现的断点下载。
><h6>首先获得NSURLSession对象并且```<NSURLSessionTaskDelegate>```遵守这个代理协议

``` 
-(NSURLSession *)LBCSession{
    if (!_LBCSession) {
         //创建config对象
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //创建session对象，并添加到主队列中,当然各位老爷也可以不添加到主队列.
        _LBCSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _LBCSession;
}
```

><h6>思路是这样的，取得```URLString```也就是下载的URL的哈希值作为当前任务的唯一标识，在做好下载准备的时候我会在本地沙盒中创建一个plist文件，存储已经开始下载文件的已下载大小，key为```URLString```的哈希，这样如果下载过程中断开网络，等下次连接到网络的时候我也知道这次我下载了多少，再从上次断开的地方接着下载就OK了


```
#pragma mark - 下载方法
-(NSURLSessionDataTask*)downLoad:(NSString *)URLString resume:(BOOL)resume progress:(void (^)(CGFloat, NSUInteger, NSString *))progressBlock state:(void (^)(LBCDownloadState))stateBlack{
    self.url = URLString;
    //判断是否已经下载完成
    if ([self getAllLength:URLString.hash]==[self getFileDownloadedLength:URLString.hash]&&[self getFileDownloadedLength:URLString.hash]>0) {
         LBCDownLoadModel *lbcModel = [self.downloadDic valueForKey:@(URLString.hash).stringValue];
        if (stateBlack) {
            stateBlack(LBCDownloadStateCompleted);
        }
        if (progressBlock) {
            progressBlock(1.0,[self getFileDownloadedLength:URLString.hash],@"0kb/s");
        }
        return lbcModel.task;
    }
    //判断是否正在下载中的任务 （暂停和继续）
    if ([self.downloadDic valueForKey:@(URLString.hash).stringValue]) {
        LBCDownLoadModel *lbcModel = [self.downloadDic valueForKey:@(URLString.hash).stringValue];
        if (resume) {
            [lbcModel.task resume];
            
        }else {
            [lbcModel.task suspend];
            if (lbcModel.stateBlock) {
                lbcModel.stateBlock(LBCDownloadStateSuspended);
            }
            
        }
        return lbcModel.task;
    }
    // 建立请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:URLString.hash]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    // 创建一个Data任务
    NSURLSessionDataTask *task = [self.LBCSession dataTaskWithRequest:request];
   // 设置下载任务的唯一标示
    [task setValue:@(URLString.hash) forKeyPath:@"taskIdentifier"];
    LBCDownLoadModel *lbc_download = [[LBCDownLoadModel alloc]init];
    lbc_download.task = task;
    lbc_download.progressBlock = progressBlock;
    lbc_download.stateBlock = stateBlack;
    [self.downloadDic setValue:lbc_download forKey:@(URLString.hash).stringValue];
    if (resume) {
        [task resume];
    }
    return task;
}
```

>从```NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];```建立请求开始为正式创建下载任务，上面为判断的是否已经下载和任务继续暂停。
上述代码中的```URLString.hash```为url的哈希值，去这个哈希值为的是做唯一标示，在多任务处理数据时可以根据唯一标识来判断是哪个任务。

<h5>接下来为```NSURLSessionDataTask```的代理方法
```
#pragma mark Delegate
// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)
response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {

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
        if (lbc_Model.stateBlock) {
            lbc_Model.stateBlock(LBCDownloadStateRunning);
        }
        [lbc_Model.stream write:data.bytes maxLength:data.length];
        CGFloat scale = (double)[self getFileDownloadedLength:dataTask.taskIdentifier] / lbc_Model.allLength;
        if (lbc_Model.progressBlock) {
            //计算网速
            NSString *speedString=@"0.00Kb/s";
            NSString *growString=[LBCDownLoad convertSize:_growth];
            speedString=[NSString stringWithFormat:@"%@/s",growString];
            lbc_Model.progressBlock(scale,[self getFileDownloadedLength:dataTask.taskIdentifier],speedString);
        }
    }
    
}
```
>然后是计算下载速度，其实很简单，就是用当前这一秒的下载数据大小减去前一秒的下载数据大小，就是下载速度啦

```
- (instancetype)init
{
    self = [super init];
    if (self) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getGrowthSize) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)getGrowthSize
{
    NSInteger size=[self getFileDownloadedLength:self.url.hash];
    _growth=size-_lastSize;
    _lastSize=size;
}
```

***