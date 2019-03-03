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















