//
//  SubjectListViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-3.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectListViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SCBSubjectManager.h"
#import "CreateSubjectViewController.h"
#import "SubjectTitleCell.h"
#import "SCBSession.h"
#import "NSString+Format.h"
#import "MBProgressHud.h"
#import "CutomNothingView.h"

@interface SubjectListViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) SCBSubjectManager *sm_list;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) CutomNothingView *nothingView;
@end

@implementation SubjectListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self updateList];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    UIBarButtonItem *itemAdd=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSubject:)];
    self.navigationItem.rightBarButtonItem=itemAdd;
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
-(void)updateList
{
    self.sm_list=[SCBSubjectManager new];
    self.sm_list.delegate=self;
    [self.sm_list getSubjectList];
}

-(IBAction)createSubject:(id)sender
{
    CreateSubjectViewController *createSubjectViewController=[CreateSubjectViewController new];
    createSubjectViewController.modalPresentationStyle=UIModalPresentationPageSheet;
    [self presentViewController:createSubjectViewController animated:YES completion:nil];
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

-(void)createNothingView
{
    if (!self.nothingView) {
        float boderHeigth = 20;
        float labelHeight = 40;
        float imageHeight = 100;
        CGRect nothingRect = self.tableView.bounds;
        self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
        [self.tableView addSubview:self.nothingView];
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView hiddenView];
        [self.nothingView.notingLabel setText:@"加载中,请稍等……"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SSCell";
    SubjectTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectTitleCell"  owner:self options:nil] lastObject];
    }
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *name = [dic objectForKey:@"name"];
    int commentCount=[[dic objectForKey:@"subj_comment_sum"] intValue];
    NSString *createTime = [dic objectForKey:@"happenTime"];
    NSString *closeTime = [dic objectForKey:@"closeTime"];
    
    cell.titleLabel.text=name;
    cell.timeLabel.text=[NSString getTimeFormat:createTime];
    NSString *countStr;
    if(commentCount>99){
        commentCount=99;
        countStr=[NSString stringWithFormat:@"%d+",commentCount];
    }else
    {
        countStr=[NSString stringWithFormat:@"%d",commentCount];
    }
    cell.numLabel.text=countStr;
    if(commentCount==0)
    {
        cell.numLabel.hidden=YES;
    }
    if([closeTime length]>0)
    {
        [cell.titleLabel setText:[NSString stringWithFormat:@"(已关闭)%@",name]];
        [cell.titleLabel setTextColor:[UIColor grayColor]];
        [cell.iconImageView setImage:[UIImage imageNamed:@"closed.png"]];
    }
    else
    {
        if([dic objectForKey:@"isMaster"]&&[[dic objectForKey:@"isMaster"] intValue]==1)
        {
            [cell.iconImageView setImage:[UIImage imageNamed:@"mycreate.png"]];
        }
        else
        {
            [cell.iconImageView setImage:[UIImage imageNamed:@"myparticipant.png"]];
        }
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *subjectId=[[dic objectForKey:@"subject_id"] stringValue];
    NSString *subjectTitle=[dic objectForKey:@"name"];
    int activitySum=[[dic objectForKey:@"subj_comment_sum"] intValue];
    NSString *closeTime = [dic objectForKey:@"closeTime"];
    BOOL isMaster=[[dic objectForKey:@"isMaster"] boolValue];
    BOOL isPublish=[[dic objectForKey:@"isPublish"] boolValue];
    if([closeTime length]>0)
    {
        [self showMessage:@"请在www.icoffer.cn恢复专题"];
        return;
    }
    NSArray * viewControllers=self.splitViewController.viewControllers;
    SubjectDetailTabBarController *detailController=[[SubjectDetailTabBarController alloc] init];
    detailController.subjectId=subjectId;
    detailController.subjectTitle=subjectTitle;
    detailController.isPublish=(isMaster||isPublish);
    self.splitViewController.viewControllers=@[viewControllers.firstObject,detailController];
    
    if (activitySum>0) {
        NSMutableDictionary *mDic=[NSMutableDictionary dictionaryWithDictionary:dic];
        [mDic setObject:@0 forKey:@"subj_comment_sum"];
        [self.listArray replaceObjectAtIndex:indexPath.row withObject:mDic];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
#pragma mark - SCBSubjectManagerDelegate
-(void)didGetSubjectList:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[NSMutableArray arrayWithArray:[self.dataDic objectForKey:@"list_subject"]];
    [self.tableView reloadData];
    if (self.listArray.count<=0) {
        if (!self.nothingView) {
            [self createNothingView];
        }
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView notHiddenView];
        [self.nothingView.notingLabel setText:@"立即新建一个专题，邀请同事参与吧"];
        
    }else
    {
        [self.nothingView hiddenView];
    }
}

-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
@end
