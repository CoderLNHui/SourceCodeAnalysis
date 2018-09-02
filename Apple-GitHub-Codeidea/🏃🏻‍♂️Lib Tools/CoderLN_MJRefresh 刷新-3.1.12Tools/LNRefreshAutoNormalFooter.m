//
//  LNRefreshAutoNormalFooter.m
//  LNBaisibudejie
//
//  Created by LN on 2018/7/19.
//  Copyright © 2018年 Public-Codeidea. All rights reserved.
//

#import "LNRefreshAutoNormalFooter.h"

@interface LNRefreshAutoNormalFooter ()
/** logo */
@property (nonatomic, weak) UIImageView *logo;
@end

@implementation LNRefreshAutoNormalFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //隐藏刷新状态的文字
        //self.stateLabel.hidden = YES;
        
        //设置文字
        [self setTitle:@"小牛！点击或是上拉加载更多" forState:MJRefreshStateIdle];
        [self setTitle:@"小牛！正在加载更多..." forState:MJRefreshStateRefreshing];
        [self setTitle:@"小牛！没有更多数据了" forState:MJRefreshStateNoMoreData];
        
        //设置字体
        self.stateLabel.font = [UIFont systemFontOfSize:17];
        
        //设置颜色
        self.stateLabel.textColor = [UIColor blueColor];
        
        //设置底部logo
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
        [self addSubview:logo];
        self.logo = logo;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.logo.ln_y += self.ln_height * 0.5;
    self.logo.ln_centerX = self.ln_width * 0.5;
}

@end
