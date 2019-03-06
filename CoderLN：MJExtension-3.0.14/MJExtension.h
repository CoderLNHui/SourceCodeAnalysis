//
//  MJExtension.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//  代码地址:https://github.com/CoderMJLee/MJExtension
//  代码地址:http://code4app.com/ios/%E5%AD%97%E5%85%B8-JSON-%E4%B8%8E%E6%A8%A1%E5%9E%8B%E7%9A%84%E8%BD%AC%E6%8D%A2/5339992a933bf062608b4c57


#import "NSObject+MJCoding.h"
#import "NSObject+MJProperty.h"
#import "NSObject+MJClass.h"
#import "NSObject+MJKeyValue.h"
#import "NSString+MJExtension.h"
#import "MJExtensionConst.h"


#pragma mark - CoderLN：MJExtension-3.0.14 更新目录
/**
 调整细节
 @CoderMJLee CoderMJLee released this on 29 May 2018 · 17 commits to master since this release
 于2018年5月29日发布
 
 1.合理调整全局变量的创建时间
 2.线程同步
 */






#pragma mark - MJExtension 实现原理
/**
 由于MJExtension是给NSObject增加了categor，因此使用该框架不需要修改数据model的继承关系,无代码入侵.
 MJExtension 底层是使用runtime获取模型类和其所有父类所有的成员变量，遍历成员变量拿到属性名在数据字典中获取对应的值,然后通过setValue:forKey设置属性的值.
 
 
 而使用KVC字典转模型方法 setValuesForKeysWithDictionary:，是通过先遍历字典中所有key，再调用setValue:forkey方法，去模型中查找有没有key对应属性。必须要保证模型中的属性名要和字典中的key一一对应,否则使用KVC运行时会报错（类与键值编码器不兼容错误）。解决报错就是重写系统方法setValue:forUndefinedKey:去除报错。如果模型中带有模型型，`setValuesForKeysWithDictionary` 也不能用。
 
 */



#pragma mark -MJExtension 字典转模型
/**
 1、MJExtension是一套字典和模型之间互相转换的超轻量级框架
 2、MJExtension能完成的功能
 1.字典 --> 模型
    简单的字典   --> 模型 mj_objectWithKeyValues:

    JSON字符串  --> 模型 mj_objectWithKeyValues:

    复杂的字典   --> 模型 (模型中嵌套模型：字典 -> 字典 -> 字典 -> 属性)
    mj_objectWithKeyValues:
    NSString *name = status.user.name;//两层字典
    NSString *name2 = status.retweetedStatus.user.name;//三层字典

    复杂的字典   --> 模型 (模型的数组属性里面又装着模型：字典 -> 数组 -> 字典 -> 属性)
    mj_setupObjectClassInArray: -> return @[@"ads" : [Ad class]] 在转化前，指定数组类。
    mj_objectWithKeyValues:

    复杂的字典   --> 模型（模型属性名和字典的key不一样。替换key：如ID和id；需要多级映射：如 oldName 和 name.oldName）
    mj_setupReplacedKeyFromPropertyName: -> return @[@"desc" : @"description"] 在转化前，指定不一样的模型属性名和字典的key。
    mj_objectWithKeyValues:
 
 2.模型 --> 字典
    字典数组 --> 模型数组 mj_objectArrayWithKeyValuesArray:

    模型 --> 字典 stu.mj_keyValues;

    模型数组 --> 字典数组 mj_keyValuesArrayWithObjectArray:

    字典 --> CoreData模型 [User mj_objectWithKeyValues:dict context:context];

 3.归档与解档 NSCoding示例
    统一转换属性名（比如驼峰转下划线）
    过滤字典的值（比如字符串日期处理为NSDate：如 2011-09-10 =》Sat Sep 10 00:00:00 2011、字符串nil处理为@""）
 
 
 其它功能：
 1. 设置类属性的黑白名单,可以定向解析或忽略某些属性
    NSObject+MJKeyValue - mj_keyValuesWithKeys:
 
 2. 对类属性的缓存,解析一次该类的属性之后,下次不会重复解析.
    NSObject+MJProperty - properties
 
 
 3.动态修改某些值特性的属性值
 NSObject+MJKeyValue - 
     在自己定义的数据model中可以通过实现 mj_newValueFromOldValue:property: 方法来替换某些属性的值.
     例如:在TestModel中写以下代码,可以实现给名为testProperty的属性赋值为testValue;
    - (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
        if ([property.name isEqualToString:@"testProperty"]) {
            return @"testValue";
        } else {
            return oldValue;
        }
    }
 
 
 NSObject+MJClass - mj_enumerateClasses:
 主要作用:遍历所有的父类,用于获取父类的属性.
 
 NSObject+MJKeyValue - mj_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
 主要作用: 遍历该类所有的属性(包括定义在父类中的属性),封装成MJProperty类型返回. 并根据MJProperty中定义的属性名从数据字典中取值(这里要求字典中的key值的名称与属性名相同), 赋值给model的属性.
 
 NSObject+MJProperty - mj_enumerateProperties:
 主要作用: 获取属性并封装成MJProperty的具体实现
 
 */


#pragma mark - MJExtension中的核心代码,包括其用到的runtime API
/**
 // ***** 获取父类, 返回Class
 class_getSuperclass(Class _Nullable cls)
 
 // ***** 获取属性列表, 返回数据类型 objc_property_t * 数组.
 class_copyPropertyList(Class _Nullable cls, unsigned int * _Nullable outCount)
 // 示例:
 unsigned int outCount = 0;
 objc_property_t *properties = class_copyPropertyList(c, &outCount);
 
 
 // ***** 获取属性名,返回char *类型,可转为NSString.
 property_getName(objc_property_t _Nonnull property)
 // 示例:
 objc_property_t property;
 NSString *name = @(property_getName(property));
 
 
 // ***** 获取property的attribute,返回char *类型,可转为NSString. 用于获取property的类型
 property_getAttributes(objc_property_t _Nonnull property)
 // 示例:
 objc_property_t property;
 NSString *attrs = @(property_getAttributes(property));
 
 // ***** 使用KVO给数据model的property赋值,value为字典中取出的数据, key为数据模型object的属性名.
 [object setValue:value forKey:key];
 
 
 就是使用runtime获取该类和其所有父类的所有的属性名,并根据属性名在数据字典中获取对应的值,然后通过setValue:forKey设置属性的值.
 */





 














