//
//  MCAppDelegate.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/15/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCAppModel.h"

@implementation MCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    // You have to initialize MCMainViewController or a custom sub-class :
    
    // 1.
    // 1.1. If you don't want a custom sub-class, use the built-in MainViewController.
    UIViewController* mainVC = [[MCViewManager sharedManager] createViewController:VIEW_MAIN];
    // 1.2. Then usual : assign it as rootVC to the window and set the frame
    [self.window setRootViewController:mainVC];
    [mainVC.view setFrame:[[UIScreen mainScreen] bounds]];
    // 1.3. Because you did not sub-class
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
