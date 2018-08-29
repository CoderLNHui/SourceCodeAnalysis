//
//  FLAnimatedImageView.h
//  Flipboard
//
//  Created by Raphael Schaad on 7/8/13.
//  Copyright (c) 2013-2015 Flipboard. All rights reserved.
//


#import <UIKit/UIKit.h>

@class FLAnimatedImage;
@protocol FLAnimatedImageViewDebugDelegate;


//
//  An `FLAnimatedImageView` can take an `FLAnimatedImage` and plays it automatically when in view hierarchy and stops when removed.
//  The animation can also be controlled with the `UIImageView` methods `-start/stop/isAnimating`.
//  It is a fully compatible `UIImageView` subclass and can be used as a drop-in component to work with existing code paths expecting to display a `UIImage`.
//  Under the hood it uses a `CADisplayLink` for playback, which can be inspected with `currentFrame` & `currentFrameIndex`.
//

/**
 `FLAnimatedImageView`是一个`UIImageView`的子类。实现了`UIImageView`的`start/stop/isAnimating`方法。所以我们可以直接使用`FLAnimatedImageView`替代`UIImageView`。
 通过`CADisplayLink`对象来处理当前图片帧和下一帧图片的显示。
 */
@interface FLAnimatedImageView : UIImageView

// Setting `[UIImageView.image]` to a non-`nil` value clears out existing `animatedImage`.
// And vice versa, setting `animatedImage` will initially populate the `[UIImageView.image]` to its `posterImage` and then start animating and hold `currentFrame`.

/**
 动态图片的封装对象。首先通过设置`[UIImageView.image]`为nil来清除已经存在的动态图片。设置`animatedImage`属性会自动设置新的动态图片并且开始显示。而且会把当前显示的UIImage存入`currentFrame`中。
 */
@property (nonatomic, strong) FLAnimatedImage *animatedImage;

@property (nonatomic, copy) void(^loopCompletionBlock)(NSUInteger loopCountRemaining);
/**
 当前动画帧对应的UIImage对象
 */
@property (nonatomic, strong, readonly) UIImage *currentFrame;

/**
 当前图片镇对应的索引
 */
@property (nonatomic, assign, readonly) NSUInteger currentFrameIndex;

// The animation runloop mode. Enables playback during scrolling by allowing timer events (i.e. animation) with NSRunLoopCommonModes.
// To keep scrolling smooth on single-core devices such as iPhone 3GS/4 and iPod Touch 4th gen, the default run loop mode is NSDefaultRunLoopMode. Otherwise, the default is NSDefaultRunLoopMode.

/**
 指定动态图片执行所在的runloop的mode。NSRunLoopCommonMode
 */
@property (nonatomic, copy) NSString *runLoopMode;

@end
