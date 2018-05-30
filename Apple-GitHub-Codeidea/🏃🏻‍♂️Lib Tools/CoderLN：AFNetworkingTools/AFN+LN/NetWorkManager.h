/*
 * NetWorkManager.h
 *
 * Effect: 负责项目的网络请求
 *
 * About ME『Public：Codeidea / https://githubidea.github.io』.
 * Copyright © All members (Star|Fork) have the right to read and write『https://github.com/CoderLN』.
 *
 * 🏃🏻‍♂️ ◕该模块将系统化学习，后续替换、补充文章内容 ~
 */

#import "AFHTTPSessionManager.h"

// NS_ENUM 枚举
typedef NS_ENUM(NSUInteger, HttpRequestType) {
    HttpRequestTypeGET,
    HttpRequestTypePOST,
};


/**定义请求成功的block*/
typedef void (^requestSuccess)(id  _Nullable responseObject);

/**定义请求失败的block*/
typedef void (^requestFailure)(NSError * _Nonnull error);

/**定义 上传/下载 进度block*/
typedef void (^progress)(float progress);

/**定义 下载完成回调 进度block*/
typedef void (^completionHandler)(NSURL *fullPath, NSError *error);


@interface NetWorkManager : AFHTTPSessionManager


/**
 * 获得全局网络请求实例单例方法
 *
 * @return 网络请求类的实例对象
 */
+ (instancetype)sharedManager;


#pragma mark - AFN实时检测网络状态

/**
 * AFN实时检测网络状态
 */
+ (void)afnReachability;


/**
 * 网络请求
 *
 * @param requestType   GET / POST
 * @param urlString     请求的地址
 * @param parameters    请求的参数
 * @param successBlock       请求成功的回调
 * @param failureBlock       请求失败的回调
 */
+ (void)requestWithType:(HttpRequestType)requestType url:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)successBlock failure:(requestFailure)failureBlock;




/**
 * 文件下载
 *
 * @param urlString             请求的地址
 * @param parameters            文件下载预留参数 (可为nil)
 * @param downloadProgressBlock 下载进度回调
 * @param completionHandler     请求完成回调
 *        fullPath              文件存储路径
 */
+ (void)downloadFileWithURL:(NSString *)urlString parameters:(id)parameters progress:(progress)downloadProgressBlock completionHandler:(completionHandler)completionHandler;




/**
 * 文件上传 (多张图片上传)
 *
 * @param urlString         上传的地址
 * @param parameters        文件上传预留参数 (可为nil)
 * @param imageAry          上传的图片数组
 * @param width             图片要被压缩到的宽度
 * @param uploadProgressBlock    上传进度
 * @param successBlock      上传成功的回调
 * @param failureBlock      上传失败的回调
 */
+ (void)uploadFileWithURL:(NSString *)urlString parameters:(id)parameters imageAry:(NSArray *)imageAry targetWidth:(CGFloat)width progress:(progress)uploadProgressBlock success:(requestSuccess)successBlock failure:(requestFailure)failureBlock;





/**
 *  视频上传
 *
 *  @param operations   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 
 整体思路已经清楚，拿到视频资源，先转为mp4，写进沙盒，然后上传，上传成功后删除沙盒中的文件。
 本地拍摄的视频，上传到服务器：
 https://www.cnblogs.com/HJQ2016/p/5962813.html
 */
+ (void)uploadVideoWithOperaitons:(NSDictionary *)operations withVideoPath:(NSString *)videoPath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withUploadProgress:(progress)progress;





/**
 * 取消所有的网络请求
 */
+ (void)cancelAllRequest;





/**
 * 取消指定的网络请求
 *
 * @param requestMethod     请求方式(GET、POST)
 * @param urlString  请求URL
 */
+ (void)cancelWithRequestMethod:(NSString *)requestMethod parameters:(id)parameters requestUrlString:(NSString *)urlString;

  
@end




































