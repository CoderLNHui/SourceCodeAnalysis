//
//  ZXModelFactory.h
//  ZX_MBProgressManager
//
//  Created by 赵祥 on 17/3/4.
//  Copyright © 2017年 XZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXModelFactory : NSObject

@property (nonatomic, strong) NSMutableArray *modelArray;

/**
 *创建model
 */
- (void)createHUDTypeModel;

@end
