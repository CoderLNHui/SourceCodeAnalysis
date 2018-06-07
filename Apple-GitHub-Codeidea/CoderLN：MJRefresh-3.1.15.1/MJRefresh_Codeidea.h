/**
 MJRefresh 刷新思想
 
 */

#pragma mark - ↑
#pragma mark - 官方释义
```objc
An easy way to use pull-to-refresh

释义：使用一个简单的方法拉取到刷新
```







#pragma mark - ↑
#pragma mark - 组成（层次结构）->（.h系统文件 -> 作用、使用、注解）

#pragma mark - 组成（层次结构）
/**
 
 ```objc
 MJRefresh 继承UIView的自定义刷新控件
 
 支持哪些类型的刷新❓
 UIScrollView 滚动视图、UITableView 表格视图、UICollectionView 综合视图、UIWebView 网页视图
 
 如何使用MJRefresh❓
 1.用CocoaPods：pod 'MJRefresh'，导入主文件：#import <MJRefresh/MJRefresh.h>
 2.手动导入：导入主文件：#import "MJRefresh.h"
 
 
 - - -
 基础文件❓
 MJRefresh.bundle                作用：快捷获取Bundle中的图片资源 和 本地化语言
 MJRefresh.h                     作用：包含所有的头文件
 MJRefreshConst.h.m              作用：基础宏、常量
 UIScrollView + MJExtension.h.m  作用：给ScrollView增加 快捷设置属性
 UIScrollView + MJRefresh.h.m    作用：给ScrollView增加下拉刷新、上拉刷新的功能
 UIView + MJExtension.h.m        作用：给UIView增加 快捷设置属性
 
 
 - - -
 MJRefresh 类结构
    1、下拉刷新控制类型
    正常：MJRefreshNormalHeader
    GIF：MJRefreshGifHeader

    2、上拉刷新控件类型
    1.自动刷新
    正常：MJRefreshAutoNormalFooter
    GIF：MJRefreshAutoGifFooter
    2.自动返回
    正常：MJRefreshBackNormalFooter
    GIF：MJRefreshBackGifFooter
 
 
 - - -
 【MJ属性默认值】
 const CGFloat MJRefreshLabelLeftInset = 25; //【文字距离圈圈、箭头的距离】
 const CGFloat MJRefreshHeaderHeight = 54.0; //【下拉刷新头部高度】
 const CGFloat MJRefreshFooterHeight = 44.0; //【上拉加载底部高度】
 const CGFloat MJRefreshFastAnimationDuration = 0.25; //【快动画时长】
 const CGFloat MJRefreshSlowAnimationDuration = 0.4; //【慢动画时长】
 
 【MJRefresh-自定义刷新控件】【*子类化AFN*】
 1.#import "LNRefreshNormalHeader.h" //【半自定义下拉刷新控件:继承MJRefreshNormalHeader】
 2.#import "LNRefreshHeader.h" //【完全自定义下拉刷新控件:继承MJRefreshHeader】
 1.#import "LNRefreshAutoNormalFooter.h" //【半自定义上拉更多控件:继承MJRefreshAutoNormalFooter】
 2.#import "LNRefreshFooter.h" //【完全自定义上拉更多控件:继承MJRefreshFooter】
 
 ```
 */









#pragma mark - ↑
#pragma mark -



