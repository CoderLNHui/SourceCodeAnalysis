//
//  LNBaseModel.h
//  CoderLN：MJExtension-3.0.13
//
//  Created by LN on 2018/6/8.
//  Copyright © 2018年 LN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNBaseModel : NSObject


//id
@property(nonatomic,copy)NSString *ID;
//通过字典来创建一个模型
+ (instancetype)objectWithDic:(NSDictionary*)dic;

//通过JSON字符串转模型
+ (instancetype)objectWithJSONStr:(NSString *)jsonStr;

//通过字典数组来创建一个模型数组
+ (NSArray*)objectsWithArray:(NSArray<NSDictionary*>*)arr;
 

@end
