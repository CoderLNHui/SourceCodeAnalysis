//
// Created by Fabrice Aneche on 06/01/14.
// Copyright (c) 2014 Dailymotion. All rights reserved.
//

#import "NSData+ImageContentType.h"


@implementation NSData (ImageContentType)

+ (NSString *)sd_contentTypeForImageData:(NSData *)data {
    uint8_t c;
    //获得传入的图片二进制数据的第一个字节
    [data getBytes:&c length:1];
    //在判断图片类型的时候，只匹配第一个字节
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            //WEBP :是一种同时提供了有损压缩与无损压缩的图片文件格式
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            //获取前12个字节
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            //如果以『RIFF』开头，且以『WEBP』结束，那么就认为该图片是Webp类型的
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            //否则返回nil
            return nil;
    }
    return nil;
}

@end


@implementation NSData (ImageContentTypeDeprecated)

+ (NSString *)contentTypeForImageData:(NSData *)data {
    return [self sd_contentTypeForImageData:data];
}

@end
