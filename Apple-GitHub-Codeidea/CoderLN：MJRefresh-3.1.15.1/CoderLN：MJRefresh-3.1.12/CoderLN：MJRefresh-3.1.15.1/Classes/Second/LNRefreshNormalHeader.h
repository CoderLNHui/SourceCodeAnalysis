//
//  LNRefreshNormalHeader.h
//  MJRefreshExample
//
//  Created by LN on 2018/6/7.
//  Copyright © 2018年 小码哥. All rights reserved.
//

/**
 继承 MJRefreshNormalHeader 半自定义头部下拉刷新控件
 */

#import "MJRefreshNormalHeader.h"

@interface LNRefreshNormalHeader : MJRefreshNormalHeader



/**
 外界使用：
 #pragma mark UITableView + 下拉刷新 自定义文字
 
 
 
 LNRefreshNormalHeader * header = [LNRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
 
 [header beginRefreshing];// 开始刷新
 self.tableView.mj_header = norHeader;// 设置头部控件
 
 
 数据请求下来后
 [tableView reloadData];// 刷新表格
 [header endRefreshing];// 结束刷新
 */
@end
