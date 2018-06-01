/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"
#import "SDWebImageOperation.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"

#pragma mark --------------------
#pragma mark typedef

//使用位移枚举，通过按位与&按位或|的组合方式传递多个值
typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {
    
    /**
     * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
     * This flag disable this blacklisting.
     *
     * 默认情况下，如果一个url在下载的时候失败了，那么这个url会被加入黑名单，不会尝试再次下载。如果使用该参数，则该URL不会被添加到黑名单中。意味着会对下载失败的URL尝试重新下载。
     * 此标记取消黑名单
     */
    SDWebImageRetryFailed = 1 << 0, //失败后尝试重新下载
    
    /**
     * By default, image downloads are started during UI interactions, this flags disable this feature,
     * leading to delayed download on UIScrollView deceleration for instance.
     *
     * 默认情况下，在 UI 交互时也会启动图像下载，此标记取消这一特性
     * 会推迟到滚动视图停止滚动之后再继续下载
     * 备注：NSURLConnection 的网络下载事件监听的运行循环模式是 NSDefaultRunLoopMode
     */
    SDWebImageLowPriority = 1 << 1, //低优先级
    
    /**
     * This flag disables on-disk caching
     *
     * 使用该参数，将禁止磁盘缓存，只做内存缓存
     */
    SDWebImageCacheMemoryOnly = 1 << 2, //只使用内存缓存
    
    /**
     * This flag enables progressive download, the image is displayed progressively during download as a browser would do.
     * By default, the image is only displayed once completely downloaded.
     *
     * 此标记允许渐进式下载，就像浏览器中那样，下载过程中，图像会逐步显示出来
     * 默认情况下，图像会在下载完成后一次性显示
     */
    SDWebImageProgressiveDownload = 1 << 3, //渐进式下载
    
    /**
     * Even if the image is cached, respect the HTTP response cache control, and refresh the image from remote location if needed.
     * The disk caching will be handled by NSURLCache instead of SDWebImage leading to slight performance degradation.
     * This option helps deal with images changing behind the same request URL, e.g. Facebook graph api profile pics.
     * If a cached image is refreshed, the completion block is called once with the cached image and again with the final image.
     *
     * Use this flag only if you can't make your URLs static with embedded cache busting parameter.
     *
     * 遵守 HTPP 响应的缓存控制，如果需要，从远程刷新图像
     * 磁盘缓存将由 NSURLCache 处理，而不是 SDWebImage，这会对性能有轻微的影响
     * 此选项用于处理URL指向图片发生变化的情况
     * 如果缓存的图像被刷新，会调用一次 completion block，并传递最终的图像
     */
    SDWebImageRefreshCached = 1 << 4,   //刷新缓存
    
    /**
     * In iOS 4+, continue the download of the image if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     *
     * 如果系统版本是iOS 4+的，那么当App进入后台后仍然会继续下载图像。
     * 这是向系统请求额外的后台时间以保证下载请求完成的
     * 如果后台任务过期，请求将会被取消
     */
    SDWebImageContinueInBackground = 1 << 5,    //后台下载
    
    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     *
     * 通过设置，处理保存在 NSHTTPCookieStore 中的 cookies
     */
    SDWebImageHandleCookies = 1 << 6,   //处理保存在NSHTTPCookieStore中的cookies
    
    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     *
     * 允许不信任的 SSL 证书
     * 可以出于测试目的使用，在正式产品中慎用
     */
    SDWebImageAllowInvalidSSLCertificates = 1 << 7,     //允许不信任的 SSL 证书
    
    /**
     * By default, image are loaded in the order they were queued. This flag move them to
     * the front of the queue and is loaded immediately instead of waiting for the current queue to be loaded (which 
     * could take a while).
     *
     *  默认情况下，图像会按照添加到队列中的顺序被加载，此标记会将它们移动到队列前端被立即加载
     *  而不是等待当前队列被加载，因为等待队列加载会需要一段时间
     */
    SDWebImageHighPriority = 1 << 8,    //高优先级（优先下载）
    
    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     *
     * 默认情况下，在加载图像时，占位图像已经会被加载。
     * 此标记会延迟加载占位图像，直到图像已经完成加载
     */
    SDWebImageDelayPlaceholder = 1 << 9,    //延迟占位图片
    
    /**
     * We usually don't call transformDownloadedImage delegate method on animated images,
     * as most transformation code would mangle it.
     * Use this flag to transform them anyway.
     *
     * 通常不会在可动画的图像上调用transformDownloadedImage代理方法，因为大多数转换代码会破坏动画文件
     * 使用此标记尝试转换
     */
    SDWebImageTransformAnimatedImage = 1 << 10, //转换动画图像
    
    /**
     * By default, image is added to the imageView after download. But in some cases, we want to
     * have the hand before setting the image (apply a filter or add it with cross-fade animation for instance)
     * Use this flag if you want to manually set the image in the completion when success
     *
     * 下载完成后手动设置图片，默认是下载完成后自动放到ImageView上
     */
    SDWebImageAvoidAutoSetImage = 1 << 11   //手动设置图像
};




