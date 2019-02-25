/*
 * SDWebImage.m
 *
 * Framework © 4.3.0
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
 
 
 SD 主要类就上面几个。
 */



































































