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
#import "PasswordManager.h"
#import "SCBSession.h"

@implementation AppDelegate
@synthesize lockScreen,localV;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"打印Log");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.alpha = 1.0;
    [self.window makeKeyAndVisible];
    
    if ([self isLogin]) {
        [self finishLogin];
    }else
    {
        [self finishLogout];
    }
    
    if([self isOpenLock])
    {
        [self showLoceView];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if([self isOpenLock])
    {
        [self showLoceView];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if([self isOpenLock])
    {
        [self showLoceView];
    }
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
-(BOOL)isOpenLock
{
    PasswordManager *manager = [[PasswordManager alloc] init];
    PasswordList *list = [[PasswordList alloc] init];
    list.is_open = YES;
    list.p_ure_id = [[SCBSession sharedSession] userId];
    NSArray *array = [manager selectPasswordListIsHave:list];
    if([array count]>0)
    {
        return YES;
    }
    return NO;
}
-(void)showLoceView
{
    if(self.lockScreen)
    {
        [self.lockScreen.view removeFromSuperview];
        self.lockScreen = nil;
    }
    self.lockScreen = [[InputViewController alloc] init];
    [self.lockScreen setPasswordDelegate:self];
    self.lockScreen.view.autoresizesSubviews = YES;
    if(self.localV)
    {
        [self.localV removeFromSuperview];
        self.localV = nil;
    }
    self.localV = [[UIView alloc] initWithFrame:self.window.frame];
    [self.localV setBackgroundColor:[UIColor blackColor]];
    [self.localV setAlpha:0.4];
    [self.window addSubview:self.localV];
    [self.window addSubview:self.lockScreen.view];
}

#pragma mark PasswordDelegate -----------

-(void)deleteView
{
    if(self.lockScreen)
    {
        [self.lockScreen.view removeFromSuperview];
        self.lockScreen = nil;
    }
    if(self.localV)
    {
        [self.localV removeFromSuperview];
        self.localV = nil;
    }
}

@end
