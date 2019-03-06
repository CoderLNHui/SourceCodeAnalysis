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


#pragma mark - CoderLN：SDWebImage-3.7.5 更新目录
/**
 bpoplauschi released this on 21 Jan 2016 · 803 commits to master since this release
 于2016年1月21日发布此消息
 Fixes:
 
 fixed #1425 and #1426 - Continuation of Fix #1366, addresses #1350 and reverts a part of #1221 - from commit 6406d8e, the wrong usage of dispatch_apply    dispatch_apply的错误用法
 fixed #1422 - Added a fallback for #976 so that if there are images saved with the old format (no extension), they can still be loaded 如果存在以旧格式保存的图像(没有扩展名)，仍然可以加载它们
 
 */






##pragma mark - SD内部实现逻辑
##pragma mark -磁盘目录位于哪里？
```objc
    SDImageCache.m 缓存在磁盘沙盒目录下 Library/Caches
    二级目录为~/Library/Caches/default/com.hackemist.SDWebImageCache.default

    //设置磁盘缓存路径
    -(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
        //获得caches路径，该框架内部对图片进行磁盘缓存，设置的缓存目录为沙盒中Library的caches目录下
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //在caches目录下，新建一个名为【fullNamespace】的文件，沙盒缓存就保存在此处
        return [paths[0] stringByAppendingPathComponent:fullNamespace];
    }
 
     //使用指定的命名空间实例化一个新的缓存存储和目录
     - (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
        if ((self = [super init])) {
            //拼接默认的磁盘缓存目录
            NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:ns];
        }
     }

    //你也可以通过下面方法来自定义一个路径。但这个路径不会被存储使用、是给开发者自定义预装图片的路径。
    [[SDImageCache sharedImageCache] addReadOnlyCachePath:bundledPath];
```

 
##pragma mark -最大并发数量、超时时长s
```objc
    _downloadQueue = [NSOperationQueue new];        //创建下载队列：非主队列（在该队列中的任务在子线程中异步执行）
    _downloadQueue.maxConcurrentOperationCount = 6; //设置下载队列的最大并发数：默认为6
    _downloadTimeout = 15.0;//超时时长15s
```

##pragma mark -默认的最大缓存时间为1周
```objc
static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week
```

##pragma mark -缓存文件的保存名称如何处理?
```objc
    1.写入缓存时、直接用图片url作为key
    NSUInteger cost = SDCacheCostForImage(image);
    [self.memCache setObject:image forKey:key cost:cost];


    2.写入磁盘时，对key(通常为URL)进行MD5加密，加密后的密文作为图片的名称，可以防止文件名过长。
    - (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
        const char *str = key.UTF8String;
        if (str == NULL) {
        str = "";
        }
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        NSURL *keyURL = [NSURL URLWithString:key];
        NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
        NSString *filename = [NSString stringWithFormat:
                            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                            r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
        return filename;
    }
```


##pragma mark -如何判断图片的类型？
```objc
+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return SDImageFormatUndefined;
    }
    //在判断图片类型的时候，只匹配NSData数据第一个字节。
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];//获得传入的图片二进制数据的第一个字节
    switch (c) {
        case 0xFF:
            return SDImageFormatJPEG;
        case 0x89:
            return SDImageFormatPNG;
        case 0x47:
            return SDImageFormatGIF;
        case 0x49:
        case 0x4D:
            return SDImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) { //WEBP :是一种同时提供了有损压缩与无损压缩的图片文件格式
                //RIFF....WEBP
                //获取前12个字节
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                //如果以『RIFF』开头，且以『WEBP』结束，那么就认为该图片是Webp类型的
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return SDImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return SDImageFormatHEIC;
                }
            }
            break;
        }
    }
    return SDImageFormatUndefined;
}
```

##pragma mark -图片缓存类型？
```objc
 SDImageCacheType cacheType（TypeNone：网络下载、TypeDisk：使用磁盘缓存、TypeMemory：使用内存缓存）
```


##pragma mark -框架内部对内存警告的处理方式?
```objc
        // Subscribe to app events
        //监听应用程序通知
        
        // init方法 监听到（应用程序发生内存警告）通知，调用didReceiveMemoryWarning方法，移除所有内存缓存；
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        //当监听到（程序将终止）调用deleteOldFiles方法,清理过期文件(默认大于一周)的磁盘缓存
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteOldFiles)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        //当监听到（进入后台），调用backgroundDeleteOldFiles方法,清理未完成、长期运行的任务缓存
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundDeleteOldFiles)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
```

##pragma mark -该框架进行缓存处理的方式?
```objc
    可变字典(以前) ---> (SDMemoryCache: NSCache) 缓存处理

    cache.totalCostLimit = 5;// 设置最大缓存控件的总成本, 如果发现存的数据超过中成本那么会自动回收之前的对
    cache.countLimit = 5;// 设置最大缓存文件的数量, 示例：多图下载综合案例
```

##pragma mark -队列中任务的处理方式?
```objc
    @property (assign, nonatomic) SDWebImageDownloaderExecutionOrder executionOrder; //通过该属性，可以修改下载操作执行顺序
    _executionOrder = SDWebImageDownloaderFIFOExecutionOrder; //下载任务的执行方式：所有下载操作将按照队列的先进先出方式执行
```


##pragma mark -SDWebImageDownloader 如何下载图片?
```objc
   发送NSURLSession (NSURLSessionDataDelegate)网络请求下载图片;
```
 
##pragma mark -磁盘清理的原则？
```objc
    程序将终止
    首先移除早于过期日期的文件（kDefaultCacheMaxCacheAge = 1 week）。
    其次如果剩余磁盘缓存空间超出最大限额，则按时间排序再次执行清理操作，循环依次删除最早的文件，直到低于期望的缓存限额的 1/2 (currentCacheSize < self.maxCacheSize / 2)。

    内存警告
    如果发生内存警告会收到通知，对应调用didReceiveMemoryWarning:方法，直接把把所有的内存缓存都删除。

    程序进入后台
    如果程序进入后台会收到通知，对应调用backgroundDeleteOldFiles方法，清理未完成、长期运行的任务task 缓存。
```


##pragma mark -清除缓存
```objc
/*
    [[SDImageCache sharedImageCache] clearMemory];//【clearMemory清除内存缓存】
    【问题】: SD清空图片(所有内存)缓存，为什么显示在屏幕上的几张没有清除？
    【解决】: 1.显示在屏幕上的几张图片被cell中，UIImageView image属性引用。 2.SD对同一个URL的网络图片不会被重复下载
     clearMemory内部调用
     - (void)clearMemory {
         [self.memCache removeAllObjects];
     }

 
 - - -

    // 1.【清空磁盘缓存】
    // clearMemory 清除内存缓存
    // -clearDisk 清除磁盘缓存,直接删除然后重新创建(所有缓存目录中的文件全部删除，再创建一个同名空目录)
    // -cleanDisk 清除过期(maxCacheAge = 7天)的磁盘缓存,计算当前缓存的大小,和设置的最大缓存数量比较,
    如果超出那么会继续删除(按照文件创建的先后顺序)，直到小于最大缓存数量
    [[SDWebImageManager sharedManager].imageCache cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];

    // 2.【取消当前所有的操作】
    [[SDWebImageManager sharedManager] cancelAll];
*/
```





























