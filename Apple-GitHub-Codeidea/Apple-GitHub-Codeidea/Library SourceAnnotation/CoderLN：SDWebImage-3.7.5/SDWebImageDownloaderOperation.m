/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageDecoder.h"
#import "UIImage+MultiFormat.h"
#import <ImageIO/ImageIO.h>
#import "SDWebImageManager.h"

NSString *const SDWebImageDownloadStartNotification = @"SDWebImageDownloadStartNotification";                    //开始下载
NSString *const SDWebImageDownloadReceiveResponseNotification = @"SDWebImageDownloadReceiveResponseNotification";//接收到响应
NSString *const SDWebImageDownloadStopNotification = @"SDWebImageDownloadStopNotification";                      //停止下载
NSString *const SDWebImageDownloadFinishNotification = @"SDWebImageDownloadFinishNotification";                  //下载完成

@interface SDWebImageDownloaderOperation () <NSURLConnectionDataDelegate>

@property (copy, nonatomic) SDWebImageDownloaderProgressBlock progressBlock;        //进度block
@property (copy, nonatomic) SDWebImageDownloaderCompletedBlock completedBlock;      //完成后的回调block
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;                    //取消回调block

@property (assign, nonatomic, getter = isExecuting) BOOL executing;     //任务的执行状态
@property (assign, nonatomic, getter = isFinished) BOOL finished;       //任务是否执行完毕
@property (strong, nonatomic) NSMutableData *imageData;                 //图片的二进制数据
@property (strong, nonatomic) NSURLConnection *connection;              //网络连接对象
@property (strong, atomic) NSThread *thread;                            //NSThread类型的线程对象

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;  //通过UIBackgroundTaskIdentifier可以实现有限时间内在后台运行程序
#endif

@end

@implementation SDWebImageDownloaderOperation {
    size_t width, height;            //宽度和高度，用来处理渐进式下载
    UIImageOrientation orientation;
    BOOL responseFromCached;
}

#warning 4 为什么采用此法
@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark --------------------------------
#pragma mark Methods

//初始化operation的方法
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock {
    if ((self = [super init])) {
        _request = request;
        _shouldDecompressImages = YES;
        _shouldUseCredentialStorage = YES;
        _options = options;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelBlock copy];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        responseFromCached = YES; // Initially wrong until `connection:willCacheResponse:` is called or not called
    }
    return self;
}

//核心方法：在该方法中处理图片下载操作
- (void)start {
    @synchronized (self) {
        //判断当前操作是否被取消，如果被取消了，则标记任务结束，并处理后续的block和清理操作
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }

        //条件编译，如果是iphone设备且大于4.0
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
       
        //程序即将进入后台
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak __typeof__ (self) wself = self;
            
            //获得UIApplication单例对象
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            
            //UIBackgroundTaskIdentifier：通过UIBackgroundTaskIdentifier可以实现有限时间内在后台运行程序
            //在后台获取一定的时间去指行我们的代码
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;

#warning 3
                if (sself) {
                    [sself cancel]; //取消当前下载操作

                    [app endBackgroundTask:sself.backgroundTaskId]; //结束后台任务
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif
        
        self.executing = YES;   //当前任务正在执行
        
        //创建NSURLConnection对象，并设置代理（没有马上发送请求）
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        
        //获得当前线程
        self.thread = [NSThread currentThread];
    }

    [self.connection start];    //发送网络请求

    if (self.connection) {
        if (self.progressBlock) {
            //进度block的回调
            self.progressBlock(0, NSURLResponseUnknownLength);
        }
        //注册通知中心，在主线程中发送通知SDWebImageDownloadStartNotification【任务开始下载】
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:self];
        });

        //开启线程对应的Runloop
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
            // Make sure to run the runloop in our background thread so it can process downloaded data
            //确保后台线程的runloop跑起来
            // Note: we use a timeout to work around an issue with NSURLConnection cancel under iOS 5
            //       not waking up the runloop, leading to dead threads (see https://github.com/rs/SDWebImage/issues/466)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
        }
        else {
            //开启Runloop
            CFRunLoopRun();
        }
        
        if (!self.isFinished) {
            [self.connection cancel];   //取消网络连接
            //处理错误信息
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
        }
    }
    else {
        //执行completedBlock回调，打印Connection初始化失败
        if (self.completedBlock) {
            self.completedBlock(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}], YES);
        }
    }

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}

//取消
- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            //线程间通信，在self.thread线程中调用cancelInternalAndStop方法执行取消和停止操作
            [self performSelector:@selector(cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:NO];
        }
        else {
            [self cancelInternal];
        }
    }
}

