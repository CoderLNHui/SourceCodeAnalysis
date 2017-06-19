/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderOperation.h"
#import <ImageIO/ImageIO.h>

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface SDWebImageDownloader ()

@property (strong, nonatomic) NSOperationQueue *downloadQueue;      //下载队列
@property (weak, nonatomic)   NSOperation *lastAddedOperation;      //最后一个下载操作
@property (assign, nonatomic) Class operationClass;                 //操作的类型
@property (strong, nonatomic) NSMutableDictionary *URLCallbacks;    //该url对应的URLCallbacks字典
@property (strong, nonatomic) NSMutableDictionary *HTTPHeaders;     //请求头字典

// This queue is used to serialize the handling of the network responses of all the download operation in a single queue
// barrierQueue是一个串行队列，在一个单一队列中顺序处理所有下载操作的网络响应
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation SDWebImageDownloader

+ (void)initialize {
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    //如果可用，则结合SDNetworkActivityIndicator，附下载地址
    //使用它只需要#import "SDNetworkActivityIndicator.h"
    if (NSClassFromString(@"SDNetworkActivityIndicator")) {

//消除SDNetworkActivityIndicator方法不存在的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // Remove observer in case it was previously added.
        //删除之前添加的观察者,注册通知
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebImageDownloadStopNotification object:nil];
    }
}

//异步下载器单例实现（类方法）
+ (SDWebImageDownloader *)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//异步下载器初始化方法
- (id)init {
    if ((self = [super init])) {
        _operationClass = [SDWebImageDownloaderOperation class];    //获得类型
        _shouldDecompressImages = YES;                              //是否解码，默认为YES(以空间换取时间）
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;   //下载任务的执行方式：默认为先进先出
        _downloadQueue = [NSOperationQueue new];                    //创建下载队列：非主队列（在该队列中的任务在子线程中异步执行）
        _downloadQueue.maxConcurrentOperationCount = 6;             //设置下载队列的最大并发数：默认为6
        _URLCallbacks = [NSMutableDictionary new];                  //初始化URLCallbacks字典
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy]; //处理请求头
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        //创建栅栏函数添加的队列：自己创建的并发队列
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;                                    //设置下载超时为15秒
    }
    return self;
}

//扫尾工作
- (void)dealloc {
    [self.downloadQueue cancelAllOperations];   //取消当前队列中所有正在执行的操作
    SDDispatchQueueRelease(_barrierQueue);
}

//设置请求头信息，如果value为nil,则表示删除对应的键值
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    }
    else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

//获得请求头中value
- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return self.HTTPHeaders[field];
}

//设置最大并发数
- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}
//设置还需要下载的任务数量
- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (void)setOperationClass:(Class)operationClass {
    _operationClass = operationClass ?: [SDWebImageDownloaderOperation class];
}

