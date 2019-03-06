//
//  ZXHUDTypeCell.m
//  ZX_MBProgressManager
//
//  Created by 赵祥 on 17/3/4.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import "ZXHUDTypeCell.h"
#import "ZXHUDTypeModel.h"

@implementation ZXHUDTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configHUDCellWithModel:(ZXHUDTypeModel *)model {
    _nameLabel.text = model.nameString;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