//取消和停止
- (void)cancelInternalAndStop {
    if (self.isFinished) return;    //如果已经完成则直接返回
    [self cancelInternal];  //处理取消操作
    CFRunLoopStop(CFRunLoopGetCurrent());   //关停当前的runloop
}

//取消网络
- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    if (self.cancelBlock) self.cancelBlock();   //执行cancelBlock块
    
    //如果连接对象存在，则取消网络请求
    if (self.connection) {
        [self.connection cancel];
        
        //注册通知中心，在主线程中发送通知SDWebImageDownloadStopNotification【下载任务停止】
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });

        //处理当前正在执行和是否已经完成
        // As we cancelled the connection, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }

    //执行清理操作
    [self reset];
}

//任务执行完毕之后，修改当前任务的结束状态（YES）和执行状态（NO），执行清理操作
- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

//清理操作
- (void)reset {
    self.cancelBlock = nil;
    self.completedBlock = nil;
    self.progressBlock = nil;
    self.connection = nil;
    self.imageData = nil;
    self.thread = nil;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark --------------------------------
#pragma mark NSURLConnection (delegate)
//当接收到服务器响应的时候调用该方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    //'304 Not Modified' is an exceptional one
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        //获得下载图片的总大小，并执行进度回调
        if (self.progressBlock) {
            self.progressBlock(0, expected);
        }
        
        //初始化可变的Data用来接收图片数据
        self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
        //得到请求的响应头信息
        self.response = response;
        
        //注册通知中心，在主线程中发送通知SDWebImageDownloadReceiveResponseNotification【接收到服务器的响应】
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadReceiveResponseNotification object:self];
        });
    }
    else {
        //请求出现问题则执行该代码块
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        
        //This is the case when server returns '304 Not Modified'. It means that remote image is not changed.
        //In case of 304 we need just cancel the operation and return cached image from the cache.
        if (code == 304) {
            [self cancelInternal];      //执行取消操作
        } else {
            [self.connection cancel];   //取消请求
        }
        
        //注册通知中心，在主线程中发送通知SDWebImageDownloadStopNotification【下载任务停止】
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
        //执行任务结束block回调，传递错误信息
        if (self.completedBlock) {
            self.completedBlock(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil], YES);
        }
        //关停当前runloop
        CFRunLoopStop(CFRunLoopGetCurrent());
        [self done];
    }
}

//当接收到服务器返回数据的时候调用该方法，可能会调用多次
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //不断拼接接收到的图片数据（二进制数据）
    [self.imageData appendData:data];

    //如果下载图片设置的策略是SDWebImageDownloaderProgressiveDownload，那么处理图片UI
    if ((self.options & SDWebImageDownloaderProgressiveDownload) && self.expectedSize > 0 && self.completedBlock) {
        // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
        // Thanks to the author @Nyx0uf

        // Get the total bytes downloaded
        //获得当前已经接收到的二进制数据大小
        const NSInteger totalSize = self.imageData.length;

        // Update the data source, we must pass ALL the data, not just the new bytes
        // 把图片的二进制数据转换为CGImageSourceRef
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
        
        //如果是第一次（即接收到第一部分的图片数据）
        if (width + height == 0) {
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            if (properties) {
                NSInteger orientationValue = -1;
                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &height);
                val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &width);
                val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
                if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
                CFRelease(properties);

                // When we draw to Core Graphics, we lose orientation information,
                // which means the image below born of initWithCGIImage will be
                // oriented incorrectly sometimes. (Unlike the image born of initWithData
                // in connectionDidFinishLoading.) So save it here and pass it on later.
                orientation = [[self class] orientationFromPropertyValue:(orientationValue == -1 ? 1 : orientationValue)];
            }

        }
        
        //接收数据中期（之前接收过一部分，但为完全）
        if (width + height > 0 && totalSize < self.expectedSize) {
            // Create the image
            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

#ifdef TARGET_OS_IPHONE
            // Workaround for iOS anamorphic image
            if (partialImageRef) {
                const size_t partialHeight = CGImageGetHeight(partialImageRef);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                if (bmContext) {
                    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = partialHeight}, partialImageRef);
                    CGImageRelease(partialImageRef);
                    partialImageRef = CGBitmapContextCreateImage(bmContext);
                    CGContextRelease(bmContext);
                }
                else {
                    CGImageRelease(partialImageRef);
                    partialImageRef = nil;
                }
            }
