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

@interface MySplitViewController ()<UISplitViewControllerDelegate>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MyTabBarViewController *myTabVC=[[MyTabBarViewController alloc] init];
    DetailViewController *detailVC=[[DetailViewController alloc] init];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:detailVC];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    self.viewControllers=@[myTabVC,nav];
    self.delegate=self;
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
