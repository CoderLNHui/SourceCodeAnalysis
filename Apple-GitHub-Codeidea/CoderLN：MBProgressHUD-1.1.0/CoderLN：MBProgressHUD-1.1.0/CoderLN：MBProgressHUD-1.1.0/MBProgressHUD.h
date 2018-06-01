//
//  MBProgressHUD.h
//  Version 1.1.0
//  Created by Matej Bukovinski on 2.4.09.
//
//  About ME『Public：Codeidea / https://githubidea.github.io』.
//  Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2009-2016 Matej Bukovinski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


            
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class MBBackgroundView;
@protocol MBProgressHUDDelegate;


extern CGFloat const MBProgressMaxOffset;

#pragma mark - ↑
#pragma mark - NS_ENUM

#pragma mark - 显示模式
typedef NS_ENUM(NSInteger, MBProgressHUDMode) {
    /// UIActivityIndicatorView.默认模式, 系统自带的指示器
    MBProgressHUDModeIndeterminate,
    /// A round, pie-chart like, progress view.圆形饼图
    MBProgressHUDModeDeterminate,
    /// Horizontal progress bar.水平进度条
    MBProgressHUDModeDeterminateHorizontalBar,
    /// Ring-shaped progress view.圆环
    MBProgressHUDModeAnnularDeterminate,
    /// Shows a custom view.自定义视图
    MBProgressHUDModeCustomView,
    /// Shows only labels.只显示文字
    MBProgressHUDModeText
};


#pragma mark - 动画效果
typedef NS_ENUM(NSInteger, MBProgressHUDAnimation) {
    /// Opacity animation默认效果，只有透明度变化
    MBProgressHUDAnimationFade,
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)透明度变化 + 形变 (放大时出现缩小消失)
    MBProgressHUDAnimationZoom,
    /// Opacity + scale animation (zoom out style)透明度变化 + 形变 (缩小)
    MBProgressHUDAnimationZoomOut,
    /// Opacity + scale animation (zoom in style)透明度变化 + 形变 (放大)
    MBProgressHUDAnimationZoomIn
};


#pragma mark - 背景样式
typedef NS_ENUM(NSInteger, MBProgressHUDBackgroundStyle) {
    /// Solid color background
    MBProgressHUDBackgroundStyleSolidColor,
    /// UIVisualEffectView or UIToolbar.layer background view
    MBProgressHUDBackgroundStyleBlur
};


#pragma mark - 完成回调Block
typedef void (^MBProgressHUDCompletionBlock)(void);


NS_ASSUME_NONNULL_BEGIN



#pragma mark - ↑
#pragma mark - MBProgressHUD : UIView

/**
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The MBProgressHUD window spans over the entire space given to it by the initWithFrame: constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view.
 *
 * @note To still allow touches to pass through the HUD, you can set hud.userInteractionEnabled = NO.
 * @attention MBProgressHUD is a UI class and should therefore only be accessed on the main thread.
 */
@interface MBProgressHUD : UIView




#pragma mark - ↑
#pragma mark - Methods

/**
 * Creates a new HUD, adds it to provided view and shows it. The counterpart to this method is hideHUDForView:animated:.
 *
 * @note This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
 *
 * @param view The view that the HUD will be added to
 * @param animated If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 * @return A reference to the created HUD.
 *
 * @see hideHUDForView:animated:
 * @see animationType

 / 与此方法相对应的是hideHUDForView:animated:方法（常用）。
 / 注意：此方法会设置removeFromSuperViewOnHide属性为YES。此HUD在隐藏时会从视图层级中自动移除。
 / 参数一view: HUD将添加到此视图上。
 / 参数二animated:如果设置为YES，HUD将使用当前的animationType属性动画出现。否则，HUD将在出现时不会使用动画。
 / 返回值: 已经创建的此HUD的对象。
 */
#pragma mark - 创建hud 添加到指定视图上并显示(内部做了hud在隐藏时会从父视图中自动移除)（常用）
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

/// @name Showing and hiding

/**
 * Finds the top-most HUD subview that hasn't finished and hides it. The counterpart to this method is showHUDAddedTo:animated:.
 *
 * @note This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
 *
 * @param view The view that is going to be searched for a HUD subview.
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @return YES if a HUD was found and removed, NO otherwise.
 *
 * @see showHUDAddedTo:animated:
 * @see animationType

 /// 与此方法相对应的是showHUDAddedTo:animated:方法
 /// 注意：此方法会设置removeFromSuperViewOnHide属性为YES。此HUD在隐藏时会从视图层级中自动移除。
 /// 参数一view:从该视图中寻找HUD子视图
 /// 参数二animated: 如果设置为YES，HUD将使用当前的animationType属性动画消失。否则，HUD将在消失时不会使用动画。
 /// 返回值：BOOL值，如果HUD被找到并从视图中移除则返回YES。否则，返回NO
 */

