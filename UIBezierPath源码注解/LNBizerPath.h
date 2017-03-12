//
//  LNBizerPath.h
//  UIBezierPath.h
//  UIKit
//
//  Copyright (c) 2009-2015 Apple Inc. All rights reserved.
//  Copyright © 2016年 刘楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, UIRectCorner) {
    UIRectCornerTopLeft     = 1 << 0,
    UIRectCornerTopRight    = 1 << 1,
    UIRectCornerBottomLeft  = 1 << 2,
    UIRectCornerBottomRight = 1 << 3,
    UIRectCornerAllCorners  = ~0UL
};

NS_CLASS_AVAILABLE_IOS(3_2) @interface UIBezierPath : NSObject<NSCopying, NSCoding>

// 创建并且返回一个新的 UIBezierPath 对象
+ (instancetype)bezierPath;

/**
 * 画矩形
 * 通过一个矩形, 创建并且返回一个新的 UIBezierPath 对象
 * 该方法将会创建一个闭合路径, 起始点是 rect 参数的的 origin, 并且按照顺时针方向添加直线, 最终形成矩形
 * @param rect: 矩形路径的 Frame
 */
+ (instancetype)bezierPathWithRect:(CGRect)rect;

/**
 * 画圆（width = height）、画椭圆（width != height）
 * 通过一个指定的矩形中的椭圆形, 创建并且返回一个新的 UIBezierPath 对象
 * 该方法将会创建一个闭合路径,  该方法会通过顺时针的绘制贝塞尔曲线, 绘制出一个近似椭圆的形状. 如果 rect 参数指定了一个矩形, 那么该 UIBezierPath 对象将会描述一个圆形.
 * @param rect:   矩形路径的 Frame
 */
+ (instancetype)bezierPathWithOvalInRect:(CGRect)rect;

/**
 * 画圆角矩形
 * 根据一个圆角矩形, 创建并且返回一个新的 UIBezierPath 对象
 * 该方法将会创建一个闭合路径,  该方法会顺时针方向连续绘制直线和曲线.  当 rect 为正方形时且 cornerRadius 等于边长一半时, 则该方法会描述一个圆形路径.
 * @param rect: 矩形路径的 Frame
 * @param cornerRadius: 矩形的圆角半径
 */
+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius; // rounds all corners with the same horizontal and vertical radius

/**
 * 画指定角为圆角的矩形
 * 根据一个圆角矩形, 创建并且返回一个新的 UIBezierPath 对象
 * 该方法将会创建一个闭合路径,  该方法会顺时针方向连续绘制直线和曲线.
 * @param rect: 矩形路径的 Frame
 * @param corners: UIRectCorner 枚举类型, 指定矩形的哪个角变为圆角
 * @param cornerRadii: 矩形的圆角半径
 */
+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;

/**
 * 画圆弧
 * 通过一个圆弧, 创建并且返回一个新的 UIBezierPath 对象
 * 该方法会创建出一个开放路径, 创建出来的圆弧是圆的一部分. 在默认的坐标系统中, 开始角度 和 结束角度 都是基于单位圆的(看下面这张图). 调用这个方法之后, currentPoint 将会设置为圆弧的结束点.
 * @param center: 弧所在的圆心（这里不能直接用self.center,因为它是相对于它的父控件的,采用rect 宽度*0.5、高度*0.5）
 * @param radius: 圆的半径
 * @param startAngle: 开始角度
 * @param endAngle:  结束角度
 * @param clockwise: 是否顺时针绘制（YES顺时针 NO逆时针）
 */
+ (instancetype)bezierPathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;

/**
 * 通过一个 CGPath, 创建并且返回一个新的 UIBezierPath 对象
 */
+ (instancetype)bezierPathWithCGPath:(CGPathRef)CGPath;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

//
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

// Returns an immutable CGPathRef which is only valid until the UIBezierPath is further mutated.
// Setting the path will create an immutable copy of the provided CGPathRef, so any further mutations on a provided CGMutablePathRef will be ignored.
/**
 * 获取这个属性, 你将会获得一个不可变的 CGPathRef 对象,
 * 他可以传入 CoreGraphics 提供的函数中
 * 你可以是用 CoreGraphics 框架提供的方法创建一个路径,
 * 并给这个属性赋值, 当时设置了一个新的路径后,
 * 这个将会对你给出的路径对象进行 Copy 操作
 */
