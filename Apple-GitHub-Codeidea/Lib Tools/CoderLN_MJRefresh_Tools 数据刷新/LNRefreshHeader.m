//
//  LNRefreshHeader.m
//  LNBaisibudejie
//
//  Created by LN on 2018/7/19.
//  Copyright © 2018年 Public-CoderLN. All rights reserved.
//

#import "LNRefreshHeader.h"

@interface LNRefreshHeader()

@property (nonatomic, weak) UISwitch *s;//开关
@property (nonatomic, weak) UIImageView *logo;//logo

@end

@implementation LNRefreshHeader

/**
 1.在initWithFrame:方法中，添加子控件，设置子控件的一次性属性
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 开关
        UISwitch *s = [[UISwitch alloc] init];
        [self addSubview:s];
        self.s = s;
        
        // 设置顶部logo
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
        [self addSubview:logo];
        self.logo = logo;
        
        // 下拉控件自动切换透明度
        self.automaticallyChangeAlpha = YES;
    }
    return self;
}

/**
 2.在layoutSubViews:方法中，设置子控件的frame
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.logo.ln_centerX = self.ln_width * 0.5;
    self.logo.ln_y =  -  3 * self.logo.ln_height;
    
    self.s.ln_centerX = self.ln_width * 0.5;
    self.s.ln_centerY = self.ln_height * 0.5;
}

#pragma mark - 重写Header内部的方法
- (void)setState:(MJRefreshState)state
{
    [super setState:state];
    
    if (state == MJRefreshStateIdle) { // 下拉可以刷新
        [self.s setOn:NO animated:YES];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.s.transform = CGAffineTransformIdentity;
        }];
    } else if (state == MJRefreshStatePulling) { // 松开立即刷新
        [self.s setOn:YES animated:YES];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.s.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
    } else if (state == MJRefreshStateRefreshing) { // 正在刷新
        [self.s setOn:YES animated:YES];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.s.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
    }
}



@end
