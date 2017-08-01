/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCache.h"
#import "SDWebImageDecoder.h"
#import "UIImage+MultiFormat.h"
#import <CommonCrypto/CommonDigest.h>

#pragma mark --------------------
#pragma mark AutoPurgeCache

// See https://github.com/rs/SDWebImage/pull/1141 for discussion
@interface AutoPurgeCache : NSCache
@end

@implementation AutoPurgeCache

//初始化
- (id)init
{
    self = [super init];
    if (self) {
        //监听到UIApplicationDidReceiveMemoryWarningNotification（应用程序发生内存警告）通知后，调用removeAllObjects方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

//移除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end

//默认的最大缓存时间为1周
static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week
// PNG signature bytes and data (below)
// PNG 签名字节和数据(PNG文件开始的8个字节是固定的)
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGSignatureData = nil;

BOOL ImageDataHasPNGPreffix(NSData *data);

BOOL ImageDataHasPNGPreffix(NSData *data) {
    //计算PNG签名数据的长度
    NSUInteger pngSignatureLength = [kPNGSignatureData length];
    //比较传入数据和PNG签名数据的长度，如果比签名数据长度更长，那么就只比较前面几个字节
    if ([data length] >= pngSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngSignatureLength)] isEqualToData:kPNGSignatureData]) {
            //比较前面的字节，如果内容一样则判定该图片是PNG格式的
            return YES;
        }
    }

    return NO;
}

//计算图片成本？
FOUNDATION_STATIC_INLINE NSUInteger SDCacheCostForImage(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

#pragma mark --------------------
#pragma mark SDImageCache
@interface SDImageCache ()

@property (strong, nonatomic) NSCache *memCache;            //内存缓存
@property (strong, nonatomic) NSString *diskCachePath;      //磁盘缓存路径
@property (strong, nonatomic) NSMutableArray *customPaths;  //自定义路径（数组）
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue; //处理IO操作的队列

@end


@implementation SDImageCache {
    NSFileManager *_fileManager;    //文件管理者
}

//单例类方法，该方法提供一个全局的SDImageCache实例
+ (SDImageCache *)sharedImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//初始化方法，默认的缓存空间名称为default
- (id)init {
    return [self initWithNamespace:@"default"];
}

//使用指定的命名空间实例化一个新的缓存存储
- (id)initWithNamespace:(NSString *)ns {
    //根据传入的命名空间设置磁盘缓存路径
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}

//使用指定的命名空间实例化一个新的缓存存储和目录
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
    if ((self = [super init])) {
        //拼接默认的磁盘缓存目录
        NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:ns];

        // initialise PNG signature data
        //初始化PNG数据签名 8字节
        kPNGSignatureData = [NSData dataWithBytes:kPNGSignatureBytes length:8];

        // Create IO serial queue
        //创建处理IO操作的串行队列
        _ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);

        // Init default values
        //初始化默认的最大缓存时间 == 1周
        _maxCacheAge = kDefaultCacheMaxCacheAge;

        // Init the memory cache
        //初始化内存缓存，使用NSCache
        _memCache = [[AutoPurgeCache alloc] init];
        _memCache.name = fullNamespace;

        // Init the disk cache
        //初始化磁盘缓存，如果磁盘缓存路径不存在则设置为默认值，否则根据命名空间重新设置
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }

        // Set decompression to YES
        //设置图片是否解压缩，默认为YES
        _shouldDecompressImages = YES;

        // memory cache enabled
        // 内存缓存是否可用
        _shouldCacheImagesInMemory = YES;

        // Disable iCloud
        //禁用iCloud备份,默认为YES
        _shouldDisableiCloud = YES;

        //同步函数+串行队列：初始化文件管理者
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });

#if TARGET_OS_IPHONE
        // Subscribe to app events
        //监听应用程序通知
        //当监听到UIApplicationDidReceiveMemoryWarningNotification（系统级内存警告）调用clearMemory方法
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        //当监听到UIApplicationWillTerminateNotification（程序将终止）调用cleanDisk方法
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        //当监听到UIApplicationDidEnterBackgroundNotification（进入后台），调用backgroundCleanDisk方法
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
    }

    return self;
}

//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SDDispatchQueueRelease(_ioQueue);
}

