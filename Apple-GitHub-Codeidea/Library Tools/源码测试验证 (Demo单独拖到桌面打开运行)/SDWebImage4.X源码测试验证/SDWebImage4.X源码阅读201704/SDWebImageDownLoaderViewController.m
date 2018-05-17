//
//  SDWebImageDownLoaderViewController.m
//  SDWebImage4.X源码阅读201704
//
//  Created by huangchengdu on 17/5/2.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "SDWebImageDownLoaderViewController.h"
#import "SDWebImageDownloader.h"
//13MB。测试图片
static NSString *const url = @"https://www.tuchuang001.com/images/2017/05/02/1.png";
@interface SDWebImageDownLoaderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,strong)SDWebImageDownloader *downloader;
@property(nonatomic,strong)SDWebImageDownloadToken *downloadToken;
@end

@implementation SDWebImageDownLoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloader = [SDWebImageDownloader sharedDownloader];
}

/**
 开始下载
 */
- (IBAction)start:(id)sender {
    __weak __typeof__(self) wSelf = self;
     self.downloadToken = [self.downloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderIgnoreCachedResponse|SDWebImageDownloaderAllowInvalidSSLCertificates progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL){
        NSLog(@"下载了:%ld---总共:%ld",(long)receivedSize,(long)expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        __typeof(wSelf) strongSelf = wSelf;
        strongSelf.imageView.image = image;
    }];
}
/**
 取消下载
 */
- (IBAction)cancel:(id)sender {
    [self.downloader cancel:self.downloadToken];
}

/**
 挂起
 */
- (IBAction)suspend:(id)sender {
    [self.downloader setSuspended:YES];
}

-(void)dealloc{
    

}

@end
