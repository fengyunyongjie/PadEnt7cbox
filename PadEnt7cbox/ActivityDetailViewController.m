//
//  ActivityDetailViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-30.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "SubjectActivityCell.h"
#import "MBProgressHud.h"
#import "ResourceCommentViewController.h"
#import "SubjectDetailTabBarController.h"

@interface ActivityDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) NSArray *resourceArray;
@end

@implementation ActivityDetailViewController

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
    NSDictionary *content = [NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
    self.resourceArray = [content objectForKey:@"eveFileUrl"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)downloadAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
    }
}

- (void)resaveAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
    }
}

- (void)reviewAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *dic = self.dic;
        
        ResourceCommentViewController *resourceCommentViewController=[ResourceCommentViewController new];
        resourceCommentViewController.resourceID=[dic objectForKey:@"resource_id"];
        resourceCommentViewController.resourceDic=dic;
        resourceCommentViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
        resourceCommentViewController.modalPresentationStyle=UIModalPresentationPageSheet;
        [self presentViewController:resourceCommentViewController animated:YES completion:nil];
    }
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int type = [[self.dic objectForKey:@"type"] intValue];
    NSDictionary *content = [NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
    NSArray *resources = [content objectForKey:@"eveFileUrl"];
    switch (section) {
        case 0:
        {
            if(type==0||type==2||type==5)
            {
                return 2;
            }else
            {
                return 1;
            }
        }
            break;
        case 1:
        {
            return resources.count;
        }
            break;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=self.dic;
    int cellType=[[dic objectForKey:@"type"] intValue];
    NSDictionary *content=[NSString stringWithDictionS:[dic objectForKey:@"content"]];
    NSString *title=[content objectForKey:@"eveTitle"];
    NSString *persons=[content objectForKey:@"object"];
    NSString *personsNum=[content objectForKey:@"number"];
    NSString *action=[content objectForKey:@"action"];
    NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
    if (indexPath.section==0) {
        static NSString *cellIdentifier = @"Cell";
        SubjectActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectActivityCell"  owner:self options:nil] lastObject];
            cell.backgroundColor=[UIColor clearColor];
        }
        cell.personLabel.text=[content objectForKey:@"eveName"];
        cell.contentLabel.text=[content objectForKey:@"eveContent"];
        cell.timeLabel.text=[content objectForKey:@"eveTime"];
        
        if (indexPath.row==0) {
            cell.personLabel.hidden=NO;
            cell.sayLabel.hidden=NO;
            cell.timeLabel.hidden=NO;
            cell.contentLabel.hidden=YES;
            switch (cellType) {
                case 0:
                {
                    //仅发言
                    cell.sayLabel.text=[NSString stringWithFormat:@"%@",@"说："];
                }
                    break;
                case 1:
                    //仅资源url超链接
                case 2:
                    //发言+资源
                case 3:
                    //修改资源
                case 4:
                    //删除资源
                case 5:
                    //评论资源（发布事件动态）
                case 7:
                    //退出专题
                case 8:
                    //主持人变更
                case 9:
                    //创建专题
                case 10:
                    //修改专题名称
                case 11:
                    //修改专题权限
                case 12:
                    //关闭专题
                case 13:
                    //恢复专题
                    cell.sayLabel.text=[NSString stringWithFormat:@"%@",title];
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
            }

        }else if(indexPath.row==1)
        {
            cell.personLabel.hidden=YES;
            cell.sayLabel.hidden=YES;
            cell.timeLabel.hidden=YES;
            cell.contentLabel.hidden=NO;
            cell.contentLabel.numberOfLines=0;
            CGSize size=[cell.contentLabel sizeThatFits:CGSizeMake(644, 1000)];
            CGRect r=cell.frame;
            if (size.height>30) {
                r.size.height=20+size.height;
            }else
            {
                r.size.height=50;
            }
            [cell setFrame:r];
        }
        return cell;
    }else
    {
        static NSString *cellIdentifier = @"Cell";
        SubjectActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectActivityCell"  owner:self options:nil] firstObject];
            cell.backgroundColor=[UIColor clearColor];
        }
        NSDictionary *fileDic = [eveFileUrl objectAtIndex:indexPath.row];
        NSString *f_id=[fileDic objectForKey:@"f_id"];
        NSString *urlTitle=[fileDic objectForKey:@"urlTitle"];
        NSString *url=[fileDic objectForKey:@"url"];
        NSString *f_name = [fileDic objectForKey:@"f_name"];
        NSString *f_mime = [[fileDic objectForKey:@"f_mime"] lowercaseString];
        NSString *f_isdir=[fileDic objectForKey:@"f_isdir"];
        
        if (url) {
            cell.iconImageView.image=[UIImage imageNamed:@"sub_link.png"];
            cell.resourceLabel1.text=urlTitle;
            cell.linkLabel1.text=url;
            cell.linkLabel1.hidden=NO;
            cell.resaveButton.hidden=YES;
            cell.downloadButton.hidden=YES;
        }else{
            cell.resourceLabel1.text=f_name;
            if ([f_isdir intValue]==0) {
                //文件夹
                cell.iconImageView.image=[UIImage imageNamed:@"file_folder.png"];
                cell.downloadButton.hidden=YES;
            }else if([f_mime isEqualToString:@"png"]||
                     [f_mime isEqualToString:@"jpg"]||
                     [f_mime isEqualToString:@"jpeg"]||
                     [f_mime isEqualToString:@"bmp"]||
                     [f_mime isEqualToString:@"gif"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
            }else if ([f_mime isEqualToString:@"doc"]||
                      [f_mime isEqualToString:@"docx"]||
                      [f_mime isEqualToString:@"rtf"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
            }
            else if ([f_mime isEqualToString:@"xls"]||
                     [f_mime isEqualToString:@"xlsx"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
            }else if ([f_mime isEqualToString:@"mp3"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
            }else if ([f_mime isEqualToString:@"mov"]||
                      [f_mime isEqualToString:@"mp4"]||
                      [f_mime isEqualToString:@"avi"]||
                      [f_mime isEqualToString:@"rmvb"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
            }else if ([f_mime isEqualToString:@"pdf"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
            }else if ([f_mime isEqualToString:@"ppt"]||
                      [f_mime isEqualToString:@"pptx"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
            }else if([f_mime isEqualToString:@"txt"])
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
            }else
            {
                cell.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
            }
        }
        [cell.downloadButton addTarget:self action:@selector(downloadAction:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.resaveButton addTarget:self action:@selector(resaveAction:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.reviewButton addTarget:self action:@selector(reviewAction:event:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
#pragma mark - SCBSubjectManager delegate
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}

@end
