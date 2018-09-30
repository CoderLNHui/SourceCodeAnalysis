//
//  ZXModelFactory.m
//  ZX_MBProgressManager
//
//  Created by 赵祥 on 17/3/4.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import "ZXModelFactory.h"
#import "ZXHUDTypeModel.h"

@implementation ZXModelFactory

- (void)createHUDTypeModel {
    ZXHUDTypeModel * model1 = [[ZXHUDTypeModel alloc] initWithNameString:@"普通菊花等待（完成自动消失）"];
    ZXHUDTypeModel * model2 = [[ZXHUDTypeModel alloc] initWithNameString:@"普通文字显示（完成自动消失）"];
    ZXHUDTypeModel * model3 = [[ZXHUDTypeModel alloc] initWithNameString:@"错误提示"];
    ZXHUDTypeModel * model4 = [[ZXHUDTypeModel alloc] initWithNameString:@"警告提示"];
    ZXHUDTypeModel * model5 = [[ZXHUDTypeModel alloc] initWithNameString:@"文字提示"];
    ZXHUDTypeModel * model6 = [[ZXHUDTypeModel alloc] initWithNameString:@"自定义图片"];
    ZXHUDTypeModel * model7 = [[ZXHUDTypeModel alloc] initWithNameString:@"动态图"];
    ZXHUDTypeModel * model8 = [[ZXHUDTypeModel alloc] initWithNameString:@"环形进度条1"];
    ZXHUDTypeModel * model9 = [[ZXHUDTypeModel alloc] initWithNameString:@"环形进度条2"];
    ZXHUDTypeModel * model10 = [[ZXHUDTypeModel alloc] initWithNameString:@"条形进度条"];
    _modelArray = [NSMutableArray arrayWithObjects:model1,model2,model3,model4,model5,model6,model7,model8,model9,model10, nil];
}

@end
