//
//  LNRefreshGifHeader.m
//  LNBaisibudejie
//
//  Created by LN on 2018/7/19.
//  Copyright © 2018年 Public-CoderLN. All rights reserved.
//
/**
 
 @property (weak, nonatomic, readonly) UIImageView *gifView;
 
 /设置state状态下的动画图片images 动画持续时间duration
 - (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state;
 - (void)setImages:(NSArray *)images forState:(MJRefreshState)state;
 */

#import "LNRefreshGifHeader.h"

@interface LNRefreshGifHeader ()

@end

@implementation LNRefreshGifHeader


// @interface LNRefreshGifHeader : MJRefreshGifHeader
// typedef NS_ENUM(NSInteger, MJRefreshState) {
//     /** 普通闲置状态 */
//    MJRefreshStateIdle = 1,
//    /** 松开就可以进行刷新的状态 */
//    MJRefreshStatePulling,
//    /** 正在刷新中的状态 */
//    MJRefreshStateRefreshing,
//    /** 即将刷新的状态 */
//    MJRefreshStateWillRefresh,
//    /** 所有数据加载完毕，没有更多的数据了 */
//    MJRefreshStateNoMoreData
//};

#pragma mark - 重写方法
#pragma mark 准备工作
- (void)prepare
{
    [super prepare];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
    
    // 隐藏时间和状态、自动改变透明度，效果：只显示一个吃包子的Gif动画
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
    self.automaticallyChangeAlpha = YES;
}








@end
