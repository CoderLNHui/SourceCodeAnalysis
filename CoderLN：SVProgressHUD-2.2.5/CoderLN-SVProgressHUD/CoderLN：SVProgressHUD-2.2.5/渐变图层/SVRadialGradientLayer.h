//
//  SVRadialGradientLayer.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2018 Tobias Tiemerding. All rights reserved.
//

/**
 SVRadialGradientLayer继承自CALayer类, 用于实现一个放射渐变层,
 该类在.h文件中提供如下属性用于定义放射渐变层的放射中心
 */

#import <QuartzCore/QuartzCore.h>

@interface SVRadialGradientLayer : CALayer

@property (nonatomic) CGPoint gradientCenter;// 放射渐变层的放射中心

@end
