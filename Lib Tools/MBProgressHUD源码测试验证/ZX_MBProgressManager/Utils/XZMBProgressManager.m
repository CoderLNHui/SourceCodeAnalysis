//
//  XZMBProgressManager.m
//  知学360
//
//  Created by 赵祥 on 17/3/1.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import "XZMBProgressManager.h"

@interface XZMBProgressManager ()<MBProgressHUDDelegate>

//全都可以使用的参数
@property (nonatomic, strong) UIView *xz_inView;/**<hud加在那个view上*/
@property (nonatomic, assign) BOOL xz_animated;/**<是否动画显示、消失*/
@property (nonatomic, assign) XZHUDMaskType xz_maskType;/**<hud背后的view是否还可以操作*/

//只有showHandleMessage可以使用的属性
@property (nonatomic, strong) UIView *xz_customView;/**<自定义的view*/
@property (nonatomic, strong) NSString *xz_customIconName;/**<自定义的小图标*/
@property (nonatomic, strong) NSString *xz_message;/**<hud上面的文字*/
@property (nonatomic, assign) NSTimeInterval xz_afterDelay;/**<自动消失时间*/
@property (nonatomic, strong) UIColor *xz_HUDColor;/**自定义弹框颜色*/
@property (nonatomic, strong) UIColor *xz_ContentColor;/**自定义内容颜色*/
@property (nonatomic, assign) MBProgressHUDMode xz_hudMode;/**弹窗模式*/

/**
 *设置全局的HUD
 */
@property (nonatomic, assign) XZHUDShowStateType xz_hudState;

/**
 *进度条进度
 */
@property (nonatomic, assign) CGFloat xz_progressValue;

/**
 *自定义动画的持续时间
 */
@property (nonatomic, assign) CGFloat xz_animationDuration;

/**
 *自定义动画的图片数组
 */
@property (nonatomic, strong) NSArray *xz_imageArray;

/**
 *自定义的图片名称
 */
@property (nonatomic, strong) NSString *xz_imageStr;
@end


@implementation XZMBProgressManager

#pragma mark - 简单的显示方法
+ (MBProgressHUD *)XZ_showLoadingOrdinary:(NSString *)loadingString {
    return [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
        make.message(loadingString);
    }];
}

#pragma mark - 简单的显示方法(加在指定view上)
+ (MBProgressHUD *)XZ_showLoadingOrdinary:(NSString *)loadingString inView:(UIView *)inView {
    return [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
        make.inView(inView).message(loadingString);
    }];
}

#pragma mark - 复杂的显示方式可以用此方法自定义
+ (MBProgressHUD *)XZ_showHUDCustom:(void (^)(XZMBProgressManager *make))block {
    XZMBProgressManager *makeObj = [[XZMBProgressManager alloc] init];
    if (block) {
        block(makeObj);
    }
    __block MBProgressHUD *hud = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [XZMBProgressManager configHUDWithMakeObj:makeObj];
        
        switch (makeObj.xz_hudMode) {
            case MBProgressHUDModeIndeterminate:
                hud.minSize=CGSizeMake(90, 100);
                break;
            case MBProgressHUDModeDeterminate:
                
                break;
            case MBProgressHUDModeDeterminateHorizontalBar:
                
                break;
            case MBProgressHUDModeAnnularDeterminate:
                
                break;
            case MBProgressHUDModeCustomView: {
                if (makeObj.xz_imageArray.count > 0) {
                    UIImage *image = [[makeObj.xz_imageArray firstObject] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    
                    UIImageView* mainImageView= [[UIImageView alloc] initWithImage:image];
                    mainImageView.animationImages = makeObj.xz_imageArray;
                    [mainImageView setAnimationDuration:makeObj.xz_animationDuration];
                    [mainImageView setAnimationRepeatCount:0];
                    [mainImageView startAnimating];
                    hud.customView = mainImageView;
                }else if (makeObj.xz_imageStr.length > 0) {
                    
                    hud.customView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:makeObj.xz_imageStr] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
                }
                
                if (CGColorEqualToColor(makeObj.xz_HUDColor.CGColor, rgba(0, 0, 0, 0.7).CGColor)) {
                    hud.bezelView.color = rgba(255, 255, 255, 0.8);
                    hud.contentColor = [UIColor blackColor];
                }else {
                    hud.bezelView.color = makeObj.xz_HUDColor;
                    hud.contentColor = makeObj.xz_ContentColor;
                }
            }
                
                break;
            case MBProgressHUDModeText:
                
                break;
            default:
                break;
        }
    });
    return hud;
}

#pragma mark - 简单的改变进度条值
+ (void)XZ_uploadProgressOrdinary:(CGFloat)progressValue {
    [XZMBProgressManager XZ_uploadProgressValue:^(XZMBProgressManager *make) {
        make.progressValue(progressValue);
    }];
}

