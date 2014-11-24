//
//  SubJectDetailViewController.m
//  icoffer
//
//  Created by Yangsl on 14-7-8.
//  Copyright (c) 2014年  All rights reserved.
//

#import "IPSubJectDetailViewController.h"
#import "IPSubjectDetailDynamicTableViewCell.h"
#import "IPSubJectNewDetailViewController.h"
#import "IPSendToSubJectViewController.h"
#import "IPSubJectDetailCommentViewController.h"
#import "IPDetailCell.h"
#import "IPResourceCell.h"
#import "QLBrowserViewController.h"
#import "PhotoLookViewController.h"
#import "YNFunctions.h"
#import "DownList.h"
#import "OtherBrowserViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MainViewController.h"
#import "YNNavigationController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "IPSubJectFileListViewController.h"
#import "MBProgressHUD.h"
#import "CutomNothingView.h"
#import "MyTabBarViewController.h"

@interface IPSubJectDetailViewController () {
    NSMutableArray *resListArray;
    UIToolbar *moreEditBar;
    NSIndexPath *selectedIndexPath;
    UIControl *singleBg;
    NSMutableArray *fileArray;
    NSDictionary *fileDic;
    
    NSDictionary *infoDic;
}
@property (nonatomic, retain) MBProgressHUD *hud;
@property (strong,nonatomic) CutomNothingView *nothingView;

@end

@implementation IPSubJectDetailViewController
@synthesize baseDiction,rightButton,segMentControl,dynamicArray,resourcesArray,subjectInfoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self viewDidNewLoad:YES];
    [self isSelectedIndex:self.sjmType];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"dictionary:%@",self.baseDiction);
    self.title = [self.baseDiction objectForKey:@"name"];
    //返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    BOOL isPublish = [[self.baseDiction objectForKey:@"isPublish"] boolValue];
    BOOL isMaster = [[self.baseDiction objectForKey:@"isMaster"] boolValue];
    if(isPublish || isMaster)
    {
        NSMutableArray *rightItems=[NSMutableArray array];
        //添加按钮
        rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,80,20)];
        [rightButton setTitle:@"发布资源" forState:UIControlStateNormal];
        [rightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [rightItems addObject:rightItem];
        self.navigationItem.rightBarButtonItems = rightItems;
    }
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect tableRect = CGRectMake(0, 60, width, height-60-64);
    self.tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:subject_detaiTableview_color];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    [self isSelectedIndex:0];
    
    fileArray = [NSMutableArray array];
    resListArray = [NSMutableArray array];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self viewDidNewLoad:YES];
    
    //动态，资源，信息
    NSArray *controlArray = [[NSArray alloc] initWithObjects:@"动态",@"资源",@"专题信息",nil];
    CGRect customRect = CGRectMake(10, 20, 300, 30);
    self.segMentControl = [[UISegmentedControl alloc] initWithItems:controlArray];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil];
    [self.segMentControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    [self.segMentControl setFrame:customRect];
    self.segMentControl.tintColor = subject_color;
    [self.segMentControl addTarget:self action:@selector(changeSegMentSelectIndex) forControlEvents:UIControlEventValueChanged];
    [self.segMentControl setBackgroundColor:subject_detaiTableview_color];
    [self.view addSubview:self.segMentControl];
    [self.segMentControl setSelectedSegmentIndex:0];
    
    self.view.backgroundColor = subject_detaiTableview_color;
    
    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)viewDidNewLoad:(BOOL)isHideTabBar
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appleDate.myTabBarVC setHidesTabBarWithAnimate:isHideTabBar];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
}

- (void)changeSegMentSelectIndex
{
    NSLog(@"self.segMentControl.selectedSegmentIndex:%i",self.segMentControl.selectedSegmentIndex);
    [self isSelectedIndex:self.segMentControl.selectedSegmentIndex];
}

-(void)requestSubjectEventOfInfo
{
    //请求主题动态
    NSString *subject_id = [self.baseDiction objectForKey:@"subject_id"];
    NSString *user_id = [self.baseDiction objectForKey:@"user_id"];
    if(subject_id && user_id)
    {
        IPSCBSubJectManager *subjectmanager = [[IPSCBSubJectManager alloc] init];
        [subjectmanager requestSubjectEventOfInfo:subject_id user_id:user_id];
        [subjectmanager setDelegate:self];
    }
}

