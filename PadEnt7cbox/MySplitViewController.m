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

@interface MySplitViewController ()

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
    if(!isFileChange)
    {
        MyTabBarViewController *myTabVC=[[MyTabBarViewController alloc] init];
        DetailViewController *detailVC=[[DetailViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:detailVC];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        self.viewControllers=@[myTabVC,nav];
        self.delegate=detailVC;
    }
    else
    {
        MainViewController *viewController=[[MainViewController alloc] init];
        viewController.delegate=self;
        viewController.type=kTypeUpload;
        //[self.navigationController pushViewController:viewController animated:YES];
        YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:viewController];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        
        DetailViewController *detailVC=[[DetailViewController alloc] init];
        UINavigationController *nav2=[[UINavigationController alloc] initWithRootViewController:detailVC];
        [nav2.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        self.viewControllers=@[nav,nav2];
        self.delegate=detailVC;
    }
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

@end
