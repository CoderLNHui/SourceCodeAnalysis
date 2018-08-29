//
//  ZXHUDTypeCell.h
//  ZX_MBProgressManager
//
//  Created by 赵祥 on 17/3/4.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXHUDTypeModel;

@interface ZXHUDTypeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)configHUDCellWithModel:(ZXHUDTypeModel *)model;

@end