//主题信息
- (void)getSubjectRightInfo {
    
    NSString *subject_id = [self.baseDiction objectForKey:@"subject_id"];
    if(subject_id) {
        IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
        [sm setDelegate:self];
        [sm getSubjectInfoWithSubjectId:subject_id];
    }
}

//资源列表
- (void)getResourceList {
    
    NSString *subject_id = [self.baseDiction objectForKey:@"subject_id"];
    if(subject_id) {
        IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
        [sm setDelegate:self];
        [sm getResourceListWithSubjectId:subject_id resourceUserIds:nil resourceType:nil resourceTitil:nil];
    }
}

-(void)backClicked
{
    //返回上一级
    NSLog(@"返回上一级");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRightButton
{
    //跳转到发送内容到专题页面
    NSLog(@"跳转到发送内容到专题页面");
    //资源添加
    IPSendToSubJectViewController *sendToSubjectView = [[IPSendToSubJectViewController alloc] init];
    sendToSubjectView.baseDiction = baseDiction;
    [self.navigationController pushViewController:sendToSubjectView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)isSelectedIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            //动态
            self.nothingView.hidden = YES;
            self.sjmType = SJMTypeDynamic;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self hideSingleBar];
            [self.tableView reloadData];
            [self requestSubjectEventOfInfo];
        }
            break;
        case 1:
        {
            //资源
            self.nothingView.hidden = YES;
            self.sjmType = SJMTypeResources;
            [self hideSingleBar];
            [self.tableView reloadData];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self getResourceList];
        }
            break;
        case 2:
        {
            //专题信息
            self.nothingView.hidden = YES;
            self.sjmType = SJMTypeSubjectInfo;
            [self.tableView reloadData];
            [self getSubjectRightInfo];
            [self hideSingleBar];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sjmType == SJMTypeSubjectInfo) {
        return 2;
    }
    else if (self.sjmType == SJMTypeDynamic) {
        return self.dynamicArray.count;
    }
    else
    {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.sjmType) {
        case SJMTypeDynamic:
        {
            //动态
            IPSubjectDetailDynamicTableViewCell *cell = [[IPSubjectDetailDynamicTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.cellDelegate = self;
            if(indexPath.section < self.dynamicArray.count)
            {
                [cell updateCell:[self.dynamicArray objectAtIndex:indexPath.section] indexPath:indexPath];
            }
            return cell;
        }
            break;
        case SJMTypeResources:
        {
            //资源
            static NSString *cellIdentifier = @"IPResourceCell";
            IPResourceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                NSArray *_nib=[[NSBundle mainBundle] loadNibNamed:@"IPResourceCell"
                                                            owner:self
                                                          options:nil];
                cell = [_nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [[cell.contentView viewWithTag:110] removeFromSuperview];
            NSDictionary *dic = [resListArray objectAtIndex:indexPath.row];
            NSString *name = [dic objectForKey:@"file_name"];
            cell.res_name.text = name;
            int len = [NSString getTitleWidth:name andFont:[UIFont systemFontOfSize:17]];
            CGRect nameRect = CGRectMake(47, 8, len,30);
            cell.res_name.frame = nameRect;
            float speakX = cell.res_name.frame.origin.x+cell.res_name.frame.size.width+6;
            CGRect speakRect = CGRectMake(speakX, 13, 28, 15);
            UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_comment.png"]];
            v.frame = speakRect;
            v.tag = 110;
            
            NSString *com_count = [[dic objectForKey:@"commentCount"] stringValue];
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 15, 15)];
            l.text = com_count;
            l.font = [UIFont systemFontOfSize:10];
            l.textColor = [UIColor colorWithRed:19.0/255 green:88.0/255.0 blue:176.0/255.0 alpha:1];
            [v addSubview:l];
            [cell.contentView addSubview:v];


            cell.res_desc.text = [dic objectForKey:@"details"];
            [cell.moreBtn setImage:[UIImage imageNamed:@"sel_nor.png"] forState:UIControlStateNormal];
            [cell.moreBtn setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateHighlighted];
            [cell.moreBtn setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateSelected];
            [cell.moreBtn addTarget:self action:@selector(accessoryButtonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.moreBtn.tag = indexPath.row;
            cell.accessoryView=cell.moreBtn;
            cell.username.text = [dic objectForKey:@"username"];
            NSString *publishTime = [dic objectForKey:@"publishTime"];
            cell.dateLabel.text = [NSString getTimeFormat:publishTime];
            
            NSString *fname = [dic objectForKey:@"file_name"];
            NSString *fmime = [[fname pathExtension] lowercaseString];
        
            int file_type = [[dic objectForKey:@"type"] intValue];
            
            if (file_type == 1) {//文件夹
                cell.res_image.image = [UIImage imageNamed:@"file_folder.png"];
                cell.res_desc.hidden = YES;
                
            } else if (file_type == 3) {//链接
                cell.res_image.image = [UIImage imageNamed:@"sub_link.png"];
                cell.res_desc.hidden = NO;

            } else { //文件
                cell.res_desc.hidden = NO;

                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"])
                {
                    NSString *fthumb=[dic objectForKey:@"file_thumb"];
                    NSString *localThumbPath=[YNFunctions getIconCachePath];
                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                        
                        UIImage *icon=[UIImage imageWithContentsOfFile:localThumbPath];
                        CGSize itemSize = CGSizeMake(100, 100);
                        UIGraphicsBeginImageContext(itemSize);
                        CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
                        if (icon.size.width>icon.size.height) {
                            theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                            theR.origin.x=-(theR.size.width/2)-itemSize.width;
                        }else
                        {
                            theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                            theR.origin.y=-(theR.size.height/2)-itemSize.height;
                        }
                        CGRect imageRect = CGRectMake(0, 0, 100, 100);
                        [icon drawInRect:imageRect];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        cell.res_image.image = image;
                    }else{
                        cell.res_image.image = [UIImage imageNamed:@"file_pic.png"];
                        NSLog(@"将要下载的文件：%@",localThumbPath);
                        [self startIconDownload:dic forIndexPath:indexPath];
                    }
                    
                }else if ([fmime isEqualToString:@"doc"]||
                          [fmime isEqualToString:@"docx"]||
                          [fmime isEqualToString:@"rtf"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_word.png"];
                }
                else if ([fmime isEqualToString:@"xls"]||
                         [fmime isEqualToString:@"xlsx"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_excel.png"];
                }else if ([fmime isEqualToString:@"mp3"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_music.png"];
                }else if ([fmime isEqualToString:@"mov"]||
                          [fmime isEqualToString:@"mp4"]||
                          [fmime isEqualToString:@"avi"]||
                          [fmime isEqualToString:@"rmvb"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_moving.png"];
                }else if ([fmime isEqualToString:@"pdf"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_pdf.png"];
                }else if ([fmime isEqualToString:@"ppt"]||
                          [fmime isEqualToString:@"pptx"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_ppt.png"];
                }else if([fmime isEqualToString:@"txt"])
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_txt.png"];
                }
                else
                {
                    cell.res_image.image = [UIImage imageNamed:@"file_other.png"];
                }
            }
            return cell;

        }
            break;
        case SJMTypeSubjectInfo:
        {
            //专题信息
            switch (indexPath.section) {
                case 0: {
                    static NSString *cellIdentifier = @"IPDetailCell";
                    IPDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (cell == nil) {
                        NSArray *_nib=[[NSBundle mainBundle] loadNibNamed:@"IPDetailCell"
                                                                    owner:self
                                                                  options:nil];
                        cell = [_nib objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    if (infoDic) {
                        cell.hidden = NO;
                        NSString *detailStr = [infoDic objectForKey:@"details"];
                        if (detailStr.length) {
                            cell.contentTV.hidden = NO;
                            cell.contentTV.text = [infoDic objectForKey:@"details"];
                            cell.remindLabel.hidden = YES;
                        } else {
                            cell.remindLabel.hidden = NO;
                            cell.contentTV.hidden = YES;
                        }
                        cell.contentTV.font = [UIFont systemFontOfSize:16];
                        
                    } else {
                        cell.hidden = YES;
                    }
                    
                    return cell;
                }
                    break;
                    
                case 1: {
                    static NSString *cellIdentifier = @"IPDetailCell2";
                    IPDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (cell == nil) {
                        NSArray *_nib=[[NSBundle mainBundle] loadNibNamed:@"IPDetailCell"
                                                                    owner:self
                                                                  options:nil];
                        cell = [_nib objectAtIndex:1];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    if (infoDic) {
                        if (indexPath.row == 0) {
                            cell.desLabel.text = @"主持人:";
                            NSDictionary *dic = [subjectInfoArray objectAtIndex:indexPath.row];
                            cell.nameLabel.text = [dic objectForKey:@"usr_turename"];
                            cell.nameLabel.textColor = [UIColor colorWithRed:19.0/255.0 green:88.0/255.0 blue:176.0/255.0 alpha:1];
                        } else {
                            cell.desLabel.text = @"成员:";
                            NSDictionary *dic = [subjectInfoArray objectAtIndex:indexPath.row];
                            cell.nameLabel.text = [dic objectForKey:@"usr_turename"];
                            cell.nameLabel.textColor = [UIColor blackColor];
                        }
                    }
                    return cell;
                }
                    break;
                default: {
                    static NSString *cellIdentifier = @"cellIdentifier";
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.textLabel.text = @"没有详细信息";
                    return cell;
                }
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.sjmType) {
        case SJMTypeDynamic:
        {
            //动态
            if(indexPath.row < self.dynamicArray.count)
            {
                NSDictionary *diction = [self.dynamicArray objectAtIndex:indexPath.row];
                return [IPSubjectDetailDynamicTableViewCell getTableViewHeights:diction];
            }
            
            return 100;
        }
            break;
        case SJMTypeResources:
        {
            //资源
            if(resListArray)
                return 60;
            return 0;
        }
            break;
        case SJMTypeSubjectInfo:
        {
            //专题信息
            if(self.subjectInfoArray) {
                switch (indexPath.section) {
                    case 0:
                        return 150;
                        break;
                    case 1:
                        return 44;
                        break;
                    default:
                        break;
                }
            }
            return 0;
        }
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.sjmType) {
        case SJMTypeDynamic:
        {
            int count = 0;
            //动态
            if(section<self.dynamicArray.count)
            {
                NSDictionary *diction = [self.dynamicArray objectAtIndex:section];
                count = [IPSubjectDetailDynamicTableViewCell getCurrTableViewCell:diction];
            }
            return count;
        }
            break;
        case SJMTypeResources:
        {
            //资源
            if(resListArray)
                return [resListArray count];
            return 0;
        }
            break;
        case SJMTypeSubjectInfo:
        {
            //专题信息
            switch (section) {
                case 0:
                    return 1;
                    break;
                case 1:
                   if(self.subjectInfoArray) {
                        return subjectInfoArray.count;
                        
                    } else
                        return 0;
                    break;
                default:
                    return 0;
                    break;
            }
            break;
        default:
            break;
        }
    
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)accessoryButtonPressedAction: (id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:button.tag inSection:0];
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.sjmType) {
        case SJMTypeDynamic:
        {
            //动态
            if(indexPath.section < self.dynamicArray.count)
            {
                NSDictionary *dictionary = [self.dynamicArray objectAtIndex:indexPath.section];
                [self selectedCell:dictionary];
            }
        }
            break;
        case SJMTypeResources:
        {
            //资源
            if(indexPath.row >= [resListArray count])
            {
                return;
            }
            selectedIndexPath = indexPath;
            NSDictionary *dic = [resListArray objectAtIndex:indexPath.row];
            int file_type = [[dic objectForKey:@"type"] intValue];
            if (file_type == 1) {
                //文件夹
                NSDictionary *fiel_dic = nil;
                int file_id = [[dic objectForKey:@"file_id"] intValue];
                for (int i = 0; i < fileArray.count; i++) {
                    NSDictionary *d2 = [fileArray objectAtIndex:i];
                    int file_id2 = [[d2 objectForKey:@"fid"] intValue];
                    if (file_id == file_id2) {
                        fiel_dic = d2;
                    }
                }
                IPSubJectFileListViewController *flVC = [[IPSubJectFileListViewController alloc] init];
                NSString *subject_id = [self.baseDiction objectForKey:@"subject_id"];
                flVC.subId = subject_id;
                flVC.fId = [dic objectForKey:@"file_id"];
                flVC.title = [dic objectForKey:@"file_name"];
                [self.navigationController pushViewController:flVC animated:YES];
            } else if (file_type == 2) {
                //文件
                [self lookAction];
                
            } else {
                //链接
                [self visitAction];
            }
        }
            break;
        case SJMTypeSubjectInfo:
        {
            //专题信息
        }
            break;
        default:
            break;
    }
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath=indexPath;
    if (!singleBg) {
        
        singleBg=[[UIControl alloc] initWithFrame:CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height)];
        [singleBg addTarget:self action:@selector(hideSingleBar) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:singleBg];
    }
    [singleBg setHidden:NO];
    singleBg.frame=CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height);
    
    int CellHeight=60;
    if (!moreEditBar) {
        [moreEditBar setBarTintColor:[UIColor blueColor]];
        moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, CellHeight)];
        [moreEditBar setBackgroundImage:[UIImage imageNamed:@"bk_select.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [moreEditBar setBarStyle:UIBarStyleBlackOpaque];
        
        
        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_selectTop.png"]];
        [jiantou setFrame:CGRectMake(280, -6, 10, 6)];
        [jiantou setTag:2012];
        [moreEditBar addSubview:jiantou];
    }
    [self.tableView addSubview:moreEditBar];
    [self.tableView bringSubviewToFront:moreEditBar];
    [moreEditBar setHidden:NO];
    CGRect r=moreEditBar.frame;
    
    r.origin.y=(indexPath.row+1) * CellHeight+10;
    if (r.origin.y+r.size.height>self.tableView.frame.size.height &&r.origin.y+r.size.height > self.tableView.contentSize.height) {
        r.origin.y=(indexPath.row+1)*CellHeight-(r.size.height *2)+10;
        UIImageView *imageView=(UIImageView *)[moreEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        imageView.frame=CGRectMake(280, CellHeight, 10, 6);
    }else
    {
        UIImageView *imageView=(UIImageView *)[moreEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        imageView.frame=CGRectMake(280, -6, 10, 6);
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
        NSLog(@"Rect:%@\n SuperView:%@",NSStringFromCGRect(rectInSuperview),NSStringFromCGRect([tableView.superview frame]));
        if (rectInSuperview.origin.y+(rectInSuperview.size.height*2)>([tableView superview].frame.size.height+[tableView superview].frame.origin.y)-49-64) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        
    }
    moreEditBar.frame=r;
    //下载 删除 转存 预览 取消共享 访问 评论
    UIButton *btn_download,*btn_del ,*btn_resave,*btn_look ,*btn_cancelShare ,*btn_visit, *btn_comment;
    UIBarButtonItem *item_download ,*item_del ,*item_resave, *item_look,*item_cancelShare, *item_visit,*item_flexible, *item_comment;
    int btnWidth=40;
    //下载
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [btn_download addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    //删除
    btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
    [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
    [btn_del addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
    
    //转存
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 39)];
    [btn_resave setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [btn_resave setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [btn_resave addTarget:self action:@selector(resaveAction) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    
    //预览
    btn_look =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_look setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
    [btn_look setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
    [btn_look addTarget:self action:@selector(lookAction) forControlEvents:UIControlEventTouchUpInside];
    item_look=[[UIBarButtonItem alloc] initWithCustomView:btn_look];
    
    // 取消共享
    btn_cancelShare =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_cancelShare setImage:[UIImage imageNamed:@"move_nor.png"] forState:UIControlStateNormal];
    [btn_cancelShare setImage:[UIImage imageNamed:@"move_se.png"] forState:UIControlStateHighlighted];
    [btn_cancelShare addTarget:self action:@selector(cancelShare) forControlEvents:UIControlEventTouchUpInside];
    item_cancelShare=[[UIBarButtonItem alloc] initWithCustomView:btn_cancelShare];
    
    
    //访问
    btn_visit =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_visit setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [btn_visit setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [btn_visit addTarget:self action:@selector(visitAction) forControlEvents:UIControlEventTouchUpInside];
    item_visit=[[UIBarButtonItem alloc] initWithCustomView:btn_visit];
    
    //评论
    btn_comment=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [btn_comment setImage:[UIImage imageNamed:@"sub_commentBtn_up.png"] forState:UIControlStateNormal];
    [btn_comment setImage:[UIImage imageNamed:@"sub_commentBtn_down.png"] forState:UIControlStateHighlighted];
    [btn_comment addTarget:self action:@selector(goToCommentListView:) forControlEvents:UIControlEventTouchUpInside];
    item_comment=[[UIBarButtonItem alloc] initWithCustomView:btn_comment];
    
    
    item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSDictionary *dic = [resListArray objectAtIndex:indexPath.row];
    int fileType = [[dic objectForKey:@"type"] intValue];
    int isPublisher = [[dic objectForKey:@"isPublisher"] intValue];
    //文件夹
    if (fileType == 1) {
        if (isPublisher == 1) {
            [moreEditBar setItems:@[item_comment]];
        } else {
            [moreEditBar setItems:@[item_resave,item_flexible,item_comment]];
        }
    } else if (fileType == 2) {//文件
        if (isPublisher == 1) {
            [moreEditBar setItems:@[item_download,item_flexible,item_comment]];
        } else {
            [moreEditBar setItems:@[item_download,item_flexible,item_resave,item_flexible,item_comment]];
        }
        
    } else {//链接
        [moreEditBar setItems:@[item_comment]];
    }
    
}



#pragma mark - SCBSubJectDelegate

//请求主题动态返回
-(void)requestSubjectEventOfInfoSuccess:(NSDictionary *)diction
{
    if([diction objectForKey:@"result"])
    {
        [self doneLoadingTableViewData];
        self.dynamicArray = [self formatTableArray:[diction objectForKey:@"result"]];
        [self.tableView reloadData];
    }
}

-(NSMutableArray *)formatTableArray:(NSMutableArray *)tableA
{
    NSMutableArray *formatTableArray = [[NSMutableArray alloc] init];
    for (int i=0;i<tableA.count; i++) {
        NSDictionary *dict = [tableA objectAtIndex:i];
        NSDictionary *content = [NSString stringWithDictionS:[dict objectForKey:@"content"]];
        if(content && ![content isEqual:[NSNull null]])
        {
            [formatTableArray addObject:dict];
        }
    }
    return formatTableArray;
}

-(void)requestSubjectEventOfInfoFail:(NSDictionary *)diction
{
    
}

- (void)getSubjectInfoSuccess:(NSDictionary *)dic {
    [self doneLoadingTableViewData];
    infoDic = [NSDictionary dictionaryWithDictionary:dic];
    subjectInfoArray = [infoDic objectForKey:@"joinMember"];
    [self.tableView reloadData];
}

- (void)getSubjectInfoUnsuccess:(NSString *)error_info {
    
}

- (void)getResourceListunsccess:(NSString *)error_info {
    
}

- (void)getResourceListSuccess:(NSDictionary *)dic {
    
    [self doneLoadingTableViewData];
    resListArray = [dic objectForKey:@"list"];
    for (int i = 0; i < resListArray.count; i++) {
        NSDictionary *d = [resListArray objectAtIndex:i];
        [self getFileWithFileId:[d objectForKey:@"file_id"]];
        
    }
    if (resListArray.count<1) {
        if(self.nothingView == nil)
        {
            float boderHeigth = 20;
            float labelHeight = 40;
            float imageHeight = 100;
            CGRect nothingRect = CGRectMake(0, (self.tableView.bounds.size.height-(labelHeight+imageHeight+boderHeigth))/2-50, 320, labelHeight+imageHeight+boderHeigth);
            self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
            self.nothingView.backgroundColor = self.view.backgroundColor;
            [self.tableView addSubview:self.nothingView];
        }
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView notHiddenView];
        [self.nothingView.notingLabel setText:@"暂无文件"];
    }else
    {
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView hiddenView];
        [self.nothingView.notingLabel setText:@"暂无文件"];
    }

    [self.tableView reloadData];
    
}

//获取文件信息
- (void)getFileWithFileId:(NSString *)file_id {
    
    fileDic = nil;
    SCBFileManager *fm = [[SCBFileManager alloc] init];
    fm.delegate = self;
    [fm requestEntFileInfo:file_id];
}

#pragma mark - SCBFileManager delegate
- (void)getFileEntInfo:(NSDictionary *)dictionary {
    fileDic = dictionary;
    if (dictionary) {
        [fileArray addObject:dictionary];
    }
}


//评论页面
- (void)goToCommentListView:(id)sender {
    [self hideSingleBar];
    NSDictionary *dic = [resListArray objectAtIndex:selectedIndexPath.row];
    IPSubJectDetailCommentViewController *s = [[IPSubJectDetailCommentViewController alloc] init];
    s.parentDic = dic;
    //s.title = [dic objectForKey:@"file_name"];
    s.parent_indexpath = selectedIndexPath;
    NSString *subject_id = [self.baseDiction objectForKey:@"subject_id"];
    s.subjectId = subject_id;
    [self.navigationController pushViewController:s animated:YES];
}


-(void)hideSingleBar
{
    [singleBg setHidden:YES];
    [moreEditBar setHidden:YES];
    if (selectedIndexPath) {
        
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        UIButton *button=(UIButton *) cell.accessoryView;
        [button setSelected:NO];
    }
}

//下载
- (void)downloadAction {
    [self hideSingleBar];
    NSDictionary *fiel_dic = nil;
    NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
    int file_id = [[d objectForKey:@"file_id"] intValue];
    for (int i = 0; i < fileArray.count; i++) {
        NSDictionary *d2 = [fileArray objectAtIndex:i];
        int file_id2 = [[d2 objectForKey:@"fid"] intValue];
        if (file_id == file_id2) {
            fiel_dic = d2;
        }
    }
    NSString *fileId = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"fid"]];
    NSString *thumb = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"fthumb"]];
    if([thumb length]==0)
    {
        thumb = @"0";
    }
    NSString *name = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"fname"]];
    NSInteger fsize = [[fiel_dic objectForKey:@"fsize"] integerValue];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    DownList *list = [[DownList alloc] init];
    list.d_name = name;
    list.d_downSize = fsize;
    list.d_thumbUrl = thumb;
    list.d_file_id = fileId;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *todayDate = [NSDate date];
    list.d_datetime = [dateFormatter stringFromDate:todayDate];
    list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    [tableArray addObject:list];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = self;
    [delegate.downmange addDownLists:tableArray];
    
}

-(void)downFileSuccess:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud = nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载完成",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
    });
}

-(void)downFileunSuccess:(NSString *)name
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud = nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载失败",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
}


//转存
- (void)resaveAction {
    [self hideSingleBar];
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择转存的位置";
    flvc.delegate=self;
    flvc.type=kTypeCopy;
    NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
    flvc.targetsArray=[NSArray arrayWithObject:[d objectForKey:@"file_id"]];
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
}

//转存delegate
-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid
{
    NSDictionary *fiel_dic = nil;
    NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
    int file_id = [[d objectForKey:@"file_id"] intValue];
    for (int i = 0; i < fileArray.count; i++) {
        NSDictionary *d2 = [fileArray objectAtIndex:i];
        int file_id2 = [[d2 objectForKey:@"fid"] intValue];
        if (file_id == file_id2) {
            fiel_dic = d2;
        }
    }
    
    SCBFileManager *fm_move = [[SCBFileManager alloc] init];
    fm_move.delegate=self;
    
    NSString *fid=[fiel_dic objectForKey:@"fid"];
    NSString *pid = [fiel_dic objectForKey:@"spid"];
    
    [fm_move resaveFileIDs:@[fid] toPID:f_id  sID:pid];
    
}

//转存成功
-(void)operateUpdate
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:2.0f];
}
//转存失败
-(void)showMessage:(NSString *)error
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:2.0f];
}

