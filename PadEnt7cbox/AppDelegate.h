//
//  AppDelegate.h
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-16.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//
#import "DownManager.h"
#import "UploadManager.h"
#import "MusicPlayerViewController.h"
#import "Reachability.h"
#import "InputViewController.h"
#import <UIKit/UIKit.h>

#define TabBarHeight 60
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]

@class LoginViewController,MySplitViewController,MyTabBarViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,PasswordDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginVC;
@property (strong, nonatomic) MySplitViewController *splitVC;
@property (strong, nonatomic) MyTabBarViewController *myTabBarVC;
@property (strong, nonatomic) DownManager *downmange;
@property (strong, nonatomic) UploadManager *uploadmanage;
@property (assign, nonatomic) BOOL isStopUpload;
@property (nonatomic, strong) MusicPlayerViewController *musicPlayer;
@property (strong, nonatomic) NSString *file_url;
@property (assign, nonatomic) BOOL isConnection;
@property (strong, nonatomic) NSString *space_id;
@property (strong, nonatomic) NSString *space_name;
@property (strong, nonatomic) NSString *old_file_url;

@property(nonatomic,strong) InputViewController *lockScreen;
@property(nonatomic,strong) UIView *localV;
-(void)finishLogin;
-(void)finishLogout;
@end
