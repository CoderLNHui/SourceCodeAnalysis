/**
 MJExtension_Codeidea 刷新思想
 
 */

#pragma mark - 官方释义
```objc

```







#pragma mark - 组成（层次结构）->（.h系统文件 -> 作用、使用、注解）


/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 *  @return 新建的对象
 */
+ (instancetype)mj_objectWithKeyValues:(id)keyValues;


/**
 *  模型转字典
 *  字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来）
 */
+ (void)mj_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference;


/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray;






#pragma mark - 实现原理(工作流程)


```objc
1、
MJExtension框架与KVC的底层实现的区别

1.KVC是通过遍历字典中的所有key，然后去模型中寻找key对应的属性；必须要保证模型中的属性名要和字典中的key一一对应,否则使用KVC运行时会报错的。
2.MJ框架是通过先遍历模型中的属性，然后拿到属性名作为键值去字典中寻找对应的key，找到值后根据模型的属性的类型将值转成正确的类型；所以用MJ框架的时候，模型中的属性和字典可以不用一一对应，同样能达到给模型赋值的效果。


- - -
2、
关于每个model的配置代码应该写在哪里❓

MJ老师他直接建立一个类MJExtensionConfig，然后把项目中所有的model的配置都放到了MJExtensionConfig的.m中的+load方法中。

大家都知道+load方法在开发者不主动调用的情况下，如果你实现了load方法，那么只会在APP启动应用的时候调用一次，而且是在main函数被调用之前调用，算是比较早调用的func，load会把项目中所有的类都加载load一遍，load方法貌似可以进行项目中model类的配置，好像是再合适不过的了。
但是我否定了方案三、也就是MJ老师的方案或者说是引导用法。为什么呢？load方法会拖慢程序启动时间，写demo可以，就如MJ老师的demo，但是写项目不可以，他会拖慢启动时间，这个是我所不能忍受的，另外一个不好之处就是MJExtensionConfig文件中要import项目中大部分需要设置model参数的类文件，这样不太好，项目越来越大，MJExtensionConfig中导入的头文件越来越多。
 


```






















































































































