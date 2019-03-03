//
//  WebImage.h
//  WebImage
//
//  Created by Florent Vilmart on 2015-03-14.
//  Copyright (c) 2015 Dailymotion. All rights reserved.
//  Public_不知名开发者 https://dwz.cn/rC1LGk2f | 注解版本仓库_https://github.com/CoderLN/Apple-GitHub-Codeidea
//

#import <UIKit/UIKit.h>

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WebImage/PublicHeader.h>

#import <WebImage/SDWebImageManager.h>
#import <WebImage/SDImageCache.h>
#import <WebImage/UIImageView+WebCache.h>
#import <WebImage/SDWebImageCompat.h>
#import <WebImage/UIImageView+HighlightedWebCache.h>
#import <WebImage/SDWebImageDownloaderOperation.h>
#import <WebImage/UIButton+WebCache.h>
#import <WebImage/SDWebImagePrefetcher.h>
#import <WebImage/UIView+WebCacheOperation.h>
#import <WebImage/UIImage+MultiFormat.h>
#import <WebImage/SDWebImageOperation.h>
#import <WebImage/SDWebImageDownloader.h>
#if !TARGET_OS_TV
#import <WebImage/MKAnnotationView+WebCache.h>
#endif
#import <WebImage/SDWebImageDecoder.h>
#import <WebImage/UIImage+WebP.h>
#import <WebImage/UIImage+GIF.h>
#import <WebImage/NSData+ImageContentType.h>



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



#pragma mark - CoderLN：SDWebImage-4.1.0 更新目录
/**
 bpoplauschi released this on 31 Jul 2017 · 439 commits to master since this release
 于2017年7月31日发布此消息
 See all tickets marked for the 4.1.0 release
 
 Features
 
 add ability to change NSURLSessionConfiguration used by SDWebImageDownloader #1891 fixes #1870 添加更改SDWebImageDownloader使用的NSURLSessionConfiguration的功能
 support animated GIF on macOS #1975    支持macOS上的动画GIF
 cleanup the Swift interface by making unavailable all methods with missing params that have alternatives - see #1797 - this may cause require some changes in the Swift code   通过使所有缺少参数的方法不可用来清理Swift接口(参见#1797)，这可能会导致需要对Swift代码进行一些更改
 
 
 Fixes
 
 handle NSURLErrorNetworkConnectionLost #1767   处理NSURLErrorNetworkConnectionLost
 fixed CFBundleVersion and CFBundleShortVersionString not valid for all platforms #1784 + 23a8be8 fixes #1780   修复CFBundleVersion和CFBundleShortVersionString对所有平台无效
 fixed UIActivityIndicator not always initialized on main thread #1802 + a6af214 fixes #1801    修正了UIActivityIndicator不总是在主线程上初始化的问题
 SDImageCacheConfig forward declaration changed to import #1805 SDImageCacheConfig转发声明已更改为导入
 making image downloading cache policy more clearer #1737   使图像下载缓存策略更加清晰
 added @autoreleasepool to SDImageCache.storeImage #1849    将@autoreleasepool添加到SDImageCache.storeImage
 fixed 32bit machine long long type transfer to NSInteger may become negative #1879 固定32位机器长长型传输到NSInteger可能会变为负数
 fixed crash on multiple concurrent downloads when accessing self.URLOperations dictionary #1911 fixes #1909 #1950 #1835 #1838  修正了在访问self时多个并发下载时崩溃的问题。URLOperations字典
 fixed crash due to incorrectly retained pointer to operation self which appears to create a dangled pointer    修复由于错误地保留指向操作self的指针而导致崩溃，这似乎会创建一个悬空指针 #1940 fixes #1807 #1858 #1859 #1821 #1925 #1883 #1816 #1716
 fixed Swift naming collision (due to the Obj-C interface that offers multiple variants of the same method but with mixed and missing params) #1797 fixes #1764 修复了Swift命名冲突（由于Obj-C接口提供了相同方法的多个变体，但具有混合和缺失的参数）
 coding style #1971
 fixed Umbrella header warning for the FLAnimatedImage (while using Carthage) d9f7cf4 (replaces #1781) fixes #1776  已修复FLAnimatedImage的伞标题警告（使用Carthage时）d9f7cf4（替换＃1781）修复
 fixed issue where animated image arrays could be populated out of order (order of download) #1452  修复了可能无序填充动画图像数组的问题（下载顺序）
 fixed animated WebP decoding issue, including canvas size, the support for dispose method and the duration per frame #1952 (replaces #1694) fixes #1951    修复了动画WebP解码问题，包括画布大小，对dispose方法的支持和每帧的持续时间
 
 
 Docs
 
 #1778 #1779 #1788 #1799 b1c3bb7 (replaces #1806) 0df32ea #1847 5eb83c3 (replaces #1828) #1946 #1966
 */