-(void)Unsucess:(NSString *)strError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    if (strError==nil||[strError isEqualToString:@""]) {
        self.hud.labelText=@"操作失败";
    }else
    {
        self.hud.labelText=strError;
    }
    
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:2.0f];
}


//预览
- (void)lookAction {
    [self hideSingleBar];
    NSDictionary *fiel_dic = nil;
    NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
    int file_id = [[d objectForKey:@"file_id"] intValue];
    for (int i = 0; i < fileArray.count; i++) {
        NSDictionary *d2 = [fileArray objectAtIndex:i];
        int file_id2 = [[d2 objectForKey:@"fid"] intValue];
        if (file_id == file_id2) {
            fiel_dic = d2;
        }
    }
    
    //picture
    if (fiel_dic) {
        NSString *fmine = [fiel_dic objectForKey:@"fmime"];
        NSString *fmime_=[fmine lowercaseString];
        
        NSInteger fsize = [[fiel_dic objectForKey:@"fsize"] integerValue];
        NSString *name = [fiel_dic objectForKey:@"fname"];
        NSString *thumb = [fiel_dic objectForKey:@"fthumb"];
        NSString *fid = [fiel_dic objectForKey:@"fid"];
        if([fmime_ isEqualToString:@"png"]||[fmime_ isEqualToString:@"jpg"]|| [fmime_ isEqualToString:@"jpeg"]|| [fmime_ isEqualToString:@"bmp"]||[fmime_ isEqualToString:@"gif"]) {
            DownList *list = [[DownList alloc] init];
            list.d_file_id = fid;
            list.d_thumbUrl = thumb;
            if([list.d_thumbUrl length]==0)
            {
                list.d_thumbUrl = @"0";
            }
            list.d_name = name;
            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
            list.d_downSize = fsize;
            
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            [tableArray addObject:list];
            if([tableArray count]>0)
            {
                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
//                look.isHaveDownload=YES;
                [look setTableArray:tableArray];
                [self presentViewController:look animated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }];
            }
        } else {
            NSString *documentDir = [YNFunctions getFMCachePath];
            NSArray *array=[name componentsSeparatedByString:@"/"];
            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
            [NSString CreatePath:createPath];
            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                browser.dataSource=browser;
                browser.delegate=browser;
                browser.title=name;
                browser.filePath=savedPath;
                browser.fileName=name;
                browser.currentPreviewItemIndex=0;
                [self presentViewController:browser animated:YES completion:nil];
            } else {
                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                
                NSArray *values = [NSArray arrayWithObjects:name,fid,[fiel_dic objectForKey:@"fname"], nil];
                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                otherBrowser.dataDic=d;
                otherBrowser.title=name;
                [self presentViewController:otherBrowser animated:YES completion:nil];
            }
        }
        
    } else {
        //[self getFileWithFileId:file_id];
    }
    
}

