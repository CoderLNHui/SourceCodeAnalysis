/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCodersManager.h"
#import "SDWebImageImageIOCoder.h"
#import "SDWebImageGIFCoder.h"
#ifdef SD_WEBP
#import "SDWebImageWebPCoder.h"
#endif
#import "UIImage+MultiFormat.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface SDWebImageCodersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t codersLock;

@end

@implementation SDWebImageCodersManager

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        //初始化SDWebImageImageIOCoder支持PNG，JPEG，TIFF，包括支持渐进解码的解码器
        NSMutableArray<id<SDWebImageCoder>> *mutableCoders = [@[[SDWebImageImageIOCoder sharedCoder]] mutableCopy];
#ifdef SD_WEBP
        //添加WebP
        [mutableCoders addObject:[SDWebImageWebPCoder sharedCoder]];
#endif
        _coders = [mutableCoders copy];
        _codersLock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Coder IO operations
//增加编码器，遵守SDWebImageCoder协议
- (void)addCoder:(nonnull id<SDWebImageCoder>)coder {
    //该编码器是否实现了SDWebImageCoder协议的方法
    if (![coder conformsToProtocol:@protocol(SDWebImageCoder)]) {
        return;
    }
    //同步添加编码器，将自己的任务插入到队列的时候，需要等待自己的任务结束之后才会继续插入被写在它后面的任务，然后执行它们
    LOCK(self.codersLock);
    NSMutableArray<id<SDWebImageCoder>> *mutableCoders = [self.coders mutableCopy];
    if (!mutableCoders) {
        mutableCoders = [NSMutableArray array];
    }
    [mutableCoders addObject:coder];
    self.coders = [mutableCoders copy];
    UNLOCK(self.codersLock);
}
//删除编码器
- (void)removeCoder:(nonnull id<SDWebImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(SDWebImageCoder)]) {
        return;
    }
    LOCK(self.codersLock);
    NSMutableArray<id<SDWebImageCoder>> *mutableCoders = [self.coders mutableCopy];
    [mutableCoders removeObject:coder];
    self.coders = [mutableCoders copy];
    UNLOCK(self.codersLock);
}

#pragma mark - SDWebImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    LOCK(self.codersLock);
    NSArray<id<SDWebImageCoder>> *coders = self.coders;
    UNLOCK(self.codersLock);
    //reverseObjectEnumerator 将数组倒序,这样一来最后面的编码器就在了最前面,意味着后面添加的编码器将具有最高优先级。
    for (id<SDWebImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

//该图片是否可以编码。 遍历self.coders中遵守SDWebImageCoder 的 coder， 然后通过canEncodeToFormat 这个方法来判断是否可以编码
- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    LOCK(self.codersLock);
    NSArray<id<SDWebImageCoder>> *coders = self.coders;
    UNLOCK(self.codersLock);
    for (id<SDWebImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}
//解码。 遍历self.coders中遵守SDWebImageCoder 的 coder， 然后通过canDecodeFromData 这个方法来判断是否可以解码，如果可以，将图像解码
- (UIImage *)decodedImageWithData:(NSData *)data {
    LOCK(self.codersLock);
    NSArray<id<SDWebImageCoder>> *coders = self.coders;
    UNLOCK(self.codersLock);
    for (id<SDWebImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return [coder decodedImageWithData:data];
        }
    }
    return nil;
}

//压缩图像. 遍历self.coders中遵守SDWebImageCoder 的 coder， 然后通过canDecodeFromData 这个方法来判断是否可以解码，如果可以，将图片压缩显示
- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
    if (!image) {
        return nil;
    }
    LOCK(self.codersLock);
    NSArray<id<SDWebImageCoder>> *coders = self.coders;
    UNLOCK(self.codersLock);
    for (id<SDWebImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:*data]) {
            UIImage *decompressedImage = [coder decompressedImageWithImage:image data:data options:optionsDict];
            decompressedImage.sd_imageFormat = image.sd_imageFormat;
            return decompressedImage;
        }
    }
    return nil;
}

//根据image和format（类型）编码图像
- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format {
    if (!image) {
        return nil;
    }
    LOCK(self.codersLock);
    NSArray<id<SDWebImageCoder>> *coders = self.coders;
    UNLOCK(self.codersLock);
    for (id<SDWebImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format];
        }
    }
    return nil;
}

@end
