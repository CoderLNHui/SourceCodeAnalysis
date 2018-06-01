/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

@interface UIImage (ForceDecode)

//图片解压缩处理通用思路：是在子线程，将原始的图片渲染成一张的新的可以字节显示的图片，来获取一个解压缩过的图片。
//图片的解压缩以前（会导致内存暴增？还未验证）
+ (UIImage *)decodedImageWithImage:(UIImage *)image;

@end