/*
 * 如果希望在 bundle 中存储预加载的图像，可以添加一个只读的缓存路径
 * 让 SDImageCache 从 Bundle 中搜索预先缓存的图像
 * 只读缓存路径(mainBundle中的全路径)
*/
- (void)addReadOnlyCachePath:(NSString *)path {
    if (!self.customPaths) {
        self.customPaths = [NSMutableArray new];
    }

    if (![self.customPaths containsObject:path]) {
        [self.customPaths addObject:path];
    }
}

//获得指定 key 对应的缓存路径
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    //获得缓存文件的名称
    NSString *filename = [self cachedFileNameForKey:key];
    //返回拼接后的全路径
    return [path stringByAppendingPathComponent:filename];
}

//获得指定 key 的默认缓存路径
- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}
#pragma mark --------------------
#pragma mark SDImageCache (private)
//对key(通常为URL)进行MD5加密，加密后的密文作为图片的名称
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];

    return filename;
}

#pragma mark --------------------
#pragma mark SDImageCache

// Init the disk cache
//设置磁盘缓存路径
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    //获得caches路径，该框架内部对图片进行磁盘缓存，设置的缓存目录为沙盒中Library的caches目录下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //在caches目录下，新建一个名为【fullNamespace】的文件，沙盒缓存就保存在此处
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

//使用指定的键将图像保存到内存和可选的磁盘缓存
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk {
    //如果图片或对应的key为空，那么就直接返回
    if (!image || !key) {
        return;
    }
    // if memory cache is enabled
    //如果内存缓存可用
    if (self.shouldCacheImagesInMemory) {
        //计算该图片的『成本』
        NSUInteger cost = SDCacheCostForImage(image);
        //把该图片保存到内存缓存中
        [self.memCache setObject:image forKey:key cost:cost];
    }

    //判断是否需要沙盒缓存
    if (toDisk) {
        //异步函数+串行队列：开子线程异步处理block中的任务
        dispatch_async(self.ioQueue, ^{
            //拿到服务器返回的图片二进制数据
            NSData *data = imageData;
            
            //如果图片存在且（直接使用imageData||imageData为空）
            if (image && (recalculate || !data)) {
#if TARGET_OS_IPHONE
                // We need to determine if the image is a PNG or a JPEG
                // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
                // The first eight bytes of a PNG file always contain the following (decimal) values:
                // 137 80 78 71 13 10 26 10

                // If the imageData is nil (i.e. if trying to save a UIImage directly or the image was transformed on download)
                // and the image has an alpha channel, we will consider it PNG to avoid losing the transparency
                //获得该图片的alpha信息
                int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
                BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                                  alphaInfo == kCGImageAlphaNoneSkipFirst ||
                                  alphaInfo == kCGImageAlphaNoneSkipLast);
                //判断该图片是否是PNG图片
                BOOL imageIsPng = hasAlpha;

                // But if we have an image data, we will look at the preffix
                if ([imageData length] >= [kPNGSignatureData length]) {
                    imageIsPng = ImageDataHasPNGPreffix(imageData);
                }
                
                //如果判定是PNG图片，那么把图片转变为NSData压缩
                if (imageIsPng) {
                    data = UIImagePNGRepresentation(image);
                }
                else {
                     //否则采用JPEG的方式
                    data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
                }
#else
                data = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
            }

            if (data) {
                //确定_diskCachePath路径是否有效，如果无效则创建
                if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                    [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }

                // get cache Path for image key
                // 根据key获得缓存路径
                NSString *cachePathForKey = [self defaultCachePathForKey:key];
                // transform to NSUrl
                //把路径转换为NSURL类型
                NSURL *fileURL = [NSURL fileURLWithPath:cachePathForKey];
                
                //使用文件管理者在缓存路径创建文件，并设置数据
                [_fileManager createFileAtPath:cachePathForKey contents:data attributes:nil];

                // disable iCloud backup
                //如果禁用了iCloud备份
                if (self.shouldDisableiCloud) {
                    //标记沙盒中不备份文件（标记该文件不备份）
                    [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
                }
            }
        });
    }
}

//使用指定的键将图像保存到内存和磁盘缓存
- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    [self storeImage:image recalculateFromImage:YES imageData:nil forKey:key toDisk:YES];
}

//使用指定的键将图像保存到内存和可选的磁盘缓存
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk {
    [self storeImage:image recalculateFromImage:YES imageData:nil forKey:key toDisk:toDisk];
}

