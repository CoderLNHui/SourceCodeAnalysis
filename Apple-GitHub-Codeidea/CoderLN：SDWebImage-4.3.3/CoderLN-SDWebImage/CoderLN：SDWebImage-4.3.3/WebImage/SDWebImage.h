/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 * Public_不知名开发者 https://dwz.cn/rC1LGk2f | 注解版本仓库_https://github.com/CoderLN/Apple-GitHub-Codeidea
 */

#import <SDWebImage/SDWebImageCompat.h>

#if SD_UIKIT
#import <UIKit/UIKit.h>
#endif

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WebImage/PublicHeader.h>

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCacheConfig.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImageView+HighlightedWebCache.h>
#import <SDWebImage/SDWebImageDownloaderOperation.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <SDWebImage/UIView+WebCacheOperation.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/SDWebImageOperation.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDWebImageTransition.h>

#if SD_MAC || SD_UIKIT
    #import <SDWebImage/MKAnnotationView+WebCache.h>
#endif

#import <SDWebImage/SDWebImageCodersManager.h>
#import <SDWebImage/SDWebImageCoder.h>
#import <SDWebImage/SDWebImageWebPCoder.h>
#import <SDWebImage/SDWebImageGIFCoder.h>
#import <SDWebImage/SDWebImageImageIOCoder.h>
#import <SDWebImage/SDWebImageFrame.h>
#import <SDWebImage/SDWebImageCoderHelper.h>
#import <SDWebImage/UIImage+WebP.h>
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/UIImage+ForceDecode.h>
#import <SDWebImage/NSData+ImageContentType.h>

#if SD_MAC
    #import <SDWebImage/NSImage+WebCache.h>
    #import <SDWebImage/NSButton+WebCache.h>
    #import <SDWebImage/SDAnimatedImageRep.h>
#endif

#if SD_UIKIT
    #import <SDWebImage/FLAnimatedImageView+WebCache.h>

    #if __has_include(<SDWebImage/FLAnimatedImage.h>)
        #import <SDWebImage/FLAnimatedImage.h>
    #endif

    #if __has_include(<SDWebImage/FLAnimatedImageView.h>)
        #import <SDWebImage/FLAnimatedImageView.h>
    #endif

#endif



#pragma mark - SD 业务层级
/**
 整个架构简单分为三层。
 
 最上层：负责业务的接入、图片的插入
 #import "UIImageView+WebCache.h"
 #import "UIButton+WebCache.h"
 #import "UIImageView+HighlightedWebCache.h"
 #import "UIView+WebCache.h" //以及其汇总的
 
 
 逻辑层：负责不同类型业务的分发。读取(或写入)缓存(或磁盘)、下载等具体逻辑处理。
 #import "SDWebImageManager.h"
 
 
 业务层：负责具体业务的实现
 #import "SDImageCache.h"// 缓存&&磁盘操作
 #import "SDWebImageDownloader.h"//下载处理
 #import "SDWebImageDownloaderOperation.h"//具体下载操作

 */


