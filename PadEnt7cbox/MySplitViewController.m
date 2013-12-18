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

@interface MySplitViewController ()

@end

@implementation MySplitViewController

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
    self.viewControllers=@[myTabVC,nav];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
