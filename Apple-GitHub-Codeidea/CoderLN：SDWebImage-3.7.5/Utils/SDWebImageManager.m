/*
 ** 3.7.5
 **
 
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import <objc/message.h>

@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled; //取消
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock; //取消的回调
@property (strong, nonatomic) NSOperation *cacheOperation; //处理缓存的操作

@end

@interface SDWebImageManager ()

@property (strong, nonatomic, readwrite) SDImageCache *imageCache; //可写的图片缓存
@property (strong, nonatomic, readwrite) SDWebImageDownloader *imageDownloader; //图片下载任务
@property (strong, nonatomic) NSMutableSet *failedURLs; //URL黑名单集合
@property (strong, nonatomic) NSMutableArray *runningOperations; //当前正在执行的任务数组

@end

@implementation SDWebImageManager

//单例类方法，该方法提供一个全局的SDWebImageManager实例
+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new]; //该方法内部调用alloc init方法
    });
    return instance;
}

//初始化方法
- (id)init {
    if ((self = [super init])) {
        _imageCache = [self createCache]; //初始化imageCache（单例）
        _imageDownloader = [SDWebImageDownloader sharedDownloader]; //初始化imageDownloader（单例）
        _failedURLs = [NSMutableSet new]; //初始化下载失败的URL（黑名单·空的集合）
        _runningOperations = [NSMutableArray new]; //初始化当前正在处理的任务（图片下载操作·空的可变数组）
    }
    return self;
}

//获取SDImageCache单例
- (SDImageCache *)createCache {
    return [SDImageCache sharedImageCache];
}

//返回指定URL的缓存键值，就是URL字符串
- (NSString *)cacheKeyForURL:(NSURL *)url {
    //先判断是否设置了缓存过滤器，如果设置了则走cacheKeyFilterBlock,否则直接把URL转换为字符串之后返回
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    }
    else {
        return [url absoluteString];
    }
}

//检查图像是否已经被缓存,如果已经缓存则返回YES
- (BOOL)cachedImageExistsForURL:(NSURL *)url {
    
    NSString *key = [self cacheKeyForURL:url]; //得到图片对应的缓存KEY
    if ([self.imageCache imageFromMemoryCacheForKey:key] != nil) return YES; //如果该图片的内存缓存存在则返回YES
    return [self.imageCache diskImageExistsWithKey:key]; //如果该图片对应的内存缓存不存在，则检查磁盘缓存，并返回对应的值
}

//检查图像是否存在磁盘缓存,如果已经缓存则返回YES
- (BOOL)diskImageExistsForURL:(NSURL *)url {
    
    NSString *key = [self cacheKeyForURL:url]; //得到图片对应的缓存KEY
    return [self.imageCache diskImageExistsWithKey:key]; //检查磁盘缓存，并返回对应的值
}

//内存缓存处理
- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    //检查该url对应的图片内存缓存是否已经存在
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    
    //如果内存缓存存在，则直接在主线程中回调completionBlock，并返回
    if (isInMemoryCache) {
        // making sure we call the completion block on the main queue
        // 确保completionBlock在主线程中调用
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    
    //如果内存缓存不存在，那么处理查看磁盘缓存
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

//磁盘缓存处理
- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    //同上
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

//加载图片的核心方法
/*
 * 如果URL对应的图像在缓存中不存在，那么就下载指定的图片，否则返回缓存的图像
 *
 * @param url 图片的URL地址
 * @param options 指定此次请求策略的选项
 * @param progressBlock 图片下载进度的回调
 * @param completedBlock 操作完成后的回调
 *      此参数是必须的，此block没有返回值
 *      Image：请求的 UIImage，如果出现错误，image参数是nil
 *      error：如果出现错误，则error有值
 *      cacheType：`SDImageCacheType` 枚举，标示该图像的加载方式
 *          SDImageCacheTypeNone：从网络下载
 *          SDImageCacheTypeDisk：从本地缓存加载
 *          SDImageCacheTypeMemory：从内存缓存加载
 *          finished：如果图像下载完成则为YES，如果使用 SDWebImageProgressiveDownload 选项，同时只获取到部分图片时，返回 NO
 *          imageURL：图片的URL地址
 *
 * @return SDWebImageOperation对象，应该是SDWebimageDownloaderOperation实例
 */
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    //没有completedblock，那么调用这个方法是毫无意义的
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    //检查用户传入的URL是否正确，如果该URL是NSString类型的，那么尝试转换
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    //防止因参数类型错误而导致应用程序崩溃，判断URL是否是NSURL类型的，如果不是则直接设置为nil
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    //初始化一个SDWebImageCombinedOperationBlock块
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;

    BOOL isFailedUrl = NO; //初始化设定该URL是正确的
    
    //加互斥锁，检索请求图片的URL是否在曾下载失败的集合中（URL黑名单）
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }

    //如果url不正确或者 选择的下载策略不是『下载失败尝试重新下载』且该URL存在于黑名单中，那么直接返回，回调任务完成block块，传递错误信息
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        
        //该宏保证了completedBlock回调在主线程中执行
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, error, SDImageCacheTypeNone, YES, url);
        });
        return operation;
    }
    
    //加互斥锁，把当前的下载任务添加到『当前正在执行任务数组』中
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    //得到该URL对应的缓存KEY
    NSString *key = [self cacheKeyForURL:url];
    
    //该方法查找URLKEY对应的图片缓存是否存在，查找完毕之后把该图片（存在|不存在）和该图片的缓存方法以block的方式传递
    //缓存情况查找完毕之后，在block块中进行后续处理（如果该图片没有缓存·下载|如果缓存存在|如果用户设置了下载的缓存策略是刷新缓存如何处理等等）
        operation.cacheOperation = [self.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        //先判断该下载操作是否已经被取消，如果被取消则把当前操作从runningOperations数组中移除，并直接返回
        if (operation.isCancelled) {
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }

            return;
        }
        
        //（图片不存在||下载策略为刷新缓存）且（shouldDownloadImageForURL不能响应||该图片存在缓存）
        if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
   //从此处开始，一直在处理downloaderOptions（即下载策略）
            if (image && options & SDWebImageRefreshCached) { //如果图像存在，但是下载策略为刷新缓存，则通知缓存图像并尝试重新下载
                dispatch_main_sync_safe(^{
                    // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                    // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                    completedBlock(image, nil, cacheType, YES, url);
                });
            }
            // download if no image or requested to refresh anyway, and download allowed by delegate
            SDWebImageDownloaderOptions downloaderOptions = 0;
            //如果下载策略为SDWebImageLowPriority 那么downloaderOptions = 其本身
            if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
            if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            if (image && options & SDWebImageRefreshCached) { //如果图片存在，且下载策略为刷新刷新缓存
                // force progressive off if image already cached but forced refreshing
                //如果图像已缓存，但需要刷新缓存，那么强制进行刷新
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // ignore image read from NSURLCache if image if cached but force refreshing
                //忽略从NSURLCache读取图片
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }
  //到此处位置，downloaderOptions（即下载策略）处理操作结束
            
            //核心方法：使用下载器，下载图片
            id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) {
                if (weakOperation.isCancelled) {
                    //如果此时操作被取消，那么什么也不做
                    // Do nothing if the operation was cancelled
                    // See #699 for more details
                    // if we would call the completedBlock, there could be a race condition between this block and another completedBlock for the same object, so if this one is called second, we will overwrite the new data
                }
                else if (error) { //如果下载失败，则处理结束的回调，在合适的情况下把对应图片的URL添加到黑名单中
                    dispatch_main_sync_safe(^{
                        if (!weakOperation.isCancelled) {
                            completedBlock(nil, error, SDImageCacheTypeNone, finished, url);
                        }
                    });

                    if (   error.code != NSURLErrorNotConnectedToInternet
                        && error.code != NSURLErrorCancelled
                        && error.code != NSURLErrorTimedOut
                        && error.code != NSURLErrorInternationalRoamingOff
                        && error.code != NSURLErrorDataNotAllowed
                        && error.code != NSURLErrorCannotFindHost
                        && error.code != NSURLErrorCannotConnectToHost) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                }
                else {//下载成功
                    //先判断当前的下载策略是否是SDWebImageRetryFailed，如果是那么把该URL从黑名单中删除
                    if ((options & SDWebImageRetryFailed)) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs removeObject:url];
                        }
                    }
                    
                    //是否要进行磁盘缓存？
                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                    
                    //如果下载策略为SDWebImageRefreshCached且该图片缓存中存在且未下载下来，那么什么都不做
                    if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                        // Image refresh hit the NSURLCache cache, do not call the completion block
                    }
                    else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                        //否则，如果下载图片存在且（不是可动画图片数组||下载策略为SDWebImageTransformAnimatedImage&&transformDownloadedImage方法可用）
                        //开子线程处理
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            //在下载后立即将图像转换，并进行磁盘和内存缓存
                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
