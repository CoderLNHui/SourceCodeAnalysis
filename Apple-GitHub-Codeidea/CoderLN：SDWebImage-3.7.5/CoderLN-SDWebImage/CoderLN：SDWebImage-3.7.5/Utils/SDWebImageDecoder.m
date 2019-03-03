/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDecoder.h"

@implementation UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    // while downloading huge amount of images
    // autorelease the bitmap context
    // and all vars to help system to free memory
    // when there are memory warning.
    // on iOS7, do not forget to call
    // [[SDImageCache sharedImageCache] clearMemory];
    
    //在iOS7中，别忘了调用[[SDImageCache sharedImageCache] clearMemory]方法
    @autoreleasepool{
        // do not decode animated images
        //不要解码动画图像,直接返回
        if (image.images) { return image; }
    
        //CGImageRef是定义在QuartzCore框架中的一个结构体指针，用C语言编写。其定义在CGImage.h
        //这个结构用来创建像素位图，可以通过操作存储的像素位来编辑图片
        CGImageRef imageRef = image.CGImage;
    
        //获得图片的透明度信息
        CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
        BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                         alpha == kCGImageAlphaLast ||
                         alpha == kCGImageAlphaPremultipliedFirst ||
                         alpha == kCGImageAlphaPremultipliedLast);
    
        //如果为nil 直接返回
        if (anyAlpha) { return image; }
    
        //获取宽度像素
        size_t width = CGImageGetWidth(imageRef);
        //获取高度像素
        size_t height = CGImageGetHeight(imageRef);
    
        // current
        //获得颜色的RGB数值
        CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
        
        bool unsupportedColorSpace = (imageColorSpaceModel == 0 || imageColorSpaceModel == -1 || imageColorSpaceModel == kCGColorSpaceModelCMYK || imageColorSpaceModel == kCGColorSpaceModelIndexed);
        if (unsupportedColorSpace)
            colorspaceRef = CGColorSpaceCreateDeviceRGB();
    
        //创建位图上下文
        /*
         第一个参数data：指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
         第二个参数width：bitmap的宽度,单位为像素
         第三个参数height：bitmap的高度,单位为像素
         第四个参数bitsPerComponent：内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8
         第五个参数bytesPerRow：bitmap的每一行在内存所占的比特数
         第六个参数space：bitmap上下文使用的颜色空间
         第七个参数bitmapInfo：指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串
         */
        CGContextRef context = CGBitmapContextCreate(NULL, width,
                                                     height,
                                                     CGImageGetBitsPerComponent(imageRef),
                                                     0,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        //绘图（上下文，rect和imageRef）
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        
        CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(context);
        //该方面使用一个CGImageRef创建UIImage,指定缩放的倍数和旋转的方向
        //当scale为1的时候，表示新创建的图像将和原图像尺寸一摸一样
        //orientation指定图像的绘制方向
        UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha scale:image.scale orientation:image.imageOrientation];
    
        //release对象
        if (unsupportedColorSpace)
            CGColorSpaceRelease(colorspaceRef);
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithAlpha);
        
        return imageWithAlpha;
    }
}

@end
