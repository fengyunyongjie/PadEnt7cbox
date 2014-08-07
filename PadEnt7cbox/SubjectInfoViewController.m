//
//  SubjectInfoViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectInfoViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SCBSubjectManager.h"
#import "SubjectInfoCell.h"
#import "MBProgressHUD.h"

@interface SubjectInfoViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,strong) NSArray *listArray;
@property (nonatomic,strong) SCBSubjectManager *sm_list;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation SubjectInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=[(SubjectDetailTabBarController *)self.tabBarController subjectTitle];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
}

-(void)viewDidLayoutSubviews
{
    self.tableView.frame=self.view.bounds;
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
- (void)updateList
{
    self.sm_list=[SCBSubjectManager new];
    self.sm_list.delegate=self;
    [self.sm_list getSubjectInfoWithSubjectID:[(SubjectDetailTabBarController *)self.tabBarController subjectId]];
}

-(void)showMessage:(NSString *)message
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    self.hud=[[MBProgressHUD alloc] initWithView:window];
    [window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=message;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self.listArray count];
            break;
    }
    return 0;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        static NSString *cellIdentifier = @"Cell";
        SubjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectInfoCell"  owner:self options:nil] lastObject];
            cell.backgroundColor=[UIColor clearColor];
        }
        cell.subjectInfoTextView.text=[self.dataDic objectForKey:@"details"];
        return cell;
    }else
    {
        static NSString *cellIdentifier = @"Cell";
        SubjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectInfoCell"  owner:self options:nil] firstObject];
            cell.backgroundColor=[UIColor clearColor];
            NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
            cell.personLabel.text=[dic objectForKey:@"usr_turename"];
            if ([[dic objectForKey:@"isMaster"] intValue]==0) {
                cell.headLabel.text=@"成员：";
                cell.personLabel.textColor=[UIColor blackColor];
            }
        }
        return cell;
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        return 148;
    }else
    {
        return 44;
    }
}
#pragma mark - SCBSubjectManagerDelegate
-(void)didGetSubjectInfo:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"joinMember"];
    [self.tableView reloadData];
}
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
@end
