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
#import "WelcomeViewController.h"
#import "PConfig.h"
#import "YNFunctions.h"

@implementation AppDelegate
@synthesize lockScreen,localV;
@synthesize downmange,myTabBarVC,loginVC,uploadmanage,isStopUpload,musicPlayer,file_url,isConnection,space_id,space_name,old_file_url;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isConnection = YES;
    
    //初始化数据
    downmange = [[DownManager alloc] init];
    uploadmanage = [[UploadManager alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadmanage.uploadArray count];
    
    //监听网络
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    [[DBSqlite3 alloc] updateVersion];
    
    //设置背景音乐
    musicPlayer = [[MusicPlayerViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.alpha = 1.0;
    [self.window setAutoresizesSubviews:YES];
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
    
    NSString *vinfo=[[NSUserDefaults standardUserDefaults]objectForKey:VERSION];
    if (!vinfo) {
        WelcomeViewController *welcomeView = [[WelcomeViewController alloc] init];
        [self.window.rootViewController presentViewController:welcomeView animated:NO completion:nil];
//        [[WelcomeViewController sharedUser] showWelCome];
        //        [[NSUserDefaults standardUserDefaults] setObject:VERSION forKey:VERSION];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(self.downmange.isStart || self.uploadmanage.isStart)
    {
        [musicPlayer startPlay];
    }
    else
    {
        [musicPlayer stopPlay];
    }
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
    self.lockScreen = [[InputViewController alloc] init];
    [self.lockScreen setPasswordDelegate:self];
    [self.lockScreen setBgView:self.window];
    self.lockScreen.view.autoresizesSubviews = YES;
    [self.window.rootViewController presentViewController:self.lockScreen animated:NO completion:^{}];
//    if(self.lockScreen)
//    {
//        [self.lockScreen.view removeFromSuperview];
//        self.lockScreen = nil;
//    }
//    self.lockScreen = [[InputViewController alloc] init];
//    [self.lockScreen setPasswordDelegate:self];
//    self.lockScreen.view.autoresizesSubviews = YES;
//    if(self.localV)
//    {
//        [self.localV removeFromSuperview];
//        self.localV = nil;
//    }
//    self.localV = [[UIView alloc] initWithFrame:self.window.frame];
//    [self.localV setBackgroundColor:[UIColor blackColor]];
//    [self.localV setAlpha:0.4];
//    [self.window addSubview:self.localV];
//    [self.window addSubview:self.lockScreen.view];
}

#pragma mark PasswordDelegate -----------

-(void)deleteView
{
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{}];
//    if(self.lockScreen)
//    {
//        [self.lockScreen.view removeFromSuperview];
//        self.lockScreen = nil;
//    }
//    if(self.localV)
//    {
//        [self.localV removeFromSuperview];
//        self.localV = nil;
//    }
}

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
}

//网络链接改变时会调用的方法
-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    NSLog(@"status:%i",status);
    switch (status) {
        case 0://无网络
        {
            
        }
            break;
        case 1://WLAN
        {
            isConnection = YES;
            if(![YNFunctions isOnlyWifi])
            {
                if([self.uploadmanage isAutoStart])
                {
                    [self.uploadmanage start];
                }
                if([self.downmange isAutoStart])
                {
                    [self.downmange start];
                }
            }
        }
            break;
        case 2://WiFi
        {
            isConnection = YES;
            if([self.uploadmanage isAutoStart])
            {
                [self.uploadmanage start];
            }
            if([self.downmange isAutoStart])
            {
                [self.downmange start];
            }
        }
            break;
        default:
            break;
    }
}

@end
