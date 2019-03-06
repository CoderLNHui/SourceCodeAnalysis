/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSImage+WebCache.h"
#import "UIImage+MemoryCacheCost.h"
#import "SDWebImageCodersManager.h"

#define SD_MAX_FILE_EXTENSION_LENGTH (NAME_MAX - CC_MD5_DIGEST_LENGTH * 2 - 1)

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

// A memory cache which auto purge the cache on memory warning and support weak cache.
/*
 NSCache是系统提供的一种类似于集合（NSMutableDictionary）的缓存，它与集合的不同如下：
 
 NSCache具有自动删除的功能，以减少系统占用的内存；
 NSCache是线程安全的，不需要加线程锁；
 键对象不会像 NSMutableDictionary 中那样被复制。（键不需要实现 NSCopying 协议）。
 */
@interface SDMemoryCache <KeyType, ObjectType> : NSCache <KeyType, ObjectType>

@end

// Private
@interface SDMemoryCache <KeyType, ObjectType> ()

@property (nonatomic, strong, nonnull) SDImageCacheConfig *config;
@property (nonatomic, strong, nonnull) NSMapTable<KeyType, ObjectType> *weakCache; // strong-weak cache
@property (nonatomic, strong, nonnull) dispatch_semaphore_t weakCacheLock; // a lock to keep the access to `weakCache` thread-safe

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfig:(nonnull SDImageCacheConfig *)config;

@end

@implementation SDMemoryCache

// Current this seems no use on macOS (macOS use virtual memory and do not clear cache when memory warning). So we only override on iOS/tvOS platform.
// But in the future there may be more options and features for this subclass.
#if SD_UIKIT

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (instancetype)initWithConfig:(SDImageCacheConfig *)config {
    self = [super init];
    if (self) {
        // Use a strong-weak maptable storing the secondary cache. Follow the doc that NSCache does not copy keys
        // This is useful when the memory warning, the cache was purged. However, the image instance can be retained by other instance such as imageViews and alive.
        // At this case, we can sync weak cache back and do not need to load from disk cache
        self.weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        self.weakCacheLock = dispatch_semaphore_create(1);
        self.config = config;
        //添加通知，当受到内存警告则移除所有的缓存对象
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    // Only remove cache, but keep weak cache
    [super removeAllObjects];
}

// `setObject:forKey:` just call this with 0 cost. Override this is enough
- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    [super setObject:obj forKey:key cost:g];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    if (key && obj) {
        // Store weak cache
        LOCK(self.weakCacheLock);
        // Do the real copy of the key and only let NSMapTable manage the key's lifetime
        // Fixes issue #2507 https://github.com/SDWebImage/SDWebImage/issues/2507
        [self.weakCache setObject:obj forKey:[[key mutableCopy] copy]];
        UNLOCK(self.weakCacheLock);
    }
}

- (id)objectForKey:(id)key {
    id obj = [super objectForKey:key];
    if (!self.config.shouldUseWeakMemoryCache) {
        return obj;
    }
    if (key && !obj) {
        // Check weak cache
        LOCK(self.weakCacheLock);
        obj = [self.weakCache objectForKey:key];
        UNLOCK(self.weakCacheLock);
        if (obj) {
            // Sync cache
            NSUInteger cost = 0;
            if ([obj isKindOfClass:[UIImage class]]) {
                cost = [(UIImage *)obj sd_memoryCost];
            }
            [super setObject:obj forKey:key cost:cost];
        }
    }
    return obj;
}

- (void)removeObjectForKey:(id)key {
    [super removeObjectForKey:key];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    if (key) {
        // Remove weak cache
        LOCK(self.weakCacheLock);
        [self.weakCache removeObjectForKey:key];
        UNLOCK(self.weakCacheLock);
    }
}

- (void)removeAllObjects {
    [super removeAllObjects];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    // Manually remove should also remove weak cache
    LOCK(self.weakCacheLock);
    [self.weakCache removeAllObjects];
    UNLOCK(self.weakCacheLock);
}

#else

- (instancetype)initWithConfig:(SDImageCacheConfig *)config {
    self = [super init];
    return self;
}

#endif

@end

@interface SDImageCache ()

