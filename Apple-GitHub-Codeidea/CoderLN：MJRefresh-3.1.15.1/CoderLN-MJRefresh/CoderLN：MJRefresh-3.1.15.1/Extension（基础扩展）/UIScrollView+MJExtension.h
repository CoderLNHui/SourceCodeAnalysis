//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+Extension.h
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//
/**
 作用：
 给ScrollView增加 快捷设置属性
 */


#import <UIKit/UIKit.h>

@interface UIScrollView (MJExtension)
@property (readonly, nonatomic) UIEdgeInsets mj_inset;

// 上下左右
@property (assign, nonatomic) CGFloat mj_insetT;
@property (assign, nonatomic) CGFloat mj_insetB;
@property (assign, nonatomic) CGFloat mj_insetL;
@property (assign, nonatomic) CGFloat mj_insetR;

// 偏移量X、偏移量Y
@property (assign, nonatomic) CGFloat mj_offsetX;
@property (assign, nonatomic) CGFloat mj_offsetY;

// 内容宽W、内容高H
@property (assign, nonatomic) CGFloat mj_contentW;
@property (assign, nonatomic) CGFloat mj_contentH;
@end