@property(nonatomic) CGPathRef CGPath;
- (CGPathRef)CGPath NS_RETURNS_INNER_POINTER CF_RETURNS_NOT_RETAINED;

// Path construction

/**
 * 设置起点
 * 将 UIBezierPath 对象的 currentPoint 移动到指定的点
 * 如果当前有正在绘制的子路径, 该方法则会隐式的结束当前路径, 并将 currentPoint 设置为指定点.
 * @param point: 当前坐标系统中的某一点
 */
- (void)moveToPoint:(CGPoint)point;

/**
 * 添加一根线到终点
 * 该方法将会从 currentPoint 到 指定点 链接一条直线.
 * @param point: 绘制直线的终点坐标, 当前坐标系统中的某一点
 * Note: 在追加完这条直线后, 该方法将会更新 currentPoint 为 指定点
 调用该方法之前, 你必须先设置 currentPoint. 如果当前绘制路径
 为空, 并且未设置 currentPoint, 那么调用该方法将不会产生任何
 效果.
 */
- (void)addLineToPoint:(CGPoint)point;

/**
 * 画三次贝塞尔曲线（由两个控制点来控制）
 * 该方法将会从 currentPoint 到 指定的 endPoint 追加一条三次贝塞尔曲线.
 * 三次贝塞尔曲线的弯曲由两个控制点来控制. 如下图所示
 * Note: 调用该方法前, 你必须先设置 currentPoint, 如果路径为空,
 并且尚未设置 currentPoint, 调用该方法则不会产生任何效果.
 当添加完贝塞尔曲线后, 该方法将会自动更新 currentPoint 为
 指定的结束点
 * @param endPoint: 终点
 * @param controlPoint1: 弯曲方向点1
 * @param controlPoint2: 弯曲方向点2
 */
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;

/**
 * 画二次贝塞尔曲线（由一个控制点来控制）
 * 该方法将会从 currentPoint 到 指定的 endPoint 追加一条二次贝塞尔曲线.
 * currentPoint、endPoint、controlPoint 三者的关系最终定义了二次贝塞尔曲线的形状.
 * 二次贝塞尔曲线的弯曲由一个控制点来控制. 如下图所示
 Note: 调用该方法前, 你必须先设置 currentPoint, 如果路径为空,
 并且尚未设置 currentPoint, 调用该方法则不会产生任何效果.
 当添加完贝塞尔曲线后, 该方法将会自动更新 currentPoint 为
 指定的结束点
 * @param endPoint: 终点
 * @param controlPoint: 弯曲方向点1
 */
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;

/**
 * 画指定一条圆弧
 * 该方法将会从 currentPoint 添加一条指定的圆弧.
 * 该方法的介绍和 bezierPathWithArcCenter构造方法中的一样. 请前往上文查看
 * @param center: 圆心
 * @param radius: 半径
 * @param startAngle: 开始角度
 * @param endAngle: 结束角度
 * @param clockwise: 是否顺时针绘制
 */
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise NS_AVAILABLE_IOS(4_0);

/**
 * 闭合路径
 * 该方法将会从 currentPoint 到子路经的起点 绘制一条直线,
 * 以此来关闭当前的自路径. 紧接着该方法将会更新 currentPoint
 * 为 刚添加的这条直线的终点, 也就是当前子路经的起点.
 */
- (void)closePath;

/**
 * 移除 UIBezierPath 对象中的所有点, 效果也就等同于移除所有子路经f
 */
- (void)removeAllPoints;

// Appending paths
/**
 * 追加路径
 * 该方法将会在当前 UIBezierPath 对象的路径中追加
 * 指定的 UIBezierPath 对象中的内容.
 */
- (void)appendPath:(UIBezierPath *)bezierPath;

// Modified paths
/**
 * 创建并返回一个新的BezierPath, 这个 BezierPath 的方向是原 BezierPath 的反方向
 * 通过该方法反转一条路径, 并不会修改该路径的样子. 它仅仅是修改了绘制的方向
 * @return: 返回一个新的 UIBezierPath 对象, 形状和原来路径的形状一样,但是绘制的方向相反.
 */
