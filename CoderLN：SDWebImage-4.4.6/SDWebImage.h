/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * Public|JShu_不知名开发者 / Address_https://github.com/CoderLN/Apple-GitHub-Codeidea
 */


#pragma mark - CoderLN：SDWebImage-4.4.6 - Fix CocoaPods 1.6.0 && WebP issue 更新目录
/**
  
 @dreampiggy dreampiggy released this Feb 26,2019 · 2 commits to master since this release
 2019年2月26日发布
 
 Fixes
 
 Fix the unused user header search path warning for CocoaPods 1.6.0. #2622
 修复CocoaPods 1.6.0中未使用的用户头搜索路径警告
 
 Fix that WebP with custom ICC Profile will randomly crash, because CGColorSpaceCreateWithICCProfile does not copy the ICC data pointer #2621
 修复自定义ICC配置文件的WebP会随机崩溃，因为CGColorSpaceCreateWithICCProfile不复制ICC数据指针
 
 Fix the issue when WebP contains the ICC Profile with colorSpace other than RGB, which cause the CGImageCreate failed #2627
 解决当WebP包含带RGB以外的colorSpace的ICC配置文件时导致CGImageCreate失败的问题
 
 
 Project
 
 Update the libwebp dependency to support using 1.0 version and above #2625
 更新libwebp依赖项以支持使用1.0及以上版本
 
 Performances
 
 Nil imageData before decode process to free memory #2624
 解码前无图像数据处理以释放内存
 */









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
 #import "SDWebImageDownloader.h"//下载
 #import "SDWebImageDownloaderOperation.h"//具体下载操作
 
 */


/**
 工具类：
 
 NSData+ImageContentType:根据图片数据获取图片的类型，比如GIF、PNG等。
 SDWebImageCompat: 根据屏幕的分辨倍数成倍放大或者缩小图片大小。
 SDImageCacheConfig: 图片缓存策略记录。比如是否解压缩、是否允许iCloud、是否允许内存缓存、缓存时间等。默认的缓存时间是一周。
 UIImage+MultiFormat: 获取UIImage对象对应的data、或者根据data生成指定格式的UIImage，其实就是UIImage和NSData之间的转换处理。
 UIImage+GIF:对于一张图片是否GIF做判断。可以根据NSData返回一张GIF的UIImage对象，并且只返回GIF的第一张图片生成的GIF。如果要显示多张GIF，使用`FLAnimatedImageView`。
 
 
 
 
 核心类：
 
 SDImageCache:负责SDWebImage的整个缓存工作，是一个单列对象。缓存路径处理、缓存名字处理、管理内存缓存和磁盘缓存的创建和删除、根据指定key获取图片、存入图片的类型处理、根据缓存的创建和修改日期删除缓存。
 
 SDWebImageManager:拥有一个`SDWebImageCache`和`SDWebImageDownloader`属性分别用于图片的缓存和加载处理。为UIView及其子类提供了加载图片的统一接口。管理正在加载操作的集合。这个类是一个单列。还有就是各种加载选项的处理。
 
 SDWebImageDownloader:实现了图片加载的具体处理，如果图片在缓存存在则从缓存区，如果缓存不存在，则直接创建一个。`SDWebImageDownloaderOperation`对象来下载图片。管理NSURLRequest对象请求头的封装、缓存、cookie的设置。加载选项的处理等功能。管理Operation之间的依赖关系。
 
 SDWebImageDownloaderOperation: 一个自定义的并行Operation子类。这个类主要实现了图片下载的具体操作、以及图片下载完成以后的图片解压缩、Operation生命周期管理等。
 
 UIView+WebCache: 所有的UIButton、UIImageView都回调用这个分类的方法来完成图片加载的处理。同时通过`UIView+WebCacheOperation`分类来管理请求的取消和记录工作。所有UIView及其子类的分类都是用这个类的`sd_intemalSetImageWithURL:`来实现图片的加载。
 
 FLAnimatedImageView：动态图片的数据通过`ALAnimatedImage`对象来封装。`FLAnimatedImageView`是`UIImageView`的子类。通过他完全可以实现动态图片的加载显示和管理。并且比`UIImageView`做了流程优化。
 */













