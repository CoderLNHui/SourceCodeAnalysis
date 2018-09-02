//
//  LNRefreshNormalHeader.m
//  LNBaisibudejie
//
//  Created by LN on 2018/7/19.
//  Copyright © 2018年 Public-Codeidea. All rights reserved.
//  自定义View

#import "LNRefreshNormalHeader.h"

@interface LNRefreshNormalHeader ()

@property (nonatomic, strong) UIImageView * logoImgView;
@end

@implementation LNRefreshNormalHeader

/**
 1.在initWithFrame:方法中，添加子控件，设置子控件的一次性属性
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // Logo
        UIImageView * logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
        self.logoImgView = logoImgView;
        [self addSubview:logoImgView];
        
        // 下拉刷新控件自动改变透明度
        self.automaticallyChangeAlpha = YES;
        
        // 设置刷新控件的状态文字
        [self setTitle:@"CoderLN_下拉刷新" forState:MJRefreshStateIdle];
        [self setTitle:@"CoderLN_松开就可以进行刷新" forState:MJRefreshStatePulling];
        [self setTitle:@"CoderLN_正在刷新中" forState:MJRefreshStateRefreshing];
        
        // 设置文字颜色
        self.stateLabel.textColor = [UIColor redColor];
        self.stateLabel.font = [UIFont systemFontOfSize:16];
        self.stateLabel.backgroundColor = [UIColor grayColor];
        
        self.lastUpdatedTimeLabel.textColor = self.stateLabel.textColor;
        self.lastUpdatedTimeLabel.font = self.stateLabel.font;
        self.lastUpdatedTimeLabel.backgroundColor = [UIColor orangeColor];
        
        // 隐藏刷新时间
        //self.lastUpdatedTimeLabel.hidden = YES;
        // 隐藏状态文字
        //self.stateLabel.hidden = YES;
        
        // 自动进入刷新
        [self beginRefreshing];
        
        // 文字距离圈圈、箭头的距离（默认25）
        //self.labelLeftInset = 50;

        // 修改菊花的样式
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        
        // 修改下拉刷新箭头❓
//        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[UIImageView class]]) {
//                UIImageView * imageView = (UIImageView *)obj;
//                imageView.image = [UIImage imageWithOriginalImageName:@"Bottom_Arrow"];
//                //imageView.backgroundColor = [UIColor redColor];
//                NSLog(@"%@",NSStringFromCGRect(obj.frame));
//            }
//        }];
    }
    return self;
}
 

/**
 2.在layoutSubViews:方法中，设置子控件的frame
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置logo的frame
    self.logoImgView.ln_y = - (self.logoImgView.ln_height + LNTitlesViewH * 3);
    self.logoImgView.ln_centerX = self.ln_width * 0.5;
}











@end
