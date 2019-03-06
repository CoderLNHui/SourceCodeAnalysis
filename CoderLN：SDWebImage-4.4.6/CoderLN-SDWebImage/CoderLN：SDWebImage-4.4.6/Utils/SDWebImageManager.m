/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import "NSImage+WebCache.h"
#import <objc/message.h>

/*
 dispatch_semaphore_t信号量:
 假设现在系统有两个空闲资源可以被利用，但同一时间却有三个线程要进行访问，这种情况下，该如何处理呢？
 
 我们要下载很多图片，并发异步进行，每个下载都会开辟一个新线程，可是我们又担心太多线程肯定cpu吃不消，
 那么我们这里也可以用信号量控制一下最大开辟线程数。
 
 1.定义：就是一种可用来控制访问资源的数量的标识，设定了一个信号量，在线程访问之前，加上信号量的处理，则可告知系统按照我们指定的信号量数量来执行多个线程。
 2.信号量主要有3个函数，分别是：
 //创建信号量，参数：信号量的初值，如果小于0则会返回NULL
 dispatch_semaphore_create（信号量值）
 //等待降低信号量
 dispatch_semaphore_wait（信号量，等待时间）
 //提高信号量
 dispatch_semaphore_signal(信号量)
 
 */

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled; //取消
@property (strong, nonatomic, nullable) SDWebImageDownloadToken *downloadToken;//取消的回调
@property (strong, nonatomic, nullable) NSOperation *cacheOperation; //处理缓存的操作
@property (weak, nonatomic, nullable) SDWebImageManager *manager;

@end

@interface SDWebImageManager ()

@property (strong, nonatomic, readwrite, nonnull) SDImageCache *imageCache; //可写的图片缓存
@property (strong, nonatomic, readwrite, nonnull) SDWebImageDownloader *imageDownloader; //图片下载任务
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;//URL黑名单集合
@property (strong, nonatomic, nonnull) dispatch_semaphore_t failedURLsLock; // a lock to keep the access to `failedURLs` thread-safe
@property (strong, nonatomic, nonnull) NSMutableSet<SDWebImageCombinedOperation *> *runningOperations;////当前正在执行的任务集合
@property (strong, nonatomic, nonnull) dispatch_semaphore_t runningOperationsLock; // a lock to keep the access to `runningOperations` thread-safe

@end

@implementation SDWebImageManager

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    return [self initWithCache:cache downloader:downloader];
}

- (nonnull instancetype)initWithCache:(nonnull SDImageCache *)cache downloader:(nonnull SDWebImageDownloader *)downloader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageDownloader = downloader;
        _failedURLs = [NSMutableSet new];
        //创建信号量，参数：信号量的初值，如果小于0则会返回NULL
        _failedURLsLock = dispatch_semaphore_create(1);
        _runningOperations = [NSMutableSet new];
        _runningOperationsLock = dispatch_semaphore_create(1);
    }
    return self;
}

//返回指定URL的缓存键值，就是URL字符串
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    //先判断是否设置了缓存过滤器，如果设置了则走cacheKeyFilterBlock,否则直接把URL转换为字符串之后返回
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return url.absoluteString;    
    }
}

- (nullable UIImage *)scaledImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return SDScaledImageForKey(key, image);
}

