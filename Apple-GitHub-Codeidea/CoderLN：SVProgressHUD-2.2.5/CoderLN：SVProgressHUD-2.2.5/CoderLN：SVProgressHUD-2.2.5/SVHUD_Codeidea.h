//
//  SVProgressHUD_Codeidea
//  Version 2.2.5
//
//  About ME『Public：Codeidea / https://githubidea.github.io』.
//  Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.

//

#pragma mark - ↑
#pragma mark - SVProgressHUD 用户提示，Version = 2.2.5
/**
 SVProgressHUD 用户提示，Version = 2.2.5

 官方释义：
 SVProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS.

 SVHUD 是一个清净和易用的 HUD，用于显示iOS和tvOS上正在进行的任务.
 */



 
#pragma mark - ↑
#pragma mark - SVHUD 组成(层次结构)
/**
 SVHUD 组成(层次结构)
 
 
 
 
 
 */







#pragma mark - ↑
#pragma mark - 总结笔记

1、
#pragma mark - + Show 显示方法工作流程
+ (void)show;// 显示白底黑色圆圈
+ (void)showWithStatus:(nullable NSString*)status;// 显示白底黑色圆圈+提示文本
+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress status:(nullable NSString*)status;

#pragma mark - + Show 显示核心方法实现原理；内部最终会调用 - fadeIn:(id)data
- (void)showProgress:(float)progress status:(NSString*)status;


2、
#pragma mark - + Show 展示图片方法工作流程
+ (void)showInfoWithStatus:(nullable NSString*)status;
+ (void)showSuccessWithStatus:(nullable NSString*)status;
+ (void)showErrorWithStatus:(nullable NSString*)status;
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status;

#pragma mark - + Show 展示图片核心方法实现原理；内部最终会调用 - fadeIn:(id)data
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration;




3、
#pragma mark - + dismiss 隐藏方法工作流程
+ (void)dismiss;
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion;
+ (void)dismissWithDelay:(NSTimeInterval)delay;// 多少秒后隐藏hud
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;// 多少秒后隐藏hud，且隐藏后的回调

#pragma mark - + dismiss 隐藏核心方法实现原理
- (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion;









#pragma mark - ↑
#pragma mark - SVHUD 实现原理(工作流程)
/**
 SVHUD 工作流程
 
 
 
 
 
 */











#pragma mark - ↑
#pragma mark - SVHUD 基本使用

// 最简单的方式
- (void)svhud
{
    [SVProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}



// 设置多少秒后隐藏
[SVProgressHUD dismissWithDelay:3.0 completion:^{
    NSLog(@"设置了 3 秒后隐藏");
}];




























