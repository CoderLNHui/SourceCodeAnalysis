//
//  WebViewJavascriptBridgeBase.h
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOldProtocolScheme @"wvjbscheme"
#define kNewProtocolScheme @"https"
#define kQueueHasMessage   @"__wvjb_queue_message__"
#define kBridgeLoaded      @"__bridge_loaded__"

typedef void (^WVJBResponseCallback)(id responseData);
//WEB与iOS交互
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);
//消息
typedef NSDictionary WVJBMessage;
//WebViewJavascriptBridgeBase代理方法，用于执行WebViewJavascriptBridge_JS.js。
@protocol WebViewJavascriptBridgeBaseDelegate <NSObject>
- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand;
@end

@interface WebViewJavascriptBridgeBase : NSObject


@property (weak, nonatomic) id <WebViewJavascriptBridgeBaseDelegate> delegate;
//初始化的时候，要发送的消息列表
@property (strong, nonatomic) NSMutableArray* startupMessageQueue;
//消息回调列表。key是回调ID，value是对应的回调实现
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
//OC注册的方法列表，key是方法名字，value是对于参数和回调
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (strong, nonatomic) WVJBHandler messageHandler;

+ (void)enableLogging;
+ (void)setLogMaxLength:(int)length;
//重置环境
- (void)reset;
//发送OC消息到WEB
- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;

- (void)flushMessageQueue:(NSString *)messageQueueString;
//把JS注入WebView中。
- (void)injectJavascriptFile;
- (BOOL)isWebViewJavascriptBridgeURL:(NSURL*)url;

- (BOOL)isQueueMessageURL:(NSURL*)urll;
- (BOOL)isBridgeLoadedURL:(NSURL*)urll;
- (void)logUnkownMessage:(NSURL*)url;
- (NSString *)webViewJavascriptCheckCommand;
- (NSString *)webViewJavascriptFetchQueyCommand;
- (void)disableJavscriptAlertBoxSafetyTimeout;

@end
