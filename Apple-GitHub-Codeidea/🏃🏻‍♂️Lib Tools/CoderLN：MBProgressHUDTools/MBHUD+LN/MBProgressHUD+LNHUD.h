/*
 * File:  MBProgressHUD+LNHUD.h
 *
 * Framework: MBProgressHUD
 *
 * About ME『Public：Codeidea / https://githubidea.github.io』.
 * Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.
 *
 * 🏃🏻‍♂️ ◕该模块将系统化学习，后续替换、补充文章内容 ~
 
 MBProgressHUD 用户提示
 1.纯文本
 2.纯图片(image+gif)
 3.文本+图片(image+gif)
 */

#import "MBProgressHUD.h"

typedef NS_ENUM(NSUInteger, ShowPromptBoxType) {
    ShowPromptBoxTypeSuccess = 0,// 成功显示
    ShowPromptBoxTypeError,// 失败显示
    ShowPromptBoxTypeMessage,// 加载中显示
    ShowPromptBoxTypeGIF,// Gif显示
    ShowPromptBoxTypeText,// 纯文本显示
};

typedef void (^MBProgressHUDBlock)(MBProgressHUD *hud);

@interface MBProgressHUD (LNHUD)


/**
 * 显示 文本+图片(image+gif) 提示框
 *
 * @param type          提示框类型
 * @param view          添加到哪个View上
 * @param enabled       是否添加遮罩
 * @param completion    完成后回调
 */
+ (MBProgressHUD *)showPromptBoxType:(ShowPromptBoxType)type icon:(UIImage *)iconImg text:(NSString *)text toView:(UIView *)view maskLayer:(BOOL)enabled completion:(MBProgressHUDCompletionBlock)completion;


/**
 * 隐藏提示框
 *
 * @param view          添加到哪个View上
 * @param completion    完成后回调
 */
+ (void)hideHUDForView:(UIView *)view completion:(MBProgressHUDCompletionBlock)completion;
+ (void)hideHUD;




@end
