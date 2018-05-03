/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"
#import "SDWebImageOperation.h"

//使用extern关键字标识 使用SDWebImageDownloadStartNotification等全局变量
extern NSString *const SDWebImageDownloadStartNotification;
extern NSString *const SDWebImageDownloadReceiveResponseNotification;
extern NSString *const SDWebImageDownloadStopNotification;
extern NSString *const SDWebImageDownloadFinishNotification;

@interface SDWebImageDownloaderOperation : NSOperation <SDWebImageOperation>

/**
 * The request used by the operation's connection.
 */
/*
 * 请求对象
 */
@property (strong, nonatomic, readonly) NSURLRequest *request;

/*
 * 图片是否需要解码
 */
@property (assign, nonatomic) BOOL shouldDecompressImages;

/**
 * Whether the URL connection should consult the credential storage for authenticating the connection. `YES` by default.
 *
 * This is the value that is returned in the `NSURLConnectionDelegate` method `-connectionShouldUseCredentialStorage:`.
 */
/*
 * URL 连接是否询问保存连接身份验证的凭据，默认是 `YES
 * 这是在 `NSURLConnectionDelegate` 的 `-connectionShouldUseCredentialStorage:` 方法中的返回值
 */
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;

/**
 * The credential used for authentication challenges in `-connection:didReceiveAuthenticationChallenge:`.
 *
 * This will be overridden by any shared credentials that exist for the username or password of the request URL, if present.
 */
/*
 * 在 `-connection:didReceiveAuthenticationChallenge:` 方法中身份验证使用的凭据
 * 如果存在请求 URL 的用户名或密码的共享凭据，此凭据会被覆盖
 */
@property (nonatomic, strong) NSURLCredential *credential;

/**
 * The SDWebImageDownloaderOptions for the receiver.
 */
/*
 * 下载选项
 */
@property (assign, nonatomic, readonly) SDWebImageDownloaderOptions options;

/**
 * The expected size of data.
 */
/*
 * 请求数据的期望大小（图片的大小）
 */
@property (assign, nonatomic) NSInteger expectedSize;

/**
 * The response returned by the operation's connection.
 */
/*
 * 网络请求的响应头信息
 */
@property (strong, nonatomic) NSURLResponse *response;

/**
 *  Initializes a `SDWebImageDownloaderOperation` object
 *
 *  @see SDWebImageDownloaderOperation
 *
 *  @param request        the URL request
 *  @param options        downloader options
 *  @param progressBlock  the block executed when a new chunk of data arrives. 
 *                        @note the progress block is executed on a background queue
 *  @param completedBlock the block executed when the download is done. 
 *                        @note the completed block is executed on the main queue for success. If errors are found, there is a chance the block will be executed on a background queue
 *  @param cancelBlock    the block executed if the download (operation) is cancelled
 *
 *  @return the initialized instance
 */
/*
 * 初始化一个 `SDWebImageDownloaderOperation` 对象
 * request:请求对象
 * options：下载选项
 * progressBlock：新的数据块到达时执行的 block(下载进度)，即进度回调
 * completedBlock：
            1）下载结束后执行的 block
            2）注意：如果下载成功，completion block 在主队列执行。如果出现错误，block 可能会在后台队列执行
 * cancelBlock：如果下载(操作)被取消，执行的 block
 */
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;

@end
