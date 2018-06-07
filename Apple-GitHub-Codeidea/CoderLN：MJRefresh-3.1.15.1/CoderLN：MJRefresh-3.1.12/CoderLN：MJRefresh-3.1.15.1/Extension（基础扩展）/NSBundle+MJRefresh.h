//
//  NSBundle+MJRefresh.h
//  MJRefreshExample
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

/**
 作用：
 快捷获取Bundle中的图片资源 和 本地化语言
 */

#import <UIKit/UIKit.h>

@interface NSBundle (MJRefresh)
+ (instancetype)mj_refreshBundle;
+ (UIImage *)mj_arrowImage;
+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)mj_localizedStringForKey:(NSString *)key;
@end