- (UIBezierPath *)bezierPathByReversingPath NS_AVAILABLE_IOS(6_0);

// Transforming paths
/**
 * Apply Transform
 * 该方法将会直接对路径中的所有点进行指定的放射
 * 变换操作.
 */
- (void)applyTransform:(CGAffineTransform)transform;

// Path info
/**
 * 路径是否为空
 * 检测当前路径是否绘制过直线或曲线.
 * Note: 记住, 就算你仅仅调用了 moveToPoint 方法
 *       那么当前路径也被看做不为空.
 */
@property(readonly,getter=isEmpty) BOOL empty;

/**
 * 路径覆盖的矩形区域
 * 该属性描述的是一个能够完全包含路径中所有点
 *  的一个最小的矩形区域. 该区域包含二次贝塞尔
 *  曲线和三次贝塞尔曲线的控制点.
 */
@property(nonatomic,readonly) CGRect bounds;

/**
 * 绘图路径中的当前点
 * 该属性的值, 将会是下一条绘制的直线或曲线的起始点.
 * 如果当前路径为空, 那么该属性的值将会是 CGPointZero
 */
@property(nonatomic,readonly) CGPoint currentPoint;

/**
 * 是否包含某个点
 * 该方法返回一个布尔值, 当曲线的覆盖区域包含
 * 指定的点(内部点)， 则返回 YES, 否则返回 NO.
 * Note: 如果当前的路径是一个开放的路径, 那么
 *       就算指定点在路径覆盖范围内, 该方法仍然会
 *       返回 NO, 所以如果你想判断一个点是否在一个
 *       开放路径的范围内时, 你需要先Copy一份路径,
 *       并调用 -(void)closePath; 将路径封闭, 然后
 *       再调用此方法来判断指定点是否是内部点.
 * @param point: 指定点.
 */
- (BOOL)containsPoint:(CGPoint)point;

// Drawing properties
/**
 * 线宽属性定义了 `UIBezierPath` 对象中绘制的曲线规格. 默认为: 1.0
 */
@property(nonatomic) CGFloat lineWidth;

/**
 * 曲线终点样式
 * 该属性应用于曲线的终点和起点. 该属性在一个闭合子路经中是无效果的. 默认为: kCGLineCapButt

 typedef CF_ENUM(int32_t, CGLineCap) {
    kCGLineCapButt,//
    kCGLineCapRound,// 圆弧
    kCGLineCapSquare //
 };
 */
@property(nonatomic) CGLineCap lineCapStyle;

/**
 * 曲线连接点样式
 * 默认为: kCGLineJoinMiter.
 
 typedef CF_ENUM(int32_t, CGLineJoin) {
    kCGLineJoinMiter,// 尖的
    kCGLineJoinRound,// 圆弧
    kCGLineJoinBevel // 斜面
 };
 */
@property(nonatomic) CGLineJoin lineJoinStyle;

/**
 * 内角和外角距离（斜接点长度）
 * 两条线交汇处内角和外角之间的最大距离, 只有当连接点样式为 kCGLineJoinMiter
 * 时才会生效，最大限制为10
 * 我们都知道, 两条直线相交时, 夹角越小, 斜接长度就越大.
 * 该属性就是用来控制最大斜接长度的.
 * 当我们设置了该属性, 如果斜接长度超过我们设置的范围,
 * 则连接处将会以 kCGLineJoinBevel 连接类型进行显示.
 */
@property(nonatomic) CGFloat miterLimit; // Used when lineJoinStyle is kCGLineJoinMiter

/**
 * 渲染精度
 * 该属性用来确定渲染曲线路径的精确度.
 * 该属性的值用来测量真实曲线的点和渲染曲线的点的最大允许距离.
 * 值越小, 渲染精度越高, 会产生相对更平滑的曲线, 但是需要花费更
 * 多的计算时间. 值越大导致则会降低渲染精度, 这会使得渲染的更迅速. flatness 的默认值为 0.6.
 * Note: 大多数情况下, 我们都不需要修改这个属性的值. 然而当我们
 希望以最小的消耗去绘制一个临时的曲线时, 我们也许会临时增
 大这个值, 来获得更快的渲染速度.
 */
@property(nonatomic) CGFloat flatness;

