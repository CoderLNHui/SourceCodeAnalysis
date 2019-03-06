/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageImageIOCoder.h"
#import "SDWebImageCoderHelper.h"
#import "NSImage+WebCache.h"
#import <ImageIO/ImageIO.h>
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"

#if SD_UIKIT || SD_WATCH
static const size_t kBytesPerPixel = 4;//kBytesPerPixel用来说明每个像素占用内存多少个字节，在这里是占用4个字节。（图像在iOS设备上是以像素为单位显示的）。
static const size_t kBitsPerComponent = 8;//kBitsPerComponent表示每一个组件占多少位。这个不太好理解，我们先举个例子，比方说RGBA，其中R（红色）G（绿色）B（蓝色）A（透明度）是4个组件，每个像素由这4个组件组成，那么我们就用8位来表示着每一个组件，所以这个RGBA就是8*4 = 32位。
//知道了kBitsPerComponent和每个像素有多少组件组成就能计算kBytesPerPixel了。计算公式是：(bitsPerComponent * number of components + 7)/8.

/*
 * Defines the maximum size in MB of the decoded image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 60.
 * Suggested value for iPad2 and iPhone 4: 120.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 30.
 //最大支持压缩图像源的大小默认的单位是MB，这里设置了60MB。当我们要压缩一张图像的时候，首先就是要定义最大支持的源文件的大小，不能没有任何限制。
 */
static const CGFloat kDestImageSizeMB = 60.0f;

/*
 * Defines the maximum size in MB of a tile used to decode image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 20.
 * Suggested value for iPad2 and iPhone 4: 40.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 10.
 //原图方块的大小,这个方块将会被用来分割原图，默认设置为20M。
 */
static const CGFloat kSourceImageTileSizeMB = 20.0f;

static const CGFloat kBytesPerMB = 1024.0f * 1024.0f; //1M有多少字节
static const CGFloat kPixelsPerMB = kBytesPerMB / kBytesPerPixel;//1M有多少像素
static const CGFloat kDestTotalPixels = kDestImageSizeMB * kPixelsPerMB;//目标总像素
static const CGFloat kTileTotalPixels = kSourceImageTileSizeMB * kPixelsPerMB;////原图放款总像素

static const CGFloat kDestSeemOverlap = 2.0f;   // the numbers of pixels to overlap the seems where tiles meet.重叠像素大小
#endif

@implementation SDWebImageImageIOCoder {
        size_t _width, _height;
#if SD_UIKIT || SD_WATCH
        UIImageOrientation _orientation;
#endif
        CGImageSourceRef _imageSource;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
}

+ (instancetype)sharedCoder {
    static SDWebImageImageIOCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDWebImageImageIOCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
//是否可以解码,根据data判断图片类型,WebP不支持，根据本机类型来判断是否支持SDImageFormatHEIC
- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP decoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        case SDImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [[self class] canDecodeFromHEIFFormat];
        default:
            return YES;
    }
}
//是否可以编码,并且实现逐渐显示效果,根据data判断图片类型,WebP不支持，根据本机类型来判断是否支持SDImageFormatHEIC
- (BOOL)canIncrementallyDecodeFromData:(NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP progressive decoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        case SDImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [[self class] canDecodeFromHEIFFormat];
        default:
            return YES;
    }
}

/*
 解码图像
 先通过initWithData获取到一个image，然后获取data的类型
 */
- (UIImage *)decodedImageWithData:(NSData *)data {
    //如果二进制数据为空，则直接返回nil
    if (!data) {
        return nil;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:data];
    //通过分类中的sd_imageFormatForImageData方法获得图片的类型
    image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
    
    return image;
}

//逐步解码
- (UIImage *)incrementallyDecodedImageWithData:(NSData *)data finished:(BOOL)finished {
    if (!_imageSource) {
        _imageSource = CGImageSourceCreateIncremental(NULL);
    }
    UIImage *image;
    
    // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
    // Thanks to the author @Nyx0uf
    
    // Update the data source, we must pass ALL the data, not just the new bytes
    CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)data, finished);
    
    if (_width + _height == 0) {
        //获取图像的属性信息
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (properties) {
            NSInteger orientationValue = 1;
            //获取图片高度信息
            CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            //将图片高度绑定在_height上
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_height);
            //获取图片宽度信息
            val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            //将图片宽度绑定在_width上
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_width);
            //获取图像方向信息
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            //将图片的方向信息绑定在orientationValue上
            if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
            CFRelease(properties);
            
            // When we draw to Core Graphics, we lose orientation information,
            // which means the image below born of initWithCGIImage will be
            // oriented incorrectly sometimes. (Unlike the image born of initWithData
            // in didCompleteWithError.) So save it here and pass it on later.
