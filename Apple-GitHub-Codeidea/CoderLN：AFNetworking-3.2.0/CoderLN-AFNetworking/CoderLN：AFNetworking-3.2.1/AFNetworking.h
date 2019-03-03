// AFNetworking.h
//
// Public_不知名开发者 https://dwz.cn/rC1LGk2f | 原始注解版本仓库_https://github.com/CoderLN/Apple-GitHub-Codeidea
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
 AFNetworking 功能模块
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
    5.`HTTPS`（HTTP+SSL加密协议）
 
 6.UIKit+AFNetworking UIKit类库的扩展与工具类(可以汲取抽取封装思想)
 */




#pragma mark - CoderLN_AFNetworking-3.2.0 更新目录
/**
 Released on Friday, December 15, 2017. All issues associated with this milestone can be found using this filter.
 2017年12月15日星期五发布。使用此过滤器可以找到与此里程碑相关的所有问题
 
 Added
 
 Config AFImageDownloader NSURLCache and ask AFImageRequestCache implementer if an image should be cached
 如果应该缓存图像，请配置AFImageDownloader NSURLCache并询问AFImageRequestCache实现者
    Implemented by wjehenddher in #4010.
 Add XMLParser/XMLDocument serializer tests
 添加XMLParser / XMLDocument序列化程序测试
    Implemented by skyline75489 in #3753.
 Enable custom httpbin URL with HTTPBIN_BASE_URL environment variable
 使用HTTPBIN_BASE_URL环境变量启用自定义httpbin URL
    Implemented by 0xced in #3748.
 AFHTTPSessionManager now throws exception if SSL pinning mode is set for non https sessions
 如果为非https会话设置SSL锁模式，则AFHTTPSessionManager将抛出异常
    Implemented by 0xced in #3687.
 
 
 Updated
 
 Update security policy test certificates
 更新安全策略测试证书
    Implemented by SlaunchaMan in #4103.
 Allow return value of HTTP redirection block to be NULL
 允许HTTP重定向块的返回值为NULL
    Implemented by TheDom in #3975.
 Clarify documentation for supported encodings in AFJSONResponseSerializer
 澄清AFJSONResponseSerializer中支持的编码的文档
    Implemented by skyline75489 in #3750.
 Handle Error Pointers according to Cocoa Convention
 根据Cocoa约定处理错误指针
    Implemented by tclementdev in #3653.
 Updates AFHTTPSessionManager documentation to reflect v3.x change
 更新AFHTTPSessionManager文档以反映v3.x更改
    Implemented by ecaselles in #3476.
 Improved code base to generate fewer warnings when using stricter compiler settings
 使用更严格的编译器设置时，改进了代码库以生成更少的警告
    Implemented by 0xced in 3431.
 
 
 Changed
 
 Change “Mac OS X” and “OS X” references to “macOS”
 将 “Mac OS X” 和 “OS X” 更改为 “macOS”
    Implemented by SlaunchaMan in #4104.
 
 
 Fixed
 
 Fixed crash around customizing NSURLCache size for < iOS 8.2
 修正了iOS 8.2自定义NSURLCache大小时崩溃的问题
    Implemented by kcharwood in #3735.
 Fixed issue where UIWebView extension did not preserve all of the request information
 修复了UIWebView扩展未保留所有请求信息的问题
    Implemented by skyline75489 in #3733.
 Fixed bug with webview delegate callback
 修正webview委托回调的bug
    Implemented by kcharwood in #3727.
 Fixed crash when passing invalid JSON to request serialization
 修正了当传递无效JSON请求序列化时崩溃的问题
    Implemented by 0xced in #3719.
 Fixed potential KVO crasher for URL Session Task delegates
 修复了URL会话任务委托的潜在KVO崩溃问题
    Implemented by 0xced in #3718.
 Removed ambiguous array creation in AFSecurityPolicy
 删除了在AFSecurityPolicy中创建不明确的数组
    Implemented by sgl0v in #3679.
 Fixed issue where NS_UNAVAILABLE is not reported for AFNetworkReachabilityManager
 修复了AFNetworkReachabilityManager未报告NS_UNAVAILABLE的问题
    Implemented by Microbee23 in #3649.
 Require app extension api only on watchOS
 仅在watchOS上需要app扩展api
    Implemented by ethansinjin in #3612.
 Remove KVO of progress in favor of using the NSURLSession delegate APIs
 删除KVO进程，支持使用NSURLSession委托api
    Implemented by coreyfloyd in #3607.
 Fixed an issue where registering a UIProgessView to a task that was causing a crash
 修正了将UIProgessView注册到导致崩溃的任务的问题
    Implemented by Starscream27 in #3604.
 Moved [self didChangeValueForKey:@"currentState"] into correct scope
 将[self didChangeValueForKey：@“currentState”]移动到正确的范围内
    Implemented by chenxin0123 in #3565.
 Fixed issue where response serializers did not inherit super class copying
 修复了响应序列化程序未继承超类复制的问题
    Implemented by kcharwood in #3559.
 Fixed crashes due to race conditions with NSMutableDictionary access in AFHTTPRequestSerializer
 修复因AFHTTPRequestSerializer中的NSMutableDictionary访问而导致的竞争条件导致的崩溃
    Implemented by alexbird in #3526.
 Updated dash character to improve markdown parsing for license
 更新破折号字符，以改进对许可的标记解析
    Implemented by gemmakbarlow in #3488.
 
 
 Removed
 
 Deprecate the unused stringEncoding property of AFHTTPResponseSerializer
 弃用AFHTTPResponseSerializer的未使用的stringEncoding属性
    Implemented by 0xced in #3751.
 Removed unused AFTaskStateChangedContext
 删除了未使用的AFTaskStateChangedContext
    Implemented by yulingtianxia in #3432.
 */






#pragma mark - CoderLN_AFNetworking-3.2.1 更新目录
/**
 Released on Friday, May 04, 2018. All issues associated with this milestone can be found using this filter.
 发布于2018年5月4日，星期五。使用此过滤器可以找到与此里程碑相关的所有问题
 
 Updated
 
 Xcode 9.3 Support
 Xcode 9.3支持
    Implemented by Jeff Kelley in #4199.
 Update HTTPBin certificates for April 2018.
 2018年4月更新HTTPBin证书
    Implemented by  Jeff Kelley in #4198.
 
 
 Additional Changes
 
 Remove conflicting nullable specifier on init
 删除init上冲突的空指定符
    Implemented by  Nick Brook and Jeff Kelley in #4182.
 Use @available if available to silence a warning.
 使用@available（如果可用）使警告静音
    Implemented by  Jeff Kelley in #4138.
 UIImageView+AFNetworking: Prevent stuck state for malformed urlRequest
 UIImageView + AFNetworking：防止格式错误的urlRequest卡住状态
    Implemented by  Adam Duflo and aduflo in #4131.
 add the link for LICENSE
 添加许可的链接
    Implemented by  Liao Malin in #4125.
 Fix analyzer warning for upload task creation
 修复分析器警告以创建上载任务
    Implemented by  Jeff Kelley in #4122.
 */