//定义任务完成的block块
typedef void(^SDWebImageCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);

//定义任务结束的block块
typedef void(^SDWebImageCompletionWithFinishedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL);

//定义缓存过滤器的block块
typedef NSString *(^SDWebImageCacheKeyFilterBlock)(NSURL *url);





#pragma mark --------------------
#pragma mark SDWebImageManagerDelegate



/***************SDWebImageManagerDelegate代理协议开始***************/
//

@class SDWebImageManager;
@protocol SDWebImageManagerDelegate <NSObject>
@optional

#warning 1
/**
 * Controls which image should be downloaded when the image is not found in the cache.
 *
 * @param imageManager The current `SDWebImageManager`
 * @param imageURL     The url of the image to be downloaded
 *
 * @return Return NO to prevent the downloading of the image on cache misses. If not implemented, YES is implied.
 *
 * 如果该图片没有缓存，那么下载
 *
 * @param imageManager：当前的SDWebImageManager
 * @param imageURL：要下载图片的URL地址
 *
 * @return 如果要下载的图片在缓存中不存在，则返回NO，否则返回YES
 */
- (BOOL)imageManager:(SDWebImageManager *)imageManager shouldDownloadImageForURL:(NSURL *)imageURL;

/**
 * Allows to transform the image immediately after it has been downloaded and just before to cache it on disk and memory.
 * NOTE: This method is called from a global queue in order to not to block the main thread.
 *
 * @param imageManager The current `SDWebImageManager`
 * @param image        The image to transform
 * @param imageURL     The url of the image to transform
 *
 * @return The transformed image object.
 *
 * 允许在下载后立即将图像转换，并进行磁盘和内存缓存。
 *
 * @param imageManager 当前的SDWebImageManager
 * @param image 要转换你的图片
 * @param imageURL 要转换的图片的URL地址
 *
 * @return 变换后的图片对象
 */
- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL;

@end

//
/***************SDWebImageManagerDelegate代理协议结束***************/

#pragma mark --------------------
#pragma mark SDWebImageManager-property
//对SDWebImageManager的功能做出说明，并提供示例代码
/**
 * The SDWebImageManager is the class behind the UIImageView+WebCache category and likes.
 * It ties the asynchronous downloader (SDWebImageDownloader) with the image cache store (SDImageCache).
 * You can use this class directly to benefit from web image downloading with caching in another context than
 * a UIView.
 *
 * Here is a simple example of how to use SDWebImageManager:
 *
 * @code

SDWebImageManager *manager = [SDWebImageManager sharedManager];
[manager downloadImageWithURL:imageURL
                      options:0
                     progress:nil
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if (image) {
                            // do something with image
                        }
                    }];

 * @endcode
 *
 * SDWebImageManager是UIImageView+WebCache 等分类后台工作的类
 * SDWebImageManager是异步下载器 (SDWebImageDownloader) 和图像缓存存储 (SDImageCache) 之间的纽带
 * 可以直接使用此类实现网络图像的下载
 * 以下是如何使用 SDWebImageManager 的示例代码
 *@code
     SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:imageURL
                        options:0
                        progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                 if (image) {
                                 // do something with image
                                 }
                        }];
 *@endcode
 */
@interface SDWebImageManager : NSObject
@property (weak, nonatomic) id <SDWebImageManagerDelegate> delegate; //遵守了SDWebImageManagerDelegate协议的代理
@property (strong, nonatomic, readonly) SDImageCache *imageCache;    //处理缓存
@property (strong, nonatomic, readonly) SDWebImageDownloader *imageDownloader; //图片下载工具类

/**
 * The cache filter is a block used each time SDWebImageManager need to convert an URL into a cache key. This can
 * be used to remove dynamic part of an image URL.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * @code

[[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    return [url absoluteString];
}];

 * @endcode
 *
 *  "缓存过滤器"是一个block，用于每次SDWebImageManager需要将一个URL转换成一个缓存的键值
 *  可用于删除图像 URL 中动态的部分
 *  以下示例在 application 代理中设置一个过滤器，该过滤器会在将URL当作缓存键值之前，从URL中删除请求字符串
 *
     [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        return [url absoluteString];
     }];
 **/
