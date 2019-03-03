//
//  UIImage+GIF.m
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (GIF)

//把图片的二进制数据转换为图片（GIF）
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    
    //如果传入的二进制数据为空，则直接返回nil
    if (!data) {
        return nil;
    }
    
     // 创建图像源
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);

    // 获取图片帧数
    size_t count = CGImageSourceGetCount(source);

    //初始化animatedImage
    UIImage *animatedImage;

    //如果图片帧数小于等于1，那么就直接把二进制数据转换为图片，并返回图片
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        //创建可变的空的图片数组
        NSMutableArray *images = [NSMutableArray array];
        
        //初始化动画播放时间为0
        NSTimeInterval duration = 0.0f;

        // 遍历并且提取所有的动画帧
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);

            // 累加动画时长
            duration += [self sd_frameDurationAtIndex:i source:source];

            // 将图像添加到动画数组
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            //释放操作
            CGImageRelease(image);
        }
        
        //计算动画时间
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        // 建立可动画图像
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    //释放操作
    CFRelease(source);

    return animatedImage;
}

//获得播放的时间长度
+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    //获得图像的属性（图像源，索引）
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    //桥接转换为NSDictionary类型
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    //取出图像属性里面kCGImagePropertyGIFDictionary这个KEY对应的值，即GIF属性
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    //得到延迟时间
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        //把延迟时间转换为浮点数类型
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        //如果上面获得的延迟时间为空，则换另外一种方式获得
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }

    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    //处理延迟时间
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    //释放操作
    CFRelease(cfFrameProperties);
    return frameDuration;
}

//处理GIF图片
+ (UIImage *)sd_animatedGIFNamed:(NSString *)name {
    //获得scale
    CGFloat scale = [UIScreen mainScreen].scale;

    if (scale > 1.0f) {
        //根据图片的名称拼接bundle全路径
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];

        //加载指定路径的图片（二进制数据）
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];

        //如果data不为空，则直接调用sd_animatedGIFWithData返回一张可动画的图片
        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }
        //下面的处理和上面一样
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];

        data = [NSData dataWithContentsOfFile:path];

        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }

        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];

        NSData *data = [NSData dataWithContentsOfFile:path];

        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }

        return [UIImage imageNamed:name];
    }
}

//缩放|裁剪...
- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size {
    //如果尺寸相等或者是为0则直接返回
    if (CGSizeEqualToSize(self.size, size) || CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }

    CGSize scaledSize = size;
    CGPoint thumbnailPoint = CGPointZero;

    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;

    if (widthFactor > heightFactor) {
        thumbnailPoint.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor) {
        thumbnailPoint.x = (size.width - scaledSize.width) * 0.5;
    }

    //初始化可变的缩放图像数组
    NSMutableArray *scaledImages = [NSMutableArray array];

    //遍历图片
    for (UIImage *image in self.images) {
        //开启图像上下文
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        //画图，把image绘制到指定的位置
        [image drawInRect:CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledSize.width, scaledSize.height)];
        //根据当前图形上下文获得一张新的图片
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        //把新图片添加到图像数组
        [scaledImages addObject:newImage];

        //关闭图形上下文
        UIGraphicsEndImageContext();
    }
    
    //建立可动画的图像并返回
    return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
}

@end
