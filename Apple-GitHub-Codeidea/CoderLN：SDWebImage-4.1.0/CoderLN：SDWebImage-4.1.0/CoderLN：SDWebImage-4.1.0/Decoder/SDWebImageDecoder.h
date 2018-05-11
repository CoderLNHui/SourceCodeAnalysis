/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) james <https://github.com/mystcolor>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

/**
 把UIImage对象解压缩。
 */
@interface UIImage (ForceDecode)

/**
 解压缩图片

 @param image 原始图片
 @return 解压缩以后的图片
 */
+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image;

/**
 先把图片缩小然后再解压缩图片

 @param image 原始图片
 @return 解压缩以后的图片
 */
+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image;

@end
