//
//  MainViewController.m
//  SDWebImage4.X源码阅读201704
//
//  Created by huangchengdu on 17/4/27.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "MainViewController.h"
#import "NSData+ImageContentType.h"
#import "SDWebImageCompat.h"
#import "SDWebImageDecoder.h"
#import "Config.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/**
 根据图片数据获取图片类型

 */
- (IBAction)getImageType:(id)sender {
    NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rock.gif" ofType:nil]];
    SDImageFormat formate = [NSData sd_imageFormatForImageData:imageData];
    NSString *message = [NSString stringWithFormat:@"%d",formate];
    showMessage(message,self);
}


/**
 获取一张图片对应的两倍或者三倍屏幕对应的图片

 */
- (IBAction)getScaleImage:(id)sender {
    UIImage *sourceImage = [UIImage imageNamed:@"2.png"];
    UIImage *dis2ScaleImage = SDScaledImageForKey(@"dist@2x.png", sourceImage);
    UIImage *dis3ScaleImage = SDScaledImageForKey(@"dist@3x.png", sourceImage);
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //NSLog(@"document:%@",documentPath);
    NSString *path1 = [documentPath stringByAppendingPathComponent:@"dist.png"];
    [UIImagePNGRepresentation(sourceImage) writeToFile:path1 atomically:YES];
    NSString *path2 = [documentPath stringByAppendingPathComponent:@"dist@2x.png"];
    [UIImagePNGRepresentation(dis2ScaleImage) writeToFile:path2 atomically:YES];
    NSString *path3 = [documentPath stringByAppendingPathComponent:@"dist@3x.png"];
    [UIImagePNGRepresentation(dis3ScaleImage) writeToFile:path3 atomically:YES];
}

/**
 解压缩图片

 @param sender 解压缩图片
 */
- (IBAction)unZipImage:(id)sender {
    UIImage *sourceImage = [UIImage imageNamed:@"2.png"];
    UIImage *distImage = [UIImage decodedAndScaledDownImageWithImage:sourceImage];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path1 = [documentPath stringByAppendingPathComponent:@"distImage.png"];
    [UIImagePNGRepresentation(distImage) writeToFile:path1 atomically:YES];
    NSString *path2 = [documentPath stringByAppendingPathComponent:@"sourceImage.png"];
    [UIImagePNGRepresentation(sourceImage) writeToFile:path2 atomically:YES];
    
}



@end
