//
//  SVProgressHUD+WB_Addtional.h
//  WB_SVPManager
//
//  Created by Admin on 2017/8/11.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "SVProgressHUD.h"
UIKIT_EXTERN NSTimeInterval const kMinimumDismissTimeInterval;
UIKIT_EXTERN NSTimeInterval const kMaxnumDismissTimeInterval;
UIKIT_EXTERN NSTimeInterval const kDelayShowTimeInterval;

NS_ASSUME_NONNULL_BEGIN
@interface SVProgressHUD (WBAddtional)

+ (void)defaultConfig;

/**  < 显示内容 >  */
+ (void)wb_showInfoWithStatus:(NSString *)status
                   completion:(SVProgressHUDDismissCompletion)completion;
/**  < 显示成功提示 >  */
+ (void)wb_showSuccessWithStatus:(NSString *)status
                      completion:(SVProgressHUDDismissCompletion)completion;
/**  < 显示错误提示 >  */
+ (void)wb_showErrorWithStatus:(NSString *)status
                    completion:(SVProgressHUDDismissCompletion)completion;
/**  < 显示提示文字 >  */
+ (void)wb_showTextWithStatus:(NSString *)status
                    completion:(SVProgressHUDDismissCompletion)completion;

#pragma mark -- Delay Show
#pragma mark
+ (void)wb_delayShowInfoWithStatus:(NSString *)status
                        completion:(SVProgressHUDDismissCompletion)completion;

+ (void)wb_delayShowSuccessWithStatus:(NSString *)status
                           completion:(SVProgressHUDDismissCompletion)completion;

+ (void)wb_delayShowErrorWithStatus:(NSString *)status
                         completion:(SVProgressHUDDismissCompletion)completion;

+ (void)wb_delayshowTextWithStatus:(NSString *)status
                        completion:(SVProgressHUDDismissCompletion)completion;

@end
NS_ASSUME_NONNULL_END
