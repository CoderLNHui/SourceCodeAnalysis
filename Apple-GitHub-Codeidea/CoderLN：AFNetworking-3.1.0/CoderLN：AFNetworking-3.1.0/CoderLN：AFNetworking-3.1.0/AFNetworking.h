// AFNetworking.h
//
// Author: https://github.com/CoderLN 
//
// Created by on Elegant programming.
// Copyright © Unauthorized shall not be reproduced reprinted.
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

//! Project version number for AFNetworking.
FOUNDATION_EXPORT double AFNetworkingVersionNumber;

//! Project version string for AFNetworking.
FOUNDATION_EXPORT const unsigned char AFNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AFNetworking/PublicHeader.h>

#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _AFNETWORKING_
#define _AFNETWORKING_

//#import <AFNetworking/AFURLRequestSerialization.h>
//#import <AFNetworking/AFURLResponseSerialization.h>
//#import <AFNetworking/AFSecurityPolicy.h>
//#import <AFNetworking/AFCompatibilityMacros.h>

#if !TARGET_OS_WATCH
//#import <AFNetworking/AFNetworkReachabilityManager.h>
#endif

//#import <AFNetworking/AFURLSessionManager.h>
//#import <AFNetworking/AFHTTPSessionManager.h>

#if TARGET_OS_IOS || TARGET_OS_TV
//#import <AFNetworking/AFAutoPurgingImageCache.h>
//#import <AFNetworking/AFImageDownloader.h>
//#import <AFNetworking/UIActivityIndicatorView+AFNetworking.h>
//#import <AFNetworking/UIButton+AFNetworking.h>
//#import <AFNetworking/UIImage+AFNetworking.h>
//#import <AFNetworking/UIImageView+AFNetworking.h>
//#import <AFNetworking/UIProgressView+AFNetworking.h>
#endif

#if TARGET_OS_IOS
//#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
//#import <AFNetworking/UIRefreshControl+AFNetworking.h>
//#import <AFNetworking/UIWebView+AFNetworking.h>
#endif


#endif /* _AFNETWORKING_ */


/**
 AFN 功能模块
 1.NSURLSession 网络通信模块管理者
    AFURLSessionManager
    AFHTTPSessionManager -> AFNURL 继承
 
 2.Serialization 网络通信信息序列化/反序列化模块
    <AFURLRequestSerialization> 请求序列化
       AFHTTPRequestSerializer
       AFJSONRequestSerializer
       AFPropertyListRequestSerializer
 
    <AFURLResponseSerialization> 响应者序列化
       AFHTTPResponseSerializer 返回原始类型，服务器返回什么类型就按什么类型解析(Data二进制、html网页)
       AFJSONResponseSerializer 返回JSON类型，默认解析方案
       AFXMLParserResponseSerializer 返回XML类型，XML解析方案
 
 Additional Functionality 额外的功能
    3.AFSecurityPolicy 网络通信安全策略模块
    4.AFNetworkReachabilityManager 网络状态监听管理者
    `HTTPS`（HTTP+SSL加密协议）
 
 5.UIKit+AFNetworking UIKit类库的扩展与工具类

 */
