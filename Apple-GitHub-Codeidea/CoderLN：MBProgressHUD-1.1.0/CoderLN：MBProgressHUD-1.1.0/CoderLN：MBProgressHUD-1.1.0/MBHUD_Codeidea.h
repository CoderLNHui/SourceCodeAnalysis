//
//  MBProgressHUD_Codeidea
//  Version 1.1.0
//
//  About ME『Public：Codeidea / https://githubidea.github.io』.
//  Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.

//

#pragma mark - ↑
#pragma mark - MBProgressHUD 用户提示，Version = 1.1.0


#pragma mark - ↑
#pragma mark - 官方释义

/**
 官方释义：
 MBProgressHUD is an iOS drop-in class that displays a translucent HUD with an indicator and/or labels while work is being done in a background thread. The HUD is meant as a replacement for the undocumented, private UIKit UIProgressHUD with some additional features.
 */





#pragma mark - ↑
#pragma mark - MBHUD 组成(层次结构)
/*
 MBProgressHUD 主要由四部分组成：
 背景框(bezelView)、动画视图(indicator)、标题文本框(label)、详情文本框(detailLabel)、按钮(UIButton)。
 
 MBProgressHUD 文件中主要包括四个类
    MBProgressHUD
    MBRoundProgressView
    MBBarProgressView
    MBBackgroundView

 */







#pragma mark - ↑
#pragma mark - 总结笔记

1、
#pragma mark - + Show 显示方法工作流程

```objc
// 1、创建hud 添加到指定视图上并显示(内部做了hud在隐藏时会从父视图中自动移除 hud.removeFromSuperViewOnHide = YES)
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated

    // 1.使用view的bounds来初始化HUD对象
    - (id)initWithView:(UIView *)view
    - (instancetype)initWithFrame:(CGRect)frame

    // 2.基本属性设置
    - (void)commonInit {
        
        // 基本属性设置
        
        [self setupViews];// 设置所需的子view
        
        [self updateIndicators];// 设置指示器样式
        
        [self registerForNotifications];// 注册通知
    }


// 2、是否动画显示
- (void)showAnimated:(BOOL)animated

    // 1.Show 核心方法：没有设置宽限时间graceTime，则直接显示
    - (void)showUsingAnimation:(BOOL)animated
    // 2.如果使用附加的相同NSProgress对象的隐藏和重新显示，则需要
    - (void)setNSProgressDisplayLinkEnabled:(BOOL)enabled

// 3、是否动画放大，动画类型，是否完成回调 (show 和 hide 都会调用)
- (void)animateIn:(BOOL)animatingIn withType:(MBProgressHUDAnimation)type completion:(void(^)(BOOL finished))completion


// 总结：
// 当程序执行到 - (void)commonInit 这个方法时，会相继执行- (void)setupViews，- (void)updateIndicators，- (void)registerForNotifications 这三个方法，当然在执行这三个方法期间，也会执行其它的方法，比如会执行- (void)updateForBackgroundStyle 和- (void)updateBezelMotionEffects等等，这和你设置的 mode 的模式，以及和 label，detailsLabel ，button 这一系列元素，以及和相应的属性都有一定的关系。
```


2、
#pragma mark - + Hide 方法工作流程

```objc
// 1、隐藏HUD
- (void)hideAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

    // 1.如果设置了最小显示时长，则计算hud显示的时间，必要时推迟隐藏操作，否则直接隐藏
    // 2.hide 核心方法
    - (void)hideUsingAnimation:(BOOL)animated

// 2、是否动画放大，动画类型，是否完成回调 (show 和 hide 都会调用)
- (void)animateIn:(BOOL)animatingIn withType:(MBProgressHUDAnimation)type completion:(void(^)(BOOL finished))completion

// 3、动画完成的操作(销毁定时器invalidate、隐藏NSProgress对象、移除HUD removeFromSuperview)
- (void)done
    // 1.如果使用附加的相同NSProgress对象的隐藏和重新显示，则需要
    - (void)setNSProgressDisplayLinkEnabled:(BOOL)enabled


// 总结：
// 无论是show方法还是hide方法，在设定animated属性为YES时，最终会走animateIn: withType: completion:方法。此方法主要作用是处理显示和隐藏的动画效果。
```










#pragma mark - ↑
#pragma mark - SVHUD 基本使用

```objc

```



