#pragma mark - 简单的改变进度条值(加在指定view上)
+ (void)XZ_uploadProgressOrdinary:(CGFloat)progressValue inView:(UIView *)inView {
    [XZMBProgressManager XZ_uploadProgressValue:^(XZMBProgressManager *make) {
        make.inView(inView).progressValue(progressValue);
    }];
}

#pragma mark - 复杂的改变进度条值可以用此方法自定义
+ (void)XZ_uploadProgressValue:(void (^)(XZMBProgressManager *make))block {
    XZMBProgressManager *makeObj = [[XZMBProgressManager alloc] init];
    if (block) {
        block(makeObj);
    }
    __block MBProgressHUD *hud = [MBProgressHUD HUDForView:makeObj.xz_inView];
    hud.progress = makeObj.xz_progressValue;
}

#pragma mark - 显示成功并自动消失
+ (void)XZ_showHUDWithSuccess:(NSString *)showString {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.hudState(XZProgressHUDTypeSuccess).message(showString);
    }];
}

#pragma mark - 显示成功并自动消失(指定view上)
+ (void)XZ_showHUDWithSuccess:(NSString *)showString inView:(UIView *)inView {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.inView(inView).hudState(XZProgressHUDTypeSuccess).message(showString);
    }];
}

#pragma mark - 显示错误并自动消失
+ (void)XZ_showHUDWithError:(NSString *)showString {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.hudState(XZProgressHUDTypeError).message(showString);
    }];
}

#pragma mark - 显示错误并自动消失(指定view上)
+ (void)XZ_showHUDWithError:(NSString *)showString inView:(UIView *)inView {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.inView(inView).hudState(XZProgressHUDTypeError).message(showString);
    }];
}

#pragma mark - 显示警告并自动消失
+ (void)XZ_showHUDWithWarning:(NSString *)showString {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.hudState(XZProgressHUDTypeWarning).message(showString);
    }];
}

#pragma mark - 显示警告并自动消失(指定view上)
+ (void)XZ_showHUDWithWarning:(NSString *)showString inView:(UIView *)inView {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.inView(inView).hudState(XZProgressHUDTypeWarning).message(showString);
    }];
}

#pragma mark - 显示纯文字并自动消失
+ (void)XZ_showHUDWithText:(NSString *)showString {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.message(showString);
    }];
}

#pragma mark - 显示纯文字并自动消失(指定view上)
+ (void)XZ_showHUDWithText:(NSString *)showString inView:(UIView *)inView {
    [XZMBProgressManager XZ_showHUDWithState:^(XZMBProgressManager *make) {
        make.inView(inView).message(showString);
    }];
}

#pragma mark - 显示状态自定义（自动消失）
+ (void)XZ_showHUDWithState:(void (^)(XZMBProgressManager *make))block {
    XZMBProgressManager *makeObj = [[XZMBProgressManager alloc] init];
    if (block) {
        block(makeObj);
    }
    __block MBProgressHUD *hud = [MBProgressHUD HUDForView:makeObj.xz_inView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!hud) {
            hud = [XZMBProgressManager configHUDWithMakeObj:makeObj];
        }
        hud.mode = MBProgressHUDModeCustomView;
        hud.detailsLabel.text=makeObj.xz_message;
        hud.userInteractionEnabled=makeObj.xz_maskType;
        
        NSString *imageStr = @"";
        if (makeObj.xz_hudState == XZProgressHUDTypeSuccess) {
            imageStr = @"hudSuccess";
        }else if (makeObj.xz_hudState == XZProgressHUDTypeError) {
            imageStr = @"hudError";
        }else if (makeObj.xz_hudState == XZProgressHUDTypeWarning) {
            imageStr = @"hudInfo";
        }else {
            hud.minSize=CGSizeMake(40,30);
        }
        hud.customView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:imageStr] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        [hud hideAnimated:makeObj.xz_animated afterDelay:makeObj.xz_afterDelay];
    });
    
}

#pragma mark - 直接消失
+ (void)dissmissHUDDirect {
    [XZMBProgressManager dissmissHUD:nil];
}

#pragma mark - 直接消失（指定view）
+ (void)dissmissHUDDirectInView:(UIView *)inView {
    [XZMBProgressManager dissmissHUD:^(XZMBProgressManager *make) {
        make.inView(inView);
    }];
}

+ (void)dissmissHUD:(void (^)(XZMBProgressManager *make))block {
    XZMBProgressManager *makeObj = [[XZMBProgressManager alloc] init];
    if (block) {
        block(makeObj);
    }
    __block MBProgressHUD *hud = [MBProgressHUD HUDForView:makeObj.xz_inView];
    [hud hideAnimated:makeObj.xz_animated];
}


