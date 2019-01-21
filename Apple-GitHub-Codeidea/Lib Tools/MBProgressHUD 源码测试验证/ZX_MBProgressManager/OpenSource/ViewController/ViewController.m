//
//  ViewController.m
//  ZX_MBProgressManager
//
//  Created by 赵祥 on 17/3/4.
//  Copyright © 2017年 XZ. All rights reserved.
//
/************************************************************
 NOTE：
    Author：https://www.jianshu.com/p/992074d2016b
    GitHubUser：XXShao
    Blog：
 *************************************************************/


#import "ViewController.h"
#import "ZXModelFactory.h"
#import "ZXHUDTypeCell.h"
#import "ZXHUDTypeModel.h"
#import "XZMBProgressManager.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ZXModelFactory *modelFactory;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat progressValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = rgb(248, 248, 248);
    _progressValue = 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelFactory.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZXHUDTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Test_HUDTypeCell" forIndexPath:indexPath];
    ZXHUDTypeModel *model = self.modelFactory.modelArray[indexPath.row];
    [cell configHUDCellWithModel:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            [XZMBProgressManager XZ_showLoadingOrdinary:@"显示中"];
        }
            break;
        case 1: {
            /**
             *可以通过XZ_showHUDCustom 方法自定义想显示的方式，或是新加公共方法
             *通过链式编程封装，一句代码传入想要的参数
             */
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeText).message(@"纯文字显示");
            }];
        }
            break;
        case 2: {
            [XZMBProgressManager XZ_showHUDWithError:@"错误提示"];
        }
            break;
        case 3: {
            [XZMBProgressManager XZ_showHUDWithWarning:@"警告提示"];
        }
            break;
        case 4: {
            [XZMBProgressManager XZ_showHUDWithText:@"文字提示"];
        }
            break;
        case 5: {
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeCustomView).imageStr(@"主页_我的").message(@"自定义图片");
            }];
        }
            break;
        case 6: {
            NSArray *imageArray = @[[UIImage imageNamed:@"11"],
                                    [UIImage imageNamed:@"22"],
                                    [UIImage imageNamed:@"33"],
                                    [UIImage imageNamed:@"44"],
                                    [UIImage imageNamed:@"55"],
                                    [UIImage imageNamed:@"66"],
                                    [UIImage imageNamed:@"77"]];
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeCustomView).animationDuration(0.4).imageArray(imageArray).message(@"动态图片");
            }];
        }
            break;
        case 7: {
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeAnnularDeterminate).message(@"环形进度条1");
            }];
            [self.timer fire];
        }
            break;
        case 8: {
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeDeterminate).message(@"环形进度条2");
            }];
            [self.timer fire];
        }
            break;
        case 9: {
            [XZMBProgressManager XZ_showHUDCustom:^(XZMBProgressManager *make) {
                make.hudMode(MBProgressHUDModeDeterminateHorizontalBar).message(@"条形进度条");
            }];
            [self.timer fire];
        }
            break;
        default:
            break;
    }
    
    [self dismissHUDWithIndex:indexPath];
    
    
}

- (void)dismissHUDWithIndex:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [XZMBProgressManager XZ_showHUDWithSuccess:@"成功提示"];
            });
        }
            break;
        case 1: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [XZMBProgressManager XZ_showHUDWithSuccess:@"成功提示"];
            });
        }
            break;
        case 5: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [XZMBProgressManager XZ_showHUDWithSuccess:@"成功提示"];
            });
        }
            break;
        case 6: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [XZMBProgressManager XZ_showHUDWithSuccess:@"成功提示"];
            });
        }
            break;
        default:
            break;
    }
}

- (void)changeProgressValue {
    _progressValue += 0.01;
    
    [XZMBProgressManager XZ_uploadProgressOrdinary:_progressValue];
    if ([@(_progressValue) integerValue] == 1) {
        [XZMBProgressManager XZ_showHUDWithSuccess:@"成功提示"];
        [_timer invalidate];
        _timer = nil;
        _progressValue = 0;
    }
}


#pragma mark - Preperty
- (ZXModelFactory *)modelFactory {
    if (!_modelFactory) {
        _modelFactory = [[ZXModelFactory alloc] init];
        [_modelFactory createHUDTypeModel];
    }
    return _modelFactory;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeProgressValue) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
