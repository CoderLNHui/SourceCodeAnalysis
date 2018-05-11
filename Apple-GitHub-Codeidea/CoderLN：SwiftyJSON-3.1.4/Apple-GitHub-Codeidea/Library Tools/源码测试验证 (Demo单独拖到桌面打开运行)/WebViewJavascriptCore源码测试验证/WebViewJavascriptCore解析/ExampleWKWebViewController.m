//
//  ExampleWKWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleWKWebViewController.h"
//#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
@interface ExampleWKWebViewController ()

@property WKWebViewJavascriptBridge* bridge;
@property WKWebView *webview;
@end

@implementation ExampleWKWebViewController

-(void)restart{
    [self viewDidAppear:true];
}


- (void)viewDidAppear:(BOOL)animated {
    if (_bridge) {
        _bridge = nil;
        //每次显示这个页面的时候都初始化。
        self.webview = nil;
    }
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor greenColor];
    webView.navigationDelegate = self;
    self.webview = webView;
    [self.view addSubview:webView];
    [WKWebViewJavascriptBridge enableLogging];
    //做一些初始化工作。并且换回一个bridge
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    //设置bridge对应的webview的delegate
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"OC提供方法给JS调用" handler:^(id data, WVJBResponseCallback responseCallback) {
        //NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"OC发给JS的返回值");
    }];
    
    
    [self renderButtons:webView];
    
    [self loadExamplePage:webView];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(WKWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"点击OC调用JS" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"重新开始" forState:UIControlStateNormal];
    [reloadButton addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
}

- (void)callHandler:(id)sender {
    id data = @{ @"OC调用JS方法": @"OC调用JS方法的参数" };
    [_bridge callHandler:@"OC调用JS提供的方法" data:data responseCallback:^(id response) {
       // NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(WKWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
