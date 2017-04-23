//
//  UIImage+GIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

//传入Gif图像的名称，得到一个可动画的图像
+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;

//传入Gif图像的二进制数据，得到一个可动画的图像
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;

- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