#### UIRefreshControl
```objc
1、UIRefresh是苹果自带的刷新控件
2、支持iOS6.0之后的版本

- - -

3、基本使用：
// 刷新中得状态判断，只读属性，根据状态可做一些自定义的事情
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

//实例化对象(里面有init,UIRefreshControl的初始化)
UIRefreshControl *control = [[UIRefreshControl alloc] init];

//设置UIRefreshControl控件的颜色(菊花和文字)
control.tintColor = [UIColor redColor];

//添加到tableView中,默认尺寸和位置都已经设置好
[self.tableView addSubview:control];

// 下拉刷新文字描述，自定义
@property (nonatomic, retain) NSAttributedString *attributedTitle

// 开始刷新
- (void)beginRefreshing NS_AVAILABLE_IOS(6_0);

// 结束刷新，在确定获得想要的加载数据之后调用
- (void)endRefreshing NS_AVAILABLE_IOS(6_0);
```








    
#### 场景示例代码
    ```objc
#pragma mark - ↑
#pragma mark UITableView + 下拉刷新 默认
    - (void)example01
{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}
    
    
#pragma mark UITableView + 下拉刷新 动画图片
    - (void)example02
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.tableView.mj_header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}
    
    
#pragma mark UITableView + 下拉刷新 隐藏时间
    - (void)example03
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 马上进入刷新状态
    [header beginRefreshing];
    
    // 设置header
    self.tableView.mj_header = header;
}
    
    
#pragma mark UITableView + 下拉刷新 隐藏状态和时间
    - (void)example04
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    // 马上进入刷新状态
    [header beginRefreshing];
    
    // 设置header
    self.tableView.mj_header = header;
}
    
    
#pragma mark UITableView + 下拉刷新 自定义文字
    - (void)example05
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置文字
    [header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];//普通闲置状态
    [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];//松开就可以进行刷新的状态
    [header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];//正在刷新中的状态
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = [UIColor redColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
    
    // 马上进入刷新状态
    [header beginRefreshing];
    
    // 设置刷新控件
    self.tableView.mj_header = header;
}
    
    
#pragma mark UITableView + 下拉刷新 自定义刷新控件
    - (void)example06
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.tableView.mj_header = [MJDIYHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.mj_header beginRefreshing];
}
    
    
#pragma mark - ↑
#pragma mark UITableView + 上拉刷新 默认
    - (void)example11
{
    [self example01];
    
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    //    ((MJRefreshAutoFooter *)self.tableView.mj_footer).onlyRefreshPerDrag = YES;
}
    
    
#pragma mark UITableView + 上拉刷新 动画图片
    - (void)example12
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    self.tableView.mj_footer = [MJChiBaoZiFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}
    
    
#pragma mark UITableView + 上拉刷新 隐藏刷新状态的文字
    - (void)example13
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 当上拉刷新控件出现50%时（出现一半），就会自动刷新。这个值默认是1.0（也就是上拉刷新100%出现时，才会自动刷新）
    //    footer.triggerAutomaticallyRefreshPercent = 0.5;
    
    // 隐藏刷新状态的文字
    footer.refreshingTitleHidden = YES;
    
    // 设置footer
    self.tableView.mj_footer = footer;
}
    
    
#pragma mark UITableView + 上拉刷新 全部加载完毕
    - (void)example14
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadLastData方法）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadLastData)];
    
    // 其他
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"恢复数据加载" style:UIBarButtonItemStyleDone target:self action:@selector(reset)];
}
    
    - (void)reset
{
    [self.tableView.mj_footer setRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.tableView.mj_footer resetNoMoreData];
}
    
    
#pragma mark UITableView + 上拉刷新 禁止自动加载
    - (void)example15
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 禁止自动加载
    footer.automaticallyRefresh = NO;
    
    // 设置footer
    self.tableView.mj_footer = footer;
}
    
    
#pragma mark UITableView + 上拉刷新 自定义文字
    - (void)example16
{
    [self example01];
    
    // 添加默认的上拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置文字
    [footer setTitle:@"Click or drag up to refresh" forState:MJRefreshStateIdle];
    [footer setTitle:@"Loading more ..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"No more data" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = [UIColor blueColor];
    
    // 设置footer
    self.tableView.mj_footer = footer;
}
    
    
#pragma mark UITableView + 上拉刷新 加载后隐藏
    - (void)example17
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadOnceData方法）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOnceData)];
}
    
    
#pragma mark UITableView + 上拉刷新 自动回弹的上拉01
    - (void)example18
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}
    
    
#pragma mark UITableView + 上拉刷新 自动回弹的上拉02
    - (void)example19
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadLastData方法）
    self.tableView.mj_footer = [MJChiBaoZiFooter2 footerWithRefreshingTarget:self refreshingAction:@selector(loadLastData)];
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
}
    
    
#pragma mark UITableView + 上拉刷新 自定义刷新控件(自动刷新)
    - (void)example20
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    self.tableView.mj_footer = [MJDIYAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}
    
    
#pragma mark UITableView + 上拉刷新 自定义刷新控件(自动回弹)
    - (void)example21
{
    [self example01];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    self.tableView.mj_footer = [MJDIYBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}
    
    
    
#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
    - (void)loadNewData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.data insertObject:MJRandomData atIndex:0];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    __weak UITableView *tableView = self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [tableView reloadData];
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [tableView.mj_header endRefreshing];
    });
}
    
    
#pragma mark 上拉加载更多数据
    - (void)loadMoreData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.data addObject:MJRandomData];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    __weak UITableView *tableView = self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [tableView.mj_footer endRefreshing];
    });
}
    
    
#pragma mark 加载最后一份数据
    - (void)loadLastData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.data addObject:MJRandomData];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    __weak UITableView *tableView = self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [tableView reloadData];
        
        // 拿到当前的上拉刷新控件，变为没有更多数据的状态
        [tableView.mj_footer endRefreshingWithNoMoreData];
    });
}
    
    
#pragma mark 只加载一次数据
    - (void)loadOnceData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.data addObject:MJRandomData];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    __weak UITableView *tableView = self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [tableView reloadData];
        
        // 隐藏当前的上拉刷新控件
        tableView.mj_footer.hidden = YES;
    });
}
    
    
#pragma mark 初始化默认数据
    - (NSMutableArray *)data
{
    if (!_data) {
        self.data = [NSMutableArray array];
        for (int i = 0; i<5; i++) {
            [self.data addObject:MJRandomData];
        }
    }
    return _data;
}
    ```
    
    
    
    