@property (nonatomic, copy) SDWebImageCacheKeyFilterBlock cacheKeyFilter; //缓存过滤器

#pragma mark --------------------
#pragma mark SDWebImageManager-Methods

/**
 * Returns global SDWebImageManager instance.
 *
 * @return SDWebImageManager shared instance
 *
 * 单例方法
 * @return 返回全局的 SDWebImageManager 实例(单例)
 */
+ (SDWebImageManager *)sharedManager;

//说明：下载图片调用的主方法
/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url            The URL to the image
 * @param options        A mask to specify options to use for this request
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed.
 *
 *   This parameter is required.
 * 
 *   This block has no return value and takes the requested UIImage as first parameter.
 *   In case of error the image parameter is nil and the second parameter may contain an NSError.
 *
 *   The third parameter is an `SDImageCacheType` enum indicating if the image was retrieved from the local cache
 *   or from the memory cache or from the network.
 *
 *   The last parameter is set to NO when the SDWebImageProgressiveDownload option is used and the image is 
 *   downloading. This block is thus called repeatedly with a partial image. When image is fully downloaded, the
 *   block is called a last time with the full image and the last parameter set to YES.
 *
 * @return Returns an NSObject conforming to SDWebImageOperation. Should be an instance of SDWebImageDownloaderOperation
 *
 * 如果URL对应的图像在缓存中不存在，那么就下载指定的图片 ，否则返回缓存的图像
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
                                        progress:(SDWebImageDownloaderProgressBlock)progressBloc
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

/**
 * Saves image to cache for given URL
 *
 * @param image The image to cache
 * @param url   The URL to the image
 *
 * 根据图片的URL保存图片到缓存
 *
 * @param image：缓存的图片
 * @param url：该图片的URL地址
 */
- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url;

/**
 * Cancel all current operations
 *
 * 取消当前所有操作
 */
- (void)cancelAll;


/**
 * Check one or more operations running
 *
 * 检查一个或多个操作是否正在运行
 */
- (BOOL)isRunning;


/**
 *  Check if image has already been cached
 *
 *  @param url image url
 *
 *  @return if the image was already cached
 *
 *  检查图像是否已经被缓存,如果已经缓存则返回YES
 *  @param url:图片对应的URL
 *
 *  @return 返回是否存在的BOOL值
 */
- (BOOL)cachedImageExistsForURL:(NSURL *)url;

/**
 *  Check if image has already been cached on disk only
 *
 *  @param url image url
 *
 *  @return if the image was already cached (disk only)
 *
 *  检查图像是否存在磁盘缓存（此方法仅针对磁盘进行检查，只要存在就返回YES）
 *
 *  @param url 图片的url
 *
 *  @return 是否存在（只检查磁盘缓存）
 */
- (BOOL)diskImageExistsForURL:(NSURL *)url;

/**
 *  Async check if image has already been cached
 *
 *  @param url              image url
 *  @param completionBlock  the block to be executed when the check is finished
 *  
 *  @note the completion block is always executed on the main queue
 *
 *  异步检查图像是否已经有内存缓存
 *
 *  @param URL             图片对应的URL
 *  @param completionBlock 当任务执行完毕之后调用的block
 *  @note  completionBlock始终在主队列执行
 */
- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;

/**
 *  Async check if image has already been cached on disk only
 *
 *  @param url              image url
 *  @param completionBlock  the block to be executed when the check is finished
 *
 *  @note the completion block is always executed on the main queue
 *
 *  异步检查图像是否已经有磁盘缓存
 *
 *  @param URL             图片对应的URL
 *  @param completionBlock 当任务执行完毕之后调用的block
 *  @note  completionBlock始终在主队列执行
 */
- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;


/**
 * Return the cache key for a given URL
 *
 * 返回指定URL的缓存键值，就是URL字符串
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;

@end

#pragma mark --------------------
#pragma mark Deprecated(过时的）

typedef void(^SDWebImageCompletedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType) __deprecated_msg("Block type deprecated. Use `SDWebImageCompletionBlock`");
typedef void(^SDWebImageCompletedWithFinishedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) __deprecated_msg("Block type deprecated. Use `SDWebImageCompletionWithFinishedBlock`");


@interface SDWebImageManager (Deprecated)

/**
 *  Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 *  @deprecated This method has been deprecated. Use `downloadImageWithURL:options:progress:completed:`
 */
- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url
                                    options:(SDWebImageOptions)options
                                   progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                  completed:(SDWebImageCompletedWithFinishedBlock)completedBlock __deprecated_msg("Method deprecated. Use `downloadImageWithURL:options:progress:completed:`");

@end
