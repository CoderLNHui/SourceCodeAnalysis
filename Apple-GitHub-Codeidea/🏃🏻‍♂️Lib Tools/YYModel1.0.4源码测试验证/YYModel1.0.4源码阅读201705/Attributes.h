//
//  Attributes.h
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/4.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@class Author;
@interface Attributes : NSObject
@property NSString *name;
@property NSArray *users;
@property NSMutableDictionary<NSString *,Author *> *authors;
@end
