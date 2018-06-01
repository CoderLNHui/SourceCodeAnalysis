//
//  SVIndefiniteAnimatedView.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2018 Guillaume Campagna. All rights reserved.
//

/**
 SVIndefiniteAnimatedView继承自UIView类, 用于实现一个无限指示器,
 该类在.h文件中提供如下3个属性分别用于定义无限指示器的厚度、半径及颜色
 
 无限旋转原理：
 也就是不断地旋转一张具有渐变颜色的图片，然后通过使用mask来遮住不需要的部分(结合layer使用)。
 讲到这里就不得不提到iOS动画中的CALayer以及Mask。常见的场景就是CAShapeLayer和mask结合使用。
 */


#import <UIKit/UIKit.h>

@interface SVIndefiniteAnimatedView : UIView

@property (nonatomic, assign) CGFloat strokeThickness;// 厚度
@property (nonatomic, assign) CGFloat radius;// 半径
@property (nonatomic, strong) UIColor *strokeColor;// 颜色

@end


