//
//  NetWorkManager.m
// 「Public|Jshu_不知名开发者 | https://github.com/CoderLN」
//  各位厂友, 由于「时间 & 知识」有限, 总结的文章难免有「未全、不足」, 该模块将系统化学习, 后续「坚持新增文章, 替换、补充文章内容」.
//

#import "NetWorkManager.h"

@implementation NetWorkManager

+ (instancetype)sharedManager
{
    static NetWorkManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        instance = [[self alloc] initWithBaseURL:nil sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return instance;
}


- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
#warning 可根据情况进行配置
        
        // 设置响应序列化
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置请求序列化
        AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
        // 设置缓存策略
        requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        // 方式二：设置请求超时；AFN默认60.0s
        [requestSerializer willChangeValueForKey:@"timeoutInterval"];
        requestSerializer.timeoutInterval = 15.0;
        [requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        // 2.获取AFN原由数据解析类型基础上添加一些响应解析器能够接受的数据类型
        NSMutableSet * acceptableContentTypes = [NSMutableSet setWithSet:self.responseSerializer.acceptableContentTypes];
        [acceptableContentTypes addObjectsFromArray:@[@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain"]];
        self.responseSerializer.acceptableContentTypes = acceptableContentTypes;
        
        // 方式一：设置请求超时；AFN默认60.0s
        //configuration.timeoutIntervalForRequest = 10.0;
        
        // 设配型号
        [self.requestSerializer setValue:[UIDevice currentDevice].model forHTTPHeaderField:@"iPhone"];
        // 系统版本
        [self.requestSerializer setValue:[UIDevice currentDevice].systemVersion forHTTPHeaderField:@"OS"];
    }
    return self;
}

 





#pragma mark - 网络请求 GET / POST

+ (void)requestWithType:(HttpRequestType)requestType url:(NSString *)urlString parameters:(id)parameters success:(requestSuccess)successBlock failure:(requestFailure)failureBlock
{
    switch (requestType) {
            
        case HttpRequestTypeGET:
        {
            [[NetWorkManager manager] GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                successBlock(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
            }];
            
        }
            break;
            
        case HttpRequestTypePOST:
        {
            [[NetWorkManager manager] POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                successBlock(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
            }];
            
        }
            break;
            
        default:
            break;
    }
}



@end