#if SD_UIKIT || SD_WATCH
            //转换方向信息
            _orientation = [SDWebImageCoderHelper imageOrientationFromEXIFOrientation:orientationValue];
#endif
        }
    }
    
    if (_width + _height > 0) {
        // Create the image
        //获取图像
        CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        
        //拿到CGImageRef 转换成image并且返回
        if (partialImageRef) {
#if SD_UIKIT || SD_WATCH
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:1 orientation:_orientation];
#elif SD_MAC
            image = [[UIImage alloc] initWithCGImage:partialImageRef size:NSZeroSize];
#endif
            CGImageRelease(partialImageRef);
            image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
        }
    }
    
    //下载完成，销毁对象
    if (finished) {
        if (_imageSource) {
            CFRelease(_imageSource);
            _imageSource = NULL;
        }
    }
    
    return image;
}

//压缩图片
- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
#if SD_MAC
    return image;
#endif
#if SD_UIKIT || SD_WATCH
    BOOL shouldScaleDown = NO;
    if (optionsDict != nil) {
        //判断是否有在压缩过程中缩小图片尺寸的标识
        NSNumber *scaleDownLargeImagesOption = nil;
        if ([optionsDict[SDWebImageCoderScaleDownLargeImagesKey] isKindOfClass:[NSNumber class]]) {
            scaleDownLargeImagesOption = (NSNumber *)optionsDict[SDWebImageCoderScaleDownLargeImagesKey];
        }
        if (scaleDownLargeImagesOption != nil) {
            shouldScaleDown = [scaleDownLargeImagesOption boolValue];
        }
    }
    if (!shouldScaleDown) {
        //如果没有压缩过程中缩小图片尺寸的标识
        return [self sd_decompressedImageWithImage:image];
    } else {
        //如果有压缩过程中缩小图片尺寸的标识
        UIImage *scaledDownImage = [self sd_decompressedAndScaledDownImageWithImage:image];
        if (scaledDownImage && !CGSizeEqualToSize(scaledDownImage.size, image.size)) {
            // if the image is scaled down, need to modify the data pointer as well
            SDImageFormat format = [NSData sd_imageFormatForImageData:*data];
            //编码
            NSData *imageData = [self encodedDataWithImage:scaledDownImage format:format];
            if (imageData) {
                *data = imageData;
            }
        }
        return scaledDownImage;
    }
#endif
}

#if SD_UIKIT || SD_WATCH
//压缩图片，重新绘制图片，得到没有透明度的图片
/*
 在自动释放池中，使用CGImageRef创建像素位图，获取图片的色彩空间、透明度、宽度像素、高度像素，创建位图上下文，绘制得到没有透明度的图片。
 */
- (nullable UIImage *)sd_decompressedImageWithImage:(nullable UIImage *)image {
    //是否可以解码图片
    if (![[self class] shouldDecodeImage:image]) {
        return image;
    }
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool{
        
        //CGImageRef是定义在QuartzCore框架中的一个结构体指针，用C语言编写。其定义在CGImage.h
        //这个结构用来创建像素位图，可以通过操作存储的像素位来编辑图片
        CGImageRef imageRef = image.CGImage;
        // device color space
        //获取色彩空间
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        BOOL hasAlpha = SDCGImageRefContainsAlpha(imageRef);
        // iOS display alpha info (BRGA8888/BGRX8888)
        //获得图片的透明度信息
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        //获取宽度像素
        size_t width = CGImageGetWidth(imageRef);
        //获取高度像素
        size_t height = CGImageGetHeight(imageRef);
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        
        //重新绘制图片，得到没有透明度的图片
        //创建位图上下文
        /*
         第一个参数data：指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
         第二个参数width：bitmap的宽度,单位为像素
         第三个参数height：bitmap的高度,单位为像素
         第四个参数bitsPerComponent：内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8
         第五个参数bytesPerRow：bitmap的每一行在内存所占的比特数
         第六个参数space：bitmap上下文使用的颜色空间
         第七个参数bitmapInfo：指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串
         */
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     kBitsPerComponent,
                                                     0,
                                                     colorspaceRef,
                                                     bitmapInfo);
        if (context == NULL) {
            return image;
        }
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        //绘图（上下文，rect和imageRef）
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
    
        //该方面使用一个CGImageRef创建UIImage,指定缩放的倍数和旋转的方向
        //当scale为1的时候，表示新创建的图像将和原图像尺寸一摸一样
        //orientation指定图像的绘制方向
        UIImage *imageWithoutAlpha = [[UIImage alloc] initWithCGImage:imageRefWithoutAlpha scale:image.scale orientation:image.imageOrientation];
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}

