//
//  MySplitViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "MySplitViewController.h"
#import "MyTabBarViewController.h"
#import "DetailViewController.h"
#import "MainViewController.h"
#import "YNNavigationController.h"
#import "PhotoLookViewController.h"
#import "DownManager.h"
#import "MBProgressHUD.h"

@interface MySplitViewController ()<UISplitViewControllerDelegate>
@property (strong,nonatomic) MBProgressHUD *hud;
@end

@implementation MySplitViewController
@synthesize isFileChange;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloaderDidFinishDownloadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloaderDidNotFinishDownloadingNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MyTabBarViewController *myTabVC=[[MyTabBarViewController alloc] init];
    DetailViewController *detailVC=[[DetailViewController alloc] init];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:detailVC];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    self.viewControllers=@[myTabVC,nav];
    self.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:DownloaderDidFinishDownloadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFail:) name:DownloaderDidNotFinishDownloadingNotification object:nil];
}

-(void)showMessage:(NSString *)message
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=message;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1];
}

-(void)downloadFinish:(NSNotification *)note{
    NSString *fname=[note.userInfo objectForKey:@"fname"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:[NSString stringWithFormat:@"%@ 下载完成",fname]];
    });
}
-(void)downloadFail:(NSNotification *)note{
    NSString *fname=[note.userInfo objectForKey:@"fname"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:[NSString stringWithFormat:@"%@ 下载失败",fname]];
    });
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UISplitViewControllerDelegate
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
@end
