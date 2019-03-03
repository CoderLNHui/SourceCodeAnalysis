//
//  HWNetworkReachabilityManager.h
//  HWProject
//
//  Created by wangqibin on 2018/5/18.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "AFNetworkReachabilityManager.h"

@interface HWNetworkReachabilityManager : NSObject

// 当前网络状态
@property (nonatomic, assign, readonly) AFNetworkReachabilityStatus networkReachabilityStatus;

// 获取单例
+ (instancetype)shareManager;

// 监听网络状态
- (void)monitorNetworkStatus;

@end