#pragma mark - Properties
@property (strong, nonatomic, nonnull) SDMemoryCache *memCache;//内存缓存
@property (strong, nonatomic, nonnull) NSString *diskCachePath;//磁盘缓存路径
@property (strong, nonatomic, nullable) NSMutableArray<NSString *> *customPaths;//自定义路径（数组
@property (strong, nonatomic, nullable) dispatch_queue_t ioQueue;//处理IO操作的队列
@property (strong, nonatomic, nonnull) NSFileManager *fileManager;//文件管理者

@end


@implementation SDImageCache

#pragma mark - Singleton, init, dealloc

//单例类方法，该方法提供一个全局的SDImageCache实例
+ (nonnull instancetype)sharedImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//初始化方法，默认的缓存空间名称为default
- (instancetype)init {
    return [self initWithNamespace:@"default"];
}

//使用指定的命名空间实例化一个新的缓存存储
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns {
    //根据传入的命名空间设置磁盘缓存路径
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}

//使用指定的命名空间实例化一个新的缓存存储和目录
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nonnull NSString *)directory {
    if ((self = [super init])) {
        //拼接默认的磁盘缓存目录
        NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:ns];
        
        // Create IO serial queue 创建串行队列
        //创建处理IO操作的串行队列
        _ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);
        
        _config = [[SDImageCacheConfig alloc] init];
        
        // Init the memory cache
        //初始化内存缓存，使用NSCache
        _memCache = [[SDMemoryCache alloc] initWithConfig:_config];
        _memCache.name = fullNamespace;

        // Init the disk cache
        //初始化磁盘缓存，如果磁盘缓存路径不存在则设置为默认值，否则根据命名空间重新设置
        if (directory != nil) {
            //是路径拼接，会在字符串前自动添加“/”，成为完整路径
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }

        //同步函数+串行队列：初始化文件管理者
        dispatch_sync(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });

#if SD_UIKIT
        // Subscribe to app events
        //在App关闭的时候清除过期图片
          //当监听到UIApplicationWillTerminateNotification（程序将终止）调用cleanDisk方法,清理过期(默认大于一周)的磁盘缓存
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteOldFiles)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        //在App进入后台的时候，后台处理过期图片
        //当监听到UIApplicationDidEnterBackgroundNotification（进入后台），调用backgroundCleanDisk方法,清理过期磁盘缓存
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundDeleteOldFiles)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
    }

    return self;
}

//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Cache paths

/*
 * 如果希望在 bundle 中存储预加载的图像，可以添加一个只读的缓存路径
 * 让 SDImageCache 从 Bundle 中搜索预先缓存的图像
 * 只读缓存路径(mainBundle中的全路径)
 */
- (void)addReadOnlyCachePath:(nonnull NSString *)path {
    if (!self.customPaths) {
        self.customPaths = [NSMutableArray new];
    }

    if (![self.customPaths containsObject:path]) {
        [self.customPaths addObject:path];
    }
}

//获得指定 key 对应的缓存路径,需要一个根缓存路径
- (nullable NSString *)cachePathForKey:(nullable NSString *)key inPath:(nonnull NSString *)path {
    //获得缓存文件的名称
    NSString *filename = [self cachedFileNameForKey:key];
    //返回拼接后的全路径
    return [path stringByAppendingPathComponent:filename];
}

//获得指定 key 的默认缓存路径
- (nullable NSString *)defaultCachePathForKey:(nullable NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

//缓存图片的名称是对key做了一次md5加密处理，以避免重名。
//对key(通常为URL)进行MD5加密，加密后的密文作为图片的名称，可以防止文件名过长。
//根据key值生成文件名：采用MD5
- (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    // File system has file name length limit, we need to check if ext is too long, we don't add it to the filename
    if (ext.length > SD_MAX_FILE_EXTENSION_LENGTH) {
        ext = nil;
    }
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}

//设置磁盘缓存路径
- (nullable NSString *)makeDiskCachePath:(nonnull NSString*)fullNamespace {
    //获得caches路径，该框架内部对图片进行磁盘缓存，设置的缓存目录为沙盒中Library的caches目录下
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //在caches目录下，新建一个名为【fullNamespace】的文件，沙盒缓存就保存在此处
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

#pragma mark - Store Ops
//储存图片
- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable SDWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:YES completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable SDWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk completion:completionBlock];
}


