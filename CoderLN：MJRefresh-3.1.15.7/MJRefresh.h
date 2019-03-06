//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000

#import "UIScrollView+MJRefresh.h"
#import "UIScrollView+MJExtension.h"
#import "UIView+MJExtension.h"

#import "MJRefreshNormalHeader.h"
#import "MJRefreshGifHeader.h"

#import "MJRefreshBackNormalFooter.h"
#import "MJRefreshBackGifFooter.h"
#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshAutoGifFooter.h"

 

#pragma mark - MJRefresh_3.1.15.7 更新目录
/**
 Fix UIScrollView+MJExtension.h
 @CoderMJLee CoderMJLee released this on 20 Aug 2018 · 3 commits to master since this release
 这是2018年8月20日发布
 
 replace "respondsToSelector" by "instancesRespondToSelector"
 用“instancesRespondToSelector”替换“respondsToSelector”
 
 
 Merge pull request #1197 from sxdxzkq/master
 解决滑动手势中断带来的计算失误(下拉刷新位置计算错误)
 
 */



#pragma mark - MJRefresh 层次结构
/**
 MJRefresh 继承UIView的自定义刷新控件；扩展性强（半自定义继承刷新控件 || 完全自定义刷新控件）
 
 1、支持哪些类型的刷新❓
    UIScrollView 滚动视图、UITableView 表格视图、UICollectionView 综合视图、UIWebView 网页视图
 
 2、如何使用MJRefresh❓
    1.用CocoaPods：pod 'MJRefresh'，导入主文件：#import <MJRefresh/MJRefresh.h>
    2.手动导入：导入主文件：#import "MJRefresh.h"
 
 3、基础文件❓
    MJRefresh.bundle                作用：快捷获取Bundle中的图片资源 和 本地化语言
    MJRefresh.h                     作用：包含所有的头文件
    MJRefreshConst.h.m              作用：基础宏、常量
    UIScrollView + MJExtension.h.m  作用：给ScrollView增加 快捷设置属性
    UIScrollView + MJRefresh.h.m    作用：给ScrollView增加下拉刷新、上拉刷新的功能
    UIView + MJExtension.h.m        作用：给UIView增加 快捷设置属性
 
 4、MJRefresh 类结构
 1、下拉刷新控件类型
    正常：MJRefreshNormalHeader
    GIF：MJRefreshGifHeader
 2、上拉刷新控件类型
    1.自动刷新
    正常：MJRefreshAutoNormalFooter
    GIF：MJRefreshAutoGifFooter
    2.自动返回
    正常：MJRefreshBackNormalFooter
    GIF：MJRefreshBackGifFooter
 
 5、MJRefresh属性默认值
 const CGFloat MJRefreshLabelLeftInset = 25; //【文字距离圈圈、箭头的距离】
 const CGFloat MJRefreshHeaderHeight = 54.0; //【下拉刷新头部高度】
 const CGFloat MJRefreshFooterHeight = 44.0; //【上拉加载底部高度】
 const CGFloat MJRefreshFastAnimationDuration = 0.25; //【快动画时长】
 const CGFloat MJRefreshSlowAnimationDuration = 0.4; //【慢动画时长】
 */



#pragma mark -MJRefresh 实现原理
/**
 MJRefresh的刷新控件的基类是MJRefreshComponent继承于UIView的自定义控件。内部以UIScrollView作为父控件来添加KVO监听，监听ContentOffset/ContentSize/拖动状态 的改变。判断contentOffset改变并做出相应处理。
 而刷新控件，比如下拉刷新控件的位置是插入（insertSubview:0）最底部，y值为（scrollView的contentInset的top + 控件自身的高度和的负值）。
 而上拉加载控件的位置是 self.mj_y = MAX(contentHeight 内容的高度, scrollHeight 表格的高度);
 */














#pragma mark - MJRefresh 基本使用
/**
 // MJ下拉刷新
 MJRefreshNormalHeader * normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
 // 下拉刷新控件自动改变透明度
 normalHeader.automaticallyChangeAlpha = YES;
 // 隐藏刷新时间
 normalHeader.lastUpdatedTimeLabel.hidden = YES;
 // 隐藏状态文字
 normalHeader.stateLabel.hidden = YES;
 // 设置header
 self.tableView.mj_header = normalHeader;
 // 设置自动刷新
 [normalHeader beginRefreshing];
 
 // MJ上拉加载
 self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
 */



























































