//访问
- (void)visitAction {
    [self hideSingleBar];
    NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
    NSString *urlString = [d objectForKey:@"details"];
    if (![urlString hasPrefix:@"http://"]) {
        urlString = [NSString stringWithFormat:@"http://%@",urlString];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

//删除
- (void)deleteAction {
    
}

//取消共享
- (void)cancelShare {
    
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    if ([resListArray count] > 0)
    {
        NSDictionary *fiel_dic = nil;
        NSDictionary *d = [resListArray objectAtIndex:selectedIndexPath.row];
        int file_id = [[d objectForKey:@"file_id"] intValue];
        for (int i = 0; i < fileArray.count; i++) {
            NSDictionary *d2 = [fileArray objectAtIndex:i];
            int file_id2 = [[d2 objectForKey:@"fid"] intValue];
            if (file_id == file_id2) {
                fiel_dic = d2;
            }
        }
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if (fiel_dic==nil) {
                return;
            }
            NSString *f_mine = [fiel_dic objectForKey:@"fmime"];
            if ([f_mine isEqual:[NSNull null]]) {
                return;
            }
            NSString *fmime=[[fiel_dic objectForKey:@"fmime"] lowercaseString];
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"]){
                
                NSString *compressaddr=[fiel_dic objectForKey:@"fthumb"];
                assert(compressaddr!=nil);
                compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
                NSString *path=[YNFunctions getIconCachePath];
                path=[path stringByAppendingPathComponent:compressaddr];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    NSLog(@"将要下载的文件：%@",path);
                    [self startIconDownload:fiel_dic forIndexPath:indexPath];
                }
            }
        }
    }
}

//icon下载
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imageDownloadsInProgress) {
        self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    }
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    
}

-(void)selectedCell:(NSDictionary *)dictioinary
{
    NSInteger type = [[dictioinary objectForKey:@"type"] integerValue];
    if(type == 0 || type == 1 || type == 2 || type == 3 || type == 4 || type == 5)
    {
        //调用动态详细页面
        IPSubJectNewDetailViewController *subjectNewDetailview = [[IPSubJectNewDetailViewController alloc] init];
        subjectNewDetailview.isPublish = ![[dictioinary objectForKey:@"auth"] boolValue];
        [subjectNewDetailview setDictionary:dictioinary];
        [self.navigationController pushViewController:subjectNewDetailview animated:YES];
    }
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    if (self.sjmType == SJMTypeDynamic) {
        [self requestSubjectEventOfInfo];
    } else if (self.sjmType == SJMTypeResources) {
        [self getResourceList];
    }else {
        [self getSubjectRightInfo];
    }
    
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
		[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self doneLoadingTableViewData];
}

@end