- (void)cachedImageExistsForURL:(nullable NSURL *)url
                     completion:(nullable SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    
    if (isInMemoryCache) {
        // making sure we call the completion block on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

- (void)diskImageExistsForURL:(nullable NSURL *)url
                   completion:(nullable SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

#pragma mark - 加载图片核心方法；调度图片的下载(Downloader)和缓存(Cache)，并不依托于 UIView+WebCache，完全可单独使用。

//加载图片的核心方法
/*
 * 如果URL对应的图像在缓存中不存在，那么就下载指定的图片，否则返回缓存的图像
 * @param url 图片的URL地址
 * @param options 指定此次请求策略的选项
 * @param progressBlock 图片下载进度的回调
 * @param completedBlock 操作完成后的回调
 *      此参数是必须的，此block没有返回值
 typedef void(^SDInternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);
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
 
 思路：
 1）首先先判断url是否正确，
 2）如果正确，封装一个下载操作的对象，这个对象主要有cancell的方法，通过self.runningOperations，和self.failedURLs 两个数组来记录正在下载的对象和失败的url
 3）到缓存当中异步查询图片是否在缓存里，有缓存直接返回图片，没有缓存区下载。在后面的文章中，我们会一块一块详细剖析SDWebImage是如何拿到图片的
 */
- (id <SDWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                     options:(SDWebImageOptions)options
                                    progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                   completed:(nullable SDInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    //没有completedblock，那么调用这个方法是毫无意义的
    //completedBlock为nil，则触发断言，程序crash
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
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

    //创建一个遵守了<<SDWebImageOperation>>协议的SDWebImageCombinedOperation对象，并且设置其manager为self
    SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    operation.manager = self;

    //初始化设定该URL是正确的
    //failedURLs是个NSMutableSet类型的，里面存放着请求失败的url。所以每次在请求之前先去failedURLs检查是否包含这个url
    BOOL isFailedUrl = NO;
    if (url) {
        //加互斥锁，检索请求图片的URL是否在曾下载失败的集合中（URL黑名单）
        LOCK(self.failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        UNLOCK(self.failedURLsLock);
    }

    //如果url不正确或者 选择的下载策略不是『下载失败尝试重新下载』且该URL存在于黑名单中，那么直接返回，回调任务完成block块，传递错误信息
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }

    //加互斥锁，把当前的下载任务添加到『当前正在执行任务集合』中
    LOCK(self.runningOperationsLock);
    [self.runningOperations addObject:operation];
    UNLOCK(self.runningOperationsLock);
    //得到该URL对应的缓存KEY
    NSString *key = [self cacheKeyForURL:url];
    
    SDImageCacheOptions cacheOptions = 0;
    if (options & SDWebImageQueryDataWhenInMemory) cacheOptions |= SDImageCacheQueryDataWhenInMemory;
    if (options & SDWebImageQueryDiskSync) cacheOptions |= SDImageCacheQueryDiskSync;
    if (options & SDWebImageScaleDownLargeImages) cacheOptions |= SDImageCacheScaleDownLargeImages;
    
    __weak SDWebImageCombinedOperation *weakOperation = operation;
    //该方法查找URLKEY对应的图片缓存是否存在，查找完毕之后把该图片（存在|不存在）和该图片的缓存方法以block的方式传递
    //缓存情况查找完毕之后，在block块中进行后续处理（如果该图片没有缓存·下载|如果缓存存在|如果用户设置了下载的缓存策略是刷新缓存如何处理等等）
    operation.cacheOperation = [self.imageCache queryCacheOperationForKey:key options:cacheOptions done:^(UIImage *cachedImage, NSData *cachedData, SDImageCacheType cacheType) {
        
        __strong __typeof(weakOperation) strongOperation = weakOperation;
        
        //先判断该下载操作是否已经被取消，如果被取消则把当前操作从runningOperations【当前正在执行的任务集合】移除，并直接返回
        if (!strongOperation || strongOperation.isCancelled) {
            [self safelyRemoveOperationFromRunning:strongOperation];
            return;
        }
        
        // Check whether we should download image from network
        //下载策略不是内存缓存且（图片不存在||下载策略为刷新缓存）且（shouldDownloadImageForURL不能响应||该图片存在缓存）
        BOOL shouldDownload = (!(options & SDWebImageFromCacheOnly))
            && (!cachedImage || options & SDWebImageRefreshCached)
            && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
        
        //从此处开始，一直在处理downloaderOptions（即下载策略）
        if (shouldDownload) {
            //如果图像存在，但是下载策略为刷新缓存，则通知缓存图像并尝试重新下载
            if (cachedImage && options & SDWebImageRefreshCached) {
                
                // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
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
            if (options & SDWebImageScaleDownLargeImages) downloaderOptions |= SDWebImageDownloaderScaleDownLargeImages;
            
            //如果图片存在，且下载策略为刷新刷新缓存
            if (cachedImage && options & SDWebImageRefreshCached) {
                
                // force progressive off if image already cached but forced refreshing
                //如果图像已缓存，但需要刷新缓存，那么强制进行刷新
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // ignore image read from NSURLCache if image if cached but force refreshing
                 //忽略从NSURLCache读取图片
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }
            
            //到此处位置，downloaderOptions（即下载策略）处理操作结束

            
            // `SDWebImageCombinedOperation` -> `SDWebImageDownloadToken` -> `downloadOperationCancelToken`, which is a `SDCallbacksDictionary` and retain the completed block below, so we need weak-strong again to avoid retain cycle
            
            //核心方法：使用下载器，下载图片

            __weak typeof(strongOperation) weakSubOperation = strongOperation;
            strongOperation.downloadToken = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
                
                __strong typeof(weakSubOperation) strongSubOperation = weakSubOperation;
                
                if (!strongSubOperation || strongSubOperation.isCancelled) {
                    //如果此时操作被取消，那么什么也不做

                    // Do nothing if the operation was cancelled
                    // See #699 for more details
                    // if we would call the completedBlock, there could be a race condition between this block and another completedBlock for the same object, so if this one is called second, we will overwrite the new data
                } else if (error) {
                    //如果下载失败，则处理结束的回调，在合适的情况下把对应图片的URL添加到黑名单中
                    [self callCompletionBlockForOperation:strongSubOperation completion:completedBlock error:error url:url];
                    BOOL shouldBlockFailedURL;
                    // Check whether we should block failed url
                    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
                        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
                    } else {
                        shouldBlockFailedURL = (   error.code != NSURLErrorNotConnectedToInternet
                                                && error.code != NSURLErrorCancelled
                                                && error.code != NSURLErrorTimedOut
                                                && error.code != NSURLErrorInternationalRoamingOff
                                                && error.code != NSURLErrorDataNotAllowed
                                                && error.code != NSURLErrorCannotFindHost
                                                && error.code != NSURLErrorCannotConnectToHost
                                                && error.code != NSURLErrorNetworkConnectionLost);
                    }
                    
                    if (shouldBlockFailedURL) {
                        //下载失败则添加图片url到failedURLs集合，添加互斥锁
                        LOCK(self.failedURLsLock);
                        [self.failedURLs addObject:url];
                        UNLOCK(self.failedURLsLock);
                    }
                }
                else {
                    //下载成功
                    
                    //先判断当前的下载策略是否是SDWebImageRetryFailed，如果是那么把该URL从黑名单中删除
                    if ((options & SDWebImageRetryFailed)) {
                        LOCK(self.failedURLsLock);
                        [self.failedURLs removeObject:url];
                        UNLOCK(self.failedURLsLock);
                    }
                    
                    //是否要进行磁盘缓存？
                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                    
                    // We've done the scale process in SDWebImageDownloader with the shared manager, this is used for custom manager and avoid extra scale.
                    if (self != [SDWebImageManager sharedManager] && self.cacheKeyFilter && downloadedImage) {
                        downloadedImage = [self scaledImageForKey:key image:downloadedImage];
                    }

                    //如果下载策略为SDWebImageRefreshCached且该图片缓存中存在且未下载下来，那么什么都不做
                    if (options & SDWebImageRefreshCached && cachedImage && !downloadedImage) {
                        // Image refresh hit the NSURLCache cache, do not call the completion block
                    } else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                        //否则，如果下载图片存在且（不是可动画图片数组||下载策略为SDWebImageTransformAnimatedImage&&transformDownloadedImage方法可用）
                        //开子线程处理
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            @autoreleasepool {
                                //在下载后立即将图像转换，并进行磁盘和内存缓存
                                UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                                // 得到下载的图片且已经完成，则进行缓存处理
                                if (transformedImage && finished) {
                                    BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                    NSData *cacheData;
                                    // pass nil if the image was transformed, so we can recalculate the data from the image
                                    if (self.cacheSerializer) {
                                        cacheData = self.cacheSerializer(transformedImage, (imageWasTransformed ? nil : downloadedData), url);
                                    } else {
                                        cacheData = (imageWasTransformed ? nil : downloadedData);
                                    }
                                    //把图片缓存
                                    [self.imageCache storeImage:transformedImage imageData:cacheData forKey:key toDisk:cacheOnDisk completion:nil];
                                }
                                
                                //回调
                                [self callCompletionBlockForOperation:strongSubOperation completion:completedBlock image:transformedImage data:downloadedData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                            }
                        });
                    } else {
                        //得到下载的图片且已经完成，则进行缓存处理
                        if (downloadedImage && finished) {
                            if (self.cacheSerializer) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                    @autoreleasepool {
                                        NSData *cacheData = self.cacheSerializer(downloadedImage, downloadedData, url);
                                        [self.imageCache storeImage:downloadedImage imageData:cacheData forKey:key toDisk:cacheOnDisk completion:nil];
                                    }
                                });
                            } else {
                                [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key toDisk:cacheOnDisk completion:nil];
                            }
                        }
                        [self callCompletionBlockForOperation:strongSubOperation completion:completedBlock image:downloadedImage data:downloadedData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                    }
                }

                if (finished) {
                    //如果下载和缓存都完成了则删除操作队列中的operation
                    [self safelyRemoveOperationFromRunning:strongSubOperation];
                }
            }];
        } else if (cachedImage) {
            //有缓存数据，在主线程回调、移除当前操作
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            [self safelyRemoveOperationFromRunning:strongOperation];
        } else {
            // Image not in cache and download disallowed by delegate
            //图片不存在缓存且不允许代理下载，那么在主线程中回调completedBlock，并把当前操作移除
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:nil data:nil error:nil cacheType:SDImageCacheTypeNone finished:YES url:url];
            [self safelyRemoveOperationFromRunning:strongOperation];
        }
    }];

    return operation;
}