//异步检查图像是否已经在磁盘缓存中存在（不加载图像）
- (BOOL)diskImageExistsWithKey:(NSString *)key {
    //初始设置为NO
    BOOL exists = NO;
    
    // this is an exception to access the filemanager on another queue than ioQueue, but we are using the shared instance
    // from apple docs on NSFileManager: The methods of the shared NSFileManager object can be called from multiple threads safely.
    // 共享的 NSFileManager 对象可以保证在多线程运行时是安全的
    // 检查文件是否存在
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:key]];
    
    return exists;
}

//异步检查图像是否已经在磁盘缓存中存在（不加载图像）
- (void)diskImageExistsWithKey:(NSString *)key completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    //开子线程异步检查文件是否存在
    dispatch_async(_ioQueue, ^{
        BOOL exists = [_fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];
        if (completionBlock) {
            //在主线程回调completionBlock块
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

//获取该key对应的图片缓存数据
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    return [self.memCache objectForKey:key];
}

// 查询内存缓存之后同步查询磁盘缓存
//【注解】: 白开水ln✔️
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key {

    // First check the in-memory cache..
    //首先检查内存缓存，如果存在则直接返回
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }

    // Second check the disk cache...
    //接下来检查磁盘缓存，如果图片存在，且可以保存到内存缓存，则保存一份到内存缓存中
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage && self.shouldCacheImagesInMemory) {
        NSUInteger cost = SDCacheCostForImage(diskImage);
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    
    //返回图片
    return diskImage;
}

- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key {
    //获得给key对应的默认的缓存路径
    NSString *defaultPath = [self defaultCachePathForKey:key];
    //加载该路径下面的二进制数据
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    //如果有值，则直接返回
    if (data) {
        return data;
    }
    
    NSArray *customPaths = [self.customPaths copy];
    //遍历customPaths，若有值，则直接返回
    for (NSString *path in customPaths) {
        NSString *filePath = [self cachePathForKey:key inPath:path];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        if (imageData) {
            return imageData;
        }
    }

    return nil;
}

//获取KEY对应的磁盘缓存，如果不存在则直接返回nil
- (UIImage *)diskImageForKey:(NSString *)key {
    //得到二进制数据
    NSData *data = [self diskImageDataBySearchingAllPathsForKey:key];
    if (data) {
        //把对应的二进制数据转换为图片
        UIImage *image = [UIImage sd_imageWithData:data];
        //处理图片的缩放
        image = [self scaledImageForKey:key image:image];
        //判断是否需要解压缩（解码）并进行相应的处理
        if (self.shouldDecompressImages) {
            image = [UIImage decodedImageWithImage:image];
        }
        //返回图片
        return image;
    }
    else {
        return nil;
    }
}

//处理图片的缩放等，2倍尺寸|3倍尺寸？
- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image {
    return SDScaledImageForKey(key, image);
}

//检查要下载图片的缓存情况
/*
 1.先检查是否有内存缓存
 2.如果没有内存缓存则检查是否有沙盒缓存
 3.如果有沙盒缓存，则把该图片做内存缓存并处理doneBlock回调
 */
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(SDWebImageQueryCompletedBlock)doneBlock {
    
    //如果回调不存在，则直接返回
    if (!doneBlock) {
        return nil;
    }

    //如果缓存对应的key为空，则直接返回，并把存储方式（无缓存）通过block块以参数的形式传递
    if (!key) {
        doneBlock(nil, SDImageCacheTypeNone);
        return nil;
    }

    // First check the in-memory cache...
    //检查该KEY对应的内存缓存，如果存在内存缓存，则直接返回，并把图片和存储方式（内存缓存）通过block块以参数的形式传递
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        doneBlock(image, SDImageCacheTypeMemory);
        return nil;
    }
    
    
    NSOperation *operation = [NSOperation new]; //创建一个操作
    //使用异步函数，添加任务到串行队列中（会开启一个子线程处理block块中的任务）
    dispatch_async(self.ioQueue, ^{
        
        //如果当前的操作被取消，则直接返回
        if (operation.isCancelled) {
            return;
        }
        
        @autoreleasepool {
            //检查该KEY对应的磁盘缓存
            UIImage *diskImage = [self diskImageForKey:key];
            //如果存在磁盘缓存，且应该把该图片保存一份到内存缓存中，则先计算该图片的cost(成本）并把该图片保存到内存缓存中
            if (diskImage && self.shouldCacheImagesInMemory) {
                NSUInteger cost = SDCacheCostForImage(diskImage);
                [self.memCache setObject:diskImage forKey:key cost:cost];
            }
            
            //线程间通信，在主线程中回调doneBlock，并把图片和存储方式（磁盘缓存）通过block块以参数的形式传递
            dispatch_async(dispatch_get_main_queue(), ^{
                doneBlock(diskImage, SDImageCacheTypeDisk);
            });
        }
    });

    return operation;
}

