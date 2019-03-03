//
//  SVProgressHUD+WB_Addtional.m
//  WB_SVPManager
//
//  Created by Admin on 2017/8/11.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "SVProgressHUD+WBAddtional.h"

NSTimeInterval const kMinimumDismissTimeInterval = 2.f;
NSTimeInterval const kMaxnumDismissTimeInterval = 3.f;
NSTimeInterval const kDelayShowTimeInterval = 1.f;

@implementation SVProgressHUD (WBAddtional)

+ (void)defaultConfig {
    [self setMinimumDismissTimeInterval:kMinimumDismissTimeInterval];
    [self setMaximumDismissTimeInterval:kMaxnumDismissTimeInterval];
}

+ (void)wb_showInfoWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    [self showInfoWithStatus:status];
    [self setDefaultStyle:SVProgressHUDStyleLight];
    [self setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [self dismissWithDelay:kMinimumDismissTimeInterval completion:completion];
}

+ (void)wb_showSuccessWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    [self showSuccessWithStatus:status];
    [self setDefaultStyle:SVProgressHUDStyleLight];
    [self dismissWithDelay:kMinimumDismissTimeInterval completion:completion];
}

+ (void)wb_showErrorWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    [self showErrorWithStatus:status];
    [self setDefaultStyle:SVProgressHUDStyleLight];
    [self setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [self dismissWithDelay:kMinimumDismissTimeInterval completion:completion];
}

+ (void)wb_showTextWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    [self showImage:nil status:status];
    [self setDefaultStyle:SVProgressHUDStyleDark];
    [self setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self dismissWithDelay:kMinimumDismissTimeInterval completion:completion];
}

#pragma mark -- Delay Show
#pragma mark
+ (void)wb_delayShowInfoWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayShowTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self wb_showInfoWithStatus:status completion:completion];
    });
}

+ (void)wb_delayShowErrorWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayShowTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self wb_showErrorWithStatus:status completion:completion];
    });
}

+ (void)wb_delayShowSuccessWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayShowTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self wb_showSuccessWithStatus:status completion:completion];
    });
}

+ (void)wb_delayshowTextWithStatus:(NSString *)status completion:(SVProgressHUDDismissCompletion)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayShowTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self wb_showTextWithStatus:status completion:completion];
    });
}

@end
