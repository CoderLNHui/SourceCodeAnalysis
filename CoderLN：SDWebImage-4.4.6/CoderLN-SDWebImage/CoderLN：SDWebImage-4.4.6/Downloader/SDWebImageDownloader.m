/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderOperation.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface SDWebImageDownloadToken ()

@property (nonatomic, weak, nullable) NSOperation<SDWebImageDownloaderOperationInterface> *downloadOperation;

@end

@implementation SDWebImageDownloadToken

- (void)cancel {
    if (self.downloadOperation) {
        SDWebImageDownloadToken *cancelToken = self.downloadOperationCancelToken;
        if (cancelToken) {
            [self.downloadOperation cancel:cancelToken];
        }
    }
}

@end


@interface SDWebImageDownloader () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic, nonnull) NSOperationQueue *downloadQueue;//下载队列
@property (weak, nonatomic, nullable) NSOperation *lastAddedOperation;//下载的上个operation 作用是为了后面的下载依赖
@property (assign, nonatomic, nullable) Class operationClass;//图片下载操作类
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSURL *, NSOperation<SDWebImageDownloaderOperationInterface> *> *URLOperations;//下载url作为key value是具体的下载operation 用字典来存储，方便cancel等操作
@property (strong, nonatomic, nullable) SDHTTPHeadersMutableDictionary *HTTPHeaders;//请求头字典
@property (strong, nonatomic, nonnull) dispatch_semaphore_t operationsLock; // a lock to keep the access to `URLOperations` thread-safe
@property (strong, nonatomic, nonnull) dispatch_semaphore_t headersLock; // a lock to keep the access to `HTTPHeaders` thread-safe

// The session in which data tasks will run  利用NSURLSession进行网络请求
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation SDWebImageDownloader

/*
 +load方法要点
 当类被引用进项目的时候就会执行load函数(在main函数开始执行之前）,与这个类是否被用到无关,每个类的load函数只会自动调用一次.由于load函数是系统自动加载的，因此不需要再调用[super load]，否则父类的load函数会多次执行。
 1.当父类和子类都实现load函数时,父类的load方法执行顺序要优先于子类
 2.当一个类未实现load方法时,不会调用父类load方法
 3.类中的load方法执行顺序要优先于类别(Category)
 4.当有多个类别(Category)都实现了load方法,这几个load方法都会执行,但执行顺序不确定(其执行顺序与类别在Compile Sources中出现的顺序一致)
 5.当然当有多个不同的类的时候,每个类load 执行顺序与其在Compile Sources出现的顺序一致
 load调用时机比较早,当load调用时,其他类可能还没加载完成,运行环境不安全.
 load方法是线程安全的，它使用了锁，我们应该避免线程阻塞在load方法.
 +initialize方法要点
 initialize在类或者其子类的第一个方法被调用前调用。即使类文件被引用进项目,但是没有使用,initialize不会被调用。由于是系统自动调用，也不需要显式的调用父类的initialize，否则父类的initialize会被多次执行。假如这个类放到代码中，而这段代码并没有被执行，这个函数是不会被执行的。
 1.父类的initialize方法会比子类先执行
 2.当子类不实现initialize方法，会把父类的实现继承过来调用一遍。在此之前，父类的方法会被优先调用一次
 3.当有多个Category都实现了initialize方法,会覆盖类中的方法,只执行一个(会执行Compile Sources 列表中最后一个Category 的initialize方法)
 注意:
 在initialize方法收到调用时,运行环境基本健全。
 initialize内部也使用了锁，所以是线程安全的。但同时要避免阻塞线程，不要再使用锁
 */