//移除key对应的缓存，默认移除沙盒缓存
- (void)removeImageForKey:(NSString *)key {
    [self removeImageForKey:key withCompletion:nil];
}
//移除key对应的缓存，默认移除沙盒缓存
- (void)removeImageForKey:(NSString *)key withCompletion:(SDWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromDisk:YES withCompletion:completion];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk {
    [self removeImageForKey:key fromDisk:fromDisk withCompletion:nil];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(SDWebImageNoParamsBlock)completion {
    
    if (key == nil) {
        return;
    }

    //如果有内存缓存，则移除
    if (self.shouldCacheImagesInMemory) {
        [self.memCache removeObjectForKey:key];
    }

    //移除沙盒缓存操作处理
    if (fromDisk) {
        //开子线程异步执行，使用文件管理者移除指定路径的文件
        dispatch_async(self.ioQueue, ^{
            [_fileManager removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
            
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

//清除内存缓存
- (void)clearMemory {
    //把所有的内存缓存都删除
    [self.memCache removeAllObjects];
}

//清除磁盘缓存
- (void)clearDisk {
    [self clearDiskOnCompletion:nil];
}

//清除磁盘缓存（简单粗暴）
- (void)clearDiskOnCompletion:(SDWebImageNoParamsBlock)completion
{
    //开子线程异步处理 清理磁盘缓存的操作
    dispatch_async(self.ioQueue, ^{
        //删除缓存路径
        [_fileManager removeItemAtPath:self.diskCachePath error:nil];
        //重新创建缓存路径
        [_fileManager createDirectoryAtPath:self.diskCachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];

        if (completion) {
            //在主线程中处理completion回调
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

//清除过期的磁盘缓存
- (void)cleanDisk {
    [self cleanDiskWithCompletionBlock:nil];
}

//清除过期的磁盘缓存
- (void)cleanDiskWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];

        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];

        // 计算过期日期
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;

        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        // 遍历缓存路径中的所有文件，此循环要实现两个目的
        //  1. 删除早于过期日期的文件
        //  2. 保存文件属性以计算磁盘缓存占用空间
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];

            // Skip directories.
            // 跳过目录
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }

            // Remove files that are older than the expiration date;
            // 记录要删除的过期文件
            
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }

            // Store a reference to this file and account for its total size.
            //保存文件引用，以计算总大小
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // 删除过期的文件
        for (NSURL *fileURL in urlsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }

        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        //如果剩余磁盘缓存空间超出最大限额，再次执行清理操作，删除最早的文件
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;

            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];

            // Delete files until we fall below our desired cache size.
            // 循环依次删除文件，直到低于期望的缓存限额
            for (NSURL *fileURL in sortedFiles) {
                if ([_fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];

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

//当进入后台后，处理的磁盘缓存清理工作
- (void)backgroundCleanDisk {
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
    // 启动长期运行的任务，并立即返回
    [self cleanDiskWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

//获得大小
- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    //同步+串行队列
    dispatch_sync(self.ioQueue, ^{
        //得到diskCachePath路径下面的所有子路径
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        //遍历得到所有子路径对应文件的大小，并累加以计算所有文件的总大小
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
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
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

//异步计算磁盘缓存的大小
- (void)calculateSizeWithCompletionBlock:(SDWebImageCalculateSizeBlock)completionBlock {
    //把文件路径转换为URL
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];

    //开子线程异步处理block块中的任务
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;   //初始化文件的数量为0
        NSUInteger totalSize = 0;   //初始化缓存的总大小为0

        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];

        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            //累加缓存的大小
            totalSize += [fileSize unsignedIntegerValue];
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
