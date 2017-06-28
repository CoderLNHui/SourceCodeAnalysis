Tabster
=======

DESCRIPTION:

An eclectic-style application designed to show how to build a tab-bar based iPhone application.

An iPhone sample app that takes the "Tab Bar Application" Xcode template a few steps further by going over useful topics in implementing a UITabBarController in your application.

It goes over the following topics:

Demonstrates the architectural design of a tab bar-based app containing multiple types of UIViewControllers.
a) three separate tabs (1,2,3) each containing their own navigation controller
b) one of the three tabs (TwoViewController) containing table view that navigate to a full screen view controller (presented with fade in and out), shows the technique of delaying the load of view controllers by calling directly: initWithNibName
c) a view controller (ThreeViewController) with badge input value.
d) a view controller (FourViewController) loaded from a separate nib - demonstrating how to use multiple nibs, and setting its tab bar item programmatically.
e) Once you add Favorites view controller you get the "more" UI and view controllers loaded from the more UI appear in a navigation controller.


UITabBarItem customization
==========================
This sample shows how to customize the appearance of its tab items by setting a custom image and title.  The iOS SDK provides a big set of default icons (Favorites, Features, Top Rated, etc.) that give you built in localized titles.  There will be a time when you want your own.  This sample shows how to set these up in Interface Builder or through code.

Loading view controllers from a separate nib
============================================
This sample has all its view controllers loaded from the same nib, with exception to "FourViewController".  In general it is good practice to keep view controllers in separate nibs to reduce nib load time at startup and to organize your nibs more efficiently.  Since FourViewController class is loaded externally (has its own nib), its "viewDidLoad" will not be called at startup.  Rather, it will be called when the user first taps its tab item.  To illustrate this point, FourViewController uses awakeFromNib to set its UITabBarItem.

User Defaults
=============
What to do when home button is pressed, incoming call SMS, etc. since you app can be interrupted.
	
    ->>>> use this to save prefs in iOS 4 and later:
        - (void)applicationDidEnterBackground:(UIApplication *)application
            In iOS 4 and later this is called when the application is no longer visible.  The application
            is still in memory and this method has five seconds to perform any cleanup before the application
            stops receiving CPU time.
            It is recomended that background enabled applications save their state here.

	->>>> use this to save prefs in iOS 3 and below:
		- (void)applicationWillTerminate:(UIApplication *)application;
            In iOS 3.x and earlier, this is called when the user returns to the home screen or switches
            to another application (taking a phone call).  This is the place to save any data/preferences in
            iOS 3 and below.  In iOS 4.x and later, this is called when the system must completely terminate 
            your application.  In both cases, your app will be started "cold" on its next launch.
            
    - (void)applicationWillResignActive:(UIApplication *)application;
		Called when the application is no longer the 1st responder.  This can occur when
        the user brings up the app switcher or when the user is deciding whether to take
        an incoming phone call.
    
	- (void)applicationDidBecomeActive:(UIApplication *)application;
		Called when your app resumes, for example, after a call was not taken or when
        the user switches back to your app.  We don't need to restore the state here
        since we were still in memory.
            

This sample uses NSUserDefaults to store the following:
1. The last tab visited before quitting the app.

2. Last Selected Tab
The easiest solution is to store the tab bar's "selectedIndex" property as a user default and restore it at launch.

3. The tab ordering
But the user may reorder the tabs and the selectedIndex value won't match the tab anymore.  So this sample stores the class name as a string and at launch walks through the view controller list and selects the proper view controller.  In this sample the tabs in the tab bar are ordered and not the once in the More screen.

4. ThreeViewController has a "badge value" that persists across launches.
This value is stored when the view is hidden and retrieved when the view is shown.

Autorotation
============
Implement "shouldAutoRotateToInterfaceOrientation" for all your view controllers.  All view controllers (in each tab) must agree on the same orientation for that orientation to occur.  The default UITabBarController only does autorotation if all of its child view controllers support autorotation to the relevant orientation.

More Page
=========
This sample shows how to customize the look of the "More" page by changing is navigation bar color.
In addition, FourViewController, FavoritesViewController and FeaturedViewController were designed NOT to have a navigation bar.  But the UITabBarController places a navigation bar on them so they can navigate in and out of the "More" page.  You get this automatically.  So by design, you need to take this into consideration that a navigation bar may or may not appear for Favorites and Featured.  Both these view controllers take this into account in viewWillAppear by hiding their UILabel titles accordingly.

Hiding the Tab Bar
==================
You will notice the "OneViewController" pushes the tab bar away when you navigate through its table.  This is because "SubLevelViewController" sets its "hidesBottomBarWhenPushed" property to YES.  If your drill down user interface in a table requires more screen space, keep this property mind.

Low memory Situations
=====================
When simulating a low memory condition using the Simulator, it is common for various view controller's "viewDidUnload" to be called as a result.  Since "FourViewController" is loaded from a separate nib, simulating a memory warning will call its viewDidUnload method more frequently than the others.


=======================================================================================================
BUILD REQUIREMENTS

iOS SDK 4.3 or later


=======================================================================================================
RUNTIME REQUIREMENTS

iOS OS 3.2 or later


=======================================================================================================
CHANGES FROM PREVIOUS VERSIONS

Version 1.0
- New Release

=======================================================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.