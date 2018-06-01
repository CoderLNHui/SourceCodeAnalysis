//
//  TableViewController.m
 

#import "TableViewController.h"
#import "MBProgressHUD+WBAddtional.h"
@interface TableViewController ()

@end

@implementation TableViewController
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            {
                [MBProgressHUD maskLayerEnabled:NO];
                [MBProgressHUD showActivity];
            }
            break;
        case 1:
        {
            [MBProgressHUD maskLayerEnabled:NO];
            [MBProgressHUD showActivityMessage:@"加载中..."];
        }
            break;
        case 2:
        {
            [MBProgressHUD showSuccess:@"登录成功" completion:nil];
        }
            break;
        case 3:
        {
            [MBProgressHUD showError:@"失败提示" completion:nil];
        }
            break;
        case 4:
        {
            [MBProgressHUD showInfo:@"信息提示" completion:nil];
        }
            break;
        case 5:
        {
            [MBProgressHUD showWarning:@"警告提示" completion:nil];
        }
            break;
        case 6:
        {
            [MBProgressHUD showMessage:@"文字提示" completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source



@end
