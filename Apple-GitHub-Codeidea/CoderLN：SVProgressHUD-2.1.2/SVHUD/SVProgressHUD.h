//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2017 Sam Vermette and contributors. All rights reserved.
//
// 不知名刘先生
// Public：Codeidea / https://githubidea.github.io / https://github.com/CoderLN
// Welcome your star|fork, Our sharing can be combined; Convenient to review and help others.
//


/************************************************************************************
 声明：
 SVProgressHUD V2.1.2 部分内容及图解摘录于，简书：蚊香酱 https://www.jianshu.com/p/71ca8bf5736b
 
 
 ************************************************************************************/



/**
 SVProgressHUD继承自UIView类, 该类提供了两类方法供使用者调用,其中
 +setXXX:方法用于设置HUD的样式、遮罩、颜色等,
 +showXXX:方法用于设置HUD的显示,
 +dismissXX:方法用于设置HUD的隐藏
 */

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000

#define

#endif



#pragma mark - ↑
#pragma mark - const 常量通知

extern NSString * _Nonnull const SVProgressHUDDidReceiveTouchEventNotification;
extern NSString * _Nonnull const SVProgressHUDDidTouchDownInsideNotification;
extern NSString * _Nonnull const SVProgressHUDWillDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDDidDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDWillAppearNotification;
extern NSString * _Nonnull const SVProgressHUDDidAppearNotification;

extern NSString * _Nonnull const SVProgressHUDStatusUserInfoKey;



#pragma mark - ↑
#pragma mark - NS_ENUM 枚举

// 设置显示样式
typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
    SVProgressHUDStyleLight,        // 显示白底黑字 默认样式背景将模糊 default style, white HUD with black text, HUD background will be blurred
    SVProgressHUDStyleDark,         // 显示黑底白字  black HUD and white text, HUD background will be blurred
    SVProgressHUDStyleCustom        // 显示黑底白字 uses the fore- and background color properties
};


// 设置HUD背景图层的样式
typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    SVProgressHUDMaskTypeNone = 1,  // 默认图层样式，当HUD显示的时候，允许用户交互。 default mask type, allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear,     // 当HUD显示的时候，不允许用户交互。 don't allow user interactions with background objects
    SVProgressHUDMaskTypeBlack,     // 当HUD显示的时候，不允许用户交互，且显示黑色背景图层。 don't allow user interactions with background objects and dim the UI in the back of the HUD (as seen in iOS 7 and above)
    SVProgressHUDMaskTypeGradient,  // 当HUD显示的时候，不允许用户交互，且显示渐变的背景图层。 don't allow user interactions with background objects and dim the UI with a a-la UIAlertView background gradient (as seen in iOS 6)
    SVProgressHUDMaskTypeCustom     // 当HUD显示的时候，不允许用户交互，且显示背景图层自定义的颜色。 don't allow user interactions with background objects and dim the UI in the back of the HUD with a custom color
};


// 设置动画效果
typedef NS_ENUM(NSUInteger, SVProgressHUDAnimationType) {
    SVProgressHUDAnimationTypeFlat,     // default animation type, custom flat animation (indefinite animated ring)
    SVProgressHUDAnimationTypeNative    // iOS native UIActivityIndicatorView
};

// show Block回调
typedef void (^SVProgressHUDShowCompletion)(void);
// dismiss Block回调
typedef void (^SVProgressHUDDismissCompletion)(void);






@interface SVProgressHUD : UIView


#pragma mark - ↑
#pragma mark - 自定义HUD Customization UI_APPEARANCE_SELECTOR

@property (assign, nonatomic) SVProgressHUDStyle defaultStyle ;                   // default is SVProgressHUDStyleLight
@property (assign, nonatomic) SVProgressHUDMaskType defaultMaskType ;             // default is SVProgressHUDMaskTypeNone
@property (assign, nonatomic) SVProgressHUDAnimationType defaultAnimationType ;   // default is SVProgressHUDAnimationTypeFlat
@property (strong, nonatomic, nullable) UIView *containerView;                              // if nil then use default window level
@property (assign, nonatomic) CGSize minimumSize ;                    // default is CGSizeZero, can be used to avoid resizing for a larger message
@property (assign, nonatomic) CGFloat ringThickness ;                 // default is 2 pt
@property (assign, nonatomic) CGFloat ringRadius ;                    // default is 18 pt
@property (assign, nonatomic) CGFloat ringNoTextRadius ;              // default is 24 pt
@property (assign, nonatomic) CGFloat cornerRadius ;                  // default is 14 pt
@property (strong, nonatomic, nonnull) UIFont *font ;                 // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
@property (strong, nonatomic, nonnull) UIColor *backgroundColor ;     // default is [UIColor whiteColor]
@property (strong, nonatomic, nonnull) UIColor *foregroundColor ;     // default is [UIColor blackColor]
@property (strong, nonatomic, nonnull) UIColor *backgroundLayerColor ;// default is [UIColor colorWithWhite:0 alpha:0.4]
@property (assign, nonatomic) CGSize imageViewSize ;                  // default is 28x28 pt
@property (strong, nonatomic, nonnull) UIImage *infoImage ;           // default is the bundled info image provided by Freepik
@property (strong, nonatomic, nonnull) UIImage *successImage ;        // default is the bundled success image provided by Freepik
@property (strong, nonatomic, nonnull) UIImage *errorImage ;          // default is the bundled error image provided by Freepik
@property (strong, nonatomic, nonnull) UIView *viewForExtension ;     // default is nil, only used if #define SV_APP_EXTENSIONS is set
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;                    // default is 5.0 seconds
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval;                    // default is CGFLOAT_MAX

