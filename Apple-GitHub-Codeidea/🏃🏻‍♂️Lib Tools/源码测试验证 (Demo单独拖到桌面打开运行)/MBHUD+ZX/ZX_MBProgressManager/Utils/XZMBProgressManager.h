//
//  XZMBProgressManager.h
//  知学360
//
//  Created by 赵祥 on 17/3/1.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

#define kXZMBProgressManager [XZMBProgressManager now]
#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

typedef NS_ENUM(NSUInteger, XZHUDMaskType) {
    XZHUDMaskType_None = 0,  //允许操作其他UI
    XZHUDMaskType_Clear,     //不允许操作
};

typedef NS_ENUM(NSUInteger, XZHUDInViewType) {
    XZHUDInViewType_KeyWindow = 0,  //UIApplication.KeyWindow
    XZHUDInViewType_CurrentView,    //CurrentViewController.view
};

typedef NS_ENUM(NSUInteger, XZHUDShowStateType) {
    XZProgressHUDTypeSuccess = 1,                   //成功
    XZProgressHUDTypeError,                     //失败
    XZProgressHUDTypeWarning,                   //警告
};

@interface XZMBProgressManager : NSObject

/**
 *简单的显示方法
 */
+ (MBProgressHUD *)XZ_showLoadingOrdinary:(NSString *)loadingString;

/**
 *简单的显示方法(加在指定view上)
 */
+ (MBProgressHUD *)XZ_showLoadingOrdinary:(NSString *)loadingString inView:(UIView *)inView;

/**
 *复杂的显示方式可以用此方法自定义
 */
+ (MBProgressHUD *)XZ_showHUDCustom:(void (^)(XZMBProgressManager *make))block;

/**
 *简单的改变进度条值
 */
+ (void)XZ_uploadProgressOrdinary:(CGFloat)progressValue;

/**
 *简单的改变进度条值(加在指定view上)
 */
+ (void)XZ_uploadProgressOrdinary:(CGFloat)progressValue inView:(UIView *)inView;

/**
 *复杂的改变进度条值可以用此方法自定义
 */
+ (void)XZ_uploadProgressValue:(void (^)(XZMBProgressManager *make))block;

/**
 *显示成功并自动消失
 */
+ (void)XZ_showHUDWithSuccess:(NSString *)showString;

/**
 *显示成功并自动消失(指定view上)
 */
+ (void)XZ_showHUDWithSuccess:(NSString *)showString inView:(UIView *)inView;

/**
 *显示错误并自动消失
 */
+ (void)XZ_showHUDWithError:(NSString *)showString;

/**
 *显示错误并自动消失(指定view上)
 */
+ (void)XZ_showHUDWithError:(NSString *)showString inView:(UIView *)inView;

/**
 *显示警告并自动消失
 */
+ (void)XZ_showHUDWithWarning:(NSString *)showString;

/**
 *显示警告并自动消失(指定view上)
 */
+ (void)XZ_showHUDWithWarning:(NSString *)showString inView:(UIView *)inView;

/**
 *显示纯文字并自动消失
 */
+ (void)XZ_showHUDWithText:(NSString *)showString;

/**
 *显示纯文字并自动消失(指定view上)
 */
+ (void)XZ_showHUDWithText:(NSString *)showString inView:(UIView *)inView;

/**
 *显示状态自定义（自动消失）
 */
+ (void)XZ_showHUDWithState:(void (^)(XZMBProgressManager *make))block;

/**
 *直接消失
 */
+ (void)dissmissHUDDirect;

/**
 *直接消失（指定view）
 */
+ (void)dissmissHUDDirectInView:(UIView *)inView;
+ (void)dissmissHUD:(void (^)(XZMBProgressManager *make))block;


#pragma mark - 下面的代码，就是设置保存相应的参数，返回self，
// self=self.message(@"文字")，分两步
// (1)第一步：self.message首先是返回一个block;
// (2)第二步：self=self.messageblock(@"文字") block里面是{ self.msg=@"文字"; 返回self }.
// 对应一般的语法就是：self=[self message:@"文字"];就是这么个意思
/**
 .showMessage(@"需要显示的文字")
 */
- (XZMBProgressManager *(^)(NSString *))message;

/**
 .animated(YES)是否动画，YES动画，NO不动画
 */
- (XZMBProgressManager *(^)(BOOL))animated;

/**
 .inView(view)
 有特殊需要inView的才使用，一般使用.inViewType()
 */
- (XZMBProgressManager *(^)(UIView *))inView;

/**
 .inViewType(inViewType) 指定的InView
 PSHUDInViewType_KeyWindow--KeyWindow,配合MaskType_Clear，就是全部挡住屏幕不能操作了，只能等消失
 PSHUDInViewType_CurrentView--当前的ViewController,配合MaskType_Clear,就是view不能操作，但是导航栏能操作（例如返回按钮）。
 */
- (XZMBProgressManager *(^)(XZHUDInViewType))inViewType;

/**
 .maskType(MaskType) HUD显示是否允许操作背后,
 PSHUDMaskType_None:允许
 PSHUDMaskType_Clear:不允许
 */
- (XZMBProgressManager *(^)(XZHUDMaskType))maskType;

/**
 .customView(view),设置customView
 注：只对.showMessage(@"")有效
 */
- (XZMBProgressManager *(^)(UIView *))customView;

/**
 .customView(iconName)，带有小图标、信息,
 iconName:小图标名字
 注：只对.showMessage(@"")有效
 */
- (XZMBProgressManager *(^)(NSString *))customIconName;

/**
 .afterDelay(2)消失时间，默认是2秒
 注：只对.showHandleMessageCalculators有效
 */
- (XZMBProgressManager *(^)(NSTimeInterval))afterDelay;

/** 
 *设置弹窗颜色
 */
- (XZMBProgressManager *(^)(UIColor *))hudColor;

/**
 *设置显示模式（菊花、进度条、纯文字、自定义）
 */
- (XZMBProgressManager *(^)(MBProgressHUDMode))hudMode;

/**
 *显示状态(失败，成功，警告)
 */
- (XZMBProgressManager *(^)(XZHUDShowStateType))hudState;

/**
 *进度条进度
 */
- (XZMBProgressManager *(^)(CGFloat))progressValue;

/**
 *设置自定义动画的持续时间
 */
- (XZMBProgressManager *(^)(CGFloat))animationDuration;

/**
 *设置自定义动画的图片数组
 */
- (XZMBProgressManager *(^)(NSArray *))imageArray;

/**
 *内容颜色
 */
- (XZMBProgressManager *(^)(UIColor *))contentColor;

/**
 *一张图时的图片名字
 */
- (XZMBProgressManager *(^)(NSString *))imageStr;
@end
