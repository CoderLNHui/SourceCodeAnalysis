//
//  NetWorkManager.m
//  https://github.com/CoderLN/Apple-GitHub-Codeidea
//


#import "NetWorkManager.h"
#import "UIImage+LNCompressIMG.h"

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

#define ACCESS_TOKEN @"access_token"

@implementation NetWorkManager

/**
 * 获得全局网络请求实例单例方法
 *
 * @return 网络请求类的实例对象
 */
+ (instancetype)sharedManager
{
    static NetWorkManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 设置BaseURL
        // 注意：BaseURL中一定要以/结尾
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://120.25.226.186:32812/"]];
    });
    
    return instance;
}


// 重写 initWithBaseURL
- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        
#warning 可根据情况进行配置
      
        // 设置响应序列化
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // 设置请求序列化
        AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer = requestSerializer;
        
        // 设置请求超时,默认60.0s
        //configuration.timeoutIntervalForRequest = 10.0;
        [requestSerializer willChangeValueForKey:@"timeoutInterval"];
        requestSerializer.timeoutInterval = 15.0;
        [requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        // 设置请求头
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 我们项目是把access_token（后台验证用户身份标识）放在了请求头里,有的项目是放在了请求体里,视实际情况而定
        [requestSerializer setValue:ACCESS_TOKEN forHTTPHeaderField:@"access_token"];
        
        // 设置缓存策略
        requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        // 是否信任带有一个无效或者过期的SSL证书的服务器，默认不信任。
        self.securityPolicy.allowInvalidCertificates = YES;
        // 是否验证域名的CN字段（不是必须的，但是如果写YES，则必须导入证书）
        self.securityPolicy.validatesDomainName = NO;
    
        
        // ❎强制更换AFN数据解析类型，只支持一下添加的数据类型这样AFN自带的就没有了，如果AFN新增了数据解析类型这里也没有变化，所以采用在原有可解析数据类型基础上添加。
        //self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
        
        // 获取AFN原由数据解析类型基础上添加一些响应解析器能够接受的数据类型
        NSMutableSet * acceptableContentTypes = [NSMutableSet setWithSet:self.responseSerializer.acceptableContentTypes];
        [acceptableContentTypes addObjectsFromArray:@[@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain"]];
        self.responseSerializer.acceptableContentTypes = acceptableContentTypes;

        
        // 设配型号
        [self.requestSerializer setValue:[UIDevice currentDevice].model forHTTPHeaderField:@"iPhone"];
        // 系统版本
        [self.requestSerializer setValue:[UIDevice currentDevice].systemVersion forHTTPHeaderField:@"OS"];
    }
    
    return self;
}








#pragma mark - 网络请求 GET / POST
/**
 * 网络请求
 *
 * @param requestType   GET / POST
 * @param urlString     请求的地址
 * @param parameters    请求的参数
 * @param successBlock  请求成功的回调
 * @param failureBlock  请求失败的回调
 */
+ (void)requestWithType:(HttpRequestType)requestType url:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)successBlock failure:(requestFailure)failureBlock
{
    // AFN没有做UTF8转码,防止URL字符串中含有中文或特殊字符发生崩溃
    urlString = [[NSString stringWithFormat:@"%@",urlString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    switch (requestType) {
            
        case HttpRequestTypeGET:
        {
            [[NetWorkManager manager] GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                //将接收回来的数据转成UTF8的字符串，然后取出格式占位符 加上个转义符后才能让数据进行转换 否则转换失败
                //NSString * jsonString = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length]encoding:NSUTF8StringEncoding];
                //jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
                //NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
                successBlock(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
            }];
            
        }
            break;
            
        case HttpRequestTypePOST:
        {
            [[NetWorkManager manager] POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                successBlock(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
            }];
            
        }
            break;
            
        default:
            break;
    }
}





#pragma mark - 文件下载
/**
 * 文件下载
 *
 * @param urlString             请求的地址
 * @param downloadProgressBlock 下载进度回调
 * @param completionHandler     请求完成回调
 *        fullPath              文件存储路径
 */
+ (void)downloadFileWithURL:(NSString *)urlString parameters:(id)parameters progress:(progress)downloadProgressBlock completionHandler:(completionHandler)completionHandler
{
    NetWorkManager * manager = [NetWorkManager manager];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // 下载进度
        downloadProgressBlock(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // 指定存储路径fullPath, targetPath临时路径
        NSString * fullPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:fullPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        completionHandler(filePath,error);
    }];
    
    [task resume];
}






#pragma mark - 文件上传 (单张 或 多张图片上传)
/**
 * 文件上传 (多张图片上传)
 *
 * @param urlString         上传的地址
 * @param imageAry          上传的图片数组
 * @param width             图片要被压缩到的宽度
 * @param uploadProgressBlock    上传进度
 * @param successBlock      上传成功的回调
 * @param failureBlock      上传失败的回调
 */
+ (void)uploadFileWithURL:(NSString *)urlString parameters:(id)parameters imageAry:(NSArray *)imageAry targetWidth:(CGFloat)width progress:(progress)uploadProgressBlock success:(requestSuccess)successBlock failure:(requestFailure)failureBlock
{
    
    [[NetWorkManager manager] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        int i = 0;
        for (UIImage *image in imageAry) {
            // image分类方法, 压缩图片
            UIImage * resizedImage = [UIImage IMGCompressed:image targetWidth:width];
            NSData * imageData = UIImagePNGRepresentation(resizedImage);
            
            // 拼接Data
            [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"picture%d",i] mimeType:@"image/png"];
            
            //[formData appendPartWithFileURL:[NSURL fileURLWithPath:@" "] name:@"file" fileName:[NSString stringWithFormat:@"picture%d.png",i] mimeType:@"image/png" error:nil];
          
            //[formData appendPartWithFileURL:[NSURL fileURLWithPath:@" "] name:@"file" error:nil];
            
            i++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        uploadProgressBlock(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
    }];
    
}













#pragma mark - 视频上传

/**
 *  视频上传
 *
 *  @param operations   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 
 整体思路已经清楚，拿到视频资源，先转为mp4，写进沙盒，然后上传，上传成功后删除沙盒中的文件。
 本地拍摄的视频，上传到服务器：
 https://www.cnblogs.com/HJQ2016/p/5962813.html
 */

+ (void)uploadVideoWithOperaitons:(NSDictionary *)operations withVideoPath:(NSString *)videoPath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withUploadProgress:(progress)progress
{
    
    /**获得视频资源*/
    
    AVURLAsset * avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
    //    AVURLAsset * avAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
    /**压缩*/
    
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    /**创建日期格式化器*/
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /**转化后直接写入Library---caches*/
    //NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];
    //avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
    
    avAssetExport.outputURL = [NSURL fileURLWithPath:videoPath];
    
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([avAssetExport status]) {
                
            case AVAssetExportSessionStatusCompleted:
            {
                AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
                
                [manager POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    //获得沙盒中的视频内容
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoPath] name:@"write you want to writre" fileName:videoPath mimeType:@"video/mpeg4" error:nil];
                    //[formData appendPartWithFileURL:[NSURL fileURLWithPath:videoPath] name:@"file" fileName:@"testVideo" mimeType:@"video/mp4" error:nil];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                    progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    
                    successBlock(responseObject);
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    failureBlock(error);
                    
                }];
                
                break;
            }
            default:
                break;
        } 
    }];
}










