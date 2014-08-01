//
//  SubjectActivityViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectActivityViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SCBSubjectManager.h"
#import "SubjectActivityCell.h"
#import "NSString+Format.h"
#import "ActivityDetailViewController.h"
#import "MBProgressHUD.h"
#import "MyTabBarViewController.h"
#import "SubjectListViewController.h"

@interface SubjectActivityViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,strong) NSArray *listArray;
@property (nonatomic,strong) SCBSubjectManager *sm_list;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation SubjectActivityViewController

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
    [self.sm_list getActivityWithSubjectID:[(SubjectDetailTabBarController *)self.tabBarController subjectId]];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.listArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic=[self.listArray objectAtIndex:section];
    NSDictionary *content=[NSString stringWithDictionS:[dic objectForKey:@"content"]];
    int cellType=[[dic objectForKey:@"type"] intValue];

    switch (cellType) {
        case 0:
        {
            //仅发言
            return 2;
        }
            break;
        case 1:
        {
            //仅资源url超链接
            return 2;
        }
            break;
        case 2:
        {
            //发言+资源
            return 3;
        }
            break;
        case 3:
        {
            //修改资源
            return 2;
        }
            break;
        case 4:
        {
            //删除资源
            return 2;
        }
            break;
        case 5:
        {
            //评论资源（发布事件动态）
            return 3;
        }
            break;
        case 6:
        {
            //加入专题
            return 1;
        }
            break;
        case 7:
        {
            //退出专题
            return 1;
        }
            break;
        case 8:
        {
            //主持人变更
            return 1;
        }
            break;
        case 9:
        {
            //创建专题
            return 1;
        }
            break;
        case 10:
        {
            //修改专题名称
            return 1;
        }
            break;
        case 11:
        {
            //修改专题权限
            return 1;
        }
            break;
        case 12:
        {
            //关闭专题
            return 1;
        }
            break;
        case 13:
        {
            //恢复专题
            return 1;
        }
            break;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SubjectActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectActivityCell"  owner:self options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.section];
    NSDictionary *content=[NSString stringWithDictionS:[dic objectForKey:@"content"]];
    NSString *title=[content objectForKey:@"eveTitle"];
    NSString *persons=[content objectForKey:@"object"];
    NSString *personsNum=[content objectForKey:@"number"];
    NSString *action=[content objectForKey:@"action"];
    NSString *eveType=[content objectForKey:@"eveType"];
    NSString *eveSeconds=[content objectForKey:@"eveSeconds"];
    NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
    
    NSDictionary *fileDic = [eveFileUrl firstObject];
    
    NSString *f_id=[fileDic objectForKey:@"f_id"];
    NSString *urlTitle=[fileDic objectForKey:@"urlTitle"];
    NSString *url=[fileDic objectForKey:@"url"];
    NSString *f_name = [fileDic objectForKey:@"f_name"];
    NSString *f_mime = [fileDic objectForKey:@"f_mime"];
    NSString *f_isdir=[fileDic objectForKey:@"f_isdir"];
    if ([f_isdir intValue]==0) {
        //文件夹
//        imageView.image=[UIImage imageNamed:@"file_folder.png"];
        cell.resourceImageView.image=[UIImage imageNamed:@"file_folder.png"];
    }else if([f_mime isEqualToString:@"png"]||
             [f_mime isEqualToString:@"jpg"]||
             [f_mime isEqualToString:@"jpeg"]||
             [f_mime isEqualToString:@"bmp"]||
             [f_mime isEqualToString:@"gif"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_pic.png"];
    }else if ([f_mime isEqualToString:@"doc"]||
              [f_mime isEqualToString:@"docx"]||
              [f_mime isEqualToString:@"rtf"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([f_mime isEqualToString:@"xls"]||
             [f_mime isEqualToString:@"xlsx"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([f_mime isEqualToString:@"mp3"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([f_mime isEqualToString:@"mov"]||
              [f_mime isEqualToString:@"mp4"]||
              [f_mime isEqualToString:@"avi"]||
              [f_mime isEqualToString:@"rmvb"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([f_mime isEqualToString:@"pdf"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([f_mime isEqualToString:@"ppt"]||
              [f_mime isEqualToString:@"pptx"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([f_mime isEqualToString:@"txt"])
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_txt.png"];
    }else
    {
        cell.resourceImageView.image = [UIImage imageNamed:@"file_other.png"];
    }
    cell.resourceLabel.text=f_name;
    
    int cellType=[[dic objectForKey:@"type"] intValue];
    cell.personLabel.text=[content objectForKey:@"eveName"];
    cell.contentLabel.text=[content objectForKey:@"eveContent"];
    cell.timeLabel.text=[NSString getTimeFormat:[content objectForKey:@"eveTime"]];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.personLabel.hidden=NO;
            cell.sayLabel.hidden=NO;
            cell.timeLabel.hidden=NO;
            cell.contentLabel.hidden=YES;
        }
            break;
        case 1:
        {
            cell.personLabel.hidden=YES;
            cell.sayLabel.hidden=YES;
            cell.timeLabel.hidden=YES;
            cell.contentLabel.hidden=NO;
            if(cellType==1||cellType==3||cellType==4)
            {
                cell.resourceImageView.hidden=NO;
                cell.resourceLabel.hidden=NO;
                
                if (url) {
                    cell.resourceImageView.image=[UIImage imageNamed:@"sub_link.png"];
                    cell.resourceLabel.text=urlTitle;
                    cell.linkLabel.text=url;
                    cell.linkLabel.hidden=NO;
                }
            }else if(cellType==5&&eveType&&eveType.intValue==1)
            {
                cell.contentLabel.hidden=YES;
                cell.resourceImageView.hidden=NO;
                cell.resourceLabel.hidden=NO;
                cell.resourceImageView.image=[UIImage imageNamed:@"sub_yuyin_ico.png"];
                cell.resourceLabel.text=[NSString stringWithFormat:@"%@''",eveSeconds];
            }
        }
            break;
        case 2:
        {
            cell.personLabel.hidden=YES;
            cell.sayLabel.hidden=YES;
            cell.timeLabel.hidden=YES;
            cell.contentLabel.hidden=YES;
            cell.resourceLabel.hidden=NO;
            cell.resourceImageView.hidden=NO;
            
            if (url) {
                cell.resourceImageView.image=[UIImage imageNamed:@"sub_link.png"];
                cell.resourceLabel.text=urlTitle;
                cell.linkLabel.text=url;
                cell.linkLabel.hidden=NO;
            }
        }
            break;
    }
    
    switch (cellType) {
        case 0:
        {
            //仅发言
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",@"说："];
        }
            break;
        case 1:
        {
            //仅资源url超链接
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 2:
        {
            //发言+资源
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 3:
        {
            //修改资源
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 4:
        {
            //删除资源
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 5:
        {
            //评论资源（发布事件动态）
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 6:
        {
            //加入专题
            cell.personLabel.text=[content objectForKey:@"inviter"];
            if (persons.length>36) {
                cell.sayLabel.text=[NSString stringWithFormat:@"%@ %@... 共%@人 %@",title,[persons substringToIndex:35],personsNum,action];
            }else
            {
                cell.sayLabel.text=[NSString stringWithFormat:@"%@ %@ 共%@人 %@",title,persons,personsNum,action];
            }
            
        }
            break;
        case 7:
        {
            //退出专题
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 8:
        {
            //主持人变更
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 9:
        {
            //创建专题
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 10:
        {
            //修改专题名称
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 11:
        {
            //修改专题权限
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 12:
        {
            //关闭专题
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
        case 13:
        {
            //恢复专题
            cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
        }
            break;
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityDetailViewController *advc=[ActivityDetailViewController new];
    advc.dic=[self.listArray objectAtIndex:indexPath.section];
    advc.title=@"专题动态详情";
    [self.navigationController pushViewController:advc animated:YES];
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
-(void)didGetActivity:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"result"];
    [self.tableView reloadData];
    MyTabBarViewController *myTabVC=[self.splitViewController.viewControllers objectAtIndex:0];
    [myTabVC checkSubjectActivityCount];
//    UINavigationController *nav=(UINavigationController *)myTabVC.viewControllers[2];
//    if ([nav respondsToSelector:@selector(viewControllers)]) {
//        SubjectListViewController *subjectVC=(SubjectListViewController *)nav.viewControllers.firstObject;
//        if ([subjectVC respondsToSelector:@selector(updateList)]) {
//            [subjectVC updateList];
//        }
//    }
}
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
@end
