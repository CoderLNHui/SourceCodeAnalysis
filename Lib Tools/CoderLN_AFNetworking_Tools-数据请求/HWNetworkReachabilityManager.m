//
//  HWNetworkReachabilityManager.m
//  HWProject
//
//  Created by wangqibin on 2018/5/18.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWNetworkReachabilityManager.h"

@interface HWNetworkReachabilityManager ()

@property (nonatomic, assign, readwrite) AFNetworkReachabilityStatus networkReachabilityStatus;

@end

@implementation HWNetworkReachabilityManager

+ (instancetype)shareManager
{
    static HWNetworkReachabilityManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

// 监听网络状态
- (void)monitorNetworkStatus
{
    // 创建网络监听者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];

    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                // 未知网络
                HWLog(@"当前网络：未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                // 无网络
                HWLog(@"当前网络：无网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                // 蜂窝数据
                HWLog(@"当前网络：蜂窝数据");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // 无线网络
                HWLog(@"当前网络：无线网络");
                break;
                
            default:
                break;
        }
        
        if (_networkReachabilityStatus != status) {
            _networkReachabilityStatus = status;
            // 网络改变通知
            [[NSNotificationCenter defaultCenter] postNotificationName:HWNetworkingReachabilityDidChangeNotification object:[NSNumber numberWithInteger:status]];
        }
    }];
    
    // 开始监听
    [manager startMonitoring];
}

@end