#pragma mark - 取消所有的网络请求
/**
 * 取消所有的网络请求
 */
+ (void)cancelAllRequest
{
    [[NetWorkManager manager].operationQueue cancelAllOperations];
}
/**
 // 一种：取消所有请求
 for (NSURLSessionTask *task in self.manager.tasks) {
    [task cancel];
 }
 
 // 二种：取消所有请求
 [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
 
 // 三种：关闭NSURLSession + 取消所有请求
 // NSURLSession一旦被关闭了, 就不能再发请求
 [self.manager invalidateSessionCancelingTasks:YES];
 
 // 四种：取消所有请求
 [[NetWorkManager manager].operationQueue cancelAllOperations];
 
 // 注意: 一个请求任务被取消了(cancel), 会自动调用AFN请求的failure这个block, block中传入error参数的code是NSURLErrorCancelled
 */





/**
 * 取消指定的网络请求
 *
 * @param requestMethod     请求方式(GET、POST)
 * @param urlString  请求URL
 */
+ (void)cancelWithRequestMethod:(NSString *)requestMethod parameters:(id)parameters requestUrlString:(NSString *)urlString
{
    // 根据请求的类型 以及 请求的url创建一个NSMutableURLRequest---通过该url去匹配请求队列中是否有该url,如果有的话 那么就取消该请求
    
    NSError * error;
    NSString * requestUrl = [[[[NetWorkManager manager].requestSerializer requestWithMethod:requestMethod URLString:urlString parameters:parameters error:&error] URL] path];
    
    for (NSOperation * operation in [NetWorkManager manager].operationQueue.operations) {
        
        // 如果是请求队列
        if ([operation isKindOfClass:[NSURLSessionTask class]]) {
            
            // 请求的类型匹配
            BOOL hasMatchRequestType = [requestMethod isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            // 请求的url匹配
            BOOL hasMatchRequestURLString = [requestUrl isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            
            // 两项都匹配的话,取消该请求
            if (hasMatchRequestType && hasMatchRequestURLString) {
                [operation cancel];
            }
        }
    }
}





 

#pragma mark - AFN实时检测网络状态

+ (void)afnReachability
{
    // 1.创建检测网络状态管理者 2.检测网络状态改变
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
                
            default:
                break;
        }
    }];
    
    // 3.开始检测
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end











