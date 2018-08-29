/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"
#import "NSData+ImageContentType.h"

@interface UIImage (MultiFormat)
/**
 根据image的data数据。生成对应的image对象
 
 @param data 图片的数据
 @return image对象
 */
+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data;
- (nullable NSData *)sd_imageData;

/**
 根据指定的图片类型，把image对象转换为对应格式的data

 @param imageFormat 指定的image格式
 @return 返回data对象
 */
- (nullable NSData *)sd_imageDataAsFormat:(SDImageFormat)imageFormat;

@end
