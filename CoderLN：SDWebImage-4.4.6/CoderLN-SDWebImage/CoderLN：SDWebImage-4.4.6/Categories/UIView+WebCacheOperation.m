/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+WebCacheOperation.h"
#import "objc/runtime.h"

static char loadOperationKey;

// key is copy, value is weak because operation instance is retained by SDWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be acessed from main queue
/**
 老的思路：
 通过 objc_setAssociatedObject 关联对象的方法，给 UIImageView 动态添加了一个 NSMutableDictionary 的属性。通过 key-value 维护这个 ImageView 已经有了哪些下载操作，如果是数组就是 UIImageViewAnimationImages 否则就是 UIImageViewImageLoad 。最后获得的都是遵从了 <SDWebImageOperation> 协议的对象，可以统一调用定义好的方法 cancel，达到取消下载操作的目的，如果 operation 都被取消了，则删除对应 key 的值。

 新的思路：
 1、这里首先获取通过loadOperationKey来通过关联对象获取operationsDictionary（这里会有一次加锁）,
 如果非空直接返回operationDictionary,
 如果为空那么使用NSMapTable创建并返回,这里会通过关联对象以loadOperationKey保存这个operations,
 NSMapTable和字典类似，不过它的key不是一定需要遵守NSCoding协议并且他可以指定key和value的内存管理语义
 2、通过上一步获取到了operationDictionary，这里通过key在operationDictionary里面取出对应的operation；
 如果operation非空并且遵守了SDWebImageOperation协议那么调用cancle取消任务，然后从operationDictionary中通过key移除这个operation


 */

typedef NSMapTable<NSString *, id<SDWebImageOperation>> SDOperationsDictionary;

@implementation UIView (WebCacheOperation)

/*
 1、这里首先获取通过loadOperationKey来通过关联对象获取operationsDictionary（这里会有一次加锁）,
 如果非空直接返回operationDictionary,
 如果为空那么使用NSMapTable创建并返回,这里会通过关联对象以loadOperationKey保存这个operations,
 NSMapTable和字典类似，不过它的key不是一定需要遵守NSCoding协议并且他可以指定key和value的内存管理语义
 
 NSMapTable类似于NSDictionary，但是NSDictionary只提供了key->value的映射。NSMapTable还提供了对象->对象的映射。
 NSDictionary的局限性：
 NSDictionary 中存储的 object 位置是由 key 来索引的。由于对象存储在特定位置，NSDictionary 中要求 key 的值不能改变（否则 object 的位置会错误）。为了保证这一点，NSDictionary 会始终复制 key 到自己私有空间。但这也有一个限制：你只能使用 OC 对象作为 NSDictionary 的 key，并且必须支持 NSCopying 协议。这意味着，NSDictionary 中真的只适合将值类型的对象作为 key（如简短字符串和数字）。并不适合自己的模型类来做对象到对象的映射
 

 
 
 */

- (SDOperationsDictionary *)sd_operationDictionary {
    @synchronized(self) {
        SDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
        if (operations) {
            return operations;
        }
        /*
         key的内存管理方式是NSPointerFunctionsStrongMemory，当一个对象添加到NSMapTable中后，key的引用技术+1。
         value内存管理方式是NSPointerFunctionsWeakMemory，当一个对象添加到NSMapTable中后，key的引用技术不会+1。
         这样使用的意义在哪呢：
         1.遵循NSCache不复制key的文档。
         2.当收到内存警告，缓存被清理的时候，可以保存image实例。这个时候我们可以同步弱缓存表，不需要从磁盘加载。
         */
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}
//目的其实是将这个任务（operation）通过validOperationKey保存到operationsDictionary中，和第二步的取消任务相呼应
- (void)sd_setImageLoadOperation:(nullable id<SDWebImageOperation>)operation forKey:(nullable NSString *)key {
    if (key) {
        [self sd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            SDOperationsDictionary *operationDictionary = [self sd_operationDictionary];
            @synchronized (self) {
                [operationDictionary setObject:operation forKey:key];
            }
        }
    }
}

/*
 2、通过上一步获取到了operationDictionary，这里通过key在operationDictionary里面取出对应的operation；
    如果operation非空并且遵守了SDWebImageOperation协议那么调用cancle取消任务，然后从operationDictionary中通过key移除这个operation
 */
- (void)sd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        // Cancel in progress downloader from queue
        SDOperationsDictionary *operationDictionary = [self sd_operationDictionary];
        id<SDWebImageOperation> operation;
        
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
        if (operation) {
            if ([operation conformsToProtocol:@protocol(SDWebImageOperation)]) {
                [operation cancel];
            }
            @synchronized (self) {
                [operationDictionary removeObjectForKey:key];
            }
        }
    }
}

- (void)sd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        SDOperationsDictionary *operationDictionary = [self sd_operationDictionary];
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

@end