@property (assign, nonatomic) UIOffset offsetFromCenter ; // default is 0, 0

@property (assign, nonatomic) NSTimeInterval fadeInAnimationDuration ;    // default is 0.15
@property (assign, nonatomic) NSTimeInterval fadeOutAnimationDuration ;   // default is 0.15

@property (assign, nonatomic) UIWindowLevel maxSupportedWindowLevel; // default is UIWindowLevelNormal

@property (assign, nonatomic) BOOL hapticsEnabled;	// default is NO



#pragma mark - 自定义HUD重写set方法
/**
 其实就是调用对应属性的 set方法.
 */

+ (void)setDefaultStyle:(SVProgressHUDStyle)style;                  // default is SVProgressHUDStyleLight
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;         // default is SVProgressHUDMaskTypeNone
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;   // default is SVProgressHUDAnimationTypeFlat
+ (void)setContainerView:(nonnull UIView*)containerView;            // default is window level
+ (void)setMinimumSize:(CGSize)minimumSize;                         // default is CGSizeZero, can be used to avoid resizing for a larger message
+ (void)setRingThickness:(CGFloat)ringThickness;                    // default is 2 pt
+ (void)setRingRadius:(CGFloat)radius;                              // default is 18 pt
+ (void)setRingNoTextRadius:(CGFloat)radius;                        // default is 24 pt
+ (void)setCornerRadius:(CGFloat)cornerRadius;                      // default is 14 pt
+ (void)setBorderColor:(nonnull UIColor*)color;                     // default is nil
+ (void)setBorderWidth:(CGFloat)width;                              // default is 0
+ (void)setFont:(nonnull UIFont*)font;                              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setForegroundColor:(nonnull UIColor*)color;                 // default is [UIColor blackColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundColor:(nonnull UIColor*)color;                 // default is [UIColor whiteColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundLayerColor:(nonnull UIColor*)color;            // default is [UIColor colorWithWhite:0 alpha:0.5], only used for SVProgressHUDMaskTypeBlack
+ (void)setImageViewSize:(CGSize)size;                              // default is 28x28 pt
+ (void)setInfoImage:(nonnull UIImage*)image;                       // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(nonnull UIImage*)image;                    // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(nonnull UIImage*)image;                      // default is the bundled error image provided by Freepik
+ (void)setViewForExtension:(nonnull UIView*)view;                  // default is nil, only used if #define SV_APP_EXTENSIONS is set
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     // default is 5.0 seconds
+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval;     // default is infinite
+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration;        // default is 0.15 seconds
+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;       // default is 0.15 seconds
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;      // default is UIWindowLevelNormal
+ (void)setHapticsEnabled:(BOOL)hapticsEnabled;						// default is NO





#pragma mark - ↑
#pragma mark - Show Methods 显示方法


#pragma mark - + Show 显示方法工作流程

+ (void)show;
+ (void)showWithStatus:(nullable NSString*)status;
+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress status:(nullable NSString*)status;


+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use show and setDefaultMaskType: instead.")));
+ (void)showWithStatus:(nullable NSString*)status;
+ (void)showWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showWithStatus: and setDefaultMaskType: instead.")));

+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress: and setDefaultMaskType: instead.")));
+ (void)showProgress:(float)progress status:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress:status: and setDefaultMaskType: instead.")));

+ (void)setStatus:(nullable NSString*)status; // change the HUD loading status while it's showing




#pragma mark - ↑
#pragma mark - + Show 展示图片方法工作流程

+ (void)showInfoWithStatus:(nullable NSString*)status;
+ (void)showSuccessWithStatus:(nullable NSString*)status;
+ (void)showErrorWithStatus:(nullable NSString*)status;
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status;


// stops the activity indicator, shows a glyph + status, and dismisses the HUD a little bit later
+ (void)showInfoWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showInfoWithStatus: and setDefaultMaskType: instead.")));

+ (void)showSuccessWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showSuccessWithStatus: and setDefaultMaskType: instead.")));
+ (void)showErrorWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showErrorWithStatus: and setDefaultMaskType: instead.")));

// shows a image + status, use white PNGs with the imageViewSize (default is 28x28 pt)
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showImage:status: and setDefaultMaskType: instead.")));

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed



 
#pragma mark - ↑
#pragma mark - + dismiss 隐藏方法工作流程

+ (void)dismiss;
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion;
+ (void)dismissWithDelay:(NSTimeInterval)delay;
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;

+ (BOOL)isVisible;

+ (NSTimeInterval)displayDurationForString:(nullable NSString*)string;

@end