#pragma mark - 隐藏View最上层的hud
+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;

/**
 * Finds the top-most HUD subview that hasn't finished and returns it.
 *
 * @param view The view that is going to be searched.
 * @return A reference to the last HUD subview discovered.
 
 /// 参数view: 从该视图中寻找HUD子视图
 /// 返回值: 最后一个被发现到的HUD子视图引用。
 */
#pragma mark - 获取View最上层的hud并返回它
+ (nullable MBProgressHUD *)HUDForView:(UIView *)view;

/**
 * A convenience constructor that initializes the HUD with the view's bounds. Calls the designated constructor with
 * view.bounds as the parameter.
 *
 * @param view The view instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the view that the HUD will be added to).
 
 /// 参数view: 为HUD提供bounds的视图实例。应该和HUD的父视图是相同的实例。(HUD将添加到此view上)
 */
#pragma mark - 使用view的bounds来初始化HUD对象
- (instancetype)initWithView:(UIView *)view;

/**
 * Displays the HUD.
 *
 * @note You need to make sure that the main thread completes its run loop soon after this method call so that
 * the user interface can be updated. Call this method when your task is already set up to be executed in a new thread
 * (e.g., when using something like NSOperation or making an asynchronous call like NSURLRequest).
 *
 * @param animated If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 *
 * @see animationType
 
 /// 注意: 需要确保在主线程调用此方法后完成它的运行循环，以便能够更新用户界面。当你的任务已经设置在一个新的线程中执行时调用此方法
 /// 参数animated：BOOL值，如果是YES，HUD将使用当前的animationType属性动画出现。否则，HUD将在出现时不使用动画
 */
#pragma mark - 显示HUD（常用）
- (void)showAnimated:(BOOL)animated;

/**
 * Hides the HUD. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 *
 * @see animationType
 
 /// 将会调用hudWasHidden:代理方法。和此方法相对应的是showAnimated:method方法。当任务完成时使用此方法来隐藏HUD。（常用）
 /// 参数animated: BOOL值，如果是YES，HUD将使用当前的animationType属性动画消失。否则，HUD将在消失时不使用动画
 */
#pragma mark - 隐藏HUD（常用）
- (void)hideAnimated:(BOOL)animated;

/**
 * Hides the HUD after a delay. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @param delay Delay in seconds until the HUD is hidden.
 *
 * @see animationType
 
 /// 将会调用hudWasHidden:代理方法。和此方法相对应的是showAnimated:method方法。当任务完成时使用此方法来隐藏HUD。（常用）
 /// 参数一animated:BOOL值，如果是YES，HUD将使用当前的animationType属性动画消失。否则，HUD将在消失时不使用动画。
 /// 参数二delay: 以秒为单位延迟，直到HUD隐藏
 */
#pragma mark - 延迟后隐藏HUD（常用）
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;





#pragma mark - ↑
#pragma mark - @name property

/**
 * The HUD delegate object. Receives HUD state notifications.
 */
#pragma mark - 代理接受HUD状态通知
@property (weak, nonatomic) id<MBProgressHUDDelegate> delegate;

/**
 * Called after the HUD is hiden.
 */
#pragma mark - HUD隐藏后调用
@property (copy, nullable) MBProgressHUDCompletionBlock completionBlock;

/*
 * Grace period is the time (in seconds) that the invoked method may be run without
 * showing the HUD. If the task finishes before the grace time runs out, the HUD will
 * not be shown at all.
 * This may be used to prevent HUD display for very short tasks.
 * Defaults to 0 (no grace time).
 * @note The graceTime needs to be set before the hud is shown. You thus can't use `showHUDAddedTo:animated:`,
 * but instead need to alloc / init the HUD, configure the grace time and than show it manually.
 
 /// 宽限期是调用方法可能在运行时没有显示HUD的时间。如果任务在宽限期内完成，HUD将一直不会显示。这可以用来防止非常短的任务时HUD显示。默认值为0。
 */
#pragma mark - 宽限时间
@property (assign, nonatomic) NSTimeInterval graceTime;

/**
 * The minimum time (in seconds) that the HUD is shown.
 * This avoids the problem of the HUD being shown and than instantly hidden.
 * Defaults to 0 (no minimum show time).
 
 /// HUD显示的最短时长。这可以用来避免HUD开始显示然后立即消失的问题出现。默认值为0。
 */
