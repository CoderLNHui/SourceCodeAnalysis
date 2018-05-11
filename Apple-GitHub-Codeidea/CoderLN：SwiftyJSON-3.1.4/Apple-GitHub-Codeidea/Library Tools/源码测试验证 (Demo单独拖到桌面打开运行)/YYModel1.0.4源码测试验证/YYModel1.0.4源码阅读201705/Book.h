//
//  Book.h
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/4.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Author.h"
@interface Book : NSObject
@property NSString *name;
@property NSUInteger pages;
@property Author *author; //Book 包含 Author 属性

@end
