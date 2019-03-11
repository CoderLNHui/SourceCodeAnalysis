/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 缓存配置对象，包含所有配置项（解压缩图像，iCloud备份， 最长缓存时间，等等）我们自己在封装类的时候，应该学习这种方式
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

//SDImageCacheConfigExpireType定义的是以什么方式来计算图片的过期时间
typedef NS_ENUM(NSUInteger, SDImageCacheConfigExpireType) {
    /**
     * When the image is accessed it will update this value
     //图片最近访问的时间
     */
    SDImageCacheConfigExpireTypeAccessDate,
    /**
     * The image was obtained from the disk cache (Default)
     //默认：图片最近修改的时间
     */
    SDImageCacheConfigExpireTypeModificationDate
};

@interface SDImageCacheConfig : NSObject

/**
 * Decompressing images that are downloaded and cached can improve performance but can consume lot of memory.
 * Defaults to YES. Set this to NO if you are experiencing a crash due to excessive memory consumption.
 //预解码图片，默认YES；
 //预解码图片可以提升性能，但会消耗太多的内存
 */
@property (assign, nonatomic) BOOL shouldDecompressImages;

/**
 * Whether or not to disable iCloud backup
 * Defaults to YES.
 禁用iCloud备份,默认为YES
 */
@property (assign, nonatomic) BOOL shouldDisableiCloud;

/**
 * Whether or not to use memory cache
 * @note When the memory cache is disabled, the weak memory cache will also be disabled.
 * Defaults to YES.
 * 使用内存缓存，默认为YES

 */
@property (assign, nonatomic) BOOL shouldCacheImagesInMemory;

/**
 * The option to control weak memory cache for images. When enable, `SDImageCache`'s memory cache will use a weak maptable to store the image at the same time when it stored to memory, and get removed at the same time.
 * However when memory warning is triggered, since the weak maptable does not hold a strong reference to image instacnce, even when the memory cache itself is purged, some images which are held strongly by UIImageViews or other live instances can be recovered again, to avoid later re-query from disk cache or network. This may be helpful for the case, for example, when app enter background and memory is purged, cause cell flashing after re-enter foreground.
 * Defautls to YES. You can change this option dynamically.
 //开启SDMemoryCache内部维护的一张图片弱引用表
 //好处：当收到内存警告，SDMemoryCache会移除图片的缓存,但是有些图片此时已经被一些诸如UIImageView强引用这，使用这个弱引用表就能访问到图片，避免后面再去query硬盘缓存
 
 */
@property (assign, nonatomic) BOOL shouldUseWeakMemoryCache;

/**
 * The reading options while reading cache from disk.
 * Defaults to 0. You can set this to `NSDataReadingMappedIfSafe` to improve performance.
 //硬盘图片读取的配置选项，默认是0
 */
@property (assign, nonatomic) NSDataReadingOptions diskCacheReadingOptions;

/**
 * The writing options while writing cache to disk.
 * Defaults to `NSDataWritingAtomic`. You can set this to `NSDataWritingWithoutOverwriting` to prevent overwriting an existing file.
 //把图片存入硬盘的配置选项，默认NSDataWritingAtomic原子操作
 */
@property (assign, nonatomic) NSDataWritingOptions diskCacheWritingOptions;

/**
 * The maximum length of time to keep an image in the cache, in seconds.
 * 缓存的最长时间，以秒为单位，默认为1周
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 缓存图像总大小，以字节为单位，默认数值为0，表示不作限制
 //最大的缓存大小，如果maxCacheSize>0,在清除硬盘缓存的时候会先把缓存时间操作maxCacheAge的图片清除掉，然后再清除图片到总缓存大小在maxCacheSize * 0.5以下
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

/**
 * The attribute which the clear cache will be checked against when clearing the disk cache
 * Default is Modified Date
 //硬盘缓存图片过期时间的计算方式，默认是最近修改的时间
 */
@property (assign, nonatomic) SDImageCacheConfigExpireType diskCacheExpireType;

@end
