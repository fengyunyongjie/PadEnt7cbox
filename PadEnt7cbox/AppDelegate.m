//
//  AppDelegate.m
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-16.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MySplitViewController.h"

@implementation AppDelegate
@synthesize password_controller;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"打印Log");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([self isLogin]) {
        [self finishLogin];
    }else
    {
        [self finishLogout];
    }
    self.password_controller = [[PasswordController alloc] init];
    [self.window addSubview:self.password_controller.view];
//    self.password_controller.view.hidden = YES;
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
-(BOOL)isLogin
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    if (userName==nil&&userPwd==nil) {
        return NO;
    }
    return YES;
}
-(void)finishLogin
{
    self.splitVC=[[MySplitViewController alloc] initWithNibName:@"MySplitViewController" bundle:nil];
    self.window.rootViewController=self.splitVC;
}
-(void)finishLogout
{
    self.loginVC=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window.rootViewController=self.loginVC;
}
@end
