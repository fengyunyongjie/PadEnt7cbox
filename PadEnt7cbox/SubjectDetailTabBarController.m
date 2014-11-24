//
//  SubjectDetailTabBarController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-4.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectDetailTabBarController.h"
#import "SubjectActivityViewController.h"
#import "SubjectResourceViewController.h"
#import "SubjectInfoViewController.h"
#import "PublishResourceViewController.h"

@interface SubjectDetailTabBarController ()
@property (nonatomic,weak) UIToolbar *tabBarView;
@end

@implementation SubjectDetailTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidLayoutSubviews
{
    self.tabBarView.frame=self.tabBar.frame;
}
- (void)viewWillAppear:(BOOL)animated
{
    if(!self.tabBarView)
    {
        UIToolbar *tabBarView=[UIToolbar new];
        tabBarView.frame=self.tabBar.frame;
        [self.view addSubview:tabBarView];
        self.tabBarView=tabBarView;
        UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithItems:@[@"动态",@"资源",@"信息"]];
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            segmentedControl.frame=CGRectMake(0, 0, 360, 36);
        }else
        {
            segmentedControl.frame=CGRectMake(0, 0, 200, 36);
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil];
        [segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
        segmentedControl.tintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]];
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *itemSegment=[[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        UIBarButtonItem *itemFlexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIButton *addButton=[[UIButton alloc] init];
        [addButton setTitle:@"发布资源" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]] forState:UIControlStateNormal];
        [addButton setFrame:CGRectMake(0, 0, 120, 36)];
        [addButton addTarget:self action:@selector(publishResource:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *itemAdd=[[UIBarButtonItem alloc] initWithCustomView:addButton];
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        }else
        {
            itemAdd=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(publishResource:)];
            [itemAdd setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]]];
        }
        //target:self action:@selector(publishResource:)];
        if (self.isPublish) {
            [self.tabBarView setItems:@[itemFlexible,itemSegment,itemFlexible,itemAdd]];
        }else
        {
            [self.tabBarView setItems:@[itemFlexible,itemSegment,itemFlexible]];
        }
        [segmentedControl setSelectedSegmentIndex:0];
    }
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SubjectActivityViewController *activityViewController=[SubjectActivityViewController new];
    UINavigationController *nav1=[[UINavigationController alloc] initWithRootViewController:activityViewController];
    [nav1.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav1.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav1.navigationBar setTintColor:[UIColor whiteColor]];
    activityViewController.title=self.subjectTitle;
    
    SubjectResourceViewController *resourceViewController=[SubjectResourceViewController new];
    UINavigationController *nav2=[[UINavigationController alloc] initWithRootViewController:resourceViewController];
    [nav2.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav2.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav2.navigationBar setTintColor:[UIColor whiteColor]];
    resourceViewController.title=self.subjectTitle;
    
    SubjectInfoViewController *infoViewController=[SubjectInfoViewController new];
    UINavigationController *nav3=[[UINavigationController alloc] initWithRootViewController:infoViewController];
    [nav3.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav3.navigationBar setTintColor:[UIColor whiteColor]];
    infoViewController.title=self.subjectTitle;
    
    self.viewControllers=@[nav1,nav2,nav3];
//    self.tabBar.hidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - 操作方法
- (void) segmentAction:(UISegmentedControl *)seg
{
    NSInteger index=seg.selectedSegmentIndex;
    self.selectedIndex=index;
}

-(IBAction)publishResource:(id)sender
{
    PublishResourceViewController *publishResourceViewController=[PublishResourceViewController new];
    publishResourceViewController.subjectID=self.subjectId;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        publishResourceViewController.modalPresentationStyle=UIModalPresentationPageSheet;
    }
    [self presentViewController:publishResourceViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate
@end
