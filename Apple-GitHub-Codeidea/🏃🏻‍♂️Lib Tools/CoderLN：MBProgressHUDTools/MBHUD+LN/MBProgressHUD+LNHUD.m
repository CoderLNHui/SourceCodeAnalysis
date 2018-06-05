/*
 * File:  MBProgressHUD+LNHUD.m
 *
 * Framework: MBProgressHUD
 *
 * About ME『Public：Codeidea / https://githubidea.github.io』.
 * Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.
 *
 * 🏃🏻‍♂️ ◕该模块将系统化学习，后续替换、补充文章内容 ~
 */

#import "MBProgressHUD+LNHUD.h"

// 显示几秒后消失
NSTimeInterval const hideAfterDelayTime = 3.0f;

@implementation MBProgressHUD (LNHUD)


#pragma mark - ↑
#pragma mark - 显示提示框

+ (MBProgressHUD *)showPromptBoxType:(ShowPromptBoxType)type icon:(UIImage *)iconImg text:(NSString *)text toView:(UIView *)view maskLayer:(BOOL)enabled completion:(MBProgressHUDCompletionBlock)completion
{
    switch (type) {
            // 成功提示
        case ShowPromptBoxTypeSuccess:
            return [self showText:text icon:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@",@"success@2x.png"]] view:view maskLayerEnabled:enabled mode:MBProgressHUDModeCustomView completion:completion];
            break;
            // 失败提示
        case ShowPromptBoxTypeError:
             return [self showText:text icon:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@",@"error@2x.png"]] view:view maskLayerEnabled:enabled mode:MBProgressHUDModeCustomView completion:completion];
            break;
            // 加载提示
        case ShowPromptBoxTypeMessage:
        {
            return [self showText:text icon:nil view:view maskLayerEnabled:enabled mode:MBProgressHUDModeIndeterminate completion:completion];
        }
            break;
            // GIF
        case ShowPromptBoxTypeGIF:
        {
            return [self showText:text icon:iconImg view:view maskLayerEnabled:enabled mode:MBProgressHUDModeCustomView completion:completion];
        }
            break;
            // 文本提示
        case ShowPromptBoxTypeText:
        {
            return [self showText:text icon:nil view:view maskLayerEnabled:enabled mode:MBProgressHUDModeText completion:completion];
        }
 
        default:
            break;
    }
    return nil;
}





+ (MBProgressHUD *)showText:(NSString *)text icon:(UIImage *)iconImg view:(UIView *)view maskLayerEnabled:(BOOL)enabled mode:(MBProgressHUDMode)mode completion:(MBProgressHUDCompletionBlock)completion
{
    // 快速显示提示信息
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    
    hud.animationType = MBProgressHUDAnimationZoom;// 动画类型
    hud.mode = mode;// 显示模式
    hud.removeFromSuperViewOnHide = YES;// 隐藏时候从父控件中移除
    
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.85f];// 中间提示框视图颜色
    //hud.label.textColor = [UIColor whiteColor];// 文本颜色
    hud.contentColor = [UIColor whiteColor];// 提示框内容颜色
    hud.label.font = [UIFont systemFontOfSize:16.f];
    [self configMaskLayer:hud maskLayerEnabled:enabled];// hud遮罩
    hud.completionBlock = completion;// 完成后回调
    
    hud.label.text = text;// 文本
    hud.customView = [[UIImageView alloc] initWithImage:iconImg];// 自定义图片(加载bundle中的图片)
 
    if (!hud.isHidden) [hud hideAnimated:YES afterDelay:hideAfterDelayTime];// 显示几秒后消失
    return hud;
}

// hud遮罩
+ (void)configMaskLayer:(MBProgressHUD *)hud maskLayerEnabled:(BOOL)enabled
{
    if (enabled) {
        hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    }
    // 添加遮罩点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHUDBackView)];
    [hud.bezelView addGestureRecognizer:tap];
}

+ (void)tapHUDBackView
{
    [self hideHUD];
}




#pragma mark - ↑
#pragma mark - 隐藏提示框

+ (void)hideHUD
{
    [self hideHUDForView:nil completion:nil];
}

+ (void)hideHUDForView:(UIView *)view completion:(MBProgressHUDCompletionBlock)completion
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];

    [self hideHUDForView:view animated:YES];
}







 

@end
