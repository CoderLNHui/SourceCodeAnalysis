//
//  ViewController.m
//  CoderLN-MJRefresh
//


#import "ViewController.h"
#import "MJRefresh.h"
@interface ViewController ()
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIView * testView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeaderClick)];
    
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:nil];
    
}


- (void)refreshHeaderClick{}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
