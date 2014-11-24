//
//  SubJectListViewController.m
//  icoffer
//
//  Created by Yangsl on 14-7-7.
//  Copyright (c) 2014年  All rights reserved.
//

#import "IPSubJectListViewController.h"
#import "IPSubJectListTableViewCell.h"
#import "IPSubJectDetailViewController.h"
#import "YNFunctions.h"
#import "IPNewSubJectViewControlller.h"
#import "YNNavigationController.h"
#import "AppDelegate.h"
#import "MyTabBarViewController.h"
#import "CutomNothingView.h"

@interface IPSubJectListViewController ()
@property (strong,nonatomic) CutomNothingView *nothingView;
@end

@implementation IPSubJectListViewController
@synthesize tableView,tableArray,rightButton,hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([YNFunctions systemIsLaterThanString:@"7.0"])
    {
        //禁用滑动返回
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    CGRect tableRect = CGRectMake(0, 0, width, height-49-44-20);
    self.tableView = [[UITableView alloc] initWithFrame:tableRect];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    self.tableArray = [[NSMutableArray alloc] init];
    [self requestSubjectList];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    NSMutableArray *items=[NSMutableArray array];
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [rightButton setImage:[UIImage imageNamed:@"new_subject.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [items addObject:rightItem];
    self.navigationItem.rightBarButtonItems = items;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.nothingView hiddenView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self viewDidNewLoad:NO];
    [self requestSubjectList];
    
}

-(void)viewDidNewLoad:(BOOL)isHideTabBar
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appleDate.myTabBarVC setHidesTabBarWithAnimate:isHideTabBar];
}

-(void)requestSubjectList
{
    //请求专题列表信息
    IPSCBSubJectManager *subjectmanager = [[IPSCBSubJectManager alloc] init];
    [subjectmanager requestSubjectList:@""];
    [subjectmanager setDelegate:self];
}

#pragma mark - SCBSubjectDelegate

-(void)requestSubJectListSuccess:(NSDictionary *)diction
{
    NSLog(@"diction:%@",diction);
    NSInteger number = [[diction objectForKey:@"num"] integerValue];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
//    [app.myTabBarVC addSubjectNumber:number];
    if([diction objectForKey:@"list_subject"])
    {
        [self.tableArray removeAllObjects];
        NSArray *array = [diction objectForKey:@"list_subject"];
        NSMutableArray *array2 = [[NSMutableArray alloc] init];
        //遍历，按照顺序排序
        for(int i=0;i<array.count;i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            NSString *closeTime = [dic objectForKey:@"closeTime"];
            if([closeTime length]>0)
            {
                [array2 addObject:dic];
            }
            else
            {
                [self.tableArray addObject:dic];
            }
        }
        
        [self.tableArray addObjectsFromArray:array2];
        if (self.tableArray.count<1) {
            if(self.nothingView == nil)
            {
                float boderHeigth = 20;
                float labelHeight = 40;
                float imageHeight = 100;
                CGRect nothingRect = CGRectMake(0, 0, 320, self.tableView.bounds.size.height);
                self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
                [self.tableView addSubview:self.nothingView];
            }
            [self.tableView bringSubviewToFront:self.nothingView];
            [self.nothingView notHiddenView];
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [self.nothingView.notingLabel setText:@"立即新建一个专题，邀请同事参与吧"];
        }
        
        [self.tableView reloadData];
    }
}

-(void)requestSubJectListFail:(NSDictionary *)diction
{
    NSLog(@"diction:%@",diction);
}

-(void)clickRightButton
{
    //新建专题入口
    NSLog(@"新建专题入口");
    IPNewSubJectViewControlller *new = [[IPNewSubJectViewControlller alloc] init];
    new.title = @"新建专题";
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:new];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"SubJectListTableViewCell";
    IPSubJectListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[IPSubJectListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if(indexPath.row < self.tableArray.count)
    {
        [cell updateCell:[self.tableArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.tableArray.count)
    {
        NSDictionary *diction = [self.tableArray objectAtIndex:indexPath.row];
        NSString *closeTime = [diction objectForKey:@"closeTime"];
        if([closeTime length]>0)
        {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"请在www.icoffer.cn恢复专题";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
        }
        else
        {
            //进入详细页面
            IPSubJectDetailViewController *subjectDetailView = [[IPSubJectDetailViewController alloc] init];
            [subjectDetailView setBaseDiction:diction];
            [self.navigationController pushViewController:subjectDetailView animated:YES];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableArray count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