#endif

            if (partialImageRef) {
                UIImage *image = [UIImage imageWithCGImage:partialImageRef scale:1 orientation:orientation];
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
                UIImage *scaledImage = [self scaledImageForKey:key image:image];
                if (self.shouldDecompressImages) {
                    image = [UIImage decodedImageWithImage:scaledImage];
                }
                else {
                    image = scaledImage;
                }
                CGImageRelease(partialImageRef);
                dispatch_main_sync_safe(^{
                    if (self.completedBlock) {
                        self.completedBlock(image, nil, nil, NO);
                    }
                });
            }
        }

        //释放imageSource对象
        CFRelease(imageSource);
    }

    //执行progressBlock，不断更新进度信息
    if (self.progressBlock) {
        self.progressBlock(self.imageData.length, self.expectedSize);
    }
}

//处理渐进式显示图片的方法
+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value {
    switch (value) {
        case 1:
            return UIImageOrientationUp;
        case 3:
            return UIImageOrientationDown;
        case 8:
            return UIImageOrientationLeft;
        case 6:
            return UIImageOrientationRight;
        case 2:
            return UIImageOrientationUpMirrored;
        case 4:
            return UIImageOrientationDownMirrored;
        case 5:
            return UIImageOrientationLeftMirrored;
        case 7:
            return UIImageOrientationRightMirrored;
        default:
            return UIImageOrientationUp;
    }
}

- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image {
    return SDScaledImageForKey(key, image);
}

//当请求结束的时候会调用该方法
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    SDWebImageDownloaderCompletedBlock completionBlock = self.completedBlock;
    @synchronized(self) {
        //关停当前的runloop
        CFRunLoopStop(CFRunLoopGetCurrent());
        //把线程和连接对象清空
        self.thread = nil;
        self.connection = nil;
        //在主线程中发出通知：
        //SDWebImageDownloadStopNotification    任务停止
        //SDWebImageDownloadFinishNotification  任务完成
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadFinishNotification object:self];
        });
    }
    
#warning 5
    //请求头是否是从缓存获取？
    if (![[NSURLCache sharedURLCache] cachedResponseForRequest:_request]) {
        responseFromCached = NO;
    }
    
    if (completionBlock) {
        //如果下载策略是SDWebImageDownloaderIgnoreCachedResponse&&responseFromCached为真，执行completionBlock
        if (self.options & SDWebImageDownloaderIgnoreCachedResponse && responseFromCached) {
            completionBlock(nil, nil, nil, YES);
        }
        else if (self.imageData) {
            //如果得到图片的二进制数据
            //把二进制数据转换为图片
            UIImage *image = [UIImage sd_imageWithData:self.imageData];
            //返回指定URL的缓存键值,即URL字符串
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
            //处理图片的缩放问题
            image = [self scaledImageForKey:key image:image];
            
            // Do not force decoding animated GIFs
            if (!image.images) {
                //如果需要，那么对图片进行解压缩处理
                if (self.shouldDecompressImages) {
                    image = [UIImage decodedImageWithImage:image];
                }
            }
            //如果发现转换之后图片的Size为0，则执行completionBlock，图片参数传nil
            if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                completionBlock(nil, nil, [NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}], YES);
            }
            else {
                completionBlock(image, self.imageData, nil, YES);
            }
        }
        else {
            completionBlock(nil, nil, [NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}], YES);
        }
    }
    self.completionBlock = nil;
    [self done];    //结束后的处理
}

//当前请求失败的时候调用该方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        //关停当前的runloop
        CFRunLoopStop(CFRunLoopGetCurrent());
        //清空线程和连接对象
        self.thread = nil;
        self.connection = nil;
        
        //在主线程中发出通知SDWebImageDownloadStopNotification    任务停止
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
    }

    //执行completedBlock回调，把错误信息传递
    if (self.completedBlock) {
        self.completedBlock(nil, nil, error, YES);
    }
    self.completionBlock = nil;
    [self done];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    responseFromCached = NO; // If this method is called, it means the response wasn't read from cache
    //如果调用了该方法，那么说明响应头信息不是从缓存读取的
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        return nil;
    }
    else {
        return cachedResponse;
    }
}


- (BOOL)shouldContinueWhenAppEntersBackground {
    return self.options & SDWebImageDownloaderContinueInBackground;
}

//以下两个方法是 https 访问时使用的方法，关于凭据的设置部分代码在 SDWebImageDownloader.m 中搜索 username 就可以看到了
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection {
    return self.shouldUseCredentialStorage;
}

//和身份验证相关的处理代码
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & SDWebImageDownloaderAllowInvalidSSLCertificates) &&
            [challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
        } else {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        }
    } else {
        if ([challenge previousFailureCount] == 0) {
            if (self.credential) {
                [[challenge sender] useCredential:self.credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        } else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

@end
