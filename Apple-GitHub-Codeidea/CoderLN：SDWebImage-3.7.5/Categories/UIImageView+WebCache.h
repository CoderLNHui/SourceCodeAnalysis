/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
// 1.下载图片(缓存)

#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

/**
 * Integrates SDWebImage async downloading and caching of remote images with UIImageView.
 *
 * Usage with a UITableViewCell sub-class:
 *
 * 为UIImageView集成了远程异步远程图片下载和缓存。
 *
 *
 *@code

#import <SDWebImage/UIImageView+WebCache.h>

...

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
 
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier]
                 autorelease];
    }
    
    //使用该方法可以先给cell设置一个占位图片
    // Here we use the provided sd_setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
 
    cell.textLabel.text = @"My Text";
    return cell;
}

 * @endcode
 */
@interface UIImageView (WebCache)

/**
 * Get the current image URL.
 *
 * Note that because of the limitations of categories this property can get out of sync
 * if you use sd_setImage: directly.
 *
 * 获得当前图片的URL
 */
- (NSURL *)sd_imageURL;

/**
 * Set the imageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url The url for the image.
 *
 * 根据图片的url下载图片并设置到ImageView上面去
 * 异步下载并缓存。
 * @param url 图片的URL
 */
- (void)sd_setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see sd_setImageWithURL:placeholderImage:options:
 *
 * 根据图片的url下载图片并设置到ImageView上面去,并设置占位图片
 * @param url 图片的URL
 * @param placeholder 显示在UIImageView上面的占位图片，直到图片下载完成
 * @see 参考sd_setImageWithURL:placeholderImage:options:方法
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options     The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 *
 * 根据图片的url下载图片并设置到ImageView上面去,并设置占位图片，自定义下载选项
 * @param url           图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options       下载图片的选项。参考SDWebImageOptions的枚举值
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

/**
 * Set the imageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder   显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options       下载图片的选项。参考SDWebImageOptions的枚举值
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 *
 * 根据图片的url下载图片并设置到ImageView上面去，占位图片
 * 异步下载并缓存
 *
 * @param url            图片的URL
 * @param placeholder    显示在UIImageView上面的占位图片，直到图片下载完成
 * @param options        下载图片的选项。参考SDWebImageOptions的枚举值
 * @param progressBlock  下载的进度回调
 * @param completedBlock 当操作执行完毕之后的回调。该回调没有返回值
 *      第一个参数为请求的图片
 *      第二个参数是NSError类型的，如果图片下载成功则error为nil,否则error有值
 *      第三个参数是图片缓存的使用情况（内存缓存|沙盒缓存|直接下载）
 *      第四个参数是图片的URL地址
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

/**
 * Download an array of images and starts them in an animation loop
 *
 * @param arrayOfURLs An array of NSURL
 */
- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs;

/**
 * Cancel the current download
 */
- (void)sd_cancelCurrentImageLoad;

- (void)sd_cancelCurrentAnimationImagesLoad;

/**
 *  Show activity UIActivityIndicatorView
 */
- (void)setShowActivityIndicatorView:(BOOL)show;

/**
 *  set desired UIActivityIndicatorViewStyle
 *
 *  @param style The style of the UIActivityIndicatorView
 */
- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end


@interface UIImageView (WebCacheDeprecated)

//过期的方法
- (NSURL *)imageURL __deprecated_msg("Use `sd_imageURL`");

- (void)setImageWithURL:(NSURL *)url __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:`");
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:`");
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:options`");

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:completed:`");
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:completed:`");
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:options:completed:`");
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `sd_setImageWithURL:placeholderImage:options:progress:completed:`");

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs __deprecated_msg("Use `sd_setAnimationImagesWithURLs:`");

- (void)cancelCurrentArrayLoad __deprecated_msg("Use `sd_cancelCurrentAnimationImagesLoad`");

- (void)cancelCurrentImageLoad __deprecated_msg("Use `sd_cancelCurrentImageLoad`");

@end
