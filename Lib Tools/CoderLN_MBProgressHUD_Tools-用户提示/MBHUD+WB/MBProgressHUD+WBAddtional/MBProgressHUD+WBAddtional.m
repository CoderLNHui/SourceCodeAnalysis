/*
 * File:  MBProgressHUD+WB.m
 *
 * Framework: MBProgressHUD
 *「Public|Jshu_不知名开发者 | https://github.com/CoderLN」
 *
 * 该模块将系统化学习, 后续「坚持新增文章, 替换、补充文章内容」
 *
 * 🏃🏻‍♂️ ◕该模块将系统化学习，后续替换、补充文章内容 ~
 */

/************************************************************
 NOTE：
    Author：https://www.jianshu.com/p/992074d2016b
    GitHubUser：XXShao
    Blog：
 *************************************************************/


#import "MBProgressHUD+WBAddtional.h"
#import <objc/runtime.h>

NSTimeInterval const kMinShowTime = 1.f;
NSTimeInterval const KHideAfterDelayTime = 1.f;
NSTimeInterval const kActivityMinDismissTime = 0.5f;

/** << 是否显示蒙层 default is YES > */
static BOOL isNeedShowMaskLayer = YES;

@implementation MBProgressHUD (WBAddtional)

#pragma mark ------ < Mask Layer > ------
#pragma mark
+ (void)maskLayerEnabled:(BOOL)enabled {
    isNeedShowMaskLayer = enabled;
}

#pragma mark --------  Basic Method   --------
#pragma mark
+ (MBProgressHUD *)showActivityMessage:(NSString *)message
                                   toView:(UIView *)view {
    if (!view) view = [UIApplication sharedApplication].delegate.window;    /**  快速显示提示信息  */
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    /**  < 显示动画效果 >  */
    hud.animationType = MBProgressHUDAnimationZoom;
    /**  < 文字内容 >  */
    hud.label.text = message;
    /**  < 影藏后移除视图 >  */
    hud.removeFromSuperViewOnHide = YES;
    /**  中间方框背景色  */
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    /**  内容颜色  */
    hud.contentColor = [UIColor whiteColor];
    /**  < 最小显示时间 >  */
    hud.minShowTime = kActivityMinDismissTime;
    [self configMaskLayer:hud];
    return hud;
}

+ (void)showMessage:(NSString *)message
                toView:(UIView *)view
            completion:(MBProgressHUDCompletionBlock)completion{
    if (!view) view = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    hud.contentColor = [UIColor whiteColor];
    hud.backgroundView.color = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    [hud hideAnimated:YES afterDelay:KHideAfterDelayTime];
    hud.minShowTime = kMinShowTime;
    [self configMaskLayer:hud];
    hud.completionBlock = completion;
}

+ (void)show:(NSString *)text
           icon:(NSString *)icon
           view:(UIView *)view
     completion:(MBProgressHUDCompletionBlock)completion {
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = text;
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@",icon]];
    hud.customView = imageView;
    hud.removeFromSuperViewOnHide = YES;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    hud.contentColor = [UIColor whiteColor];
    hud.backgroundView.color = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    hud.minShowTime = kMinShowTime;
    [hud hideAnimated:YES afterDelay:KHideAfterDelayTime];
    hud.completionBlock = completion;
}

+ (void)showSuccess:(NSString *)success
                toView:(UIView *)view
            completion:(MBProgressHUDCompletionBlock)completion{
    [self show:success icon:@"success" view:view completion:completion];
}

+ (void)showError:(NSString *)error toView:(UIView *)view completion:(MBProgressHUDCompletionBlock)completion{
    [self show:error icon:@"error" view:view completion:completion];
}

+ (void)showInfo:(NSString *)info
             toView:(UIView *)view
         completion:(MBProgressHUDCompletionBlock)completion {
    [self show:info icon:@"MBHUD_Info" view:view completion:completion];
}

+ (void)showWarning:(NSString *)warning
                toView:(UIView *)view completion:(MBProgressHUDCompletionBlock)completion{
    [self show:warning icon:@"MBHUD_Warn" view:view completion:completion];
}

#pragma mark --------  Activity && Text  --------
#pragma mark
+ (MBProgressHUD *)showActivity {
    MBProgressHUD *hud = [self showActivityMessage:nil toView:nil];
    hud.square = YES;
    return hud;
}

+ (MBProgressHUD *)showActivityMessage:(NSString *)message {
    return [self showActivityMessage:message toView:nil];
}

#pragma mark --------  Text && Image  --------
#pragma mark
+ (void)showSuccess:(NSString *)success completion:(MBProgressHUDCompletionBlock)completion {
    [self hideHUD];
    [self showSuccess:success toView:nil completion:completion];
}

+ (void)showError:(NSString *)error completion:(MBProgressHUDCompletionBlock)completion{
    [self hideHUD];
    [self showError:error toView:nil completion:completion];
}

+ (void)showInfo:(NSString *)info completion:(MBProgressHUDCompletionBlock)completion{
    [self hideHUD];
    [self showInfo:info toView:nil completion:completion];
}

+ (void)showWarning:(NSString *)warning completion:(MBProgressHUDCompletionBlock)completion{
    [self hideHUD];
    [self showWarning:warning toView:nil completion:completion];
}

+ (void)showMessage:(NSString *)message completion:(MBProgressHUDCompletionBlock)completion{
    [self hideHUD];
    [self showMessage:message toView:nil completion:completion];
}

#pragma mark --------  Hide  --------
#pragma mark
+ (void)hideHUD {
    /** << 隐藏WindowHUD > */
    UIView *winView = (UIView*)[UIApplication sharedApplication].delegate.window;
    [self hideHUDForView:winView animated:YES];
    /** << 隐藏view的HUD > */
    [self hideHUDForView:[self getCurrentVc].view animated:YES];
}

+ (void)hideHUDForView:(UIView *)view {
    [self hideHUDForView:view animated:YES];
}

#pragma mark ------ < Event Response > ------
#pragma mark
+ (void)taped:(UITapGestureRecognizer *)sender {
    [self hideHUD];
}

#pragma mark --------  Private Method  --------
#pragma mark
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentWindowVc
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else
    {
        result = window.rootViewController;
    }
    return  result;
}

+ (UIViewController *)getCurrentVc
{
    UIViewController  *superVC = [[self class]  getCurrentWindowVc ];
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}

+ (void)addTapGestureRecognizer:(UIView *)view {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taped:)];
    [view addGestureRecognizer:tap];
}

+ (void)configMaskLayer:(MBProgressHUD *)hud {
    /** << 设置蒙层 > */
    if (isNeedShowMaskLayer) {
        /**  < 蒙层颜色 >  */
        hud.backgroundView.color = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    }
    /** << 添加单击手势 > */
    [self addTapGestureRecognizer:hud.backgroundView];
}

@end