/**
 * 是否使用基偶填充规则
 * 设置为 YES, 则路径将会使用 基偶规则 (even-odd) 进行填充.
 * 设置为 NO,  则路径将会使用 非零规则 (non-zero) 规则进行填充.
 */
@property(nonatomic) BOOL usesEvenOddFillRule; // Default is NO. When YES, the even-odd fill rule is used for drawing, clipping, and hit testing.

/**
 * @param pattern: 该属性是一个 C 语言的数组, 其中每一个元素都是 CGFloat
 *                 数组中的元素代表着线段每一部分的长度, 第一个元素代表线段的第一条线,
 *                 第二个元素代表线段中的第一个间隙. 这个数组中的值是轮流的. 来解释一下
 *                 什么叫轮流的.
 *                 举个例子: 声明一个数组 CGFloat dash[] = @{3.0, 1.0};
 *                 这意味着绘制的虚线的第一部分长度为3.0, 第一个间隙长度为1.0, 虚线的
 *                 第二部分长度为3.0, 第二个间隙长度为1.0. 以此类推.
 *
 * @param count: 这个参数是 pattern 数组的个数
 * @param phase: 这个参数代表着, 虚线从哪里开始绘制.
 *                 举个例子: 这是 phase 为 6. pattern[] = @{5, 2, 3, 2}; 那么虚线将会
 第一个间隙的中间部分开始绘制, 如果不是很明白就请继续往下看,
 下文实战部分会对虚线进行讲解.
 */
- (void)setLineDash:(nullable const CGFloat *)pattern count:(NSInteger)count phase:(CGFloat)phase;

/**
 * 重新获取虚线的模式
 * 该方法可以重新获取之前设置过的虚线样式.
 *  Note:  pattern 这个参数的容量必须大于该方法返回数组的容量.
 *         如果无法确定数组的容量, 那么可以调用两次该方法, 第一次
 *         调用该方法的时候, 传入 count 参数, 然后在用 count 参数
 *         来申请 pattern 数组的内存空间. 然后再第二次正常的调用该方法
 */
- (void)getLineDash:(nullable CGFloat *)pattern count:(nullable NSInteger *)count phase:(nullable CGFloat *)phase;

// Path operations on the current graphics context
/**
 * 填充路径（实心）
 * 该方法当前的填充颜色 和 绘图属性对路径的封闭区域进行填充.
 * 如果当前路径是一条开放路径, 该方法将会隐式的将路径进行关闭后进行填充
 * 该方法在进行填充操作之前, 会自动保存当前绘图的状态, 所以我们不需要
 * 自己手动的去保存绘图状态了.
 */
- (void)fill;

/**
 * 描边路径
 */
- (void)stroke;

// These methods do not affect the blend mode or alpha of the current graphics context
/**
 * 混合模式进行填充
 * 该方法当前的填充颜色 和 绘图属性 (外加指定的混合模式 和 透明度)
 * 对路径的封闭区域进行填充. 如果当前路径是一条开放路径, 该方法将
 * 会隐式的将路径进行关闭后进行填充
 * 该方法在进行填充操作之前, 会自动保存当前绘图的状态, 所以我们不需要
 * 自己手动的去保存绘图状态了.
 *
 * @param blendMode: 混合模式决定了如何和已经存在的被渲染过的内容进行合成
 * @param alpha: 填充路径时的透明度
 */
- (void)fillWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (void)strokeWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

/**
 * 剪切路径
 * 该方法将会修改当前绘图上下文的可视区域.
 * 当调用这个方法之后, 会导致接下来所有的渲染操作,只会在剪切下来的区域内进行, 区域外的内容将不会被渲染.
 * 如果你希望执行接下来的绘图时, 删除剪切区域,
 * 那么你必须在调用该方法前, 先使用CGContextSaveGState 方法保存当前的绘图状态,
 * 当你不再需要这个剪切区域的时候, 你只需要使用 CGContextRestoreGState 方法，来恢复之前保存的绘图状态就可以了.
 *
 * @param blendMode: 混合模式决定了如何和已经存在的被渲染过的内容进行合成
 * @param alpha: 填充路径时的透明度
 */
- (void)addClip;

@end

NS_ASSUME_NONNULL_END
