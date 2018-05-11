//
//  SVProgressAnimatedView.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2017 Tobias Tiemerding. All rights reserved.
//
//  About ME『Public：Codeidea / https://githubidea.github.io』.
//  Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.
//

#import <UIKit/UIKit.h>

@interface SVProgressAnimatedView : UIView

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat strokeThickness;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeEnd;

@end
