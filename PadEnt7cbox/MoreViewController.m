//
//  MoreViewController.m
//  icoffer
//
//  Created by Yangsl on 14-8-28.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#define MORECONTROLTAG 9527

#import "MoreViewController.h"
#import "SettingViewController.h"
#import "AdressBookListViewController.h"
#import "AddressBookDept.h"
#import "MyTabBarViewController.h"
#import "AppDelegate.h"

@interface MoreViewController ()

@end

@implementation MoreViewController
@synthesize control;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.control = (UIControl *)[appDelegate.window viewWithTag:MORECONTROLTAG];
    if(self.control)
    {
        [self.control removeFromSuperview];
    }
    CGRect controRect = CGRectMake(0, 0, 320, appDelegate.window.frame.size.height);
    self.control = [[UIControl alloc] initWithFrame:controRect];
    UIControl *grayView=[[UIControl alloc] initWithFrame:controRect];
    [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
    [grayView addTarget:nil action:@selector(hiddenControl) forControlEvents:UIControlEventTouchUpInside];
    [self.control addSubview:grayView];
    [appDelegate.window addSubview:self.control];
    return self;
}

- (void)hiddenControl
{
    [self.control setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)leftToucheUpInside
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
    abList.title = [NSString stringWithFormat:@"%@(%d人)",list.dept_name,num];
    abList.select_dept_id = list.dept_id;
    abList.isShowRecent = YES;
    abList.isSendMessage = NO;
    [self.navigationController pushViewController:abList animated:YES];
}

- (void)rightToucheUpInside
{
    SettingViewController *abList = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:abList animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
