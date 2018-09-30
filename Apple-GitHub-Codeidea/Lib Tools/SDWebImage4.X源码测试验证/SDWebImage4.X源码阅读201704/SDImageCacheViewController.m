//
//  SDImageCacheViewController.m
//  SDWebImage4.X源码阅读201704
//
//  Created by huangchengdu on 17/4/28.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "SDImageCacheViewController.h"
#import "SDImageCache.h"
#import "Config.h"

NSString *key = @"SDWebImageClassDiagram.png";
@interface SDImageCacheViewController ()
@property(nonatomic,strong)SDImageCache *imageCache;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SDImageCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_imageCache) {
        _imageCache = [SDImageCache sharedImageCache];
    }
}

/**
 缓存一张图片的过程

 @param sender nil
 */
- (IBAction)clickButton1:(id)sender {

    [self.imageCache storeImage:[UIImage imageNamed:key] forKey:key toDisk:YES completion:^{
        showMessage(@"回调", self);
    }];
}

/**
 从缓存查询图片的过程

 @param sender nil
 */
- (IBAction)clickButton2:(id)sender {
    self.imageView.image = nil;
    [self.imageCache queryCacheOperationForKey:key done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        NSString *type;
        if (cacheType == SDImageCacheTypeMemory) {
            type = @"内存缓存";
        }else if (cacheType == SDImageCacheTypeDisk){
            type = @"磁盘缓存";
        }else{
            type = @"没有缓存";
        }
        showMessage(type, self);
        self.imageView.image = [UIImage imageWithData:data];
    }];
}

/**
 模拟应用进入后台，清除缓存数据

 @param sender nil
 */
- (IBAction)clickButton3:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    
}
/*
 发送内存警告。清除内存缓存
 */
- (IBAction)clickButton4:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
- (IBAction)clickButton5:(id)sender {
//    SDImageCacheConfig *config = [[SDImageCacheConfig alloc]init];
//    config.maxCacheSize = 0.001;
//    self.imageCache.config = config;
}


@end