+ (void)initialize {
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    //NSClassFromString，用来判断当前程序是否有指定字符串的类，如果没有回返回一个空对象
    if (NSClassFromString(@"SDNetworkActivityIndicator")) {

        
//消除SDNetworkActivityIndicator方法不存在的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //如果项目中引用了SDNetworkActivityIndicator，则开启一些关于小菊花的监听
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
+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//异步下载器初始化方法
- (nonnull instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration {
    if ((self = [super init])) {
        _operationClass = [SDWebImageDownloaderOperation class];//获得类型
        _shouldDecompressImages = YES;//是否解码，默认为YES(以空间换取时间）
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;//下载任务的执行方式：所有下载操作将按照队列的先进先出方式执行
        _downloadQueue = [NSOperationQueue new];//创建下载队列：非主队列（在该队列中的任务在子线程中异步执行）
        _downloadQueue.maxConcurrentOperationCount = 6;//设置下载队列的最大并发数：默认为6

        _downloadQueue.name = @"com.hackemist.SDWebImageDownloader";
        _URLOperations = [NSMutableDictionary new];//初始化_URLOperations字典
        SDHTTPHeadersMutableDictionary *headerDictionary = [SDHTTPHeadersMutableDictionary dictionary];
        NSString *userAgent = nil;
#if SD_UIKIT
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif SD_WATCH
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; watchOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[WKInterfaceDevice currentDevice] model], [[WKInterfaceDevice currentDevice] systemVersion], [[WKInterfaceDevice currentDevice] screenScale]];
#elif SD_MAC
        userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
        if (userAgent) {
            if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                NSMutableString *mutableUserAgent = [userAgent mutableCopy];
                if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                    userAgent = mutableUserAgent;
                }
            }
            headerDictionary[@"User-Agent"] = userAgent;
        }
#ifdef SD_WEBP
        headerDictionary[@"Accept"] = @"image/webp,image/*;q=0.8";
#else
        headerDictionary[@"Accept"] = @"image/*;q=0.8";
#endif
        _HTTPHeaders = headerDictionary;
        _operationsLock = dispatch_semaphore_create(1);
        _headersLock = dispatch_semaphore_create(1);
        _downloadTimeout = 15.0;//设置下载超时为15秒

        [self createNewSessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

- (void)createNewSessionWithConfiguration:(NSURLSessionConfiguration *)sessionConfiguration {
    //先取消 _downloadQueue 队列中的所有任务
    [self cancelAllDownloads];

    if (self.session) {
        //invalidateAndCancel失效(取消未完成任务)或finishTasksAndInvalidate(允许任务完成之前无效的对象)。
        [self.session invalidateAndCancel];
    }

    //设置时间
    sessionConfiguration.timeoutIntervalForRequest = self.downloadTimeout;

    /**
     *  Create the session for this task
     *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
     *  method calls and completion handler calls.
     delegate设置为自己，也就是当使用这个会话请求数据，收到响应时，会调用SDWebImageDownloader.m中的代理方法，然后再调用SDWebImageDownloaderOperation中的代理方法处理事情。这样做的目的是为了共用一个URLSession
     */
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
}
//session取消下载方法
- (void)invalidateSessionAndCancel:(BOOL)cancelPendingOperations {
    if (self == [SDWebImageDownloader sharedDownloader]) {
        return;
    }
    if (cancelPendingOperations) {
        [self.session invalidateAndCancel];//取消
    } else {
        [self.session finishTasksAndInvalidate];//结束
    }
}

//session的dealloc方法
- (void)dealloc {
    //取消当前队列中所有正在执行的操作
    [self.session invalidateAndCancel];
    self.session = nil;

    [self.downloadQueue cancelAllOperations];
}

//设置请求头信息，如果value为nil,则表示删除对应的键值
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field {
    LOCK(self.headersLock);
    if (value) {
        self.HTTPHeaders[field] = value;
    } else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
    UNLOCK(self.headersLock);
}
//获得请求头中value
- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field {
    if (!field) {
        return nil;
    }
    return [[self allHTTPHeaderFields] objectForKey:field];
}

- (nonnull SDHTTPHeadersDictionary *)allHTTPHeaderFields {
    LOCK(self.headersLock);
    SDHTTPHeadersDictionary *allHTTPHeaderFields = [self.HTTPHeaders copy];
    UNLOCK(self.headersLock);
    return allHTTPHeaderFields;
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

- (NSURLSessionConfiguration *)sessionConfiguration {
    return self.session.configuration;
}

//设置一个SDWebImageDownloaderOperation的子类赋值给_operationClass
- (void)setOperationClass:(nullable Class)operationClass {
    if (operationClass && [operationClass isSubclassOfClass:[NSOperation class]] && [operationClass conformsToProtocol:@protocol(SDWebImageDownloaderOperationInterface)]) {
        _operationClass = operationClass;
    } else {
        _operationClass = [SDWebImageDownloaderOperation class];
    }
}

- (NSOperation<SDWebImageDownloaderOperationInterface> *)createDownloaderOperationWithUrl:(nullable NSURL *)url
                                                                                  options:(SDWebImageDownloaderOptions)options {
    //处理下载超时，如果没有设置过则初始化为15秒
    NSTimeInterval timeoutInterval = self.downloadTimeout;
    if (timeoutInterval == 0.0) {
        timeoutInterval = 15.0;
    }

    // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests if told otherwise
    /*
     //根据给定的URL和缓存策略创建可变的请求对象，设置请求超时
     //请求策略：如果是SDWebImageDownloaderUseNSURLCache则使用NSURLRequestUseProtocolCachePolicy，否则使用NSURLRequestReloadIgnoringLocalCacheData
     
     创建request，注意我们设置的缓存策略的选择:
     NSURLRequestUseProtocolCachePolicy = 0 //默认的缓存策略，使用协议的缓存策略
     NSURLRequestReloadIgnoringLocalCacheData = 1 //每次都从网络加载
     NSURLRequestReturnCacheDataElseLoad = 2 //返回缓存否则加载，很少使用
     NSURLRequestReturnCacheDataDontLoad = 3 //只返回缓存，没有也不加载，很少使用

     NSURLRequestUseProtocolCachePolicy:默认的缓存策略
     1)如果缓存不存在，直接从服务端获取。
     2)如果缓存存在，会根据response中的Cache-Control字段判断下一步操作，如: Cache-Control字段为must-revalidata, 则询问服务端该数据是否有更新，无更新的话直接返回给用户缓存数据，若已更新，则请求服务端.
     NSURLRequestReloadIgnoringLocalCacheData:忽略本地缓存数据，直接请求服务端。
     */

    NSURLRequestCachePolicy cachePolicy = options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:cachePolicy
                                                            timeoutInterval:timeoutInterval];
    //设置是否使用Cookies(采用按位与）
    /*
     关于cookies参考：http://blog.csdn.net/chun799/article/details/17206907
     */

    request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
    //开启HTTP管道，这可以显著降低请求的加载时间，但是由于没有被服务器广泛支持，默认是禁用的
    request.HTTPShouldUsePipelining = YES;
    //设置请求头信息（过滤等）

    if (self.headersFilter) {
        request.allHTTPHeaderFields = self.headersFilter(url, [self allHTTPHeaderFields]);
    }
    else {
        request.allHTTPHeaderFields = [self allHTTPHeaderFields];
    }
    //核心方法：创建下载图片的操作
    //对于同一个url，在第一次调用sd_setImage的时候进行，创建网络请求SDWebImageDownloaderOperation。
    NSOperation<SDWebImageDownloaderOperationInterface> *operation = [[self.operationClass alloc] initWithRequest:request inSession:self.session options:options];
    //设置是否需要解码
    operation.shouldDecompressImages = self.shouldDecompressImages;
    //身份认证(证书)
    if (self.urlCredential) {
        operation.credential = self.urlCredential;
    } else if (self.username && self.password) {
        //设置 https 访问时身份验证使用的凭据(默认 账号密码为空的通用证书)
        operation.credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
    }
    
    //判断下载策略是否是高优先级的或低优先级，以设置操作的队列优先级
    if (options & SDWebImageDownloaderHighPriority) {
        operation.queuePriority = NSOperationQueuePriorityHigh;
    } else if (options & SDWebImageDownloaderLowPriority) {
        operation.queuePriority = NSOperationQueuePriorityLow;
    }
    
    //判断任务的执行优先级，如果是后进先出，则调整任务的依赖关系，优先执行当前的（最后添加）任务
    if (self.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
        // Emulate LIFO execution order by systematically adding new operations as last operation's dependency
        [self.lastAddedOperation addDependency:operation];
        //设置当前下载操作为最后一个操作
        self.lastAddedOperation = operation;
    }

    return operation;
}

//根据token取消operation
- (void)cancel:(nullable SDWebImageDownloadToken *)token {
    NSURL *url = token.url;
    if (!url) {
        return;
    }
    LOCK(self.operationsLock);
    NSOperation<SDWebImageDownloaderOperationInterface> *operation = [self.URLOperations objectForKey:url];
    if (operation) {
        BOOL canceled = [operation cancel:token.downloadOperationCancelToken];
        if (canceled) {
            [self.URLOperations removeObjectForKey:url];
        }
    }
    UNLOCK(self.operationsLock);
}

#pragma mark - SDWebImageDownloader 下载处理 👣
/**
 之所以返回SDWebImageDownloadToken,应该主要是为了返回后面取消下载操作用的。
 */
- (nullable SDWebImageDownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                                   options:(SDWebImageDownloaderOptions)options
                                                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                                                 completed:(nullable SDWebImageDownloaderCompletedBlock)completedBlock {
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return nil;
    }
    
    LOCK(self.operationsLock);
    
   // 在创建操作之前，先去URLOperations，如果取不到或者已经完成，再去创建。因为同一个url对应的operation就只有一个,以此来保证同一个url不被下载两次。
    //下载url作为key value是具体的下载operation 用字典来存储，方便cancel等操作
    NSOperation<SDWebImageDownloaderOperationInterface> *operation = [self.URLOperations objectForKey:url];
    // There is a case that the operation may be marked as finished or cancelled, but not been removed from `self.URLOperations`.
    // 去URLOperations去取operation，如果取不到或者已经完成才去创建operation
    
    if (!operation || operation.isFinished || operation.isCancelled) {
        //这样的话可以保证一个URL在多次下载的时候，只进行多次回调，而不会进行多次网络请求
        operation = [self createDownloaderOperationWithUrl:url options:options];
        __weak typeof(self) wself = self;
        operation.completionBlock = ^{
            __strong typeof(wself) sself = wself;
            if (!sself) {
                return;
            }
            //下载完成 删除 url
            //URLOperations的数据结构是一个NSMutableDictionary，key是图片url，value是一个operation
            LOCK(sself.operationsLock);
            [sself.URLOperations removeObjectForKey:url];
            UNLOCK(sself.operationsLock);
        };
        [self.URLOperations setObject:operation forKey:url];
        // Add operation to operation queue only after all configuration done according to Apple's doc.
        // `addOperation:` does not synchronously execute the `operation.completionBlock` so this will not cause deadlock.
        //把下载操作添加到下载队列中
        //该方法会调用operation内部的start方法开启图片的下载任务
        [self.downloadQueue addOperation:operation];
    }
    else if (!operation.isExecuting) {
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        } else {
            operation.queuePriority = NSOperationQueuePriorityNormal;
        }
    }
    UNLOCK(self.operationsLock);

    id downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];//绑定callback
    
    SDWebImageDownloadToken *token = [SDWebImageDownloadToken new];
    token.downloadOperation = operation;
    token.url = url;
    token.downloadOperationCancelToken = downloadOperationCancelToken;

    return token;
}