/**
 工具类：
 NSData+ImageContentType:根据图片数据获取图片的类型，比如GIF、PNG等。
 SDWebImageCompat: 根据屏幕的分辨倍数成倍放大或者缩小图片大小。
 SDImageCacheConfig: 图片缓存策略记录。比如是否解压缩、是否允许iCloud、是否允许内存缓存、缓存时间等。默认的缓存时间是一周。
 UIImage+MultiFormat: 获取UIImage对象对应的data、或者根据data生成指定格式的UIImage，其实就是UIImage和NSData之间的转换处理。
 UIImage+GIF:对于一张图片是否GIF做判断。可以根据NSData返回一张GIF的UIImage对象，并且只返回GIF的第一张图片生成的GIF。如果要显示多张GIF，使用`FLAnimatedImageView`。
 SDWebImageDecoder:根据图片的情况，做图片的解压缩处理。并且根据图片的情况决定如何处理解压缩。
 
 核心类：
 SDImageCache:负责SDWebImage的整个缓存工作，是一个单列对象。缓存路径处理、缓存名字处理、管理内存缓存和磁盘缓存的创建和删除、根据指定key获取图片、存入图片的类型处理、根据缓存的创建和修改日期删除缓存。
 
 SDWebImageManager:拥有一个`SDWebImageCache`和`SDWebImageDownloader`属性分别用于图片的缓存和加载处理。为UIView及其子类提供了加载图片的统一接口。管理正在加载操作的集合。这个类是一个单列。还有就是各种加载选项的处理。
 
 SDWebImageDownloader:实现了图片加载的具体处理，如果图片在缓存存在则从缓存区，如果缓存不存在，则直接创建一个。`SDWebImageDownloaderOperation`对象来下载图片。管理NSURLRequest对象请求头的封装、缓存、cookie的设置。加载选项的处理等功能。管理Operation之间的依赖关系。
 
 SDWebImageDownloaderOperation: 一个自定义的并行Operation子类。这个类主要实现了图片下载的具体操作、以及图片下载完成以后的图片解压缩、Operation生命周期管理等。
 
 UIView+WebCache: 所有的UIButton、UIImageView都回调用这个分类的方法来完成图片加载的处理。同时通过`UIView+WebCacheOperation`分类来管理请求的取消和记录工作。所有UIView及其子类的分类都是用这个类的`sd_intemalSetImageWithURL:`来实现图片的加载。
 
 FLAnimatedImageView：动态图片的数据通过`ALAnimatedImage`对象来封装。`FLAnimatedImageView`是`UIImageView`的子类。通过他完全可以实现动态图片的加载显示和管理。并且比`UIImageView`做了流程优化。
 */








#pragma mark - CoderLN：SDWebImage-4.3.3 更新目录
/**
 dreampiggy released this on 5 Dec 2018 · 71 commits to master since this release
 于2018年12月5日发布了这个版本
 
 See all tickets marked for the 4.4.3 release
 
 Fixes
 
 Revert the hack code for FLAnimatedImage, because of the FLAnimatedImage initializer method blocks the main queue #2441    恢复FLAnimatedImage的hack代码，因为FLAnimatedImage初始化方法阻塞主队列
 Fix extention long length of file name #2516 6c6d848   修复扩展文件名的长度
 Fix resource key invalid when clean cached disk file #2463 修复在清除缓存的磁盘文件时资源键无效的问题
 Fix the test case testFLAnimatedImageViewSetImageWithURL because of remote resource is not available #2450     修复测试用例testFLAnimatedImageViewSetImageWithURL，因为远程资源不可用
 Add default HTTP User-Agent for specific system #2409  为特定的系统添加默认的HTTP用户代理
 Add SDImageFormatHEIF represent mif1 && msf1 brands #2423  添加SDImageFormatHEIF代表mif1 && msf1品牌
 remove addProgressCallback, add createDownloaderOperationWithUrl #2336 删除addProgressCallback，添加createDownloaderOperationWithUrl
 Fix the bug when FLAnimatedImageView firstly show one EXIF rotation JPEG UIImage, later animated GIF FLAnimatedImage will also be rotated #2406    修复FLAnimatedImageView首次显示一个EXIF旋转JPEG UIImage时的错误，后来动画GIF FLAnimatedImage也将被旋转
 Replace SDWebImageDownloaderOperation with NSOperation<SDWebImageDownloaderOperationInterface> to make generic #2397   用NSOperation 替换SDWebImageDownloaderOperation以使通用
 Fix wrong image cache type when disk and memory cache missed #2529 修复磁盘和内存缓存丢失时错误的图像缓存类型
 Fix FLAnimatedImage version check issue for custom property optimalFrameCacheSize && predrawingEnabled #2543   修复自定义属性optimalFrameCacheSize && predrawingEnabled的FLAnimatedImage版本检查问题
 
 
 Performances
 
 Add autoreleasepool to release autorelease objects in advance when using GCD for 4.x #2475
 Optimize when scale = 1 #2520  使用GCD for 4.x时，添加autoreleasepool以预先释放自动释放对象＃2475当scale = 1时优化
 
 
 Docs
 
 Updated URLs after project was transfered to SDWebImage organization #2510 f9d05d9 项目转移到SDWebImage组织后更新的URL
 Tidy up spacing for README.md #2511    整理README.md的间距
 Remove versioneye from README #2424    从README中删除versioneye
 */























