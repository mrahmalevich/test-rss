//
//  TRAppDelegate.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "TRAppDelegate.h"
#import "TRFeedsTableViewController.h"

@implementation TRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStack];
    
    TRFeedsTableViewController *controller = [TRFeedsTableViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
 
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
 
    return YES;
}

@end
