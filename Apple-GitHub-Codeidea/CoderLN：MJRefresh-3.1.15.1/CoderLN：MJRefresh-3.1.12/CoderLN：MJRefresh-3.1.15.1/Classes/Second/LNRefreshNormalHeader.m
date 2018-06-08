//
//  LNRefreshNormalHeader.m
//  MJRefreshExample
//
//  Created by LN on 2018/6/7.
//  Copyright © 2018年 小码哥. All rights reserved.
//

#import "LNRefreshNormalHeader.h"

@interface LNRefreshNormalHeader ()

@property (nonatomic, strong) UIImageView * logoImg;// 头部刷新

@end

@implementation LNRefreshNormalHeader


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
    [self setTitle:@"Codeidea 下拉试试刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松开就可以刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新中勿骚动" forState:MJRefreshStateRefreshing];
 
    // 设置文字大小
    self.stateLabel.font = [UIFont systemFontOfSize:14.f];
    self.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:16.f];
    
    // 设置文字颜色
    // 设置stateLabel文字颜色同时系统箭头会被渲染❓
    self.stateLabel.textColor = [UIColor cyanColor];
    self.lastUpdatedTimeLabel.textColor = [UIColor redColor];
    
    // 设置隐藏状态文字
//    self.stateLabel.hidden = YES;
//    self.lastUpdatedTimeLabel.hidden = YES;
    
    // 设置自动切换透明度
    self.automaticallyChangeAlpha = YES;
    
    // 设置文字距离圈圈、箭头的距离（默认25）
    //self.labelLeftInset = 80;
    
    // 设置刷新控件高度（HeaderHeight = 54.0；FooterHeight = 44.0；）
    //self.mj_h = 100;
    
    // 设置正在刷新状态下小菊花的样式
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    
    
 
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
    self.logoImg.mj_y = - self.mj_h;
}


// 3.重写模型类set方法 赋值属性值




/**
 场景需求：1、设置文字距离圈圈、箭头的距离（默认25）2、修改刷新图片arrowView)❓
 解决：
 重写【placeSubviews】的set方法
 */
- (void)placeSubviews
{
    [super placeSubviews];

    self.arrowView.mj_x = 20;
    [self setValue:@(self.arrowView.mj_x) forKeyPath:@"_loadingView.mj_x"];

    // 设置自定义MJ刷新箭头的图片，怎么设置图片的大小❓
    [self setValue:[UIImage imageNamed:@"自定义MJ刷新箭头"] forKeyPath:@"_arrowView.image"];
}





/**
 场景需求：
 下拉刷新时间Label显示格式：2015-01-15 15:45:33 下午❓
 解决：
 重写【lastUpdatedTimeKey:】的set方法（这个key用来存储上一次下拉刷新成功的时间），修改时间显示格式。
 */
// 重写：这个key用来存储上一次下拉刷新成功的时间
- (void)setLastUpdatedTimeKey:(NSString *)lastUpdatedTimeKey
{
    [super setLastUpdatedTimeKey:lastUpdatedTimeKey];
    
    NSDate *lastTime = self.lastUpdatedTime;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSInteger hour = [[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:lastTime];
    if (hour >12) {
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss 下午";
    }else{
        
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss 上午";
    }
    NSString *timeStr = [fmt stringFromDate:lastTime];
    self.lastUpdatedTimeLabel.text = timeStr;
}




@end





























