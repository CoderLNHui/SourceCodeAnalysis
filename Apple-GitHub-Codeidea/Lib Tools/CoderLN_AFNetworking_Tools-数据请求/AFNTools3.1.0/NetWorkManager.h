//
//  NetWorkManager.h
//  简/众_不知名开发者 | https://github.com/CoderLN
//  各位厂友, 由于「时间 & 知识」有限, 难免有「未全、不足」, 该模块后续「坚持新增、替换、补充, 内容」.
//

/**
 作用：数据请求模块 - 子类化AFN
 */

#import "AFHTTPSessionManager.h"

// NS_ENUM 枚举
typedef NS_ENUM(NSUInteger, HttpRequestType) {
    HttpRequestTypeGET,
    HttpRequestTypePOST,
};


/**定义请求成功的block*/
typedef void (^requestSuccess)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);

/**定义请求失败的block*/
typedef void (^requestFailure)(NSError * _Nonnull error);

/**定义 上传/下载 进度block*/
typedef void (^progress)(float progress);

/**定义 下载完成回调 进度block*/
typedef void (^completionHandler)(NSURL *fullPath, NSError *error);

@interface NetWorkManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

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

@end
