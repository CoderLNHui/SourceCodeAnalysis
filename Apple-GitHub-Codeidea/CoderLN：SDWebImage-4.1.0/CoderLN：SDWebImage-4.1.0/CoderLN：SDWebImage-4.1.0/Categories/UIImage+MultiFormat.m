/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"
#import "NSData+ImageContentType.h"
#import <ImageIO/ImageIO.h>

#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

@implementation UIImage (MultiFormat)

/**
 根据image的data数据。生成对应的image对象

 @param data 图片的数据
 @return image对象
 */
+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    UIImage *image;
    //获取data的图片类型，png，gif，jpg
    SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:data];
    if (imageFormat == SDImageFormatGIF) {
        //gif处理：返回一张只包含数据第一张image 的gif图片
        image = [UIImage sd_animatedGIFWithData:data];
    }
#ifdef SD_WEBP
    else if (imageFormat == SDImageFormatWebP)
    {
        image = [UIImage sd_imageWithWebPData:data];
    }
#endif
    else {
        image = [[UIImage alloc] initWithData:data];
#if SD_UIKIT || SD_WATCH
        //获取方向
        UIImageOrientation orientation = [self sd_imageOrientationFromImageData:data];
        //如果不是向上的，还需要再次生成图片
        if (orientation != UIImageOrientationUp) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:orientation];
        }
#endif
    }


    return image;
}

#if SD_UIKIT || SD_WATCH

/**
 根据图片数据获取图片的方向

 @param imageData 图片数据
 @return 方向
 */
+(UIImageOrientation)sd_imageOrientationFromImageData:(nonnull NSData *)imageData {
    //默认是向上的
    UIImageOrientation result = UIImageOrientationUp;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (imageSource) {
        //获取图片的属性列表
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (properties) {
            CFTypeRef val;
            int exifOrientation;
            //获取图片方向
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                result = [self sd_exifOrientationToiOSOrientation:exifOrientation];
            } // else - if it's not set it remains at up
            CFRelease((CFTypeRef) properties);
        } else {
            //NSLog(@"NO PROPERTIES, FAIL");
        }
        CFRelease(imageSource);
    }
    return result;
}

#pragma mark EXIF orientation tag converter
// Convert an EXIF image orientation to an iOS one.
// reference see here: http://sylvana.net/jpegcrop/exif_orientation.html

/**
 根据不同的值返回不同的图片方向

 @param exifOrientation 输入值
 @return 图片的方向
 */
+ (UIImageOrientation) sd_exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;

        case 3:
            orientation = UIImageOrientationDown;
            break;

        case 8:
            orientation = UIImageOrientationLeft;
            break;

        case 6:
            orientation = UIImageOrientationRight;
            break;

        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;

        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;

        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;

        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
}
#endif

- (nullable NSData *)sd_imageData {
    return [self sd_imageDataAsFormat:SDImageFormatUndefined];
}
/**
 根据指定的图片类型，把image对象转换为对应格式的data
 
 @param imageFormat 指定的image格式
 @return 返回data对象
 */
- (nullable NSData *)sd_imageDataAsFormat:(SDImageFormat)imageFormat {
    NSData *imageData = nil;
    if (self) {
#if SD_UIKIT || SD_WATCH
        int alphaInfo = CGImageGetAlphaInfo(self.CGImage);
        //是否有透明度
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        //只有png图片有alpha属性
        BOOL usePNG = hasAlpha;
        
        // the imageFormat param has priority here. But if the format is undefined, we relly on the alpha channel
        //是否是PNG类型的图片
        if (imageFormat != SDImageFormatUndefined) {
            usePNG = (imageFormat == SDImageFormatPNG);
        }
        //根据不同的图片类型获取到对应的图片data
        if (usePNG) {
            imageData = UIImagePNGRepresentation(self);
        } else {
            imageData = UIImageJPEGRepresentation(self, (CGFloat)1.0);
        }
#else
        NSBitmapImageFileType imageFileType = NSJPEGFileType;
        if (imageFormat == SDImageFormatGIF) {
            imageFileType = NSGIFFileType;
        } else if (imageFormat == SDImageFormatPNG) {
            imageFileType = NSPNGFileType;
        }
        
        imageData = [NSBitmapImageRep representationOfImageRepsInArray:self.representations
                                                             usingType:imageFileType
                                                            properties:@{}];
#endif
    }
    return imageData;
}


@end
