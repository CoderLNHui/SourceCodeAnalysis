//
//  YYClassInfo.h
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
iOS的encoding编码类型枚举。包括成员变量、属性、访问控制的encoding类型枚举
 */
typedef NS_OPTIONS(NSUInteger, YYEncodingType) {
    YYEncodingTypeMask       = 0xFF, ///< mask of type value
    YYEncodingTypeUnknown    = 0, ///< unknown
    YYEncodingTypeVoid       = 1, ///< void
    YYEncodingTypeBool       = 2, ///< bool
    YYEncodingTypeInt8       = 3, ///< char / BOOL
    YYEncodingTypeUInt8      = 4, ///< unsigned char
    YYEncodingTypeInt16      = 5, ///< short
    YYEncodingTypeUInt16     = 6, ///< unsigned short
    YYEncodingTypeInt32      = 7, ///< int
    YYEncodingTypeUInt32     = 8, ///< unsigned int
    YYEncodingTypeInt64      = 9, ///< long long
    YYEncodingTypeUInt64     = 10, ///< unsigned long long
    YYEncodingTypeFloat      = 11, ///< float
    YYEncodingTypeDouble     = 12, ///< double
    YYEncodingTypeLongDouble = 13, ///< long double
    YYEncodingTypeObject     = 14, ///< id
    YYEncodingTypeClass      = 15, ///< Class
    YYEncodingTypeSEL        = 16, ///< SEL
    YYEncodingTypeBlock      = 17, ///< block
    YYEncodingTypePointer    = 18, ///< void*
    YYEncodingTypeStruct     = 19, ///< struct
    YYEncodingTypeUnion      = 20, ///< union
    YYEncodingTypeCString    = 21, ///< char*
    YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

#pragma mark ==============================YYEncodingGetType方法===========================

/**
 把iOS的Type-Encoding类型转换为枚举类型的值

 @param typeEncoding encoding类型
 @return encoding对应的枚举类型
 */
YYEncodingType YYEncodingGetType(const char *typeEncoding);

#pragma mark ==============================YYClassIvarInfo===========================

/*
 *封装Ivar信息到YYClassIvarInfo对象中
 */
@interface YYClassIvarInfo : NSObject

/**
 一个成员变量
 */
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct

/**
 成员变量对应的名字
 */
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name

/**
 成员变量对应的内存相对位置
 */
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset

/**
 成员变量的编码类型
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding

/**
 编码类型对应的枚举类型
 */
@property (nonatomic, assign, readonly) YYEncodingType type;    ///< Ivar's type

/**
 创建并且返回一个YYClassIvarInfo类对象

 @param ivar 成员变量
 @return YYClassIvarInfo对象
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end

#pragma mark ==============================YYClassMethodInfo===========================

/**
 封装一个Method的信息到YYClassMethodInfo对象中
 */
@interface YYClassMethodInfo : NSObject

/**
 Method结构体
 */
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct

/**
 Method对应的名字
 */
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name

/**
 Method对应的SEL
 */
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector

/**
 Method对应的实现
 */
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation

/**
 Method的encoding类型
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types

/**
 Method的返回类型的encoding
 */
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type

/**
 参数的encoding类型数组
 */
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 根据Method对象创建一个YYClassMethodInfo对象

 @param method Method对象
 @return YYClassMethodInfo对象
 */
- (instancetype)initWithMethod:(Method)method;
@end

#pragma mark ==============================YYClassPropertyInfo===========================

/**
 封装一个objc_property_t对象到YYClassPropertyInfo中
 */
@interface YYClassPropertyInfo : NSObject

/**
 iOS的属性结构体
 */
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct

/**
 属性名字
 */
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name

/**
 属性的encoding类型对应的枚举类型
 */
@property (nonatomic, assign, readonly) YYEncodingType type;      ///< property's type

/**
 属性的encoding类型
 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value

/**
 属性对应的成员变量类型
 */
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name

/**
 属性所在的Class
 */
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil

/**
 如果属性对应的是某个protocol，则用于存储protocol列表
 */
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil

/**
 属性对应的getter和setter
 */
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 通过一个objc_property_t对象创建一个YYClassPropertyInfo的初始化方法

 @param property objc_property_t对象
 @return YYClassPropertyInfo对象
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end

#pragma mark ==============================YYClassInfo================================

/**
 封装Class到一个YYClassInfo对象中
 */
@interface YYClassInfo : NSObject

/**
 Class对象
 */
@property (nonatomic, assign, readonly) Class cls; ///< class object

/**
 Class对象对应的父类
 */
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object

/**
 Class对象对应的元类
 */
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object

/**
 当前Class是否是元类
 */
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class

/**
 Class的名字
 */
@property (nonatomic, strong, readonly) NSString *name; ///< class name

/**
 父类对应的ClassInfo
 */
@property (nullable, nonatomic, strong, readonly) YYClassInfo *superClassInfo; ///< super class's class info

/**
 Class所对应的所有Ivar信息
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassIvarInfo *> *ivarInfos; ///< ivars

/**
 Class对应的所有Method信息
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassMethodInfo *> *methodInfos; ///< methods

/**
 Class对应的所有Property信息
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos; ///< properties

/**
* 如果Class改变了(比如：通过class_addMethod()方法向Class添加一个方法)。需要手动调用这个方法来刷新Class的缓存信息。
*当调用这个方法以后，`needUpdate`方法会返回`YES`。并且我们需要调用`classInfoWithClass`或者`classInfoWithClassName`来获取更新以后的YYClassInfo。
 */
- (void)setNeedUpdate;


/**
 如果这个方法返回`YES`，你需要暂停使用这个对象，并且调用`classInfoWithClass`或者`classInfoWithClassName`来获取更新以后的YYClassInfo。

 @return YES或者NO
 */
- (BOOL)needUpdate;


/**
 *获取指定Class的YYClassInfo信息。
 *这个方法会在第一次调用Class之前缓存Class和Super Class的信息。这个方法是线程安全的。
 
 @param cls Class对象
 @return YYClassInfo对象
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;


/**
 *获取指定Class的YYClassInfo信息。
 *这个方法会在第一次调用Class之前缓存Class和Super Class的信息。这个方法是线程安全的。

 @param className Class对应的名字
 @return Class对应的YYClassInfo对象
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