- (void)saveImageToCache:(nullable UIImage *)image forURL:(nullable NSURL *)url {
    if (image && url) {
        NSString *key = [self cacheKeyForURL:url];
        [self.imageCache storeImage:image forKey:key toDisk:YES completion:nil];
    }
}

- (void)cancelAll {
    LOCK(self.runningOperationsLock);
    NSSet<SDWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    UNLOCK(self.runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    LOCK(self.runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    UNLOCK(self.runningOperationsLock);
    return isRunning;
}

- (void)safelyRemoveOperationFromRunning:(nullable SDWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    LOCK(self.runningOperationsLock);
    [self.runningOperations removeObject:operation];
    UNLOCK(self.runningOperationsLock);
}

- (void)callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                             completion:(nullable SDInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:SDImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                             completion:(nullable SDInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(SDImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    //该宏保证了completedBlock回调在主线程中执行
    dispatch_main_async_safe(^{
        if (operation && !operation.isCancelled && completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

@end


@implementation SDWebImageCombinedOperation
//取消操作
- (void)cancel {
    @synchronized(self) {
        self.cancelled = YES;
        //如果缓存操作存在，那么取消该操作的执行并赋值为nil
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.downloadToken) {
            [self.manager.imageDownloader cancel:self.downloadToken];
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end
