//
//  YYClassInfo.m
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYClassInfo.h"
#import <objc/runtime.h>

#pragma mark ==============================YYEncodingGetType方法===========================

/**
 把iOS的Type-Encoding类型转换为枚举类型的值
 
 @param typeEncoding encoding类型
 @return encoding对应的枚举类型
 */
YYEncodingType YYEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return YYEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown;
    
    YYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return YYEncodingTypeBlock | qualifier;
            else
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
    }
}

#pragma mark ==============================YYClassIvarInfo===========================

/*
 *封装Ivar信息到YYClassIvarInfo对象中
 */
@implementation YYClassIvarInfo

/**
 初始化一个YYClassIvarInfo

 @param ivar 参数。Ivar类型
 @return YYClassIvarInfo对象
 */
- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    //获取ivar对应name
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    //获取ivar对应的内存偏移量
    _offset = ivar_getOffset(ivar);
    //获取ivar对应的encoding类型
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        //获取encoding类型对应的枚举类型
        _type = YYEncodingGetType(typeEncoding);
    }
    return self;
}

@end

#pragma mark ==============================YYClassMethodInfo===========================

/**
 封装一个Method的信息到YYClassMethodInfo对象中
 */
@implementation YYClassMethodInfo

/**
 初始化一个YYClassMethodInfo对象

 @param method Method对象参数
 @return YYClassMethodInfo对象
 */
- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    //获取Method对应的SEL，通俗讲就是函数名，包括参数信息，返回值信息等
    _sel = method_getName(method);
    //获取Method对应的IMP，通俗讲就是函数的实现
    _imp = method_getImplementation(method);
    //方法名，仅仅名字
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    //获取Method对应的encoding类型
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    //获取函数的返回类型
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    //获取Method对应的参数个数
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        //迭代获取参数对应的类型
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end
#pragma mark ==============================YYClassPropertyInfo===========================

/**
 封装一个objc_property_t对象到YYClassPropertyInfo中
 */
@implementation YYClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    //获取property的名字
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    YYEncodingType type = 0;
    unsigned int attrCount;
    //获取objc_proterty_t属性对应的各种信息
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
                //encoding属性，T表示引用类型或者NSObject对象
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    //encoding对应的枚举类型
                    type = YYEncodingGetType(attrs[i].value);
                    //如果type是encoding类型并且是`YYEncodingTypeObject`。则说明当前属性是一个Object类型的子类，比如NSString，此时_typeEncoding等于@"NSString"。
                    if ((type & YYEncodingTypeMask) == YYEncodingTypeObject && _typeEncoding.length) {
                        //对_typeEncoding扫描
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        //把_typeEncoding中的@"置为null
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        //获取引用类型的名字
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        //协议类型的属性处理，_typeEncoding就如@"<protocolTest>"这种类型
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                //去除左边和右边的符号。得到属性名
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                //属性对应成员变量名字
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
                //属性的访问控制属性
            case 'R': {
                type |= YYEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= YYEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= YYEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= YYEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= YYEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= YYEncodingTypePropertyWeak;
            } break;
            case 'G': {
                //自定义getter方法
                type |= YYEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                //自定义setter方法
                type |= YYEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        //如果没有自定getter和setter，则使用默认的
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}
@end

#pragma mark ==============================YYClassInfo================================

/**
 封装Class到一个YYClassInfo对象中
 */

@implementation YYClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    //父类
    _superCls = class_getSuperclass(cls);
    //是否是元类
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        //如果不是元类，则获取类的元类
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    //Class对应的name
    _name = NSStringFromClass(cls);
    //初始化其他信息
    [self _update];
    //获取父类的YYClassInfo对象
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}


/**
 重新初始化Class对应的Ivar、Method、objc_property_t信息
 */
- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    //获取方法列表
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            //把Method对象的信息封装到YYClassMethodInfo对象，然后加入_methodInfos字典中
            YYClassMethodInfo *info = [[YYClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    //获取属性列表
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            //把objc_property_t对象的信息封装到YYClassPropertyInfo对象，然后加入_propertyInfos字典中
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    //获取成员变量列表
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            //把Ivar对象的信息封装到YYClassIvarInfo对象，然后加入_ivarInfos字典中
            YYClassIvarInfo *info = [[YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    //如果都没有，使用空字典
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

/**
 * 如果Class改变了(比如：通过class_addMethod()方法向Class添加一个方法)。需要手动调用这个方法来刷新Class的缓存信息。
 *当调用这个方法以后，`needUpdate`方法会返回`YES`。并且我们需要调用`classInfoWithClass`或者`classInfoWithClassName`来获取更新以后的YYClassInfo。
 */
- (void)setNeedUpdate {
    _needUpdate = YES;
}

/**
 如果这个方法返回`YES`，你需要暂停使用这个对象，并且调用`classInfoWithClass`或者`classInfoWithClassName`来获取更新以后的YYClassInfo。
 
 @return YES或者NO
 */
- (BOOL)needUpdate {
    return _needUpdate;
}

/**
 *获取指定Class的YYClassInfo信息。
 *这个方法会在第一次调用Class之前缓存Class和Super Class的信息。这个方法是线程安全的。
 
 @param cls Class对象
 @return YYClassInfo对象
 */
+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        //类和元类缓存
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //信号总量，1表示同时只能有一个对象访问
        lock = dispatch_semaphore_create(1);
    });
    //等待信号，当信号总量少于0的时候就会一直等待，否则就可以正常的执行，并让信号总量-1
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    //是否已经缓存了类或者元类的YYClassInfo
    YYClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    //如果已经缓存并且_needUpdate是true
    if (info && info->_needUpdate) {
        //更新信息
        [info _update];
    }
    //发送一个信号，让信号量+1
    dispatch_semaphore_signal(lock);
    //没有缓存类或者元类的YYClassInfo
    if (!info) {
        //获取类的YYClassInfo信息
        info = [[YYClassInfo alloc] initWithClass:cls];
        if (info) {
            //添加访问控制，信号量-1
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            //把Class的YYClassInfo信息缓存到字典中
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            //操作完成，信号量+1
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

/**
 *获取指定Class的YYClassInfo信息。
 *这个方法会在第一次调用Class之前缓存Class和Super Class的信息。这个方法是线程安全的。
 
 @param className Class对应的名字
 @return Class对应的YYClassInfo对象
 */
+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
