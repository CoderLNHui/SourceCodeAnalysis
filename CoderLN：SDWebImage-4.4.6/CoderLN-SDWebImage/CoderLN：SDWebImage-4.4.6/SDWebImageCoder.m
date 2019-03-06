/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCoder.h"

NSString * const SDWebImageCoderScaleDownLargeImagesKey = @"scaleDownLargeImages";

//获取颜色空间
CGColorSpaceRef SDCGColorSpaceGetDeviceRGB(void) {
    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorSpace = CGColorSpaceCreateDeviceRGB();
    });
    return colorSpace;
}

//判断图片是否包含透明度
BOOL SDCGImageRefContainsAlpha(CGImageRef imageRef) {
    //如果imageRef为空就直接返回NO
    if (!imageRef) {
        return NO;
    }
    //获取图片的Alpha的信息
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}