#pragma mark - HUD显示的最短时长
@property (assign, nonatomic) NSTimeInterval minShowTime;

/**
 * Removes the HUD from its parent view when hidden.
 * Defaults to NO.
 /// 是否当HUD隐藏时从它的父视图移除。默认为NO，不移除。
 */
#pragma mark - 是否当HUD隐藏时从它的父视图移除
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;



#pragma mark - @name Appearance

/**
 * MBProgressHUD operation mode. The default is MBProgressHUDModeIndeterminate.
 /// MBProgressHUD显示模式。默认是MBProgressHUDModeIndeterminate
 */

#pragma mark - 显示模式
@property (assign, nonatomic) MBProgressHUDMode mode;

/**
 * A color that gets forwarded to all labels and supported indicators. Also sets the tintColor
 * for custom views on iOS 7+. Set to nil to manage color individually.
 * Defaults to semi-translucent black on iOS 7 and later and white on earlier iOS versions.
 /// 获取转发给所有标签和支持的指示器的颜色。还为iOS7+上的自定义视图设置tintColor。设置为nil用来单独管理颜色。默认在iOS7及以后系统上设置为半透明的黑色，在之前的系统上设置为白色。
 */
#pragma mark - 所有标签和支持的指示器的颜色
@property (strong, nonatomic, nullable) UIColor *contentColor ;

/**
 * The animation type that should be used when the HUD is shown and hidden.
 /// 当HUD显示和隐藏时应该被用到的动画类型
 */
#pragma mark - 显示和隐藏时的动画类型
@property (assign, nonatomic) MBProgressHUDAnimation animationType ;

/**
 * The bezel offset relative to the center of the view. You can use MBProgressMaxOffset
 * and -MBProgressMaxOffset to move the HUD all the way to the screen edge in each direction.
 * E.g., CGPointMake(0.f, MBProgressMaxOffset) would position the HUD centered on the bottom edge.
 /// 表圈bezelView相对于视图中心的偏移量。可以使用MBProgressMaxOffset和 -MBProgressMaxOffset将HUD一直移动到每个方向的屏幕边缘。例如CGPointMake(0.f, MBProgressMaxOffset) 将HUD定位在底部边缘的中心。
 */
#pragma mark - 表圈bezelView相对于视图中心的偏移量
@property (assign, nonatomic) CGPoint offset ;

/**
 * The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views).
 * This also represents the minimum bezel distance to the edge of the HUD view.
 * Defaults to 20.f
 /// HUD边缘与HUD元素(标签、指示器或自定义视图)之间的空间量。
 */
#pragma mark - 边框到HUD视图边缘的最小距离。默认2.0f
@property (assign, nonatomic) CGFloat margin ;

/**
 * The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
 /// HUD表圈的最小尺寸。默认为CGSizeZero。
 */
#pragma mark - HUD表圈的最小尺寸
@property (assign, nonatomic) CGSize minSize ;

/**
 * Force the HUD dimensions to be equal if possible.
 /// 如果可能，强制HUD尺寸相等
 */
#pragma mark - 强制HUD尺寸相等
@property (assign, nonatomic, getter = isSquare) BOOL square ;

/**
 * When enabled, the bezel center gets slightly affected by the device accelerometer data.
 * Has no effect on iOS < 7.0. Defaults to YES.
 /// 启用后，表圈中心会收到设备加速度计数据的轻微影响。在iOS < 7.0无影响。默认为YES。
 */

@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled ;



#pragma mark - ↑
#pragma mark - @name Progress

/**
 * The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
 /// 进度指示器的进度，范围是0.0 - 1.0。默认为0。
 */
#pragma mark - 进度
@property (assign, nonatomic) float progress;

/// @name ProgressObject

/**
 * The NSProgress object feeding the progress information to the progress indicator.
 /// NSProgress对象将进度信息提供给进度指示器
 */
#pragma mark - 进度指示器
@property (strong, nonatomic, nullable) NSProgress *progressObject;



#pragma mark - ↑
#pragma mark - @name Views

/**
 * The view containing the labels and indicator (or customView).
 是指包括文本和指示器的视图，和自定义的 customView 类似
 提供元素 （indicator（指示器显示进度情况 这个视图由我们设定的mode属性决定）、label（显示标题文本）、detailLabel（显示详情文本）、button（添加点击事件））的背景。
 */
#pragma mark - 包括文本和指示器的视图
@property (strong, nonatomic, readonly) MBBackgroundView *bezelView;

