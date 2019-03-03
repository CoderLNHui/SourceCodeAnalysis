//
//  NetWorkManager.h
//  https://github.com/CoderLN/Apple-GitHub-Codeidea
//
 
/**
 数据请求模块 - 子类化AFN
 
 创建网络工具类单例，在单例创建的时候配置相关参数，
 例如：新增一些响应解析器能够接受的数据类型（接受数据不全导致网络请求错误是AFN的一大坑）、设置超时时间、配置请求头（这里我们把access_token验证放到了请求头里，有的项目是放到了请求体或参数里）、配置响应器和解析器等
 基于AFHTTPSessionManager（是对NSURLSession的封装）GET、POST、Upload、Download方法二次封装
 上传Upload方法需要上传数据的参数，所以这里建立了个参数模型 UploadParametersModel
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




































