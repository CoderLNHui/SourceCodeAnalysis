/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"


/**
 不同图片类型的枚举

 - SDImageFormatUndefined: 未知
 - SDImageFormatJPEG: JPG
 - SDImageFormatPNG: PNG
 - SDImageFormatGIF: GIF
 - SDImageFormatTIFF: TIFF
 - SDImageFormatWebP: WEBP  
 */
typedef NS_ENUM(NSInteger, SDImageFormat) {
    SDImageFormatUndefined = -1,
    SDImageFormatJPEG = 0,
    SDImageFormatPNG,
    SDImageFormatGIF,
    SDImageFormatTIFF,
    SDImageFormatWebP
};
#pragma mark 根据图片数据获取图片的类型

/**
 图片数据的第一个字节存储了图片的类型，我们取到第一个字节就可以获取图片类型
 */
@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data;

@end