//压缩图片并且缩小图片尺寸
- (nullable UIImage *)sd_decompressedAndScaledDownImageWithImage:(nullable UIImage *)image {
   
    //是否可以解码图片
    if (![[self class] shouldDecodeImage:image]) {
        return image;
    }
    
    //是否可以缩小图片
    if (![[self class] shouldScaleDownImage:image]) {
        return [self sd_decompressedImageWithImage:image];
    }
    
    CGContextRef destContext;
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool {
        //拿到图片属性
        CGImageRef sourceImageRef = image.CGImage;
        
        //拿到图片的宽和高
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        //原图总像素
        CGFloat sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        // Determine the scale ratio to apply to the input image
        // that results in an output image of the defined size.
        // see kDestImageSizeMB, and how it relates to destTotalPixels.
        //计算压缩比例
        CGFloat imageScale = sqrt(kDestTotalPixels / sourceTotalPixels);
        //目标像素
        CGSize destResolution = CGSizeZero;
        //目标像素宽
        destResolution.width = (int)(sourceResolution.width * imageScale);
        //目标像素高
        destResolution.height = (int)(sourceResolution.height * imageScale);
        
        // device color space
        //颜色空间
        CGColorSpaceRef colorspaceRef = SDCGColorSpaceGetDeviceRGB();
        BOOL hasAlpha = SDCGImageRefContainsAlpha(sourceImageRef);
        // iOS display alpha info (BGRA8888/BGRX8888)
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        destContext = CGBitmapContextCreate(NULL,
                                            destResolution.width,
                                            destResolution.height,
                                            kBitsPerComponent,
                                            0,
                                            colorspaceRef,
                                            bitmapInfo);
        
        if (destContext == NULL) {
            return image;
        }
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        
        // Now define the size of the rectangle to be used for the
        // incremental blits from the input image to the output image.
        // we use a source tile width equal to the width of the source
        // image due to the way that iOS retrieves image data from disk.
        // iOS must decode an image from disk in full width 'bands', even
        // if current graphics context is clipped to a subrect within that
        // band. Therefore we fully utilize all of the pixel data that results
        // from a decoding opertion by achnoring our tile size to the full
        // width of the input image.
        //计算第一个原图方块 sourceTile，这个方块的宽度同原图一样，高度根据方块容量计算
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // The source tile height is dynamic. Since we specified the size
        // of the source tile in MB, see how many rows of pixels high it
        // can be given the input image width.
        sourceTile.size.height = (int)(kTileTotalPixels / sourceTile.size.width );
        sourceTile.origin.x = 0.0f;
        // The output tile is the same proportions as the input tile, but
        // scaled to image scale.
        //计算目标图像方块 destTile
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        // The source seem overlap is proportionate to the destination seem overlap.
        // this is the amount of pixels to overlap each tile as we assemble the ouput image.
        //计算原图像方块与方块重叠的像素大小 sourceSeemOverlap
        float sourceSeemOverlap = (int)((kDestSeemOverlap/destResolution.height)*sourceResolution.height);
        CGImageRef sourceTileImageRef;
        // calculate the number of read/write operations required to assemble the
        // output image.
        //计算原图像需要被分割成多少个方块 iterations
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // If tile height doesn't divide the image height evenly, add another iteration
        // to account for the remaining pixels.
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if(remainder) {
            iterations++;
        }
        // Add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
        //根据重叠像素计算原图方块的大小后，获取原图中该方块内的数据，把该数据写入到相对应的目标方块中
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += kDestSeemOverlap;
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = destResolution.height - (( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + kDestSeemOverlap);
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImageRef, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        
        //返回目标图像
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [[UIImage alloc] initWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}
#endif

#pragma mark - Encode
//确定是否可以编码,webP不支持，HEIC通过canEncodeToHEICFormat方法来判断，其他的类型可以
- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    switch (format) {
        case SDImageFormatWebP:
            // Do not support WebP encoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [[self class] canEncodeToHEICFormat];
        case SDImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [[self class] canEncodeToHEIFFormat];
        default:
            return YES;
    }
}

//编码
- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format {
    //图片不存在就返回
    if (!image) {
        return nil;
    }
    //若没有指定类型，如果有透明度，就是png，没有就是jpeg
    if (format == SDImageFormatUndefined) {
        //这边是根据是否含有Alpha通道来判断
        BOOL hasAlpha = SDCGImageRefContainsAlpha(image.CGImage);
        if (hasAlpha) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
    }
    
    //创建要写入的数据对象
    NSMutableData *imageData = [NSMutableData data];
    //转换成系统的图片类型
    CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:format];
    
    // Create an image destination.
    //创建一个Image Destination
    /**
     CGImageDestinationRef将图片数据写入目的地，并且负责做图片编码，CGImageDestination用于将照片写入到用户的磁盘中，在写入前可修改元数据
     参数1：要写入的数据对象
     参数2：生成的图像文件的统一类型标识符
     参数3：图像文件将包含的图像数量，不包含缩略图
     参数4：留给未来使用，保留为NULL。
      */
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    
    
    //创建属性
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
#if SD_UIKIT || SD_WATCH
    //转换ios图像的方向到EXIF格式的方向
    /**
     EXIF信息官方的话语
     EXIF信息，是可交换图像文件的缩写，是专门为数码相机的照片设定的，可以记录数码照片的属性信息和拍摄数据。
     EXIF可以附加于JPEG、TIFF、RIFF等文件之中，为其增加有关数码相机拍摄信息的内容和索引图或图像处理软件的版本信息
     */
 
    NSInteger exifOrientation = [SDWebImageCoderHelper exifOrientationFromImageOrientation:image.imageOrientation];
    //设置相应的属性
    [properties setValue:@(exifOrientation) forKey:(__bridge NSString *)kCGImagePropertyOrientation];
#endif
    
    // Add your image to the destination. 添加数据和图片
    //添加图片和元信息到imageDestination中
    CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination. 最后调用，完成数据写入
    //最后调用，完成数据写入，如果图像成功写入就返回YES，否则返回NO
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    //结束要释放这个对象

    CFRelease(imageDestination);
    
    return [imageData copy];
}

#pragma mark - Helper
//是否可以解码image，若有透明度，则不需要解码
+ (BOOL)shouldDecodeImage:(nullable UIImage *)image {
    // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
    if (image == nil) {
        return NO;
    }
    
    // do not decode animated images
    if (image.images != nil) {
        return NO;
    }
    
    return YES;
}

//是否支持HEIC类型的解码，iOS 11+ 的设备可以解码
+ (BOOL)canDecodeFromHEICFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatHEIC];
        NSArray *imageUTTypes = (__bridge_transfer NSArray *)CGImageSourceCopyTypeIdentifiers();
        if ([imageUTTypes containsObject:(__bridge NSString *)(imageUTType)]) {
            canDecode = YES;
        }
    });
    return canDecode;
}

