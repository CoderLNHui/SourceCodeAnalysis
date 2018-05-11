//
//  AppDelegate.m
//  WebViewJavascriptCore解析
//
//  Created by huangchengdu on 17/3/30.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

/************************************************************************
    摘录说明：向优秀的开源者致敬 ！向优秀的分享者致敬 ！

    GitHubUser：huang303513
    DemoAddress：https://github.com/huang303513/SourceCodeResearchAndExploration
    Blog:

    NOTE：如Demo中有疑问 或 好的idea替换、补充，建议前去原著仓库下 issue，请自愿留下 你的 STAR
 
 / ************************************************************************/

#import "AppDelegate.h"
//#import "ExampleUIWebViewController.h"
#import "ExampleWKWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 1. Create the UIWebView example
//    ExampleUIWebViewController* UIWebViewExampleController = [[ExampleUIWebViewController alloc] init];
   // UIWebViewExampleController.tabBarItem.title             = @"UIWebView";
    
    // 2. Create the tab footer and add the UIWebView example
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    // 3. Create the  WKWebView example for devices >= iOS 8
    if([WKWebView class]) {
        ExampleWKWebViewController* WKWebViewExampleController = [[ExampleWKWebViewController alloc] init];
        WKWebViewExampleController.tabBarItem.title             = @"WKWebView";
        [tabBarController addChildViewController:WKWebViewExampleController];
    }
    //[tabBarController addChildViewController:UIWebViewExampleController];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

@end