+ (MBProgressHUD *)configHUDWithMakeObj:(XZMBProgressManager *)makeObj {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:makeObj.xz_inView animated:makeObj.xz_animated];
    hud.detailsLabel.text=makeObj.xz_message;
    hud.detailsLabel.font = [UIFont systemFontOfSize:16.0];
    hud.bezelView.color = makeObj.xz_HUDColor;
    hud.contentColor = makeObj.xz_ContentColor;
    hud.animationType = MBProgressHUDAnimationZoomOut;
    hud.userInteractionEnabled=makeObj.xz_maskType;
    hud.mode = makeObj.xz_hudMode;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}



- (instancetype)init {
    
    self=[super init];
    if (self) {//这里可以设置一些默认的属性
        _xz_inView=[UIApplication sharedApplication].keyWindow;
        _xz_maskType=XZHUDMaskType_Clear;
        _xz_afterDelay= 0.6;
        _xz_animated = YES;
        _xz_HUDColor = rgba(0, 0, 0, 0.7);
        _xz_ContentColor = [UIColor whiteColor];
        _xz_hudMode = MBProgressHUDModeIndeterminate;
    }
    return self;
}

- (XZMBProgressManager *(^)(UIView *))inView{
    return ^XZMBProgressManager *(id obj) {
        _xz_inView=obj;
        return self;
    };
}

- (XZMBProgressManager *(^)(UIView *))customView{
    return ^XZMBProgressManager *(id obj) {
        _xz_customView=obj;
        return self;
    };
}

- (XZMBProgressManager *(^)(NSString *))customIconName{
    return ^XZMBProgressManager *(id obj) {
        _xz_customIconName=obj;
        return self;
    };
}

- (XZMBProgressManager *(^)(XZHUDInViewType))inViewType{
    
    return ^XZMBProgressManager *(XZHUDInViewType inViewType) {
        
        if (inViewType==XZHUDInViewType_KeyWindow) {
            _xz_inView=[UIApplication sharedApplication].keyWindow;
        }else if(inViewType==XZHUDInViewType_CurrentView){
            _xz_inView=[[UIApplication sharedApplication].delegate window].rootViewController.view;
        }
        return self;
    };
}


- (XZMBProgressManager *(^)(BOOL))animated {
    return ^XZMBProgressManager *(BOOL animated) {
        _xz_animated=animated;
        return self;
    };
}

- (XZMBProgressManager *(^)(XZHUDMaskType))maskType{
    return ^XZMBProgressManager *(XZHUDMaskType maskType) {
        _xz_maskType=maskType;
        return self;
    };
}

- (XZMBProgressManager *(^)(NSTimeInterval))afterDelay{
    return ^XZMBProgressManager *(NSTimeInterval afterDelay) {
        _xz_afterDelay=afterDelay;
        return self;
    };
}

- (XZMBProgressManager *(^)(NSString *))message {
    
    return ^XZMBProgressManager *(NSString *msg) {
        _xz_message=msg;
        return self;
    };
}

- (XZMBProgressManager *(^)(UIColor *))hudColor {
    return ^XZMBProgressManager *(UIColor *hudColor) {
        _xz_HUDColor = hudColor;
        return self;
    };
}

- (XZMBProgressManager *(^)(MBProgressHUDMode))hudMode {
    return ^XZMBProgressManager *(MBProgressHUDMode hudMode) {
        _xz_hudMode = hudMode;
        return self;
    };
}

- (XZMBProgressManager *(^)(XZHUDShowStateType))hudState {
    return ^XZMBProgressManager *(XZHUDShowStateType hudState) {
        _xz_hudState = hudState;
        return self;
    };
}

- (XZMBProgressManager *(^)(CGFloat))progressValue {
    return ^XZMBProgressManager *(CGFloat value) {
        _xz_progressValue = value;
        return self;
    };
}

- (XZMBProgressManager *(^)(CGFloat))animationDuration {
    return ^XZMBProgressManager *(CGFloat duration) {
        _xz_animationDuration = duration;
        return self;
    };
}

- (XZMBProgressManager *(^)(NSArray *))imageArray {
    return ^XZMBProgressManager *(NSArray *imageArray) {
        _xz_imageArray = [NSArray arrayWithArray:imageArray];
        return self;
    };
}

- (XZMBProgressManager *(^)(UIColor *))contentColor {
    return ^XZMBProgressManager *(UIColor *contentColor) {
        _xz_ContentColor = contentColor;
        return self;
    };
}

- (XZMBProgressManager *(^)(NSString *))imageStr {
    return ^XZMBProgressManager *(NSString *imageString) {
        _xz_imageStr = imageString;
        return self;
    };
}
@end
