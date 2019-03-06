/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+ImageContentType.h"
#if SD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

// Currently Image/IO does not support WebP
#define kSDUTTypeWebP ((__bridge CFStringRef)@"public.webp")
// AVFileTypeHEIC/AVFileTypeHEIF is defined in AVFoundation via iOS 11, we use this without import AVFoundation
#define kSDUTTypeHEIC ((__bridge CFStringRef)@"public.heic")
#define kSDUTTypeHEIF ((__bridge CFStringRef)@"public.heif")

@implementation NSData (ImageContentType)
//SDWebImage通过文件头来获取图片的类型，以png为例，png的前8个字节依次为：0x89  0x50 0x4E   0x47 0x0D 0x0A 0x1A 0x0A，再比如jpg图片，jpg文件比较复杂，JPG文件数据，分很多很多的数据段， 并且每个数据段都会以 0xFF开头
+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return SDImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    //获得传入的图片二进制数据的第一个字节
    [data getBytes:&c length:1];
    //在判断图片类型的时候，只匹配第一个字节
    switch (c) {
        case 0xFF:
            return SDImageFormatJPEG; //jpeg是 FF开头
        case 0x89:
            return SDImageFormatPNG; //png 是 89开头
        case 0x47:
            return SDImageFormatGIF;// gif 是 47开头
        case 0x49:
        case 0x4D:
            return SDImageFormatTIFF;// tiff 是 49 或者 4D开头
        case 0x52: {
            //WEBP :是一种同时提供了有损压缩与无损压缩的图片文件格式，webp是以524946462A73010057454250开头的，占用12个字节，当第一个字节为52时，如果长度<12 我们就认定为不是图片。因此返回nil。我们通过数据截取后获得testString,如果testString头部包含RIFF且尾部也包含WEBP，那么就认定该图片格式为webp。
            
            if (data.length >= 12) {
                //RIFF....WEBP
                //获取前12个字节

                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                //如果以『RIFF』开头，且以『WEBP』结束，那么就认为该图片是Webp类型的
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return SDImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            /*
             1.什么是.heic格式图片？
             之前叫“live”图片，打开下图红框中的按钮即可打开该模式，拍照后会截取拍照前后大概两秒的一个片段，与“Gif”图不同的是，该格式还包含了声音，目前只有在 iOS11系统下且CPU为A10及其以上（最低也得是iPhone 7），其他情况下拍出来的都是普通“live”图，即在需要转换格式的时候会自动转换为“.jpg/.jpeg”格式
             2.如何判断.heic格式图片？
             第四到第八个字节，分别等于：ftypheic，ftypheix，ftyphevc，ftyphevx，就可以认定他是.heic格式的图片
             */
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return SDImageFormatHEIC;
                }
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return SDImageFormatHEIF;
                }
            }
            break;
        }
    }
    return SDImageFormatUndefined;
}

//根据format转换成相应的CFStringRef类型的格式
+ (nonnull CFStringRef)sd_UTTypeFromSDImageFormat:(SDImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case SDImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case SDImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case SDImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case SDImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case SDImageFormatWebP:
            UTType = kSDUTTypeWebP;
            break;
        case SDImageFormatHEIC:
            UTType = kSDUTTypeHEIC;
            break;
        case SDImageFormatHEIF:
            UTType = kSDUTTypeHEIF;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

+ (SDImageFormat)sd_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return SDImageFormatUndefined;
    }
    SDImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatTIFF;
    } else if (CFStringCompare(uttype, kSDUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatWebP;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatHEIC;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = SDImageFormatHEIF;
    } else {
        imageFormat = SDImageFormatUndefined;
    }
    return imageFormat;
}

@end