//是否暂停和恢复和取消所有的下载
- (void)setSuspended:(BOOL)suspended {
    self.downloadQueue.suspended = suspended;
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark Helper methods

- (NSOperation<SDWebImageDownloaderOperationInterface> *)operationWithTask:(NSURLSessionTask *)task {
    NSOperation<SDWebImageDownloaderOperationInterface> *returnOperation = nil;
    for (NSOperation<SDWebImageDownloaderOperationInterface> *operation in self.downloadQueue.operations) {
        if ([operation respondsToSelector:@selector(dataTask)]) {
            if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
                returnOperation = operation;
                break;
            }
        }
    }
    return returnOperation;
}

#pragma mark NSURLSessionDataDelegate
/*
 这样写的原因是为了和SDWebImageDownloaderOperation共有一个session。delegate设置为自己，也就是当使用这个会话请求数据，收到响应时，会调用SDWebImageDownloader.m中的代理方法，然后再调用SDWebImageDownloaderOperation中的代理方法处理事情
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:dataTask];
    if ([dataOperation respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(proposedResponse);
        }
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [dataOperation URLSession:session task:task didCompleteWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [dataOperation URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(request);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {

    // Identify the operation that runs this task and pass it the delegate method
    NSOperation<SDWebImageDownloaderOperationInterface> *dataOperation = [self operationWithTask:task];
    if ([dataOperation respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end
