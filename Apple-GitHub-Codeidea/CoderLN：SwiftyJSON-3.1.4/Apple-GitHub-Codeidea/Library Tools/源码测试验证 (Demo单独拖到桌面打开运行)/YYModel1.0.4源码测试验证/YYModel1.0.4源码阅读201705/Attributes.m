//
//  Attributes.m
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/4.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "Attributes.h"
#import "User.h"
#import "Author.h"
@implementation Attributes
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [User class],
             @"authors" : @"Author" };
}
@end
