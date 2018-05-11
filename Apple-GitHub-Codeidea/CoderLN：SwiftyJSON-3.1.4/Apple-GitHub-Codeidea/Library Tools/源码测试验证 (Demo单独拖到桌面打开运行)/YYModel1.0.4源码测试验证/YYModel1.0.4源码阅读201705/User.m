//
//  User.m
//  YYModel1.0.4源码阅读201705
//
//  Created by huangchengdu on 17/5/4.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#import "User.h"

@interface User ()<protocolTest>
{
    NSString *ivarTest;
}
@end


@implementation User

-(instancetype)init{
    self = [super init];
    if (self) {
        self.testProtocol = self;
    }
    return self;
}

-(void)doTest{

}

@end
