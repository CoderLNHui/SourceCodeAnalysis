//
//  SVProgressHUD_Codeidea
//  Version 2.2.5
//
// 不知名刘先生
// Public：Codeidea / https://githubidea.github.io / https://github.com/CoderLN
// Welcome your star|fork, Our sharing can be combined; Convenient to review and help others.

//

#pragma mark - ↑
#pragma mark - SVProgressHUD
/**
 SVProgressHUD 用户提示 

 官方释义：
 SVProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS.

 SVProgressHUD 是一个干净，易于使用的HUD，旨在显示iOS和tvOS正在进行的任务的进展。
 
 常用的还有MBProgressHUD.这两个都是很常用的HUD,大体相似,但是还是有一些不同的.
 MBProgressHUD和SVProgressHUD的区别：
 svprogresshud 使用起来很方便,但 可定制 差一些,看它的接口貌似只能添加一个全屏的HUD,不能把它添加到某个视图上面去.
 MBProgressHUD 功能全一些,可定制 高一些,而且可以指定加到某一个View上去.用起来可能就没上面那个方便了.
 具体还要看你的使用场景.
 */





 
#pragma mark - ↑
#pragma mark - SVHUD 组成(层次结构)
/**
 SVHUD 组成(层次结构)
 

 标准SVProgressHUD提供两种预配置样式：
     typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
        SVProgressHUDStyleLight,        // 显示白底黑字 默认样式背景将模糊
        SVProgressHUDStyleDark,         // 显示黑底白字
        SVProgressHUDStyleCustom        // 显示黑底白字
     };

 这样可以自定义颜色，且HUDStyle设置为Custom
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];// 设置显示样式
    [SVProgressHUD setForegroundColor:[UIColor cyanColor]];// 设置文本和动画颜色
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];// 设置背景颜色
 */







#pragma mark - ↑
#pragma mark - 总结笔记

```objc
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
```





#pragma mark - 重要属性
/**
 SVProgressHUDStyle defaultStyle;设置显示样式（Light白底黑字背景模糊、Dark黑底白字、Custom黑底白字）
 
 SVProgressHUDMaskType defaultMaskType;设置背景遮罩类型（None交互、Clear不交互、Black不交互且背景黑色、Gradient不交互渐变背景、Custom不交互自定义背景颜色）
 
 SVProgressHUDAnimationType defaultAnimationType;设置动画类型（Flat黑色圆圈、Native菊花）
 */









#pragma mark - ↑
#pragma mark - SVHUD 实现原理(工作流程)

```objc
/**
 HUD显示时间(默认设置为0.5s)
 取决于minimumDismissTimeInterval(设置HUD销毁的最短时间) 给定字符串的长度，
 
 #pragma mark - Getters
 //根据文字的长度计算需要展示的时间大小
 + (NSTimeInterval)displayDurationForString:(NSString*)string {
 CGFloat minimum = MAX((CGFloat)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
 return MIN(minimum, [self sharedView].maximumDismissTimeInterval);
 }
 
 */
```












#pragma mark - ↑
#pragma mark - SVHUD 基本使用

```objc
- (void)svhud2
{
    if ([SVProgressHUD isVisible]) return;// 显示直接返回
    
    // 设置显示状态(显示白底黑色圆圈+提示文本)
    [SVProgressHUD showWithStatus:@"加载中..."];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];// 设置显示样式
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];// 设置HUD背景遮罩类型
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];//  设置动画类型(圆圈、菊花)
    //    [SVProgressHUD setForegroundColor:[UIColor cyanColor]];// 设置文本和动画颜色
    //    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];// 设置背景颜色
    //    [SVProgressHUD setImageViewSize:CGSizeMake(100, 100)];// 设置图片的大小-无效果
    
    
    [SVProgressHUD dismissWithDelay:3.0 completion:^{
        // 完成回调
        NSLog(@"SVHUD 3s后隐藏");
    }];
    
    - - -
    // 1.只显示文本
    [SVProgressHUD showImage:nil status:@"只显示文本"];
    
    // 2.只显示动画图片
    [SVProgressHUD showImage:[UIImage imageWithGIFNamed:@"loading"] status:nil];
    
    // 3.自定义动画(显示图片+文本)
    [SVProgressHUD showImage:[UIImage imageWithGIFNamed:@"loading"] status:@"自定义图片+文本"];
    [SVProgressHUD setImageViewSize:CGSizeMake(70, 55)];
    [SVProgressHUD setShouldTintImages:NO];// 是否渲染自定义图片
    
    
    // 4.显示登录成功(显示打对勾图片+文本) 或 失败(显示打叉号图片+文本)
    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    [SVProgressHUD showErrorWithStatus:@"登录失败"];
    [SVProgressHUD dismissWithDelay:2.0 completion:^{
        NSLog(@"2s 登录成功");
    }];
}
```





#pragma mark - ↑
#pragma mark - SVHUD 抽取封装







 











