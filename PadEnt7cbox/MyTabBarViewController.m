//
//  MyTabBarViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "UpDownloadViewController.h"
#import "EmailListViewController.h"
#import "SubjectListViewController.h"
#import "SCBEmailManager.h"
#import "SCBSubjectManager.h"
#import "AdressBookListViewController.h"

@interface MyTabBarViewController ()

@end

@implementation MyTabBarViewController
@synthesize imageView,label;

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self checkNotReadEmail];
    [self checkSubjectActivityCount];
}
- (void)checkSubjectActivityCount
{
    SCBSubjectManager *sm=[SCBSubjectManager new];
    sm.delegate=self;
    [sm getSubjectSum];
}
- (void)checkNotReadEmail
{
    SCBEmailManager *em=[[SCBEmailManager alloc] init];
    em.delegate=self;
    [em notReadCount];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor *itemSeColor=[UIColor colorWithRed:0/255.0f green:47/255.0f blue:167/255.0f alpha:1];
    UIColor *itemNorColor=[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1];
    
    
    UINavigationController *vc1=[[UINavigationController alloc] init];
    [vc1.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc1.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
    [vc1.navigationBar setTintColor:[UIColor whiteColor]];
    MainViewController * vc11=[[MainViewController alloc] init];
    [vc1 pushViewController:vc11 animated:YES];
    vc11.title=@"文件管理";
    vc1.title=@"文件管理";
    //vc1.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    [vc1.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_file_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_file_nor.png"]];
//    [vc1.tabBarItem setSelectedImage:[UIImage imageNamed:@"nav_selected.png"]];
    [vc1.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc1.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    //[vc1.tabBarItem setImage:[UIImage imageNamed: @"nav_selected.png"]];
    UINavigationController *vc2=[[UINavigationController alloc] init];
    UpDownloadViewController *vc22=[[UpDownloadViewController alloc] init];
    vc22.title=@"文件传输";
    [vc22 performSelector:@selector(updateTableViewCount) withObject:Nil afterDelay:0.5];
    [vc2 pushViewController:vc22 animated:YES];
    vc2.title=@"文件传输";
    [vc2.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc2.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc2.navigationBar setTintColor:[UIColor whiteColor]];
    //vc2.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    [vc2.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_trans_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_trans_nor.png"]];
    [vc2.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc2.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    UINavigationController *vc3=[[UINavigationController alloc] init];
    EmailListViewController * vc33=[[EmailListViewController alloc] init];
    [vc3 pushViewController:vc33 animated:YES];
    vc33.title=@"收件管理";
    vc3.title=@"收件管理";
    [vc3.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc3.navigationBar setTintColor:[UIColor whiteColor]];
    //vc3.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];
    [vc3.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_send_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_send_nor.png"]];
    [vc3.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc3.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    SettingViewController *vc44=[[SettingViewController alloc] init];
    UINavigationController *vc4=[[UINavigationController alloc] initWithRootViewController:vc44];
    vc44.title=@"更多";
    vc4.title=@"更多";
    [vc4.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc4.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc4.navigationBar setTintColor:[UIColor whiteColor]];
    //vc4.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    //[vc4.tabBarItem setImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
    [vc4.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_more_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_more_nor.png"]];
    [vc4.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc4.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    UINavigationController *vc5=[[UINavigationController alloc] init];
    [vc5.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc5.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
    [vc5.navigationBar setTintColor:[UIColor whiteColor]];
    SubjectListViewController * vc55=[[SubjectListViewController alloc] init];
    [vc5 pushViewController:vc55 animated:YES];
    vc55.title=@"专题";
    vc5.title=@"专题";
    //vc1.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    [vc5.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_subject_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_subject_nor.png"]];
    //    [vc1.tabBarItem setSelectedImage:[UIImage imageNamed:@"nav_selected.png"]];
    [vc5.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc5.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    
    UINavigationController *more=[[UINavigationController alloc] init];
    more.title=@"更多";
    more.tabBarItem.title=@"更多";
    [more.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [more.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    [more.navigationBar setTintColor:[UIColor whiteColor]];
    [more.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_more_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_more_nor.png"]];
    [more.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemSeColor forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [more.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:itemNorColor forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    
    
    //[vc1.tabBarItem setImage:[UIImage imageNamed: @"nav_selected.png"]];
    
    //2013年10月29日，隐掉“文件收发”模块; by FengYN
    self.viewControllers=@[vc1,vc3,vc5,vc2,more];
    self.selectedIndex=0;
    
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"nav_bk.png"]];
    NSLog(@"self.tabbar:%@",NSStringFromCGRect(self.tabBar.frame));
    //[self.tabBar setBarStyle:UIBarStyleBlack];
    //[self.tabBar setAlpha:0.65f];
    //[self.tabBar setTranslucent:NO];
    UIButton *moreButton=[[UIButton alloc] initWithFrame:CGRectMake(320-(320/5), 1, 320/5, 59)];
    [moreButton addTarget:self action:@selector(showMoreMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:moreButton];
    self.moreBtn=moreButton;
    [self performSelector:@selector(requestAddressBookData) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)hiddenControl
{
    [self.moreControl setHidden:YES];
}
-(void)showMoreMenu:(UIButton *)sender
{
    NSLog(@"showMoreMenu");
    if(!self.moreControl)
    {
        float height = self.view.bounds.size.height;
        CGRect controRect = self.view.bounds;
        self.moreControl = [[UIControl alloc] initWithFrame:controRect];
        UIControl *grayView=[[UIControl alloc] initWithFrame:controRect];
        //        [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        [grayView addTarget:self action:@selector(hiddenControl) forControlEvents:UIControlEventTouchUpInside];
        [self.moreControl addSubview:grayView];
        //添加更多按钮
        float button_height = 49;
        CGRect leftRect = CGRectMake(320-138, height-60-49*2, 138, button_height);
        UIButton *leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [leftButton addTarget:self action:@selector(showAddressBookViewController:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"address_icon.png"] forState:UIControlStateNormal];
        [self.moreControl addSubview:leftButton];
        //添加设置按钮
        CGRect right_Rect = CGRectMake(320-138, height-60-49, 138, button_height);
        UIButton *rightButton = [[UIButton alloc] initWithFrame:right_Rect];
        [rightButton addTarget:self action:@selector(showSettingViewController:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"address_setting.png"] forState:UIControlStateNormal];
        [self.moreControl addSubview:rightButton];
        [self.view addSubview:self.moreControl];
        [self.moreControl setHidden:YES];
    }
    [self.moreControl setHidden:NO];
}
-(void)showSettingViewController:(UIButton *)sender
{
    SettingViewController *settingVC=[SettingViewController new];
    settingVC.title=@"设置";
    UINavigationController *moreVC=(UINavigationController *)self.viewControllers[4];
    [moreVC setViewControllers:@[settingVC]];
    [self setSelectedIndex:4];
    settingVC.tabBarItem.title=@"更多";
    [self hiddenControl];
}
-(void)showAddressBookViewController:(UIButton *)sender
{
    AdressBookListViewController *abList = [[AdressBookListViewController alloc] init];
    AddressBookDept *dept = [[AddressBookDept alloc] init];
    AddressBookDept *list = [[dept selectBaseAddressBookDeptList] firstObject];
    NSMutableArray *a = [list selectAllAddressBookDeptList];
    NSUInteger num = 0;
    for (int i = 0; i < a.count; i++) {
        NSObject *obj = a[i];
        if ([obj isKindOfClass:[AddressBookUser class]]) {
            num++;
        } else {
            AddressBookDept *dept = (AddressBookDept *)obj;
            num = num + dept.dept_number;
        }
    }
    abList.title = [NSString stringWithFormat:@"%@",list.dept_name];
    abList.select_dept_id = list.dept_id;
    abList.isShowRecent = YES;
    abList.isSendMessage = NO;
    
    UINavigationController *moreVC=(UINavigationController *)self.viewControllers[4];
    [moreVC setViewControllers:@[abList]];
    abList.navigationTitle=abList.title;
    [self setSelectedIndex:4];
    abList.tabBarItem.title=@"更多";
    [self hiddenControl];
}
- (void)requestAddressBookData
{
    SCBAddressBookManager *abManager = [[SCBAddressBookManager alloc] init];
    [abManager setDelegate:self];
    [abManager requestAddressBookUser];
}
-(void)setHasEmailTagHidden:(BOOL)isHidden
{
    if (!self.tagImageView) {
        self.tagImageView=[[UIImageView alloc] initWithFrame:CGRectMake(110, 6, 10, 10)];
        self.tagImageView.image=[UIImage imageNamed:@"icon_hasnew_tag.png"];
        [self.tabBar addSubview:self.tagImageView];
    }
    [self.tagImageView setHidden:isHidden];
}
-(void)setSubjectActivityCount:(int)count
{
    if (count<=0) {
         [[self.viewControllers[2] tabBarItem] setBadgeValue:nil];
    }else if(count<=99)
    {
        [[self.viewControllers[2] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }else
    {
        [[self.viewControllers[2] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"99+"]];
    }
}
-(void)addUploadNumber:(NSInteger)count
{
//    if(!imageView)
//    {
//        CGRect imageRect = CGRectMake(225, -10, 35, 35);
//        imageView = [[UIImageView alloc] initWithFrame:imageRect];
//        
//        if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
//        {
//            [imageView setImage:[UIImage imageNamed:@"icon_checked_grid.png"]];
//        }
//        else
//        {
//            [imageView setImage:[UIImage imageNamed:@"icon_checked_gridIpad.png"]];
//        }
//        CGRect labelRect = CGRectMake(5, 2, 25, 30);
//        label = [[UILabel alloc] initWithFrame:labelRect];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [label setTextColor:[UIColor whiteColor]];
//        [label setFont:[UIFont boldSystemFontOfSize:11]];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        [label setLineBreakMode:NSLineBreakByTruncatingTail];
//        [imageView addSubview:label];
//        [self.tabBar addSubview:imageView];
//    }
//    if(count>0)
//    {
//        [label setText:[NSString stringWithFormat:@"%i",count]];
//        [imageView setHidden:NO];
//    }
//    else
//    {
//        [label setText:@""];
//        [imageView setHidden:YES];
//    }
    if (count<=0) {
        [[self.viewControllers[3] tabBarItem] setBadgeValue:nil];
    }else if(count<=99)
    {
        [[self.viewControllers[3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }else
    {
        [[self.viewControllers[3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"99+"]];
    }

}
#pragma mark -SCBEmailManagerDelegate
-(void)networkError
{
}
-(void)notReadCountSucceed:(NSDictionary *)datadic
{
    int notread=[[datadic objectForKey:@"notread"] intValue];
    if (notread>0) {
        [self setHasEmailTagHidden:NO];
    }else
    {
        [self setHasEmailTagHidden:YES];
    }
}
#pragma mark -SCBSubjectManagerDelegate
-(void)didGetSubjectSum:(NSDictionary *)datadic
{
    if ([datadic objectForKey:@"num"]) {
        [self setSubjectActivityCount:[[datadic objectForKey:@"num"]intValue]];
    }
}
#pragma mark SCBAddressBookDelegate ---------

//用户信息
-(void)requestSuccessAddressBookUser:(NSDictionary *)dictionary
{
    NSArray *list=[dictionary objectForKey:@"list"];
    if([list isKindOfClass:[NSArray class]])
    {
        NSDictionary *diction = [list firstObject];
        NSMutableArray *userArray = [diction objectForKey:@"user"];
        AddressBookUser *user = [[AddressBookUser alloc] init];
        [user deleteAddressBookList];
        userArray = [user getUserArray:userArray];
        [user insertAllAddressBookUserList:userArray];
        NSMutableArray *deptArray = [diction objectForKey:@"dept"];
        AddressBookDept *dept = [[AddressBookDept alloc] init];
        deptArray = [dept getDeptArray:deptArray];
        [dept insertAllAddressBookDeptList:deptArray];
    }
}

-(void)requestFailAddressBookUser:(NSDictionary *)dictionary
{
    NSLog(@"dictionary：%@",dictionary);
}
@end
