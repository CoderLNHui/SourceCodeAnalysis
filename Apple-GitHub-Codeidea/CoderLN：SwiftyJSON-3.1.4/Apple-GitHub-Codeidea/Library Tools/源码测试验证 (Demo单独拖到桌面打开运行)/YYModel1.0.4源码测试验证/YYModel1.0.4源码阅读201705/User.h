//
//  User.h
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/4.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol protocolTest <NSObject>

-(void)doTest;
@end

@interface User : NSObject
@property UInt64 uid;
@property NSString *name;
@property NSDate *created;
@property id<protocolTest> testProtocol;
@end
