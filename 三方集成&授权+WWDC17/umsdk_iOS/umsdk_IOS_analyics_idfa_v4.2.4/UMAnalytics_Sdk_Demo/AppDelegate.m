/*
     File: AppDelegate.m 
 Abstract: The application delegate class used for installing our navigation controller. 
  Version: 1.0 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "AppDelegate.h"
//#import "UMMobClick/MobClick.h"

NSString *kWhichTabPrefKey		= @"kWhichTab";
NSString *kTabBarOrderPrefKey	= @"kTabBarOrder";

#define kDefaultTabSelection 0	// default tab value is 0 (tab #1)


@interface AppDelegate ()
- (void)updateMethod:(NSDictionary *)appInfo;

@end

@implementation AppDelegate

@synthesize window, myTabBarController;

- (void)umengTrack {
//    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = @"54448737fd98c53d2b0018af";
    UMConfigInstance.secret = @"secretstringaldfkals";
//    UMConfigInstance.eSType = E_UM_GAME;
    [MobClick startWithConfigure:UMConfigInstance];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];

//	[NSClassFromString(@"WebView") _enableRemoteInspector];
	
    // add the tab bar controller's current view as a subview of the window
//	[window addSubview:myTabBarController.view];
    [window setRootViewController:myTabBarController];
	[window makeKeyAndVisible];
	
	NSUInteger testValue = (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey];	// test for "kWhichTabPrefKey" key value
	if (testValue == 0)
	{
		// no default source value has been set, create it here
		//
		
		// since no default values have been set (i.e. no preferences file created), create it here
		NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithInt:kDefaultTabSelection], kWhichTabPrefKey,	
									  nil];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	}
	
	// customize the More page's navigation bar color
	self.myTabBarController.moreNavigationController.navigationBar.tintColor = [UIColor grayColor];
	
	// restore the tab-order from prefs
	NSArray* classNames = [[NSUserDefaults standardUserDefaults] arrayForKey:kTabBarOrderPrefKey];
	if (classNames.count > 0)
	{
		NSMutableArray* controllers = [[NSMutableArray alloc] init];
		for (NSString* className in classNames)
		{
			for (UIViewController* controller in self.myTabBarController.viewControllers)
			{
				NSString* controllerClassName = nil;
				
				if ([controller isKindOfClass:[UINavigationController class]])
				{
					controllerClassName = NSStringFromClass([[(UINavigationController*)controller topViewController] class]);
				}
				else
				{
					controllerClassName = NSStringFromClass([controller class]);
				}
				
				if ([className isEqualToString:controllerClassName])
				{
					[controllers addObject:controller];
					break;
				}
			}
		}
		
		if (controllers.count == self.myTabBarController.viewControllers.count)
		{
			self.myTabBarController.viewControllers = controllers;
		}
		
		[controllers release];
	}
	
	// re-store previously selected tab from prefs
	//
	// if the More navigation controller was last selected, you must change the value of the "selectedViewController" property instead.
	if ([[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey] == NSNotFound)
	{
		self.myTabBarController.selectedViewController = self.myTabBarController.moreNavigationController;
	}
	else
	{
		self.myTabBarController.selectedIndex = (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey];
	}
	
	// listen for changes in view controller from the More screen
	self.myTabBarController.moreNavigationController.delegate = self;

    return YES;
}

- (void)saveTabOrder
{
	// store the tab-order to preferences
	//
	NSMutableArray* classNames = [[NSMutableArray alloc] init];
	for (UIViewController* controller in self.myTabBarController.viewControllers)
	{
		if ([controller isKindOfClass:[UINavigationController class]])
		{
			UINavigationController *navController = (UINavigationController *)controller;
			
			[classNames addObject:NSStringFromClass([navController.topViewController/*•• figure out how to use: visibleViewController*/ class])];
			
			//•• we store the "visible" view controller and not the root one (i.e. topViewController)
			// because next time we want to restore the drill down position in case the user navigated down
			//
		}
		else
		{
			[classNames addObject:NSStringFromClass([controller class])];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:classNames forKey:kTabBarOrderPrefKey];
	
	[classNames release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // In iOS 4 and above, this will store off tab ordering.
    [self saveTabOrder];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// This will store off tab ordering in all iOS versions.
	[self saveTabOrder];
}

- (void)dealloc
{
	[window release];
    [myTabBarController release], myTabBarController = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	// store the selected tab for next time:
	//		normally we can do this at "applicationDidTerminate", but this is a convenient spot
	// note: if the user has the "More" tab selected, then the value stored is "NSNotFound"
	//
	[[NSUserDefaults standardUserDefaults] setInteger:[tabBarController selectedIndex] forKey:kWhichTabPrefKey];
}


#pragma mark -
#pragma mark UINavigationControllerDelegate (More screen)

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == [self.myTabBarController.moreNavigationController.viewControllers objectAtIndex:0])
	{
		NSLog(@"-> returned to More page");
	}
}

- (void)updateMethod:(NSDictionary *)appInfo {
    NSLog(@"update info %@",appInfo);
}



@end