/**
 * View covering the entire HUD area, placed behind bezelView.
 /// 覆盖整个HUD区域的视图，放置在表圈视图的后面。
 */
#pragma mark - 背景视图
@property (strong, nonatomic, readonly) MBBackgroundView *backgroundView;

/**
 * The UIView (e.g., a UIImageView) to be shown when the HUD is in MBProgressHUDModeCustomView.
 * The view should implement intrinsicContentSize for proper sizing. For best results use approximately 37 by 37 pixels.
 /// 当HUD的模式是MBProgressHUDModeCustomView时用于显示的自定义视图。该视图应该实现 intrinsicContentSize 以适当调整大小。为获得最佳效果，请使用大约37x37像素。
 */
#pragma mark - 自定义视图
@property (strong, nonatomic, nullable) UIView *customView;

/**
 * A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text.
 /// 标签，包含可选短信息的标签，显示在活动指示器下方。HUD会自动调整大小以适应整个文本。
 */
#pragma mark - 标题label
@property (strong, nonatomic, readonly) UILabel *label;

/**
 * A label that holds an optional details message displayed below the labelText message. The details text can span multiple lines.
 /// 标签，包含可选详细信息的标签，显示在短信息标签的下方。详细文本可以跨度多行。
 */
#pragma mark - 详情label
@property (strong, nonatomic, readonly) UILabel *detailsLabel;

/**
 * A button that is placed below the labels. Visible only if a target / action is added.
 /// 放置在标签下方。仅在添加target/action时才可见。
 */
#pragma mark - 按钮
@property (strong, nonatomic, readonly) UIButton *button;

@end





@protocol MBProgressHUDDelegate <NSObject>

@optional

/**
 * Called after the HUD was fully hidden from the screen.
 */
- (void)hudWasHidden:(MBProgressHUD *)hud;

@end


#pragma mark - ↑
#pragma mark - MBRoundProgressView : UIView

/**
 * A progress view for showing definite progress by filling up a circle (pie chart).
 */
@interface MBRoundProgressView : UIView

/**
 * Progress (0.0 to 1.0)
 进度条 (0.0 到 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 * Indicator progress color.
 * Defaults to white [UIColor whiteColor].
 进度条指示器的颜色
 */
@property (nonatomic, strong) UIColor *progressTintColor;

/**
 * Indicator background (non-progress) color.
 * Only applicable on iOS versions older than iOS 7.
 * Defaults to translucent white (alpha 0.1).
 进度条指示器的背景颜色，只适用在 iOS7 以上，默认为半透明的白色 (透明度 0.1)
 */
@property (nonatomic, strong) UIColor *backgroundTintColor;

/*
 * Display mode - NO = round or YES = annular. Defaults to round.
 显示模式，NO = 圆形；YES = 环形。默认是 NO
 */
@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end



#pragma mark - ↑
#pragma mark - MBBarProgressView : UIView

/**
 * A flat bar progress view.
 */
@interface MBBarProgressView : UIView

/**
 * Progress (0.0 to 1.0)
  进度条 (0.0 到 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 * Bar border line color.
 * Defaults to white [UIColor whiteColor].
  进度条边界线的颜色，默认是白色
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 * Bar background color.
 * Defaults to clear [UIColor clearColor];
 进度条背景色，默认是透明
 */
@property (nonatomic, strong) UIColor *progressRemainingColor;

/**
 * Bar progress color.
 * Defaults to white [UIColor whiteColor].
 进度条颜色
 */
@property (nonatomic, strong) UIColor *progressColor;

@end



#pragma mark - ↑
#pragma mark - MBBackgroundView : UIView

@interface MBBackgroundView : UIView

/**
 * The background style.
 * Defaults to MBProgressHUDBackgroundStyleBlur on iOS 7 or later and MBProgressHUDBackgroundStyleSolidColor otherwise.
 * @note Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
 背景图层样式，有两种，iOS7 或者以上版本默认风格是MBProgressHUDBackgroundStyleBlur，其他为MBProgressHUDBackgroundStyleSolidColor，由于 iOS7 不支持 UIVisualEffectView，所以在 iOS7 和更高版本中会有所不同
 */
@property (nonatomic) MBProgressHUDBackgroundStyle style;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
/**
 * The blur effect style, when using MBProgressHUDBackgroundStyleBlur.
 * Defaults to UIBlurEffectStyleLight.
 */
@property (nonatomic) UIBlurEffectStyle blurEffectStyle;
#endif

/**
 * The background color or the blur tint color.
 * @note Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
 背景颜色，由于 iOS7 不支持 UIVisualEffectView，所以在 iOS7 和更高版本中会有所不同
 */
@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END
