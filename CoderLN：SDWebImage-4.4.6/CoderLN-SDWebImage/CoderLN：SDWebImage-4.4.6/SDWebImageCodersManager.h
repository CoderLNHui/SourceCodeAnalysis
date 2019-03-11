/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 SDWebImage里自己写了一个编解码管理器，用于实现编码，解码，压缩，缩小图片像素功能。涉及到的文件有SDWebImageCodersManager，SDWebImageCoder，SDWebImageImageIOCoder等等
 SDWebImageCodersManager是一个编解码管理器，处理多个图片编码解码任务，编码器数组是一个优先级队列，这意味着后面添加的编码器将具有最高优先级。
 
 编码Encode：image-->NSData
 编码过程，这里指的就是将一个UIImage表示的图像，编码为对应图像格式的数据，输出一个NSData的过程。Image/IO提供的对应概念，叫做CGImageDestination，表示一个输出。之后的编码相关的操作，和这个Destination一一对应。
 解码Decoder：NSData-->image
 解码，指的是讲已经编码过的图像封装格式的数据，转换为可以进行渲染的图像数据。具体来说，iOS平台上就指的是将一个输入的二进制Data，转换为上层UI组件渲染所用的UIImage对象。
 
 +----Decoder 解码器
 |--------SDWebImageCodersManager 整体Coders的入口，提供是否可Coder和Coder转发
 |--------SDWebImageCoder  主要说明Coder Delegate 需要实现的接口
 |--------SDWebImageImageIOCoder  PNG/JPEG的Encode和解压操作
 |--------SDWebImageGIFCoder  GIF的Coder操作
 |--------SDWebImageWebPCoder  WebP的Coder操作
 |--------SDWebImageFrame  辅助类，主要在GIF等动态图使用
 |--------SDWebImageCoderHelper  辅助类，包括方向、Gif图合成等
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCoder.h"

/**
 Global object holding the array of coders, so that we avoid passing them from object to object.
 Uses a priority queue behind scenes, which means the latest added coders have the highest priority.
 This is done so when encoding/decoding something, we go through the list and ask each coder if they can handle the current data.
 That way, users can add their custom coders while preserving our existing prebuilt ones
 
 Note: the `coders` getter will return the coders in their reversed order
 Example:
 - by default we internally set coders = `IOCoder`, `WebPCoder`. (`GIFCoder` is not recommended to add only if you want to get GIF support without `FLAnimatedImage`)
 - calling `coders` will return `@[WebPCoder, IOCoder]`
 - call `[addCoder:[MyCrazyCoder new]]`
 - calling `coders` now returns `@[MyCrazyCoder, WebPCoder, IOCoder]`
 
 Coders
 ------
 A coder must conform to the `SDWebImageCoder` protocol or even to `SDWebImageProgressiveCoder` if it supports progressive decoding
 Conformance is important because that way, they will implement `canDecodeFromData` or `canEncodeToFormat`
 Those methods are called on each coder in the array (using the priority order) until one of them returns YES.
 That means that coder can decode that data / encode to that format
 */
@interface SDWebImageCodersManager : NSObject<SDWebImageCoder>

/**
 Shared reusable instance
 */
+ (nonnull instancetype)sharedInstance;

/**
 All coders in coders manager. The coders array is a priority queue, which means the later added coder will have the highest priority
 编码器管理器中的所有编码器。编码器数组是一个优先级队列，这意味着后面添加的编码器将具有最高优先级。
 */
@property (nonatomic, copy, readwrite, nullable) NSArray<id<SDWebImageCoder>> *coders;

/**
 Add a new coder to the end of coders array. Which has the highest priority.

 @param coder coder
 增加一个新的coder ，新加入的最先编解码
 */
- (void)addCoder:(nonnull id<SDWebImageCoder>)coder;

/**
 Remove a coder in the coders array.

 @param coder coder
 删除一个coder
 */
- (void)removeCoder:(nonnull id<SDWebImageCoder>)coder;

@end