+ (BOOL)canDecodeFromHEIFFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatHEIF];
        NSArray *imageUTTypes = (__bridge_transfer NSArray *)CGImageSourceCopyTypeIdentifiers();
        if ([imageUTTypes containsObject:(__bridge NSString *)(imageUTType)]) {
            canDecode = YES;
        }
    });
    return canDecode;
}

//是否可以进行HEIC编码，通过判断HEIC是否可以写入imageDestination来确定是否可以编码
+ (BOOL)canEncodeToHEICFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableData *imageData = [NSMutableData data];
        CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatHEIC];
        
        // Create an image destination.
        CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
        if (!imageDestination) {
            // Can't encode to HEIC
            canEncode = NO;
        } else {
            // Can encode to HEIC
            CFRelease(imageDestination);
            canEncode = YES;
        }
    });
    return canEncode;
}

+ (BOOL)canEncodeToHEIFFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableData *imageData = [NSMutableData data];
        CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatHEIF];
        
        // Create an image destination.
        CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
        if (!imageDestination) {
            // Can't encode to HEIF
            canEncode = NO;
        } else {
            // Can encode to HEIF
            CFRelease(imageDestination);
            canEncode = YES;
        }
    });
    return canEncode;
}

#if SD_UIKIT || SD_WATCH
//是否可以剪切image，若有透明度，则不需要剪切
+ (BOOL)shouldScaleDownImage:(nonnull UIImage *)image {
    BOOL shouldScaleDown = YES;
    
    CGImageRef sourceImageRef = image.CGImage;
    CGSize sourceResolution = CGSizeZero;
    sourceResolution.width = CGImageGetWidth(sourceImageRef);
    sourceResolution.height = CGImageGetHeight(sourceImageRef);
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    float imageScale = kDestTotalPixels / sourceTotalPixels;
    if (imageScale < 1) {
        shouldScaleDown = YES;
    } else {
        shouldScaleDown = NO;
    }
    
    return shouldScaleDown;
}
#endif

@end