//核心方法：下载图片的操作
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    __block SDWebImageDownloaderOperation *operation;
    __weak __typeof(self)wself = self;  //为了避免block的循环引用

    //处理进度回调|完成回调等，如果该url在self.URLCallbacks并不存在，则调用createCallback block块
    [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^{
        
        //处理下载超时，如果没有设置过则初始化为15秒
        NSTimeInterval timeoutInterval = wself.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }

        // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests if told otherwise
        //根据给定的URL和缓存策略创建可变的请求对象，设置请求超时
        //请求策略：如果是SDWebImageDownloaderUseNSURLCache则使用NSURLRequestUseProtocolCachePolicy，否则使用NSURLRequestReloadIgnoringLocalCacheData
        /*
         NSURLRequestUseProtocolCachePolicy:默认的缓存策略
            1)如果缓存不存在，直接从服务端获取。
            2)如果缓存存在，会根据response中的Cache-Control字段判断下一步操作，如: Cache-Control字段为must-revalidata, 则询问服务端该数据是否有更新，无更新的话直接返回给用户缓存数据，若已更新，则请求服务端.
         NSURLRequestReloadIgnoringLocalCacheData:忽略本地缓存数据，直接请求服务端。
         */
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:timeoutInterval];
        
        //设置是否使用Cookies(采用按位与）
        /*
         关于cookies参考：http://blog.csdn.net/chun799/article/details/17206907
         */
        request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
        //开启HTTP管道，这可以显著降低请求的加载时间，但是由于没有被服务器广泛支持，默认是禁用的
        request.HTTPShouldUsePipelining = YES;
        
        //设置请求头信息（过滤等）
        if (wself.headersFilter) {
            request.allHTTPHeaderFields = wself.headersFilter(url, [wself.HTTPHeaders copy]);
        }
        else {
            request.allHTTPHeaderFields = wself.HTTPHeaders;
        }
        
        //核心方法：创建下载图片的操作
        operation = [[wself.operationClass alloc] initWithRequest:request
                                                          options:options
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             SDWebImageDownloader *sself = wself;
                                                             if (!sself) return;
                                                             __block NSArray *callbacksForURL;
                                                             dispatch_sync(sself.barrierQueue, ^{
                                                                 callbacksForURL = [sself.URLCallbacks[url] copy];
                                                             });
                                                             
                                                             //遍历callbacksForURL数组中的所有字典，执行SDWebImageDownloaderProgressBlock回调
                                                             for (NSDictionary *callbacks in callbacksForURL) {
                                                        //说明：SDWebImageDownloaderProgressBlock作者可能考虑到用户拿到进度数据后会进行刷新处理，因此在主线程中处理了回调
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     SDWebImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                                                                     if (callback) callback(receivedSize, expectedSize);
                                                                 });
                                                             }
                                                         }
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            __block NSArray *callbacksForURL;
                                                            
                                                            dispatch_barrier_sync(sself.barrierQueue, ^{
                                                                callbacksForURL = [sself.URLCallbacks[url] copy];
                                                                
                                                                //如果完成，那么把URL从URLCallbacks字典中删除
                                                                if (finished) {
                                                                    [sself.URLCallbacks removeObjectForKey:url];
                                                                }
                                                            });
                                                            
                                                            //遍历callbacksForURL数组中的所有字典，执行SDWebImageDownloaderCompletedBlock回调
                                                            for (NSDictionary *callbacks in callbacksForURL) {
                                                                SDWebImageDownloaderCompletedBlock callback = callbacks[kCompletedCallbackKey];
                                                                if (callback) callback(image, data, error, finished);
                                                            }
                                                        }
                                                        cancelled:^{
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            
                                                            //把当前的url从URLCallbacks字典中移除
                                                            dispatch_barrier_async(sself.barrierQueue, ^{
                                                                [sself.URLCallbacks removeObjectForKey:url];
                                                            });
                                                        }];
        //设置是否需要解码
        operation.shouldDecompressImages = wself.shouldDecompressImages;
        
        //身份认证
        if (wself.urlCredential) {
            operation.credential = wself.urlCredential;
        } else if (wself.username && wself.password) {
            //设置 https 访问时身份验证使用的凭据
            operation.credential = [NSURLCredential credentialWithUser:wself.username password:wself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        //判断下载策略是否是高优先级的或低优先级，以设置操作的队列优先级
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
        
        //把下载操作添加到下载队列中
        //该方法会调用operation内部的start方法开启图片的下载任务
        [wself.downloadQueue addOperation:operation];
        
        //判断任务的执行优先级，如果是后进先出，则调整任务的依赖关系，优先执行当前的（最后添加）任务
        if (wself.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
            // Emulate LIFO execution order by systematically adding new operations as last operation's dependency
            [wself.lastAddedOperation addDependency:operation];
            
            wself.lastAddedOperation = operation;//设置当前下载操作为最后一个操作
        }
    }];

    return operation;
}

//处理SDWebImageDownloaderProgressBlock和SDWebImageDownloaderCompletedBlock
//主要处理对象为self.URLCallbacks字典
- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock completedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    //如果URL为空，则执行completedBlock回调，并直接返回
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return;
    }
    
    //栅栏函数
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        //如果URLCallbacks字典中url对应的数组不存在，那么就创建一个空的可变数组，并设置first的值为YES
        if (!self.URLCallbacks[url]) {
            self.URLCallbacks[url] = [NSMutableArray new];
            first = YES;
        }

        // Handle single download of simultaneous download request for the same URL
        // 保证如果统一URL有多个下载请求，那么只下载一次
        
        //得到URLCallbacks字典中url对应的数组
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        
        //创建可变字典，在该字典中存放progressBlock和completedBlock，并把该字典作为元素添加到数组中（即url对应的value）
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
        if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
        [callbacksForURL addObject:callbacks];
        self.URLCallbacks[url] = callbacksForURL;

        //如果URLCallbacks字典中url对应的数组不存在,那么就调用createCallback（）
        if (first) {
            createCallback();
        }
    });
}

//设置是否暂停downloadQueue队列里面的任务，当suspended==YES的时候表示暂停，当suspended==NO的时候表示恢复
- (void)setSuspended:(BOOL)suspended {
    [self.downloadQueue setSuspended:suspended];
}

@end
