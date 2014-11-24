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
#import "SCBAccountManager.h"
#import "BackgroundRunner.h"
#import <MessageUI/MessageUI.h>
#import "SCBoxConfig.h"
#import "MF_Base64Additions.h"
#import "BackgroundRunner.h"
#import "MyTabBarViewController.h"

typedef enum{
    kAlertTypeNewVersion,
    kAlertTypeNoNewVersion,
    kAlertTypeHideFeature,
    kAlertTypeMustUpdate,
}kAlertType;
@implementation AppDelegate
@synthesize lockScreen,localV;
@synthesize downmange,myTabBarVC,loginVC,uploadmanage,isStopUpload,file_url,isConnection,space_id,space_name,old_file_url,action_array,isFileShare,messageArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NetworkStatus status = [self isConnections];
    if(status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        isConnection = YES;
    }
    else
    {
        isConnection = NO;
    }
    
    //初始化数据
    action_array = [[NSMutableArray alloc] init];
    self.alertViewArray=[[NSMutableArray alloc] init];
    downmange = [[DownManager alloc] init];
    uploadmanage = [[UploadManager alloc] init];
    self.messageArray = [[NSMutableArray alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadmanage.uploadArray count];
    
    //监听网络
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    [[DBSqlite3 alloc] updateVersion];
    
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
    }
    [self checkUpdate];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self checkUpdate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(self.downmange.isStart || self.uploadmanage.isStart)
    {
        [[BackgroundRunner shared] run];
    }
    else
    {
        [[BackgroundRunner shared] stop];
    }
    [(UIAlertView *)self.alertViewArray.lastObject dismissWithClickedButtonIndex:-1 animated:YES];
    
    [(UIActionSheet *)self.action_array.lastObject dismissWithClickedButtonIndex:-1 animated:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkUpdate];
    [[BackgroundRunner shared] stop];
    UIViewController *viewController = self.window.rootViewController.presentedViewController;
    if([viewController isKindOfClass:[InputViewController class]])
    {
        [self deleteView];
    }
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
-(void)checkUpdate
{
    SCBAccountManager *am=[[SCBAccountManager alloc] init];
    am.delegate=self;
    [am checkNewVersion:BUILD_VERSION];
}

-(void)networkError
{
    
}
-(BOOL)isLogin
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    //如果网络正常，请求登录，网络异常，则本地判断
    NetworkStatus status = [self isConnections];
    if(status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        isConnection = YES;
        NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_LOGIN_URI]];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        NSMutableString *body=[[NSMutableString alloc] init];
        NSString *mi_ma =[userPwd base64String];
        [body appendFormat:@"usr_account=%@&usr_pwd=%@",userName,mi_ma];
        NSMutableData *myRequestData=[NSMutableData data];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        //[request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
        [request setHTTPBody:myRequestData];
        [request setHTTPMethod:@"POST"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
        NSError *error = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                                   returningResponse:nil error:&error];
        if(!returnData)
        {
            if (userName==nil&&userPwd==nil) {
                return NO;
            }
            return YES;
        }
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
        if ([dictionary objectForKey:@"code"] && [[dictionary objectForKey:@"code"] intValue]==0)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    else
    {
        if (userName==nil&&userPwd==nil) {
            return NO;
        }
        return YES;
    }
}
-(void)finishLogin
{
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        self.splitVC=[[MySplitViewController alloc] initWithNibName:@"MySplitViewController" bundle:nil];
        self.window.rootViewController=self.splitVC;
    }else{
        self.myTabBarVC=[[MyTabBarViewController alloc] init];
        self.window.rootViewController=self.myTabBarVC;
    }
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
    self.lockScreen.isShowBackground = YES;
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
    [(UIAlertView *)self.alertViewArray.lastObject show];
    [self.alertViewArray removeLastObject];
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
            isConnection = NO;
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
#pragma mark - SCBAccountManagerDelegate
-(void)checkVersionSucceed:(NSDictionary *)datadic
{
    int code=-1;
    code=[[datadic objectForKey:@"code"] intValue];
    if (code==0) {
        int isupdate=-1;//是否强制更新，0不强制，1强制   10月31日，修改为： 强制更新的版本号
        isupdate=[[datadic objectForKey:@"isupdate"] intValue];
        if ([BUILD_VERSION intValue]>=isupdate) {
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
            //                                                                message:@"有新版本，点确定更新"
            //                                                               delegate:self
            //                                                      cancelButtonTitle:@"取消"
            //                                                      otherButtonTitles:@"确定", nil];
            //            alertView.tag=kAlertTypeNewVersion;
            //            [alertView show];
        }else if([BUILD_VERSION intValue]<isupdate)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"当前版本需要更新才可以使用，点确定更新"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag=kAlertTypeMustUpdate;
            [alertView show];
            
        }
        NSLog(@"有新版本");
    }else if(code==1)
    {
        NSLog(@"失败，服务端异常");
        
    }else if(code==2)
    {
        //        NSLog(@"无新版本");
        //        [self.hud show:NO];
        //        if (self.hud) {
        //            [self.hud removeFromSuperview];
        //        }
        //        self.hud=nil;
        //        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        //        [self.view.superview addSubview:self.hud];
        //        [self.hud show:NO];
        //        self.hud.labelText=@"当前是最新版本";
        //        self.hud.mode=MBProgressHUDModeText;
        //        self.hud.margin=10.f;
        //        [self.hud show:YES];
        //        [self.hud hide:YES afterDelay:1.0f];
        
    }else
    {
        NSLog(@"失败，服务端发生未知错误");
    }
}
-(void)checkVersionFail
{
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTypeNewVersion:
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
            }
            break;
        case kAlertTypeMustUpdate:
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
                //[self sureExit];
            }else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
                //[self sureExit];
            }
            break;
        default:
            break;
    }
    
}

//判断当前的网络是3g还是wifi
-(NetworkStatus) isConnections
{
    Reachability *hostReachs = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReachs currentReachabilityStatus];
}

//是否要暂停音乐播放
-(void)getStopUpload
{
    if(!self.downmange.isStart && !self.uploadmanage.isStart)
    {
        [[BackgroundRunner shared] stop];
    }
}

@end
