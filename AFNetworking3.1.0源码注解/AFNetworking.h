// AFNetworking.h
//
// Copyright (c) 2013 AFNetworking (http://afnetworking.com/)
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
// The version 3.1.0 of AFNetworking, The translator Liu Nan.
// THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _AFNETWORKING_
    #define _AFNETWORKING_

    #import "AFURLRequestSerialization.h"
    #import "AFURLResponseSerialization.h"
    #import "AFSecurityPolicy.h"

#if !TARGET_OS_WATCH
    #import "AFNetworkReachabilityManager.h"
#endif

    #import "AFURLSessionManager.h"
    #import "AFHTTPSessionManager.h"

#endif /* _AFNETWORKING_ */

/**
 AFN 功能模块
 1.NSURLSession 管理者
    AFURLSessionManager
    AFHTTPSessionManager 继承上面
 2.Serialization 序列化
    <AFURLRequestSerialization> 请求序列化
       AFHTTPRequestSerializer
       AFJSONRequestSerializer
       AFPropertyListRequestSerializer
    <AFURLResponseSerialization> 响应者序列化
       AFHTTPResponseSerializer 返回原始类型，默认解析方案
       AFJSONResponseSerializer 返回JSON类型，JSON解析方案
       AFXMLParserResponseSerializer 返回XML类型，XML解析方案
 3.Additional Functionality 额外的功能
    3.AFSecurityPolicy 安全策略相关
    4.AFNetworkReachabilityManager 网络状态监听管理者
 5.UIKit+AFNetworking UIKit类库的扩展与工具类
 
 - NSURLSession（网络通信模块）
 - ReachAbility（网络状态监听模块）
 - Security（网络通信安全策略模块）
 - Serialization（网络通信信息序列化/反序列化模块）
 - UIKit（UIKit库的扩展）
 */
