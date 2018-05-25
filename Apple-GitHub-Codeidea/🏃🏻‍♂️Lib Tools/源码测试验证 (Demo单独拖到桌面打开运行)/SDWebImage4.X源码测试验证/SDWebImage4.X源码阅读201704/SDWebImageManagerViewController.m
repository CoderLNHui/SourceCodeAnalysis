//
//  SDWebImageManagerViewController.m
//  SDWebImage4.X源码阅读201704
//
//  Created by huangchengdu on 17/4/29.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "SDWebImageManagerViewController.h"
#import "SDWebImageManager.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImageView+WebCache.h"

static NSString *url = @"http://i1.piimg.com/4851/059582e7cf7a7f43.png";
//大图。6.1MB。
static NSString *bigUrl = @"https://www.tuchuang001.com/images/2017/04/30/11.png";
//gif图片
static NSString *gifUrl = @"https://www.tuchuang001.com/images/2017/05/01/QQ20150326140155.gif";
@interface SDWebImageManagerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *animateImageView;

@end

@implementation SDWebImageManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 图片加载以后,在图片解压缩之前。是否做处理

 @param sender nil
 */
- (IBAction)clickButton1:(id)sender {
    self.imageView.image = nil;
    SDWebImageOptions type;
    //图片处理以后，再解压缩。然后再缓存
    /*
     通过是否设置SDWebImageScaleDownLargeImages属性。我们发现缓存的图片大小不同。如果设置了，则图片大小有11k。没有设置，则大小只有7k
     */
    if (true) {
        type = SDWebImageScaleDownLargeImages;
    }
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:bigUrl] options:type progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"收到：%d---总共：%d",receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        self.imageView.image = image;
    }];

}


/**
 同一个请求。第二次待上cookie

 @param sender <#sender description#>
 */
- (IBAction)clickButton2:(id)sender {
    self.imageView.image = nil;
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"收到：%d---总共：%d",receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        self.imageView.image = image;
    }];
}

/**
 HTTPS处理.忽略SSL证书

 @param sender <#sender description#>
 */
- (IBAction)clickButton3:(id)sender {
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:bigUrl] options:SDWebImageAllowInvalidSSLCertificates progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"收到：%d---总共：%d",receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        self.imageView.image = image;
    }];
}


/**
应用进入后台下载处理
 
 @param sender nil
 */
- (IBAction)clickButton4:(id)sender {
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:bigUrl] options:SDWebImageAllowInvalidSSLCertificates|SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"收到：%d---总共：%d",receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        self.imageView.image = image;
    }];
}


/**
gif动态图片处理
 
 @param sender nil
 */
- (IBAction)clickButton5:(id)sender {
    [self.animateImageView sd_setImageWithURL:[NSURL URLWithString:gifUrl] placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates|SDWebImageTransformAnimatedImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"下载完成");
    }];
    
}

@end
