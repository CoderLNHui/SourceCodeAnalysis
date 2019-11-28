// AFNetworking.h
//
// 不知名开发者 https://dwz.cn/rC1LGk2f | 原始注解版本仓库_https://github.com/CoderLN/Apple-GitHub-Codeidea
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





#pragma mark - CoderLN_AFNetworking-3.1.0 更新目录分解
/**
 Released on Thursday, March 31, 2016. All issues associated with this milestone can be found using this filter.
 发布于2016年3月31日，星期四。可以使用此过滤器找到与此里程碑相关的所有问题
 
 Added
 
 Improved AFImageResponseSerializer test coverage
 改进了AFImageResponseSerializer测试覆盖率
    Implemented by quellish in #3367.
 Exposed AFQueryStringFromParameters and AFPercentEscapedStringFromString for public use.
 公开的AFQueryStringFromParameters和AFPercentEscapedStringFromString供公共使用
    Implemented by Kevin Harwood in #3160.
 
 
 Updated
 
 Updated Test Suite to run on Xcode 7.3
 更新了测试套件以在Xcode 7.3上运行
    Implemented by Kevin Harwood in #3418.
 Added white space to URLs in code comment to allow Xcode to properly parse them
 在代码注释中为URL添加了空格，以允许Xcode正确解析它们
    Implemented by Draveness in #3384.
 Updated documentation to match method names and correct compiler warnings
 更新了文档以匹配方法名称和正确的编译器警告
    Implemented by Hakon Hanesand in #3369.
 Use NSKeyValueChangeNewKey constant in change dictionary rather than hardcoded string.
 在更改字典中使用NSKeyValueChangeNewKey常量而不是硬编码字符串
    Implemented by Wenbin Zhang in #3360.
 Resolved compiler warnings for documentation errors
 解决了编译器对文档错误的警告
    Implemented by Ricardo Santos in #3336.
 
 
 Changed
 
 Reverted NSURLSessionAuthChallengeDisposition to NSURLSessionAuthChallengeCancelAuthenticationChallenge for SSL Pinning
 将NSURLSessionAuthChallengeDisposition还原为NSURLSessionAuthChallengeCancelAuthenticationChallenge进行SSL固定
    Implemented by Kevin Harwood in #3417.
 
 
 Fixed
 
 Removed trailing question mark in query string if parameters are empty
 如果参数为空，则删除查询字符串中的尾随问号
    Implemented by Kevin Harwood in #3386.
 Fixed crash if bad URL was passed into the image downloader
 修复了错误的URL传递到图像下载器时崩溃的问题
    Implemented by Christian Wen and Kevin Harwood in #3385.
 Fixed image memory calculation
 固定图像内存计算
    Implemented by 周明宇 in #3344.
 Fixed issue where UIButton image downloading called wrong cancel method
 修复了UIButton图像下载调用错误取消方法的问题
    Implemented by duanhong in #3332.
 Fixed image downloading cancellation race condition
 固定图像下载取消竞争条件
    Implemented by Kevin Harwood in #3325.
 Fixed static analyzer warnings on AFNetworkReachabilityManager
 修复了AFNetworkReachabilityManager上的静态分析器警告
    Implemented by Jeff Kelley in #3315.
 Fixed issue where download progress would not be reported in iOS 7
 修复了iOS 7中无法报告下载进度的问题
    Implemented by zwm in #3294.
 Fixed status code 204/205 handling
 修复状态代码204/205处理
    Implemented by Kevin Harwood in #3292.
 Fixed crash when passing nil/null for progress in UIWebView extension
 修复了在UIWebView扩展中为进度传递nil / null时的崩溃问题
    Implemented by Kevin Harwood in #3289.
 
 
 Removed
 
 Removed workaround for NSJSONSerialization bug that was fixed in iOS 7
 移除iOS 7中修复的NSJSONSerialization错误的解决方案
    Implemented by Cédric Luthi in #3253.
 */




