#### 基本使用
    ```objc
#pragma mark - 下拉刷新
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    // 进入刷新状态后会自动调用这个block
}];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
    
    //自动更改透明度
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    //进入刷新状态
    [self.tableView.mj_header beginRefreshing];
    
    - - -
#pragma mark - 上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
    //结束头部刷新
    [weakSelf.tableView.mj_header endRefreshing];
    
    //结束尾部刷新
    [weakSelf.tableView.mj_footer endRefreshing];
    ```




    
    
#### MJRefresh自定义控件
    ```objc
    @interface LNRefreshNormalHeader () //继承MJRefreshNormalHeader
/** logo */
    @property (nonatomic, weak) UIImageView *logo;
    @end
    @implementation LNRefreshNormalHeader
    - (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //--------------------------- 【MJ基本常用属性】 ------------------------------//
        //
        //【设置文字】
        [self setTitle:@"大牛！下拉试试刷新" forState:MJRefreshStateIdle]; //【普通状态下文字】
        [self setTitle:@"大牛！松开就可以刷新" forState:MJRefreshStatePulling]; //【松开就可以进行刷新的状态下文字】
        [self setTitle:@"大牛！正在刷新中勿骚动" forState:MJRefreshStateRefreshing]; //【正在刷新中的状态下文字】
        
        //【设置字体】
        self.stateLabel.font = [UIFont systemFontOfSize:20.f];
        self.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14.f];
        
        //【设置颜色】
        self.stateLabel.textColor = [UIColor redColor];
        self.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
        
        //【隐藏Label】
        //self.stateLabel.hidden = YES; //【隐藏文字Label】
        //self.lastUpdatedTimeLabel.hidden = YES; //【隐藏时间Label】
        
        //【自动切换透明度】
        self.automaticallyChangeAlpha = YES;
        //【文字距离圈圈、箭头的距离】
        self.labelLeftInset = 25;
        //【设置刷新控件高度】
        //self.ln_height = 70;
        
        //【设置顶部logo】
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
        [self addSubview:logo];
        self.logo = logo;
    }
    return self;
}
    - (void)layoutSubviews
{
    [super layoutSubviews];
    self.logo.ln_centerX = self.ln_width *0.5;
    self.logo.ln_y = - self.ln_height;
}
    ```
 
