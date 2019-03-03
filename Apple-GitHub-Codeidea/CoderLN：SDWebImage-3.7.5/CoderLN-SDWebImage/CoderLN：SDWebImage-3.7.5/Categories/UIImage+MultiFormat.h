//
//  UIImage+MultiFormat.h
//  SDWebImage
//
//  Created by Olivier Poitrey on 07/06/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MultiFormat)

//把二进制数据转换为对应的图片
+ (UIImage *)sd_imageWithData:(NSData *)data;

@end