#warning 2
                            if (transformedImage && finished) {
                                BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                [self.imageCache storeImage:transformedImage recalculateFromImage:imageWasTransformed imageData:(imageWasTransformed ? nil : data) forKey:key toDisk:cacheOnDisk];
                            }
                            
                            //在主线程中回调completedBlock
                            dispatch_main_sync_safe(^{
                                if (!weakOperation.isCancelled) {
                                    completedBlock(transformedImage, nil, SDImageCacheTypeNone, finished, url);
                                }
                            });
                        });
                    }
                    else {
                        //得到下载的图片且已经完成，则进行缓存处理
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage recalculateFromImage:NO imageData:data forKey:key toDisk:cacheOnDisk];
                        }

                        dispatch_main_sync_safe(^{
                            if (!weakOperation.isCancelled) {
                                completedBlock(downloadedImage, nil, SDImageCacheTypeNone, finished, url);
                            }
                        });
                    }
                }

                if (finished) {
                    @synchronized (self.runningOperations) {
                        [self.runningOperations removeObject:operation];
                    }
                }
            }];
            
            //处理cancelBlock
            operation.cancelBlock = ^{
                [subOperation cancel];
                
                @synchronized (self.runningOperations) {
                    [self.runningOperations removeObject:weakOperation];
                }
            };
        }
        else if (image) { //如果图片存在，且操作没有被取消，那么在主线程中回调completedBlock，并把当前操作移除
            dispatch_main_sync_safe(^{
                if (!weakOperation.isCancelled) {
                    completedBlock(image, nil, cacheType, YES, url);
                }
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
        else {
            // Image not in cache and download disallowed by delegate
            //图片不存在缓存且不允许代理下载，那么在主线程中回调completedBlock，并把当前操作移除
            dispatch_main_sync_safe(^{
                if (!weakOperation.isCancelled) {
                    completedBlock(nil, nil, SDImageCacheTypeNone, YES, url);
                }
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
    }];

    return operation;
}

/*
 * 根据图片的URL保存图片到缓存
 *
 * @param image：缓存的图片
 * @param url：该图片的URL地址
 */
- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url {
    //如果图片和url存在，则对该图片进行缓存处理
    if (image && url) {
        NSString *key = [self cacheKeyForURL:url];
        [self.imageCache storeImage:image forKey:key toDisk:YES];
    }
}

//取消当前所有的操作
- (void)cancelAll {
    @synchronized (self.runningOperations) {
        //得到当前所有正在执行的任务
        NSArray *copiedOperations = [self.runningOperations copy];
        //遍历数组中所有的操作，调用所有正在执行操作的cancel方法
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        //把这些操作从runningOperations数组中移除
        [self.runningOperations removeObjectsInArray:copiedOperations];
    }
}

//检查一个或多个操作是否正在运行
- (BOOL)isRunning {
    BOOL isRunning = NO;    //初始设定为NO，即没有
    //加互斥锁，根据runningOperations数组中元素的个数来判断当前是否有任务正在执行
    @synchronized(self.runningOperations) {
        isRunning = (self.runningOperations.count > 0);
    }
    return isRunning;
}

@end


@implementation SDWebImageCombinedOperation

//取消block的回调
- (void)setCancelBlock:(SDWebImageNoParamsBlock)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil; // don't forget to nil the cancelBlock, otherwise we will get crashes
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}
//取消操作
- (void)cancel {
    self.cancelled = YES;
    //如果缓存操作存在，那么取消该操作的执行并赋值为nil
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    //取消block的回调
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
//        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}

@end

//过时的方法
@implementation SDWebImageManager (Deprecated)

// deprecated method, uses the non deprecated method
// adapter for the completion block
- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedWithFinishedBlock)completedBlock {
    return [self downloadImageWithURL:url
                              options:options
                             progress:progressBlock
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (completedBlock) {
                                    completedBlock(image, error, cacheType, finished);
                                }
                            }];
}

@end
