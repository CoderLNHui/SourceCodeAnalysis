//
//  SVIndefiniteAnimatedView.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2017 Guillaume Campagna. All rights reserved.
//

/**
 SVIndefiniteAnimatedView继承自UIView类, 用于实现一个无限指示器,
 该类在.h文件中提供如下3个属性分别用于定义无限指示器的厚度、半径及颜色
 */


#import <UIKit/UIKit.h>

@interface SVIndefiniteAnimatedView : UIView

@property (nonatomic, assign) CGFloat strokeThickness;// 厚度
@property (nonatomic, assign) CGFloat radius;// 半径
@property (nonatomic, strong) UIColor *strokeColor;// 颜色


@end

