//
//  LNRefreshBackNormalFooter.m
//  MJRefreshExample
//
//  Created by LN on 2018/6/7.
//  Copyright © 2018年 小码哥. All rights reserved.
//

#import "LNRefreshBackNormalFooter.h"

@interface LNRefreshBackNormalFooter ()

@property (nonatomic, strong) UIImageView * logoImg;// 头部刷新
@property (nonatomic, strong) UIButton *btn;// 底部按钮
@end

@implementation LNRefreshBackNormalFooter


// 1.initWithFrame 添加子控件
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpAttributes];
    }
    return self;
}


/**
 场景需求：
 自定义MJRefresh header头部下拉刷新控件，中文文字提示
 解决：
 重写【initWithFrame:】方法（设置修改属性）。
*/
- (void)setUpAttributes
{
    // 设置文字
    [self setTitle:@"Codeidea 上拉试试刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松开就可以刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新中勿骚动" forState:MJRefreshStateRefreshing];
    
    // 怎么设置时间Label文字❓

    // 设置文字大小
    self.stateLabel.font = [UIFont systemFontOfSize:14.f];

    // 设置文字颜色
    self.stateLabel.textColor = [UIColor cyanColor];

    // 设置隐藏状态文字
    //self.stateLabel.hidden = YES;
    
    // 设置自动切换透明度
    self.automaticallyChangeAlpha = YES;
    
    // 设置文字距离圈圈、箭头的距离（默认25）
    //self.labelLeftInset = 80;
    
    // 设置刷新控件高度（HeaderHeight = 54.0、FooterHeight = 44.0）
    //self.mj_h = 100;
    
    // 设置顶部logo
    self.logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logoImg.frame = CGRectMake(0, 0, 90, 54);
    [self addSubview:self.logoImg];
}
 


// 2.设置子控件的frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.logoImg.mj_centerX = self.mj_w * 0.5;
    self.logoImg.mj_y = self.mj_h;
}


// 3.重写模型类set方法 赋值属性值








/**
 场景需求：1、需求显示是一个按钮，前100条自动刷新，100条之后需要用户自己点击按钮刷新20条❓
 解决：
 重写【placeSubviews】的set方法

- (void)placeSubviews
{
    [super placeSubviews];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, kScreenW - 10, 50)];
    [btn setBackgroundImage:[UIImage imageNamed:@"iPhone_TableView_LoadMore_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"iPhone_TableView_LoadMore_active"] forState:UIControlStateHighlighted];
    [btn setTitle:@"加载中..." forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(stateLabelClick) forControlEvents:UIControlEventTouchUpInside];
    self.btn = btn;
    [self addSubview:btn];
}

 
- (void)setState:(MJRefreshState)state
{
    if (state == MJRefreshStateIdle || state == MJRefreshStateNoMoreData) {
        [self.btn setTitle:@"点击加载下20条" forState:UIControlStateNormal];
    }else if (state == MJRefreshStateRefreshing || state == MJRefreshStatePulling){
        [self.btn setTitle:@"加载中..." forState:UIControlStateNormal];
    }
    [super setState:state];
}
*/











@end