/*
 缓存处理 包含两块：
 
 内存缓存（SDMemoryCache）：
 磁盘缓存
 内存缓存集成自NSCache。添加了在收到内存警告通知UIApplicationDidReceiveMemoryWarningNotification的时候自动removeAllObjects。
 
 */
//使用指定的键将图像保存到内存和可选的磁盘缓存
- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable SDWebImageNoParamsBlock)completionBlock {
    //如果图片或对应的key为空，那么就直接返回
    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    // if memory cache is enabled
    //如果内存缓存可用
    if (self.config.shouldCacheImagesInMemory) {
        //计算该图片的『成本』
        NSUInteger cost = image.sd_memoryCost;
        [self.memCache setObject:image forKey:key cost:cost];
    }
    
    //判断是否需要磁盘缓存
    if (toDisk) {
        //异步函数+串行队列：开子线程异步处理block中的任务
        dispatch_async(self.ioQueue, ^{
            @autoreleasepool {
                //拿到服务器返回的图片二进制数据
                NSData *data = imageData;
                //如果图片存在且imageData为空
                if (!data && image) {
                    // If we do not have any data to detect image format, check whether it contains alpha channel to use PNG or JPEG format
                    SDImageFormat format;
                    //获得该图片的alpha信息
                    if (SDCGImageRefContainsAlpha(image.CGImage)) {
                        format = SDImageFormatPNG;
                    } else {
                        format = SDImageFormatJPEG;
                    }
                    //编码
                    data = [[SDWebImageCodersManager sharedInstance] encodedDataWithImage:image format:format];
                }
                [self _storeImageDataToDisk:data forKey:key];
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

//储存data到 disk
- (void)storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key {
    //判断imageData存不存在还有key如果有一个不存在，就返回
    if (!imageData || !key) {
        return;
    }
    dispatch_sync(self.ioQueue, ^{
        [self _storeImageDataToDisk:imageData forKey:key];
    });
}

// Make sure to call form io queue by caller
- (void)_storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key {
    if (!imageData || !key) {
        return;
    }
    
    //判断是否存在_diskCachePath,这个就是磁盘缓存路径，如果不存在则创建
    if (![self.fileManager fileExistsAtPath:_diskCachePath]) {
        [self.fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    // get cache Path for image key
    //获取图片的缓存路径，这里就是图片的url的md5的结果，然后拼接磁盘路径、
    // 根据key获得缓存路径
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    // transform to NSUrl
    //转换为NSURL
    NSURL *fileURL = [NSURL fileURLWithPath:cachePathForKey];
    //写入到文件中
    [imageData writeToURL:fileURL options:self.config.diskCacheWritingOptions error:nil];
    
    // disable iCloud backup 判断是否需要iCloud备份
    if (self.config.shouldDisableiCloud) {
        //标记沙盒中不备份文件（标记该文件不备份）
        [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

#pragma mark - Query and Retrieve Ops
//异步检查图像是否已经在磁盘缓存中存在（不加载图像）
- (void)diskImageExistsWithKey:(nullable NSString *)key completion:(nullable SDWebImageCheckCacheCompletionBlock)completionBlock {
    //开子线程异步检查文件是否存在
    dispatch_async(self.ioQueue, ^{
        BOOL exists = [self _diskImageDataExistsWithKey:key];
        //在主线程回调completionBlock块
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

//异步检查图像是否已经在磁盘缓存中存在（不加载图像）
- (BOOL)diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    //初始设置为NO
    __block BOOL exists = NO;
    // 检查文件是否存在
    dispatch_sync(self.ioQueue, ^{
        exists = [self _diskImageDataExistsWithKey:key];
    });
    
    return exists;
}

// Make sure to call form io queue by caller
- (BOOL)_diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    // 共享的 NSFileManager 对象可以保证在多线程运行时是安全的
    BOOL exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];
    
    // fallback because of https://github.com/SDWebImage/SDWebImage/pull/976 that added the extension to the disk file name
    // checking the key with and without the extension
    if (!exists) {
        exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key].stringByDeletingPathExtension];
    }
    
    return exists;
}

//获取KEY对应的磁盘缓存，如果key不存在则直接返回nil

- (nullable NSData *)diskImageDataForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    __block NSData *imageData = nil;
    dispatch_sync(self.ioQueue, ^{
        //获取储存的data
        imageData = [self diskImageDataBySearchingAllPathsForKey:key];
    });
    
    return imageData;
}

//获取该key对应的图片缓存数据
- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key {
    return [self.memCache objectForKey:key];
}

//查询内存缓存之后同步查询磁盘缓存
- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key {
    //接下来检查磁盘缓存，如果图片存在，且可以保存到内存缓存，则保存一份到内存缓存中
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = diskImage.sd_memoryCost;
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    //返回图片
    return diskImage;
}

//获取图像
- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key {
    // First check the in-memory cache...
    //首先检查内存缓存，如果存在则直接返回
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    
    // Second check the disk cache...
    //接下来检查磁盘缓存，如果图片存在，且可以保存到内存缓存，则保存一份到内存缓存中
    image = [self imageFromDiskCacheForKey:key];
    return image;
}

//在全路径搜索image的key的data
- (nullable NSData *)diskImageDataBySearchingAllPathsForKey:(nullable NSString *)key {
    //第一步：在默认路径中取出data
    //获得给key对应的默认的缓存路径
    NSString *defaultPath = [self defaultCachePathForKey:key];
    //加载该路径下面的二进制数据
    NSData *data = [NSData dataWithContentsOfFile:defaultPath options:self.config.diskCacheReadingOptions error:nil];
    //如果有值，则直接返回
    if (data) {
        return data;
    }

    // fallback because of https://github.com/SDWebImage/SDWebImage/pull/976 that added the extension to the disk file name
    // checking the key with and without the extension
    //第二步：如果默认路径没有，通过删除最后一部分扩展名，来确保路径正确
     //从文件的最后一部分删除扩展名 通过路径，取出data
    data = [NSData dataWithContentsOfFile:defaultPath.stringByDeletingPathExtension options:self.config.diskCacheReadingOptions error:nil];
    if (data) {
        return data;
    }

    //第三部：通过常用的储存路径获取filePath，从而获得imageData，customPaths 需要外包设置
    NSArray<NSString *> *customPaths = [self.customPaths copy];
    //遍历customPaths，若有值，则直接返回
    for (NSString *path in customPaths) {
        NSString *filePath = [self cachePathForKey:key inPath:path];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath options:self.config.diskCacheReadingOptions error:nil];
        if (imageData) {
            return imageData;
        }

        // fallback because of https://github.com/SDWebImage/SDWebImage/pull/976 that added the extension to the disk file name
        // checking the key with and without the extension
        imageData = [NSData dataWithContentsOfFile:filePath.stringByDeletingPathExtension options:self.config.diskCacheReadingOptions error:nil];
        if (imageData) {
            return imageData;
        }
    }

    return nil;
}

//通过key将disk里的图片拿出来
- (nullable UIImage *)diskImageForKey:(nullable NSString *)key {
    NSData *data = [self diskImageDataForKey:key];
    return [self diskImageForKey:key data:data];
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data {
    return [self diskImageForKey:key data:data options:0];
}

//获取KEY对应的磁盘缓存，如果不存在则直接返回nil
- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data options:(SDImageCacheOptions)options {
    if (data) {
        //把对应的二进制数据转换为图片
        UIImage *image = [[SDWebImageCodersManager sharedInstance] decodedImageWithData:data];
        //处理图片的缩放
        //根据图片的scale或图片中的图片组 重新计算返回一张新图片
        image = [self scaledImageForKey:key image:image];
        //判断是否需要解压缩（解码）并进行相应的处理
        if (self.config.shouldDecompressImages) {
            //根据设备来缩放图片
            BOOL shouldScaleDown = options & SDImageCacheScaleDownLargeImages;
            image = [[SDWebImageCodersManager sharedInstance] decompressedImageWithImage:image data:&data options:@{SDWebImageCoderScaleDownLargeImagesKey: @(shouldScaleDown)}];
        }
        //返回图片
        return image;
    } else {
        return nil;
    }
}

//处理图片的缩放等，2倍尺寸|3倍尺寸？
- (nullable UIImage *)scaledImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return SDScaledImageForKey(key, image);
}

- (NSOperation *)queryCacheOperationForKey:(NSString *)key done:(SDCacheQueryCompletedBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:0 done:doneBlock];
}

#pragma mark - 缓存&&磁盘操作：SDImageCache；Bundle version 4.3.3
//检查要下载图片的缓存情况
/*
 0.首先判断这里的传入的key是否为空，如果为nil了直接return
 1.先检查是否有内存缓存
 2.如果没有内存缓存则检查是否有沙盒缓存
 3.如果有沙盒缓存，则把该图片做内存缓存并处理doneBlock回调
 */
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(SDImageCacheOptions)options done:(nullable SDCacheQueryCompletedBlock)doneBlock {
  
    //如果缓存对应的key为空，则直接返回，并把存储方式（无缓存）通过block块以参数的形式传递
    if (!key) {
        if (doneBlock) {
            doneBlock(nil, nil, SDImageCacheTypeNone);
        }
        return nil;
    }
    
    // First check the in-memory cache..
    //1、内存缓存查找，检查该KEY对应的内存缓存，
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    //如果存在内存缓存，并且没有强制指明查询磁盘的话，则直接返回，并把图片和存储方式（内存缓存）通过block块以参数的形式传递
    BOOL shouldQueryMemoryOnly = (image && !(options & SDImageCacheQueryDataWhenInMemory));
    if (shouldQueryMemoryOnly) {
        if (doneBlock) {
            doneBlock(image, nil, SDImageCacheTypeMemory);
        }
        return nil;
    }
//    2、磁盘缓存查找
    //创建一个操作
    NSOperation *operation = [NSOperation new];
    void(^queryDiskBlock)(void) =  ^{
        
        //如果当前的操作被取消，则直接返回
        if (operation.isCancelled) {
            // do not call the completion if cancelled
            return;
        }
        
        @autoreleasepool {
            //到这里说明已经来到磁盘缓存区获取 然后回调结束

            //得到二进制数据
            NSData *diskData = [self diskImageDataBySearchingAllPathsForKey:key];
            UIImage *diskImage;
            SDImageCacheType cacheType = SDImageCacheTypeNone;
            if (image) {
                // the image is from in-memory cache
                diskImage = image;
                cacheType = SDImageCacheTypeMemory;
            } else if (diskData) {
                cacheType = SDImageCacheTypeDisk;
                // decode image data only if in-memory cache missed
                //获取KEY对应的磁盘缓存，如果不存在则直接返回nil
                diskImage = [self diskImageForKey:key data:diskData options:options];
                //如果存在磁盘缓存，且应该把该图片保存一份到内存缓存中，则先计算该图片的cost(成本）并把该图片保存到内存缓存中
                if (diskImage && self.config.shouldCacheImagesInMemory) {
                    NSUInteger cost = diskImage.sd_memoryCost;
                    [self.memCache setObject:diskImage forKey:key cost:cost];
                }
            }
            
            if (doneBlock) {
               // 默认情况下，我们同步查询内存缓存，异步访问磁盘缓存。该选项可以强制同步查询磁盘缓存，以确保图像在同一个runloop中加载

                if (options & SDImageCacheQueryDiskSync) {
                    doneBlock(diskImage, diskData, cacheType);
                } else {
                    //线程间通信，在主线程中回调doneBlock，并把图片和存储方式（磁盘缓存）通过block块以参数的形式传递
                    dispatch_async(dispatch_get_main_queue(), ^{
                        doneBlock(diskImage, diskData, cacheType);
                    });
                }
            }
        }
    };
    
    //默认情况下，我们同步查询内存缓存，异步访问磁盘缓存。SDImageCacheQueryDiskSync选项可以强制同步查询磁盘缓存，以确保图像在同一个runloop中加载
    if (options & SDImageCacheQueryDiskSync) {
        queryDiskBlock();
    } else {
        //使用异步函数，添加任务到串行队列中（会开启一个子线程处理block块中的任务）
        dispatch_async(self.ioQueue, queryDiskBlock);
    }
    
    return operation;
}

#pragma mark - Remove Ops
//移除key对应的缓存，默认移除沙盒缓存
- (void)removeImageForKey:(nullable NSString *)key withCompletion:(nullable SDWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromDisk:YES withCompletion:completion];
}
//删除缓存中指定key的图片 磁盘是可选项
- (void)removeImageForKey:(nullable NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(nullable SDWebImageNoParamsBlock)completion {
    if (key == nil) {
        return;
    }

    //如果有内存缓存，则移除
    if (self.config.shouldCacheImagesInMemory) {
        [self.memCache removeObjectForKey:key];
    }

    //移除沙盒缓存操作处理
    if (fromDisk) {
        //开子线程异步执行，使用文件管理者移除指定路径的文件
        dispatch_async(self.ioQueue, ^{
            [self.fileManager removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
            
            //回到主线程中处理completion回调
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else if (completion){
        completion();
    }
    
}

# pragma mark - Mem Cache settings
//totalCostLimit:设置缓存占用的内存大小，并不是一个严格的限制，当总数超过了totalCostLimit设定的值，系统会清除一部分缓存，直至总消耗低于totalCostLimit的值
//设置内存缓存（NSCache）能保存的最大成本
- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memCache.totalCostLimit = maxMemoryCost;
}
//最大内存缓存成本
- (NSUInteger)maxMemoryCost {
    return self.memCache.totalCostLimit;
}

//最大缓存的文件数量
- (NSUInteger)maxMemoryCountLimit {
    return self.memCache.countLimit;
}

//设置内存缓存（NSCache）的最大文件数量
- (void)setMaxMemoryCountLimit:(NSUInteger)maxCountLimit {
    self.memCache.countLimit = maxCountLimit;
}

#pragma mark - Cache clean Ops
//清除内存缓存
- (void)clearMemory {
    //把所有的内存缓存都删除
    [self.memCache removeAllObjects];
}

//异步清除所有的磁盘缓存
- (void)clearDiskOnCompletion:(nullable SDWebImageNoParamsBlock)completion {
    //开子线程异步处理 清理磁盘缓存的操作
    dispatch_async(self.ioQueue, ^{
        //删除缓存路径
        [self.fileManager removeItemAtPath:self.diskCachePath error:nil];
        //重新创建缓存路径
        [self.fileManager createDirectoryAtPath:self.diskCachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];//创建文件夹

        if (completion) {
            //在主线程中处理completion回调
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

//清除过期的磁盘缓存
- (void)deleteOldFiles {
    [self deleteOldFilesWithCompletionBlock:nil];
}

//异步清除所有失效的缓存图片-因为可以设定缓存时间，超过则失效
- (void)deleteOldFilesWithCompletionBlock:(nullable SDWebImageNoParamsBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];

        // Compute content date key to be used for tests
        NSURLResourceKey cacheContentDateKey = NSURLContentModificationDateKey;
        switch (self.config.diskCacheExpireType) {
            case SDImageCacheConfigExpireTypeAccessDate:
                cacheContentDateKey = NSURLContentAccessDateKey;
                break;

            case SDImageCacheConfigExpireTypeModificationDate:
                cacheContentDateKey = NSURLContentModificationDateKey;
                break;

            default:
                break;
        }
        
        //resourceKeys数组包含遍历文件的属性，NSURLIsDirectoryKey判断遍历到的URL所指对象是否是目录，
        //NSURLContentModificationDateKey判断遍历返回的URL所指项目的最后修改时间，NSURLTotalFileAllocatedSizeKey判断URL目录中所分配的空间大小
        NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, cacheContentDateKey, NSURLTotalFileAllocatedSizeKey];

        // This enumerator prefetches useful properties for our cache files.
        //利用目录枚举器遍历指定磁盘缓存路径目录下的文件，从而我们获得文件大小，缓存时间等信息

        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        //计算过期时间，默认1周以前的缓存文件是过期失效
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.config.maxCacheAge];
        //保存遍历的文件url
        NSMutableDictionary<NSURL *, NSDictionary<NSString *, id> *> *cacheFiles = [NSMutableDictionary dictionary];
        //保存当前缓存的大小
        NSUInteger currentCacheSize = 0;

        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        //  遍历缓存路径中的所有文件，此循环要实现两个目的
        //  1. 删除早于过期日期的文件
        //  2. 保存文件属性以计算磁盘缓存占用空间
        //保存删除的文件url
        NSMutableArray<NSURL *> *urlsToDelete = [[NSMutableArray alloc] init];
        //遍历目录枚举器，目的1删除过期文件 2纪录文件大小，以便于之后删除使用
        for (NSURL *fileURL in fileEnumerator) {
            NSError *error;
            //获取指定url对应文件的指定三种属性的key和value
            NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];

            // Skip directories and errors.
            //如果是文件夹则返回
            if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }

            // Remove files that are older than the expiration date;
            // 记录要删除的过期文件
            //获取指定url文件对应的修改日期
            NSDate *modifiedDate = resourceValues[cacheContentDateKey];
            //如果修改日期大于指定日期，则加入要移除的数组里
            if ([[modifiedDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            //保存文件引用，以计算总大小
            //获取指定的url对应的文件的大小，并且把url与对应大小存入一个字典中
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += totalAllocatedSize.unsignedIntegerValue;
            cacheFiles[fileURL] = resourceValues;
        }
        
        // 删除过期的文件
        //删除所有最后修改日期大于指定日期的所有文件
        for (NSURL *fileURL in urlsToDelete) {
            [self.fileManager removeItemAtURL:fileURL error:nil];
        }

        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        //如果当前缓存的大小超过了默认大小，则按照日期删除，直到缓存大小<默认大小的一半
        // 如果剩余磁盘缓存空间超出最大限额，再次执行清理操作，删除最早的文件
        if (self.config.maxCacheSize > 0 && currentCacheSize > self.config.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.config.maxCacheSize / 2;

            // Sort the remaining cache files by their last modification time or last access time (oldest first).
            //根据文件创建的时间排序
            NSArray<NSURL *> *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                         return [obj1[cacheContentDateKey] compare:obj2[cacheContentDateKey]];
                                                                     }];

            // Delete files until we fall below our desired cache size.
            // 循环依次删除文件，直到低于期望的缓存限额的1/2
            //迭代删除缓存，直到缓存大小是默认缓存大小的一半
            for (NSURL *fileURL in sortedFiles) {
                if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary<NSString *, id> *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= totalAllocatedSize.unsignedIntegerValue;

                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        //在主线程中处理完成回调
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

#if SD_UIKIT
//当进入后台后，处理的磁盘缓存清理工作
/*
 如果你想在后台完成一个长期任务,就必须调用 UIApplication 的 beginBackgroundTaskWithExpirationHandler:实例方法,来向 iOS 借点时间。经过证明，即使时执行Long-Running Task 任务，当程序被调到后台后，也是有时间限制的。一般为10分总（600s）
 
 */
- (void)backgroundDeleteOldFiles {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    //得到UIApplication单例对象
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        // 清理任何未完成的任务
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    // Start the long-running task and return immediately.
    // 清理长期运行的任务，并立即返回
    [self deleteOldFilesWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}
#endif

#pragma mark - Cache Info
//得到磁盘缓存的大小size
- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    //同步+串行队列
    dispatch_sync(self.ioQueue, ^{
        //得到diskCachePath路径下面的所有子路径
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:self.diskCachePath];
        //遍历得到所有子路径对应文件的大小，并累加以计算所有文件的总大小
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [self.fileManager attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

//获得磁盘文件的数量
- (NSUInteger)getDiskCount {
    //初始化为0
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        //根据计算该路径下面的子路径的数量得到
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:self.diskCachePath];
        count = fileEnumerator.allObjects.count;
    });
    return count;
}

//异步计算磁盘缓存的大小
- (void)calculateSizeWithCompletionBlock:(nullable SDWebImageCalculateSizeBlock)completionBlock {
    //把文件路径转换为URL
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];

    //开子线程异步处理block块中的任务
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;//初始化文件的数量为0
        NSUInteger totalSize = 0;//初始化缓存的总大小为0

        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];

        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            //累加缓存的大小
            totalSize += fileSize.unsignedIntegerValue;
            //累加缓存的数量
            fileCount += 1;
        }

        if (completionBlock) {
            //在主线程中处理completionBlock回调
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}

@end

