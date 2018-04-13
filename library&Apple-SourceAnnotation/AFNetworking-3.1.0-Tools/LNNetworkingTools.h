/*
 * File:  LNAFNetworkingTools.h
 * Framework:  AFNetworking
 * Author:  白开水ln（https://github.com/CoderLN）
 *
 * Created by 【WechatPublic-Codeidea】 on Elegant programming16.
 * Copyright © Reprinted（https://githubidea.github.io）Please indicate the source.Mustbe.
 *
 * JaneBook:  http://www.jianshu.com/u/fd745d76c816
 *
 * 🐾 |Codeidea 用文字记录自己的思想与经验 | 编程 | 职场 | 阅读 | 摄影 | 体验 | 👣
 */


//-------------- 【网络请求工具类，负责整个项目中所有的Http网络请求】 --------------//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface LNHttpTool : NSObject

/**
 *  发送一个GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(NSError *error))failure;




/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (NSURLSessionDataTask *)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failure:(void(^)(NSError *error))failure;



@end
