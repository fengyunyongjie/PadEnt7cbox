//
//  FileListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "FileListViewController.h"
#import "SCBFileManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "SelectFileListViewController.h"
#import "MainViewController.h"
#import "SendEmailViewController.h"
#import "DownManager.h"
#import "AppDelegate.h"
#import "DownList.h"
#import "PhotoLookViewController.h"
#import "OtherBrowserViewController.h"
#import "SCBSession.h"
#import "CustomViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MyTabBarViewController.h"
#import "YNNavigationController.h"
#import "SharedEmailViewController.h"
#import "DetailViewController.h"
#import "MySplitViewController.h"
#import "PartitionViewController.h"
#import "OpenFileViewController.h"
#import "SCBEmailManager.h"
#import "ShareToSubjectViewController.h"
#import "NSString+Format.h"
#import "SubjectDetailTabBarController.h"

#define KCOVERTag 888

typedef enum{
    kAlertTagDeleteOne,
    kAlertTagDeleteMore,
    kAlertTagRename,
    kAlertTagNewFinder,
    kAlertTagMailAddr,
}AlertTag;
typedef enum{
    kActionSheetTagShare,
    kActionSheetTagMore,
    kActionSheetTagDeleteOne,
    kActionSheetTagDeleteMore,
    kActionSheetTagPhoto,
    kActionSheetTagSend,
    kActionSheetTagSendHasDir,
    kActionSheetTagSort,
    kActionSheetTagUpload,
    kActionSheetTagSendSubject,
    kActionSheetTagSendSubjectHasDir,
}ActionSheetTag;

@interface FileListViewController ()<SCBFileManagerDelegate,IconDownloaderDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,SCBEmailManagerDelegate,MFMessageComposeViewControllerDelegate>
{
    UIBarButtonItem *item_send,*item_download;
    BOOL isSelectedDir;
}
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) MBProgressHUD *hud;

@property (strong,nonatomic) UIToolbar *singleEditBar;
@property (strong,nonatomic) UIToolbar *moreEditBar;
@property (strong,nonatomic) UIControl *menuView;
@property (strong,nonatomic) UIControl *singleBg;
@property (strong,nonatomic) UIBarButtonItem *titleRightBtn;
@property (strong,nonatomic) NSArray *rightItems;
@property (strong,nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong,nonatomic) UILabel * notingLabel;
@property (strong,nonatomic) UIView *nothingView;
@property (strong,nonatomic) NSArray *selectedFIDs;
@property (strong,nonatomic) UIPopoverController *activityPopover;
@end

@implementation FileListViewController
@synthesize dataDic,listArray,finderArray,selectArray,f_id,fcmd,spid,roletype,flType,imageDownloadsInProgress,tableView,selectedIndexPath,tableViewSelectedFid,isNotRequestUpdate;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
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
- (void)viewWillAppear:(BOOL)animated
{
    if(self.tabBarController.tabBar.hidden&&!self.tableView.isEditing)
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
    if(self.moreEditBar.hidden && self.tableView.isEditing)
    {
        [self.moreEditBar setHidden:NO];
    }
    if (!self.tableView.isEditing) {
        if(isNotRequestUpdate)
        {
            isNotRequestUpdate = NO;
        }
        else
        {
            [self updateFileList];
        }
    }
    
//    CGRect r=self.view.frame;
//    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
//    self.view.frame=r;
    
    BOOL isHideTabBar = NO;
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self hideMenu];
//    if (self.activityViewController) {
//        [self.activityViewController dismissViewControllerAnimated:NO completion:nil];
//    }
}
- (void)viewDidAppear:(BOOL)animated
{
}
- (void)viewDidLayoutSubviews
{
    if (self.shareType==kShareTypeShare) {
        int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
        [self.tableView setFrame:self.view.frame];
        
        CGRect notLabel_rect = self.notingLabel.frame;
            notLabel_rect.origin.y = (self.view.frame.size.height-40)/2;
        [self.notingLabel setFrame:notLabel_rect];
        
        CGRect noting_rect = self.view.frame;
        [self.nothingView setFrame:noting_rect];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    tableViewSelectedTag = -1;
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    isSelectedDir=NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if(self.shareType!=kShareTypeShare)
    {
        NSMutableArray *items=[NSMutableArray array];
        UIButton*rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,40)];
        [rightButton1 setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
        [rightButton1 setBackgroundImage:[UIImage imageNamed:@"title_more_se.png"] forState:UIControlStateHighlighted];
        [rightButton1 addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton1];
        [items addObject:rightItem1];
        self.rightItems=items;
        self.navigationItem.rightBarButtonItems = items;
    }

    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.backBarButtonItem=backItem;
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self updateFileList];
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
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - 操作方法
- (void)updateFileList
{
    if (self.tableView.isEditing) {
        self.selectedFIDs=[self selectedIDs];
    }
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
//            if ([self.f_id intValue]==0) {
//                self.fcmd=[self.dataDic objectForKey:@"cmds"];
//            }
            self.fcmd=[self.dataDic objectForKey:@"cmds"];
            if (self.listArray) {
                [self.tableView reloadData];
            }
        }
    }
    if (self.listArray.count<=0) {
        if(self.notingLabel == nil)
        {
            UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientation];
            CGRect noting_rect = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                noting_rect.size.height = 768-56-64;
            }
            else
            {
                noting_rect.size.height = 1024-56-64;
            }
            self.nothingView=[[UIView alloc] initWithFrame:noting_rect];
            [self.nothingView setBackgroundColor:[UIColor whiteColor]];
            [self.tableView addSubview:self.nothingView];
            
            CGRect notLabel_rect = CGRectMake(0, 300, 320, 40);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                notLabel_rect.origin.y = (768-56-64-40)/2;
            }
            else
            {
                notLabel_rect.origin.y = (1024-56-64-40)/2;
            }
            self.notingLabel = [[UILabel alloc] initWithFrame:notLabel_rect];
            [self.notingLabel setTextColor:[UIColor grayColor]];
            [self.notingLabel setFont:[UIFont systemFontOfSize:18]];
            [self.notingLabel setTextAlignment:NSTextAlignmentCenter];
            [self.nothingView addSubview:self.notingLabel];
        }
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView setHidden:NO];
        [self.notingLabel setText:@"加载中,请稍等……"];
    }else
    {
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView setHidden:YES];
        [self.notingLabel setText:@"加载中,请稍等……"];
    }

    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    NSString *authModelID=self.roletype;
    if ([authModelID isEqualToString:@"1"]&&[self.f_id intValue]==0) {
        authModelID=@"0";
    }
    [self.fm openFinderWithID:self.f_id sID:self.spid authModelId:authModelID];
}
- (void)operateUpdate
{
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    NSString *authModelID=self.roletype;
    if ([authModelID isEqualToString:@"1"]&&[self.f_id intValue]==0) {
        authModelID=@"0";
    }
    [self.fm operateUpdateWithID:self.f_id sID:self.spid authModelId:authModelID];
}
-(void)handelSingleTap:(UITapGestureRecognizer*)gestureRecognizer{
    [self hideMenu];
    [self hideSingleBar];
}
-(void)hideMenu
{
    [self.menuView setHidden:YES];
}
-(void)hideSingleBar
{
    [self.singleBg setHidden:YES];
    [self.singleEditBar setHidden:YES];
    if (self.selectedIndexPath) {
        
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        UIButton *button=(UIButton *) cell.accessoryView;
        [button setSelected:NO];
    }
}
-(void)menuAction:(id)sender
{
    [self hideSingleBar];
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        self.menuView=nil;
    }
    if (!self.menuView) {
        int Height=1024;
        self.menuView =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, Height, Height)];
        //[self.menuView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        UIControl *grayView=[[UIControl alloc] initWithFrame:CGRectMake(0, 64, Height, Height)];
        [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        [grayView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:grayView];
        CGSize btnSize=CGSizeMake(320, 45);
        UIButton *btnNewFinder,*btnEdit,*btnSort,*btnUpload;
        UIColor *titleColor=[UIColor colorWithRed:83/255.0f green:113/255.0f blue:190/255.0f alpha:1];
        btnUpload=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)];
        [btnUpload setImage:[UIImage imageNamed:@"title_upload.png"] forState:UIControlStateHighlighted];
        [btnUpload setImage:[UIImage imageNamed:@"title_upload.png"] forState:UIControlStateNormal];
        [btnUpload setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
        [btnUpload setTitle:@"  上传" forState:UIControlStateNormal];
        [btnUpload setTitleColor:titleColor forState:UIControlStateNormal];
        [btnUpload setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnUpload addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnNewFinder=[[UIButton alloc] initWithFrame:CGRectMake(0, 1*btnSize.height, btnSize.width, btnSize.height)];
        [btnNewFinder setImage:[UIImage imageNamed:@"title_new.png"] forState:UIControlStateHighlighted];
        [btnNewFinder setImage:[UIImage imageNamed:@"title_new.png"] forState:UIControlStateNormal];
        [btnNewFinder setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
        [btnNewFinder setTitle:@"  新建文件夹" forState:UIControlStateNormal];
        [btnNewFinder setTitleColor:titleColor forState:UIControlStateNormal];
        [btnNewFinder setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnNewFinder addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
        
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 2*btnSize.height, btnSize.width, btnSize.height)];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
        [btnEdit setTitle:@"  编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:titleColor forState:UIControlStateNormal];
        [btnEdit setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnSort=[[UIButton alloc] initWithFrame:CGRectMake(0, 3*btnSize.height, btnSize.width, btnSize.height)];
        [btnSort setImage:[UIImage imageNamed:@"title_sort.png"] forState:UIControlStateHighlighted];
        [btnSort setImage:[UIImage imageNamed:@"title_sort.png"] forState:UIControlStateNormal];
        [btnSort setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
        [btnSort setTitle:@"  排序" forState:UIControlStateNormal];
        [btnSort setTitleColor:titleColor forState:UIControlStateNormal];
        [btnSort setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnSort addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventTouchUpInside];
        NSMutableArray *array=[NSMutableArray array];
        if ([self hasCmdInFcmd:@"upload"])
        {
            if ([self.roletype isEqualToString:@"2"]) {
                [array addObject:btnUpload];
            }else
            {
                if([self.f_id intValue]!=0)
                {
                    [array addObject:btnUpload];
                }
            }
        }
        if ([self hasCmdInFcmd:@"mkdir"]) {
            [array addObject:btnNewFinder];
        }
        if ([self hasCmdInFcmd:@"publiclink"]||[self hasCmdInFcmd:@"download"]||[self hasCmdInFcmd:@"copy"]||[self hasCmdInFcmd:@"move"]||[self hasCmdInFcmd:@"del"]) {
            [array addObject:btnEdit];
        }
        [array addObject:btnSort];
        for (int i=0; i<array.count; i++) {
            UIButton *btn=[array objectAtIndex:i];
            btn.frame= CGRectMake(0, i*btnSize.height+64, btnSize.width, btnSize.height);
            if (i==0) {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
            }else if(i==array.count-1)
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_3.png"] forState:UIControlStateNormal];
            }else
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
            }
            [self.menuView addSubview:btn];
        }
//        [self.menuView addSubview:btnUpload];
//        [self.menuView addSubview:btnNewFinder];
//        [self.menuView addSubview:btnEdit];
//        [self.menuView addSubview:btnSort];
        
        [self.menuView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarController.view.superview addSubview:self.menuView];
//        if ([self.roletype isEqualToString:@"1"]||[self.roletype isEqualToString:@"2"])
//        {
//            [bgView setImage:[UIImage imageNamed:@"title_menu2.png"]];
//            //可提交 或 可查看
//            [btnNewFinder setHidden:YES];
//            [bgView setFrame:CGRectMake(40*scale, 0, 80*scale, 47*scale)];
//        }else
//        {
//            [bgView setFrame:CGRectMake(0, 0, 120*scale, 47*scale)];
//        }
        [self.menuView setHidden:YES];
    }
    [self.menuView setHidden:!self.menuView.hidden];
}
-(BOOL)hasCmdInFcmd:(NSString *)cmd
{
//  mkdir：新建文件夹
//	authz：权限管理
//	download：下载
//	ren：重命名
//	del：删除
//	copy：复制
//	move：移动
//  upload:上传
//	edit：编辑
//	preview：预览
//	publiclink：外链发送
//  clear:清空
//	restore：还原
//  remove:回收站删除
    if([self.roletype isEqualToString:@"2"])
    {
        return YES;
    }
    if (!self.fcmd||[self.fcmd isEqualToString:@""]||!cmd) {
        return NO;
    }
    NSArray *array=[self.fcmd componentsSeparatedByString:@","];
    for (NSString *str in array) {
        if ([str isEqualToString:cmd]) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)hasCmd:(NSString *) cmd InFcmd:(NSString *)fcmd
{
    //  mkdir：新建文件夹
    //	authz：权限管理
    //	download：下载
    //	ren：重命名
    //	del：删除
    //	copy：复制
    //	move：移动
    //  upload:上传
    //	edit：编辑
    //	preview：预览
    //	publiclink：外链发送
    //  clear:清空
    //	restore：还原
    //  remove:回收站删除
    if([self.roletype isEqualToString:@"2"])
    {
        return YES;
    }
    if (!fcmd||[fcmd isEqualToString:@""]||!cmd) {
        return NO;
    }
    NSArray *array=[fcmd componentsSeparatedByString:@","];
    for (NSString *str in array) {
        if ([str isEqualToString:cmd]) {
            return YES;
        }
    }
    return NO;
}
-(void)uploadAction:(id)sender
{
    [self hideMenu];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片并上传",@"从本机相册选择", nil];
    [actionSheet setTag:kActionSheetTagUpload];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
//    app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.old_file_url];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.f_id  = self.f_id;
//    imagePickerController.f_name = self.title;
//    imagePickerController.space_id = self.spid;
//    [imagePickerController requestFileDetail];
//    [imagePickerController setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:imagePickerController animated:NO];
}

-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.uploadmanage changeUpload:array_ changeDeviceName:device_name changeFileId:f_id changeSpaceId:s_id];
}
-(NSArray *)selectedIndexPaths
{
    NSArray *retVal=nil;
    retVal=self.tableView.indexPathsForSelectedRows;
    return retVal;
}
-(BOOL)isHasSelectFile
{
    BOOL result=NO;
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexpath.row];
        NSString *fisdir=[dic objectForKey:@"fisdir"];
        if (![fisdir isEqualToString:@"0"]) {
            result=YES;
        }
        NSString *fid=[dic objectForKey:@"fid"];
        [ids addObject:fid];
    }
    return result;
}
-(NSArray *)selectedIDs
{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexpath.row];
        NSString *fid=[dic objectForKey:@"fid"];
        [ids addObject:fid];
    }
    return ids;
}
-(void)newFinder:(id)sender
{
    [self hideMenu];
    NSLog(@"点击新建文件夹");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //[[alert textFieldAtIndex:0] setText:@"新建文件夹"];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [alert setTag:kAlertTagNewFinder];
    [alert show];
}
-(void)selectAllCell:(id)sender
{
    if (self.listArray) {
        BOOL canSend=YES;
        BOOL canDown=YES;
        for (int i=0; i<self.listArray.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                //选中了文件夹，禁用分享;
                //            UIBarButtonItem *item=(UIBarButtonItem *)[self.moreEditBar.items objectAtIndex:0];
                //            [item setEnabled:NO];
//                canSend=NO;
                canDown=NO;
            }
        }
//        [item_send setEnabled:canSend];
        [item_download setEnabled:canDown];
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(deselectAllCell:)]];
    
    BOOL isDis=NO;
    for (NSIndexPath *newIP in [self selectedIndexPaths]) {
        NSDictionary *dic=[self.listArray objectAtIndex:newIP.row];
        NSString *fisdir=[dic objectForKey:@"fisdir"];
        if ([fisdir isEqualToString:@"0"]) {
            //选中了文件夹，禁用分享;
            isDis=YES;
            break;
        }
    }
    //UIBarButtonItem *item=(UIBarButtonItem *)[self.moreEditBar.items objectAtIndex:0];
    if (isDis) {
        if([self.roletype isEqualToString:@"1"])
        {
            [item_send setEnabled:NO];
        }else if([self selectedIndexPaths].count>1)
        {
            [item_send setEnabled:NO];
        }
        isSelectedDir=YES;
        [item_download setEnabled:NO];
    }else
    {
        if([self.roletype isEqualToString:@"1"])
        {
            [item_send setEnabled:YES];
        }
        [item_send setEnabled:YES];
        isSelectedDir=NO;
        [item_download setEnabled:YES];
    }

}
-(void)deselectAllCell:(id)sender
{
    if (self.listArray) {
        for (int i=0; i<self.listArray.count; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
        }
    }
    [item_send setEnabled:YES];
    [item_download setEnabled:YES];
//    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
//    }else
//    {
//        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,71,33)];
//        [button setTitle:@"全选" forState:UIControlStateNormal];
//        button.titleLabel.font=[UIFont systemFontOfSize:12];
//        [button addTarget:self action:@selector(selectAllCell:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
}
-(void)editFinished;
{
    if (self.tableView.isEditing) {
        [self editAction:nil];
    }
}
-(void)editAction:(id)sender
{
    //文件列表为空时你，编辑按钮无效！
    if (!self.tableView.isEditing&&self.listArray.count==0) {
        return;
    }
    
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    
    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"self.tableview.frame:%@",NSStringFromCGRect(self.tableView.frame));
    
    
    [self hideMenu];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        isSelectedDir=NO;
    }
    BOOL isHideTabBar=self.tableView.editing;
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    //isHideTabBar=!isHideTabBar;
    [self.tabBarController.tabBar setHidden:isHideTabBar];
    
    //隐藏返回按钮
    if (isHideTabBar) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItems:@[]];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    }else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.navigationItem setLeftBarButtonItem:nil];
        }else
        {
            [self.navigationItem setLeftBarButtonItem:self.backBarButtonItem];
        }
        [self.navigationItem setRightBarButtonItems:self.rightItems];
        if(self.moreEditBar)
        {
            [self.moreEditBar setHidden:YES];
        }
    }
    
    if (!self.moreEditBar) {
        self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-56, 320, 56)];
        [self.moreEditBar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.moreEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.moreEditBar setTintColor:[UIColor blueColor]];
        }
        [self.tabBarController.view addSubview:self.moreEditBar];
        //发送 删除 提交 移动 全选
        UIButton *btn_send, *btn_commit ,*btn_del ,*btn_move,*btn_download ,*btn_resave ,*btn_copy;
        UIBarButtonItem *item_commit ,*item_del ,*item_move, *item_resave,*item_flexible, *item_copy;
        int btnWidth=40;
        btn_send =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_send setImage:[UIImage imageNamed:@"share_nor.png"] forState:UIControlStateNormal];
        [btn_send setImage:[UIImage imageNamed:@"share_se.png"] forState:UIControlStateHighlighted];
        [btn_send setImage:[UIImage imageNamed:@"share_locked"] forState:UIControlStateDisabled];
        [btn_send addTarget:self action:@selector(toSend:) forControlEvents:UIControlEventTouchUpInside];
        item_send=[[UIBarButtonItem alloc] initWithCustomView:btn_send];
        
        btn_commit =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_commit setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
        [btn_commit setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
        [btn_commit addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
        item_commit=[[UIBarButtonItem alloc] initWithCustomView:btn_commit];
        
        btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_resave setImage:[UIImage imageNamed:@"zc_nor.png"] forState:UIControlStateNormal];
        [btn_resave setImage:[UIImage imageNamed:@"zc_se.png"] forState:UIControlStateHighlighted];
        [btn_resave addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
        item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
        
        btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
        [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
        [btn_del addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
        
        btn_move =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_move setImage:[UIImage imageNamed:@"move_nor.png"] forState:UIControlStateNormal];
        [btn_move setImage:[UIImage imageNamed:@"move_se.png"] forState:UIControlStateHighlighted];
        [btn_move addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
        item_move=[[UIBarButtonItem alloc] initWithCustomView:btn_move];
        
        btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
        [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
        [btn_download addTarget:self action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
        item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
        
        btn_copy =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
        [btn_copy setImage:[UIImage imageNamed:@"copy_nor.png"] forState:UIControlStateNormal];
        [btn_copy setImage:[UIImage imageNamed:@"copy_se.png"] forState:UIControlStateHighlighted];
        [btn_copy addTarget:self action:@selector(toCopy:) forControlEvents:UIControlEventTouchUpInside];
        item_copy=[[UIBarButtonItem alloc] initWithCustomView:btn_copy];
        
        item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //    for (NSString *str in buttons) {
        //        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        //        [button setImage:[UIImage imageNamed:@"rename_nor.png"] forState:UIControlStateNormal];
        //        [button setImage:[UIImage imageNamed:@"rename_se.png"] forState:UIControlStateHighlighted];
        //        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:nil action:nil];
        //        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithCustomView:button];
        //        [barItems addObject:item1];
        //    }
        
        if ([self.roletype isEqualToString:@"2"]) {
            //个人空间
            [self.moreEditBar setItems:@[item_send,item_flexible,item_download,item_flexible,item_copy,item_flexible,item_move,item_flexible,item_del]];
        }else
        {
            //管理员
            //[self.moreEditBar setItems:@[item_send,item_flexible,item_resave,item_flexible,item_move,item_flexible,item_download,item_flexible,item_del]];
            NSMutableArray *array=[NSMutableArray array];
            //[array addObject:item_flexible];

            if([self hasCmdInFcmd:@"publiclink"])
            {
                [array addObject:item_send];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"download"])
            {
                [array addObject:item_download];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"copy"])
            {
                [array addObject:item_copy];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"move"])
            {
                [array addObject:item_move];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"del"])
            {
                [array addObject:item_del];
                //[array addObject:item_flexible];
            }
            
            NSArray *theArray=nil;
            if (array.count>4) {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3],item_flexible,[array objectAtIndex:4]];
            }else if(array.count==1)
            {
                theArray=@[item_flexible,[array objectAtIndex:0],item_flexible];
            }else if(array.count==2)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1]];
            }
            else if(array.count==3)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2]];
            }
            else if(array.count==4)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3]];
            }
            [self.moreEditBar setItems:theArray];
        }
    }
    [self.moreEditBar setHidden:!isHideTabBar];
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}
-(void)sortAction:(id)sender
{
    [self hideMenu];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"排序" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"按时间排序",@"按名称排序",@"按大小排序", nil];
    [actionSheet setTag:kActionSheetTagSort];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
}
-(void)toMore:(id)sender
{
    [self hideSingleBar];
    if ([self.roletype isEqualToString:@"2"]) {
        //个人空间
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"更多" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制",@"移动",@"重命名", nil];
        [actionSheet setTag:kActionSheetTagMore];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.action_array addObject:actionSheet];
    }else
    {
        //企业空间;
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"更多" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制",@"移动",@"重命名", nil];
        [actionSheet setTag:kActionSheetTagMore];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.action_array addObject:actionSheet];
    }
}
-(void)toRename:(id)sender
{
    [self hideSingleBar];
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *name=[dic objectForKey:@"fname"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:name];
    [alert setTag:kAlertTagRename];
    [alert show];
}
-(void)toDelete:(id)sender
{
    [self hideSingleBar];
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }

    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //    [alertView show];
    //    [alertView setTag:kAlertTagDeleteOne];
    //    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTagDeleteOne];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
}
-(void)toCommitOrResave:(id)sender
{
    [self hideSingleBar];
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }
    
    NSLog(@"提交或转存！！！");
    if ([self.roletype isEqualToString:@"9999"]) {
        NSLog(@"提交");
        MainViewController *flvc=[[MainViewController alloc] init];
        flvc.title=@"选择提交的位置";
        flvc.delegate=self;
        flvc.type=kTypeCommit;
        YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        [self presentViewController:nav animated:YES completion:nil];

    }else
    {
        NSLog(@"转存");
        MainViewController *flvc=[[MainViewController alloc] init];
        flvc.title=@"选择转存的位置";
        flvc.delegate=self;
        flvc.type=kTypeResave;
        YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        [self presentViewController:nav animated:YES completion:nil];
    }
}
//内部分享
-(void)qiyeShared
{
    SharedEmailViewController *sevc=[[SharedEmailViewController alloc] init];
    sevc.title=@"新邮件";
    sevc.fids=[NSMutableArray arrayWithArray:self.selectedFids];
    sevc.fileArray=[NSMutableArray arrayWithArray:self.selectedFiles];
    sevc.tyle=kTypeShareIn;
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:sevc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
    [self editFinished];
}
//发布到专题
- (void)publishToSubject {
    
    ShareToSubjectViewController *shareViewController = [[ShareToSubjectViewController alloc] init];
    NSDictionary *dic = [self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fisdir = [dic objectForKey:@"fisdir"];
    shareViewController.dataDic=dic;
    shareViewController.fisdir=fisdir;
    shareViewController.parentSelectedIds=self.selectedFids;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:shareViewController];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    nav.modalPresentationStyle=UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)emailLinkShared
{
    SharedEmailViewController *sevc=[[SharedEmailViewController alloc] init];
    sevc.title=@"新邮件";
    sevc.fids=[NSMutableArray arrayWithArray:self.selectedFids];
    sevc.fileArray=[NSMutableArray arrayWithArray:self.selectedFiles];
    sevc.tyle=kTypeShareEx;
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:sevc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
    [self editFinished];
}
-(void)createLink
{
    SCBEmailManager *em=[[SCBEmailManager alloc] init];
    [em setDelegate:self];
    [em createLinkWithFids:self.selectedFids];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在生成链接...";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
}
-(void)toSend:(id)sender
{
    [self hideSingleBar];
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];

            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }else if(array.count>50)
        {
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"一次最多只能分享50个文件" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [av setTag:234];
            [av show];
            return;
        }
    }
    
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    SharedEmailViewController *sevc=[[SharedEmailViewController alloc] init];
    sevc.title=@"新邮件";
    if (self.tableView.isEditing) {
        sevc.fids=[self selectedIDs];
        NSMutableArray *fileDatas=[NSMutableArray array];
        NSArray *indexs=[self selectedIndexPaths];
        for (NSIndexPath *indexpath in indexs) {
            NSDictionary *dic=[self.listArray objectAtIndex:indexpath.row];
            [fileDatas addObject:dic];
        }
        sevc.fileArray=fileDatas;
        self.selectedFids=[self selectedIDs];
        self.selectedFiles=fileDatas;
    }else
    {
        sevc.fids=@[fid];
        sevc.fileArray=@[dic];
        self.selectedFids=@[fid];
        self.selectedFiles=@[dic];
    }
    
    if (self.tableView.isEditing) {
        if (isSelectedDir) {
            goto hasDirSend;
        }else
        {
            goto noDirSend;
        }
    }else
    {
        NSString *fisdir=[dic objectForKey:@"fisdir"];
        if ([fisdir isEqualToString:@"0"]) {
            goto hasDirSend;
        }else
        {
            goto noDirSend;
        }
    }
hasDirSend:
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"选择分享方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"邮件分享",@"短信分享",@"复制链接",@"其他分享",nil];
        [actionSheet setTag:kActionSheetTagSendHasDir];
        if([self.roletype isEqualToString:@"2"])
        {
            actionSheet=[[UIActionSheet alloc]  initWithTitle:@"选择分享方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"发布到专题",@"邮件分享",@"短信分享",@"复制链接",@"其他分享",nil];
            [actionSheet setTag:kActionSheetTagSendSubjectHasDir];
        }
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.action_array addObject:actionSheet];
        return;
    }
noDirSend:
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"选择分享方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"内部分享",@"邮件分享",@"短信分享",@"复制链接",@"其他分享",nil];
        [actionSheet setTag:kActionSheetTagSend];
        if([self.roletype isEqualToString:@"2"])
        {
            actionSheet=[[UIActionSheet alloc]  initWithTitle:@"选择分享方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"发布到专题",@"内部分享",@"邮件分享",@"短信分享",@"复制链接",@"其他分享",nil];
            [actionSheet setTag:kActionSheetTagSendSubject];
        }
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.action_array addObject:actionSheet];
        return;
    }
}
-(void)toCopy:(id)sender
{
    
    [self hideSingleBar];
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }
    
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    NSString *fisdir=[dic objectForKey:@"fisdir"];
    
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择复制的位置";
    flvc.delegate=self;
    flvc.type=kTypeCopy;
    if (self.tableView.isEditing) {
        flvc.targetsArray=[self selectedIDs];
        flvc.isHasSelectFile=[self isHasSelectFile];
    }else
    {
        flvc.targetsArray=@[fid];
        flvc.isHasSelectFile=![fisdir isEqualToString:@"0"];
    }
//    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
//    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
//    [nav.navigationBar setTintColor:[UIColor whiteColor]];
//    [self presentViewController:nav animated:YES completion:nil];
    [self.tabBarController.tabBar setHidden:YES];
    [self.moreEditBar setHidden:YES];
    [self.navigationController pushViewController:flvc animated:YES];
}
-(void)toMove:(id)sender
{

    [self hideSingleBar];
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }

    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    NSString *fisdir=[dic objectForKey:@"fisdir"];

    
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择移动的位置";
    flvc.delegate=self;
    flvc.type=kTypeMove;
    if (self.tableView.isEditing) {
        flvc.targetsArray=[self selectedIDs];
        flvc.isHasSelectFile=[self isHasSelectFile];
    }else
    {
        flvc.targetsArray=@[fid];
        flvc.isHasSelectFile=![fisdir isEqualToString:@"0"];
    }
//    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
//    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
//    [nav.navigationBar setTintColor:[UIColor whiteColor]];
//    [self presentViewController:nav animated:YES completion:nil];
    [self.tabBarController.tabBar setHidden:YES];
    [self.moreEditBar setHidden:YES];
    [self.navigationController pushViewController:flvc animated:YES];
}
-(void)toDownload:(id)sender
{
    [self hideSingleBar];
    if (self.tableView.isEditing) {
        NSArray *selectArray=[self selectedIndexPaths];
        for (NSIndexPath *indexPath in selectArray) {
            NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
            BOOL isDir=[[dic objectForKey:@"fisdir"] boolValue];
            if (!isDir) {
                if (self.hud)
                {
                    [self.hud removeFromSuperview];
                }
                self.hud=nil;
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
                [appDelegate.window addSubview:self.hud];
                [self.hud show:NO];
                self.hud.labelText=@"不能下载文件夹";
                self.hud.mode=MBProgressHUDModeText;
                self.hud.margin=10.f;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:1.0f];
                return;
            }
        }
        if (selectArray.count==0) {
            if (self.hud)
            {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
        NSMutableArray *tableArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in selectArray) {
            NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
            NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
            NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"fthumb"]];
            if([thumb length]==0)
            {
                thumb = @"0";
            }
            NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
            NSInteger fsize = [[dic objectForKey:@"fsize"] integerValue];
            
            DownList *list = [[DownList alloc] init];
            list.d_name = name;
            list.d_downSize = fsize;
            list.d_thumbUrl = thumb;
            list.d_file_id = file_id;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *todayDate = [NSDate date];
            list.d_datetime = [dateFormatter stringFromDate:todayDate];
            list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
            [tableArray addObject:list];
        }
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.downmange addDownLists:tableArray];
        [self editFinished];
    }else
    {
        NSLog(@"下载");
        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
        BOOL isDir = [[dic objectForKey:@"fisdir"] boolValue];
        if(!isDir)
        {
            if (self.hud)
            {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"不能下载文件夹";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
        NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
        NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"fthumb"]];
        if([thumb length]==0)
        {
            thumb = @"0";
        }
        NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
        NSInteger fsize = [[dic objectForKey:@"fsize"] integerValue];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *tableArray = [[NSMutableArray alloc] init];
        DownList *list = [[DownList alloc] init];
        list.d_name = name;
        list.d_downSize = fsize;
        list.d_thumbUrl = thumb;
        list.d_file_id = file_id;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *todayDate = [NSDate date];
        list.d_datetime = [dateFormatter stringFromDate:todayDate];
        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        [tableArray addObject:list];
        [delegate.downmange addDownLists:tableArray];
    }
}
-(void)commitFileToID:(NSString *)f_id sID:(NSString *)s_pid
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    if (self.tableView.isEditing) {
        [self.fm_move commitFileIDs:[self selectedIDs] toPID:f_id sID:s_pid];
    }else
    {
        [self.fm_move commitFileIDs:@[fid] toPID:f_id sID:s_pid];
    }
    [self editFinished];

}
-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid;
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    if (self.tableView.isEditing) {
        [self.fm_move resaveFileIDs:[self selectedIDs] toPID:f_id sID:spid];
    }else
    {
        [self.fm_move resaveFileIDs:@[fid] toPID:f_id sID:spid];
    }
   [self editFinished];
}
-(void)moveFileToID:(NSString *)f_id spid:(NSString *)spid;
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    if (self.tableView.isEditing) {
        [self.fm_move moveFileIDs:[self selectedIDs] toPID:f_id sID:spid];
    }else
    {
        [self.fm_move moveFileIDs:@[fid] toPID:f_id sID:spid];
    }
    [self editFinished];
}
-(void)copyFileToID:(NSString *)f_id spid:(NSString *)spid;
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    if (self.tableView.isEditing) {
        [self.fm_move resaveFileIDs:[self selectedIDs] toPID:f_id sID:spid];
    }else
    {
        [self.fm_move resaveFileIDs:@[fid] toPID:f_id sID:spid];
    }
    [self editFinished];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
        if (self.listArray.count>0) {
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        }else
        {
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        return self.listArray.count;
    }
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        NSString *versionWithoutRotation = @"7.0";
        BOOL noRotationNeeded = ([versionWithoutRotation compare:osVersion options:NSNumericSearch] != NSOrderedDescending);
        if(self.shareType==kShareTypeShare)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        else if(noRotationNeeded) {
            cell.accessoryType=UITableViewCellAccessoryDetailButton;
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        }
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(80, 5, 200, 21)];
        UILabel *detailTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 21)];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:detailTextLabel];
        imageView.tag=1;
        textLabel.tag=2;
        detailTextLabel.tag=3;
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [detailTextLabel setTextColor:[UIColor grayColor]];
        
        UIView *tagView = [cell viewWithTag:KCOVERTag];
        if(tagView == nil)
        {
            tagView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ico_CoverF.png"]];
            CGRect rect = CGRectMake(53, 40, 15, 15);
            [tagView setFrame:rect];
            [tagView setTag:KCOVERTag];
            [cell addSubview:tagView];
            [tagView setHidden:YES];
        }
    }
    
    //修改accessoryType
    UIButton *accessory=[[UIButton alloc] init];
    [accessory setFrame:CGRectMake(5, 5, 40, 40)];
    [accessory setTag:indexPath.row];
    [accessory setImage:[UIImage imageNamed:@"sel_nor@2x.png"] forState:UIControlStateNormal];
    [accessory setImage:[UIImage imageNamed:@"sel_se@2x.png"] forState:UIControlStateHighlighted];
    [accessory setImage:[UIImage imageNamed:@"sel_se@2x.png"] forState:UIControlStateSelected];
    [accessory  addTarget:self action:@selector(accessoryButtonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=accessory;
    if(self.shareType==kShareTypeShare)
    {
        cell.accessoryView=nil;
    }
    
    UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailTextLabel=(UILabel *)[cell.contentView viewWithTag:3];
    
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        NSString *fid_ = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
        if (self.tableView.isEditing) {
            BOOL isSelectThis=NO;
            for (NSString *str in [self selectedIDs]) {
                if ([str intValue]==[fid_ intValue]) {
                    isSelectThis=YES;
                    break;
                }
            }
            if (isSelectThis) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        if([fid_ isEqualToString:tableViewSelectedFid] && !self.tableView.editing)
        {
            [cell setSelected:YES animated:YES];
        }
        cell.imageView.transform=CGAffineTransformMakeScale(1.0f,1.0f);
        if (dic) {
            textLabel.text=[dic objectForKey:@"fname"];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                if([roletype isEqualToString:@"1"])
                {
                    imageView.image=[UIImage imageNamed:@"file_folder_comp@2x.png"];
                }
                else
                {
                    imageView.image=[UIImage imageNamed:@"file_folder.png"];
                }
            }else
            {
                imageView.image=[UIImage imageNamed:@"file_other.png"];
                NSString *filesize=[dic objectForKey:@"filesize"];
                if (filesize==nil) {
                    detailTextLabel.text=[NSString stringWithFormat:@"%@   %@",[dic objectForKey:@"fmodify"],[YNFunctions convertSize1:[dic objectForKey:@"fsize"]]];
                }else
                {
                    detailTextLabel.text=[NSString stringWithFormat:@"%@   %@",[dic objectForKey:@"fmodify"],filesize];
                }
                
                NSString *fname=[dic objectForKey:@"fname"];
                NSString *fmime=[[fname pathExtension] lowercaseString];
//                NSString *fmime=[[dic objectForKey:@"fmime"] lowercaseString];
                NSLog(@"fmime:%@",fmime);
                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"])
                {
                    NSString *fthumb=[dic objectForKey:@"fthumb"];
                    NSString *localThumbPath=[YNFunctions getIconCachePath];
                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                    NSLog(@"是否存在文件：%@",localThumbPath);
                    if ([self hasCmdInFcmd:@"preview"]&&[[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                        NSLog(@"存在文件：%@",localThumbPath);
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
//                        CGSize size=icon.size;
//                        if (size.width>size.height) {
//                            imageRect.size.height=size.height*(30.0f/imageRect.size.width);
//                            imageRect.origin.y+=(30-imageRect.size.height)/2;
//                        }else{
//                            imageRect.size.width=size.width*(30.0f/imageRect.size.height);
//                            imageRect.origin.x+=(30-imageRect.size.width)/2;
//                        }
                        [icon drawInRect:imageRect];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        imageView.image = image;
//                        CGRect r=cell.imageView.frame;
//                        r.size.width=r.size.height=30;
//                        cell.imageView.frame=r;
                        //cell.imageView.transform=CGAffineTransformMakeScale(0.5f,0.5f);

                    }else{
                        imageView.image = [UIImage imageNamed:@"file_pic.png"];
                        NSLog(@"将要下载的文件：%@",localThumbPath);
                        if ([self hasCmdInFcmd:@"preview"]) {
                            [self startIconDownload:dic forIndexPath:indexPath];
                        }
                    }
                }else if ([fmime isEqualToString:@"doc"]||
                          [fmime isEqualToString:@"docx"]||
                          [fmime isEqualToString:@"rtf"])
                {
                    imageView.image = [UIImage imageNamed:@"file_word.png"];
                }
                else if ([fmime isEqualToString:@"xls"]||
                         [fmime isEqualToString:@"xlsx"])
                {
                    imageView.image = [UIImage imageNamed:@"file_excel.png"];
                }else if ([fmime isEqualToString:@"mp3"])
                {
                    imageView.image = [UIImage imageNamed:@"file_music.png"];
                }else if ([fmime isEqualToString:@"mov"]||
                          [fmime isEqualToString:@"mp4"]||
                          [fmime isEqualToString:@"avi"]||
                          [fmime isEqualToString:@"rmvb"])
                {
                    imageView.image = [UIImage imageNamed:@"file_moving.png"];
                }else if ([fmime isEqualToString:@"pdf"])
                {
                    imageView.image = [UIImage imageNamed:@"file_pdf.png"];
                }else if ([fmime isEqualToString:@"ppt"]||
                          [fmime isEqualToString:@"pptx"])
                {
                    imageView.image = [UIImage imageNamed:@"file_ppt.png"];
                }else if([fmime isEqualToString:@"txt"])
                {
                    imageView.image = [UIImage imageNamed:@"file_txt.png"];
                }else
                {
                    imageView.image = [UIImage imageNamed:@"file_other.png"];
                }

            }
            if ([self.roletype isEqualToString:@"2"]) {
                [cell.accessoryView setHidden:NO];
            }else if([self.f_id intValue]==0)
            {
                NSString *fcmd=[dic objectForKey:@"fcmd"];
                if ([fisdir isEqualToString:@"0"])
                {
                    if ([self hasCmd:@"copy" InFcmd:fcmd]||[self hasCmd:@"move" InFcmd:fcmd]||[self hasCmd:@"ren" InFcmd:fcmd]||[self hasCmd:@"del" InFcmd:fcmd]) {
                        [cell.accessoryView setHidden:NO];
                    }else
                    {
                        [cell.accessoryView setHidden:YES];
                    }
                }else
                {
                    if ([self hasCmd:@"download" InFcmd:fcmd]||[self hasCmd:@"publiclink" InFcmd:fcmd]||[self hasCmd:@"del" InFcmd:fcmd]||[self hasCmd:@"copy" InFcmd:fcmd]||[self hasCmd:@"move" InFcmd:fcmd]||[self hasCmd:@"ren" InFcmd:fcmd]) {
                        [cell.accessoryView setHidden:NO];
                    }else
                    {
                        [cell.accessoryView setHidden:YES];
                    }
                }
            }else
            {
                if([fisdir isEqualToString:@"0"])
                {
                    if ([self hasCmdInFcmd:@"copy"]||[self hasCmdInFcmd:@"move"]||[self hasCmdInFcmd:@"ren"]||[self hasCmdInFcmd:@"del"]) {
                        [cell.accessoryView setHidden:NO];
                    }else
                    {
                        [cell.accessoryView setHidden:YES];
                    }
                    
                }else
                {
                    if ([self hasCmdInFcmd:@"download"]||[self hasCmdInFcmd:@"publiclink"]||[self hasCmdInFcmd:@"del"]||[self hasCmdInFcmd:@"copy"]||[self hasCmdInFcmd:@"move"]||[self hasCmdInFcmd:@"ren"]) {
                        [cell.accessoryView setHidden:NO];
                    }else
                    {
                        [cell.accessoryView setHidden:YES];
                    }
                }
            }
        }
        //判断文件是否已经下载
        UIImageView *tagView = (UIImageView *)[cell viewWithTag:KCOVERTag];
        //获取数据
        NSString *fileName = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
        NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
        NSInteger fileSize = [[dic objectForKey:@"fsize"] integerValue];
        
        NSString *documentDir = [YNFunctions getFMCachePath];
        NSArray *array=[fileName componentsSeparatedByString:@"/"];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
        [NSString CreatePath:createPath];
        NSString *file_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        
        DownList *list = [[DownList alloc] init];
        //d_name=? and d_ure_id=? and d_state=? and d_file_id=?
        list.d_name = [NSString formatNSStringForOjbect:fileName];
        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        list.d_file_id = [NSString formatNSStringForOjbect:file_id];
        list.d_state = 1;
        BOOL bl = [list selectUploadListIsHave];
        if(bl)
        {
            //查询本地是否已经有该图片
            bl = [NSString image_exists_FM_file_path:file_path];
            if(bl)
            {
                NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:file_path];
                bl = fileSize==[[handle availableData] length];
            }
            else
            {
                bl = FALSE;
            }
        }
        if(bl)
        {
            [tagView setHidden:NO];
        }
        else
        {
            [tagView setHidden:YES];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)accessoryButtonPressedAction: (id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
//    UITableViewCell *cell = (UITableViewCell *)[button superview];
//    NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:button.tag inSection:0];
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenu];
    self.selectedIndexPath=indexPath;
    if (!self.singleBg) {

        self.singleBg=[[UIControl alloc] initWithFrame:CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height)];
        [self.singleBg addTarget:self action:@selector(hideSingleBar) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:self.singleBg];
    }
    [self.singleBg setHidden:NO];

    self.singleBg.frame=CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height);
    //显示单选操作菜单
    int CellHeight=60;
    if (!self.singleEditBar) {
        self.singleEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, CellHeight)];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.singleEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.singleEditBar setTintColor:[UIColor blueColor]];
        }
        [self.singleEditBar setBackgroundImage:[UIImage imageNamed:@"bk_select.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.singleEditBar setBarStyle:UIBarStyleBlackOpaque];
        [self.tableView addSubview:self.singleEditBar];
        [self.tableView bringSubviewToFront:self.singleEditBar];
        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_selectTop.png"]];
        [jiantou setFrame:CGRectMake(280, -6, 10, 6)];
        [jiantou setTag:2012];
        [self.singleEditBar addSubview:jiantou];
    }
    [self.tableView bringSubviewToFront:self.singleEditBar];
    [self.singleEditBar setHidden:NO];
    CGRect r=self.singleEditBar.frame;
    
    r.origin.y=(indexPath.row+1) * CellHeight;
    if (r.origin.y+r.size.height>self.tableView.frame.size.height &&r.origin.y+r.size.height > self.tableView.contentSize.height) {
        r.origin.y=(indexPath.row+1)*CellHeight-(r.size.height *2);
        UIImageView *imageView=(UIImageView *)[self.singleEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        imageView.frame=CGRectMake(280, CellHeight, 10, 6);
    }else
    {
        UIImageView *imageView=(UIImageView *)[self.singleEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        imageView.frame=CGRectMake(280, -6, 10, 6);
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
        NSLog(@"Rect:%@\n SuperView:%@",NSStringFromCGRect(rectInSuperview),NSStringFromCGRect([tableView.superview frame]));
        if (rectInSuperview.origin.y+(rectInSuperview.size.height*2)>([tableView superview].frame.size.height+[tableView superview].frame.origin.y)-49-64) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        
    }
    self.singleEditBar.frame=r;
    
//    NSArray *buttons=@[@"移动",@"重命名",@"删除",@"下载",@"发送",@"提交/转存"];
    //发送 提交 删除 更多
//    NSMutableArray *barItems=[NSMutableArray array];
    UIButton *btn_send, *btn_commit ,*btn_del ,*btn_more ,*btn_resave ,*btn_download ,*btn_rename ,*btn_move ,*btn_copy;
    UIBarButtonItem *item_send, *item_commit ,*item_del ,*item_more, *item_flexible ,*item_resave ,*item_download ,*item_rename ,*item_move ,*item_copy;
    int btnWidth=40;
    btn_send =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_send setImage:[UIImage imageNamed:@"share_nor.png"] forState:UIControlStateNormal];
    [btn_send setImage:[UIImage imageNamed:@"share_se.png"] forState:UIControlStateHighlighted];
    [btn_send setImage:[UIImage imageNamed:@"share_locked"] forState:UIControlStateDisabled];
    [btn_send addTarget:self action:@selector(toSend:) forControlEvents:UIControlEventTouchUpInside];
    item_send=[[UIBarButtonItem alloc] initWithCustomView:btn_send];
    
    btn_commit =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_commit setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
    [btn_commit setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
    [btn_commit addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
    item_commit=[[UIBarButtonItem alloc] initWithCustomView:btn_commit];
    
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_resave setImage:[UIImage imageNamed:@"zc_nor.png"] forState:UIControlStateNormal];
    [btn_resave setImage:[UIImage imageNamed:@"zc_se.png"] forState:UIControlStateHighlighted];
    [btn_resave addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    
    btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
    [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
    [btn_del addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
    item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
    
    btn_more =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_more setImage:[UIImage imageNamed:@"more_nor.png"] forState:UIControlStateNormal];
    [btn_more setImage:[UIImage imageNamed:@"more_se.png"] forState:UIControlStateHighlighted];
    [btn_more addTarget:self action:@selector(toMore:) forControlEvents:UIControlEventTouchUpInside];
    item_more=[[UIBarButtonItem alloc] initWithCustomView:btn_more];
    
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [btn_download addTarget:self action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    
    btn_rename =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_rename setImage:[UIImage imageNamed:@"rename_nor.png"] forState:UIControlStateNormal];
    [btn_rename setImage:[UIImage imageNamed:@"rename_se.png"] forState:UIControlStateHighlighted];
    [btn_rename addTarget:self action:@selector(toRename:) forControlEvents:UIControlEventTouchUpInside];
    item_rename=[[UIBarButtonItem alloc] initWithCustomView:btn_rename];
    
    btn_move =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_move setImage:[UIImage imageNamed:@"move_nor.png"] forState:UIControlStateNormal];
    [btn_move setImage:[UIImage imageNamed:@"move_se.png"] forState:UIControlStateHighlighted];
    [btn_move addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
    item_move=[[UIBarButtonItem alloc] initWithCustomView:btn_move];
    
    btn_copy =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_copy setImage:[UIImage imageNamed:@"copy_nor.png"] forState:UIControlStateNormal];
    [btn_copy setImage:[UIImage imageNamed:@"copy_se.png"] forState:UIControlStateHighlighted];
    [btn_copy addTarget:self action:@selector(toCopy:) forControlEvents:UIControlEventTouchUpInside];
    item_copy=[[UIBarButtonItem alloc] initWithCustomView:btn_copy];
    
    item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    for (NSString *str in buttons) {
//        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
//        [button setImage:[UIImage imageNamed:@"rename_nor.png"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"rename_se.png"] forState:UIControlStateHighlighted];
//        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:nil action:nil];
//        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithCustomView:button];
//        [barItems addObject:item1];
//    }
    //2013年10月29日去提交和发送功能;by FengYN
    
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *fisdir=[dic objectForKey:@"fisdir"];

    if ([self.roletype isEqualToString:@"2"]) {
        //个人空间
        if ([fisdir isEqualToString:@"0"])
        {
            [self.singleEditBar setItems:@[item_flexible,item_send,item_flexible,item_copy,item_flexible,item_move,item_flexible,item_rename,item_flexible,item_del]];
        }else
        {
            [self.singleEditBar setItems:@[item_download,item_flexible,item_send,item_flexible,item_del,item_flexible,item_more]];
        }
        //[self.singleEditBar setItems:@[item_send,item_flexible,item_commit,item_flexible,item_del,item_flexible,item_more]];
    }else if([self.f_id intValue]==0)
    {
        //企业库根目录
        NSString *fcmd=[dic objectForKey:@"fcmd"];
        
        //管理员
        if ([fisdir isEqualToString:@"0"])
        {
            //            [self.singleEditBar setItems:@[item_resave,item_flexible,item_move,item_flexible,item_rename,item_flexible,item_del]];
            NSMutableArray *array=[NSMutableArray array];
            //[array addObject:item_flexible];
            if([self hasCmd:@"publiclink" InFcmd:fcmd])
            {
                [array addObject:item_send];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"copy" InFcmd:fcmd])
            {
                [array addObject:item_copy];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"move" InFcmd:fcmd])
            {
                [array addObject:item_move];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"ren" InFcmd:fcmd])
            {
                [array addObject:item_rename];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"del" InFcmd:fcmd])
            {
                [array addObject:item_del];
                //[array addObject:item_flexible];
            }
            NSArray *theArray=nil;
            if (array.count>5) {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,item_more];
            }else if(array.count==1)
            {
                theArray=@[item_flexible,[array objectAtIndex:0],item_flexible];
            }else if(array.count==2)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1]];
            }
            else if(array.count==3)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2]];
            }
            else if(array.count==4)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3]];
            }
            else if(array.count==5)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3],item_flexible,[array objectAtIndex:4]];
            }
            [self.singleEditBar setItems:theArray];
        }else
        {
            //            [self.singleEditBar setItems:@[item_download,item_flexible,item_send,item_flexible,item_del,item_flexible,item_more]];
            NSMutableArray *array=[NSMutableArray array];
            //[array addObject:item_flexible];
            if([self hasCmd:@"download" InFcmd:fcmd])
            {
                [array addObject:item_download];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"publiclink" InFcmd:fcmd])
            {
//                [array addObject:item_send];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"del" InFcmd:fcmd])
            {
                [array addObject:item_del];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"copy" InFcmd:fcmd])
            {
                [array addObject:item_copy];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"move" InFcmd:fcmd])
            {
                [array addObject:item_move];
                //[array addObject:item_flexible];
            }
            if([self hasCmd:@"ren" InFcmd:fcmd])
            {
                [array addObject:item_rename];
                //[array addObject:item_flexible];
            }
            NSArray *theArray=nil;
            if (array.count>4) {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,item_more];
            }else if(array.count==1)
            {
                theArray=@[item_flexible,[array objectAtIndex:0],item_flexible];
            }else if(array.count==2)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1]];
            }
            else if(array.count==3)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2]];
            }
            else if(array.count==4)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3]];
            }
            [self.singleEditBar setItems:theArray];
        }
    }else
    {
         //企业库子目录
        if ([fisdir isEqualToString:@"0"])
        {
            //文件夹
//            [self.singleEditBar setItems:@[item_resave,item_flexible,item_move,item_flexible,item_rename,item_flexible,item_del]];
            NSMutableArray *array=[NSMutableArray array];
            //[array addObject:item_flexible];
            if([self hasCmdInFcmd:@"publiclink"])
            {
//                [array addObject:item_send];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"copy"])
            {
                [array addObject:item_copy];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"move"])
            {
                [array addObject:item_move];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"ren"])
            {
                [array addObject:item_rename];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"del"])
            {
                [array addObject:item_del];
                //[array addObject:item_flexible];
            }
            NSArray *theArray=nil;
            if (array.count>5) {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,item_more];
            }else if(array.count==1)
            {
                theArray=@[item_flexible,[array objectAtIndex:0],item_flexible];
            }else if(array.count==2)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1]];
            }
            else if(array.count==3)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2]];
            }
            else if(array.count==4)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3]];
            }
            else if(array.count==5)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3],item_flexible,[array objectAtIndex:4]];
            }
            [self.singleEditBar setItems:theArray];
        }else
        {
//            [self.singleEditBar setItems:@[item_download,item_flexible,item_send,item_flexible,item_del,item_flexible,item_more]];
            NSMutableArray *array=[NSMutableArray array];
            //[array addObject:item_flexible];
            if([self hasCmdInFcmd:@"download"])
            {
                [array addObject:item_download];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"publiclink"])
            {
                [array addObject:item_send];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"del"])
            {
                [array addObject:item_del];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"copy"])
            {
                [array addObject:item_copy];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"move"])                                                                                                      
            {
                [array addObject:item_move];
                //[array addObject:item_flexible];
            }
            if([self hasCmdInFcmd:@"ren"])
            {
                [array addObject:item_rename];
                //[array addObject:item_flexible];
            }
            NSArray *theArray=nil;
            if (array.count>4) {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,item_more];
            }else if(array.count==1)
            {
                theArray=@[item_flexible,[array objectAtIndex:0],item_flexible];
            }else if(array.count==2)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1]];
            }
            else if(array.count==3)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2]];
            }
            else if(array.count==4)
            {
                theArray=@[[array objectAtIndex:0],item_flexible,[array objectAtIndex:1],item_flexible,[array objectAtIndex:2],item_flexible,[array objectAtIndex:3]];
            }
            [self.singleEditBar setItems:theArray];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        
        //判断文件夹数量 有文件夹，并且个数大于一
        BOOL isHidden = NO;
        NSArray *indexs=[self selectedIndexPaths];
        for (NSIndexPath *inpath in indexs) {
            NSDictionary *dic=[self.listArray objectAtIndex:inpath.row];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"] && indexs.count>1)
            {
                [item_send setEnabled:NO];
                isHidden = YES;
                break;
            }
        }
        if(!isHidden)
        {
            [item_send setEnabled:YES];
        }
        
        tableViewSelectedTag = -1;
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        NSString *fisdir=[dic objectForKey:@"fisdir"];
        if ([fisdir isEqualToString:@"0"]) {
            //选中了文件夹，禁用分享;
            if([self.roletype isEqualToString:@"1"])
            {
                [item_send setEnabled:NO];
            }
            isSelectedDir=YES;
            [item_download setEnabled:NO];
        }
        return;
    }
    tableViewSelectedTag = -1;
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            NSString *fname = [dic objectForKey:@"fname"];
            NSString *fmime=[[fname pathExtension] lowercaseString];
            
            if(![fisdir isEqualToString:@"0"] && self.shareType==kShareTypeShare)
            {
                [self addSharedFileView:dic];
            }else if([fisdir isEqualToString:@"0"]&&self.shareType==kShareTypeShare){
                FileListViewController *flVC=[[FileListViewController alloc] init];
                flVC.spid=self.spid;
                flVC.roletype=self.roletype;
                flVC.f_id=[dic objectForKey:@"fid"];
                flVC.title=[dic objectForKey:@"fname"];
                flVC.fcmd=[dic objectForKey:@"fcmd"];
                
                flVC.shareType=kShareTypeShare;
                flVC.FileEmialViewDelegate=self.FileEmialViewDelegate;
                
                [self.navigationController pushViewController:flVC animated:YES];
            }else
            if ([fisdir isEqualToString:@"0"]) {
                FileListViewController *flVC=[[FileListViewController alloc] init];
                flVC.spid=self.spid;
                flVC.roletype=self.roletype;
                flVC.f_id=[dic objectForKey:@"fid"];
                flVC.title=[dic objectForKey:@"fname"];
                flVC.fcmd=[dic objectForKey:@"fcmd"];
                [self.navigationController pushViewController:flVC animated:YES];
            }
            else if ([fmime isEqualToString:@"png"]||
                     [fmime isEqualToString:@"jpg"]||
                     [fmime isEqualToString:@"jpeg"]||
                     [fmime isEqualToString:@"bmp"]||
                     [fmime isEqualToString:@"gif"])
            {
                tableViewSelectedTag = indexPath.row;
                NSString *curr_fid = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
                if([tableViewSelectedFid isEqualToString:curr_fid])
                {
                    return;
                }
                tableViewSelectedFid = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
                if (![self hasCmdInFcmd:@"preview"]) {
                    OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
                    openFileView.isNotLook = YES;
                    DetailViewController *viewCon=[[DetailViewController alloc] init];
                    viewCon.isFileManager = YES;
                    [viewCon removeAllView];
                    [viewCon showOtherView:openFileView.title withIsHave:NO withIsHaveDown:NO];
                    [viewCon.view addSubview:openFileView.view];
                    [viewCon addChildViewController:openFileView];
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                    [nav.navigationBar setTintColor:[UIColor whiteColor]];
                    NSArray * viewControllers=self.splitViewController.viewControllers;
                    self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    return;
                }
                int row = 0;
                if(indexPath.row<[self.listArray count])
                {
                    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                    for(int i=0;i<[self.listArray count];i++) {
                        NSDictionary *diction = [self.listArray objectAtIndex:i];
                        NSString *fname_ = [diction objectForKey:@"fname"];
                        NSString *fmime_=[[fname_ pathExtension] lowercaseString];
                        if([[diction objectForKey:@"fisdir"] boolValue] && ([fmime_ isEqualToString:@"png"]||
                           [fmime_ isEqualToString:@"jpg"]||
                           [fmime_ isEqualToString:@"jpeg"]||
                           [fmime_ isEqualToString:@"bmp"]||
                           [fmime_ isEqualToString:@"gif"]))
                        {
                            DownList *list = [[DownList alloc] init];
                            list.d_file_id = [NSString formatNSStringForOjbect:[diction objectForKey:@"fid"]];
                            list.d_thumbUrl = [NSString formatNSStringForOjbect:[diction objectForKey:@"fthumb"]];
                            if([list.d_thumbUrl length]==0)
                            {
                                list.d_thumbUrl = @"0";
                            }
                            list.d_name = [NSString formatNSStringForOjbect:[diction objectForKey:@"fname"]];
                            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
                            list.d_downSize = [[diction objectForKey:@"fsize"] integerValue];
                            [tableArray addObject:list];
                            if(row==0 && [fname isEqualToString:fname_])
                            {
                                row = [tableArray count]-1;
                            }
                        }
                    }
                    if([tableArray count]>0)
                    {
                        PartitionViewController *look = [[PartitionViewController alloc] init];
                        [look setCurrPage:row];
                        [look setTableArray:tableArray];
                        if ([self.roletype isEqualToString:@"2"]) {
                            look.isHaveDelete = YES;
                            look.isHaveDownload=YES;
                        }else{
                            look.isHaveDelete=[self hasCmdInFcmd:@"del"];
                            look.isHaveDownload=[self hasCmdInFcmd:@"download"];
                        }
                        DetailViewController *viewCon=[[DetailViewController alloc] init];
                        viewCon.isFileManager = YES;
                        [viewCon removeAllView];
                        [viewCon showPhotoView:fname withIsHave:look.isHaveDelete withIsHaveDown:look.isHaveDownload];
                        [viewCon.view addSubview:look.view];
                        [viewCon addChildViewController:look];
                        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        NSArray * viewControllers=self.splitViewController.viewControllers;
                        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    }
                }
            }
            else
            {
                tableViewSelectedTag = indexPath.row;
                NSString *curr_fid = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
                if([tableViewSelectedFid isEqualToString:curr_fid])
                {
                    return;
                }
                tableViewSelectedFid = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
                if (![self hasCmdInFcmd:@"preview"]) {
                    OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
                    openFileView.isNotLook = YES;
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                    DetailViewController *viewCon=[[DetailViewController alloc] init];
                    viewCon.isFileManager = YES;
                    [viewCon removeAllView];
                    [viewCon showOtherView:openFileView.title withIsHave:NO withIsHaveDown:NO];
                    [viewCon.view addSubview:openFileView.view];
                    [viewCon addChildViewController:openFileView];
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                    [nav.navigationBar setTintColor:[UIColor whiteColor]];
                    NSArray * viewControllers=self.splitViewController.viewControllers;
                    self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    return;
                }
                NSString *file_id=[dic objectForKey:@"fid"];
                NSString *f_name=[dic objectForKey:@"fname"];
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
                [NSString CreatePath:createPath];
                BOOL isHaveDelete,isHaveDownload;
                if ([self.roletype isEqualToString:@"2"]) {
                    isHaveDelete = YES;
                    isHaveDownload=YES;
                }else{
                    isHaveDelete=[self hasCmdInFcmd:@"del"];
                    isHaveDownload=[self hasCmdInFcmd:@"download"];
                }
                OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
                openFileView.dataDic = dic;
                openFileView.title = f_name;
                
                DetailViewController *viewCon=[[DetailViewController alloc] init];
                viewCon.isFileManager = YES;
                [viewCon removeAllView];
                viewCon.dataDic=dic;
                [viewCon showOtherView:openFileView.title withIsHave:isHaveDelete withIsHaveDown:NO];
                [viewCon.view addSubview:openFileView.view];
                [viewCon addChildViewController:openFileView];
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                [nav.navigationBar setTintColor:[UIColor whiteColor]];
                NSArray * viewControllers=self.splitViewController.viewControllers;
                self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.editing) {
        
        //判断文件夹数量 有文件夹，并且个数大于一
        BOOL ishidden = NO;
        NSArray *indexs=[self selectedIndexPaths];
        for (NSIndexPath *inpath in indexs) {
            NSDictionary *dic=[self.listArray objectAtIndex:inpath.row];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"] && indexs.count>1)
            {
                [item_send setEnabled:NO];
                ishidden = YES;
                break;
            }
        }
        if(!ishidden)
        {
            [item_send setEnabled:YES];
        }
        
        BOOL isDis=NO;
        for (NSIndexPath *newIP in [self selectedIndexPaths]) {
            NSDictionary *dic=[self.listArray objectAtIndex:newIP.row];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                //选中了文件夹，禁用分享;
                isDis=YES;
                break;
            }
        }
        //UIBarButtonItem *item=(UIBarButtonItem *)[self.moreEditBar.items objectAtIndex:0];
        if (isDis) {
            if([self.roletype isEqualToString:@"1"])
            {
                [item_send setEnabled:NO];
            }
            isSelectedDir=YES;
            [item_download setEnabled:NO];
        }else
        {
            if([self.roletype isEqualToString:@"1"])
            {
                [item_send setEnabled:YES];
            }
            isSelectedDir=NO;
            [item_download setEnabled:YES];
        }
        return;
    }
}
#pragma mark - SCBEmailManagerDelegate
-(void)createLinkSucceed:(NSDictionary *)datadic
{
    NSString *link=[datadic objectForKey:@"msg"];
    NSString *template=@"%@想和您分享icoffer的文件，链接地址：%@";
    NSLog(@"Link:%@",link);
    [self.hud hide:YES];
    switch (self.shareType) {
        case kShareTypeCopyLink:
        {
            [[UIPasteboard generalPasteboard] setString:link];
            
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];

            [self.hud show:NO];
            self.hud.labelText=@"复制成功";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
        }
            break;
        case kShareTypeMessage:
        {
            NSString *text=[NSString stringWithFormat:template,[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],link];
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                [picker setBody:text];
                [self presentViewController:picker animated:YES completion:nil];
            }else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"iMessage未启用，请到［设置］中开启！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
            break;
        case kShareTypeOther:
        {
            NSString *text=[NSString stringWithFormat:template,[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],link];
            UIActivityViewController * activityViewController=[[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
            [activityViewController setExcludedActivityTypes:[NSArray arrayWithObjects:
                                                              UIActivityTypeMail,UIActivityTypeMessage,nil]];
            if (![self.activityPopover isPopoverVisible]) {
                self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                [self.activityPopover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            else
            {
                //Dismiss if the button is tapped while pop over is visible
                [self.activityPopover dismissPopoverAnimated:YES];
            }
//            [self presentViewController:self.activityViewController animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}
#pragma mark - SCBFileManagerDelegate
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self doneLoadingTableViewData];
}
-(void)openFinderSucess:(NSDictionary *)datadic
{
    if (self.tableView.isEditing) {
        self.selectedFIDs=[self selectedIDs];
    }
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
//        if ([self.f_id intValue]==0) {
//            self.fcmd=[self.dataDic objectForKey:@"cmds"];
//        }
        self.fcmd=[self.dataDic objectForKey:@"cmds"];
        if (self.listArray) {
            [self.tableView reloadData];
        }
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }
        else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
        [self updateSelected];
    }else
    {
        //[self updateFileList];
    }
    [self doneLoadingTableViewData];
    NSLog(@"openFinderSucess:");
    if (self.dataDic)
    {
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }
    if (self.listArray.count<=0) {
        if(self.notingLabel == nil)
        {
            UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientation];
            
            CGRect noting_rect = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                noting_rect.size.height = 768-56-64;
            }
            else
            {
                noting_rect.size.height = 1024-56-64;
            }
            self.nothingView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
            [self.nothingView setBackgroundColor:[UIColor whiteColor]];
            [self.tableView addSubview:self.nothingView];
            
            CGRect notLabel_rect = CGRectMake(0, 300, 320, 40);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                notLabel_rect.origin.y = (768-56-64-40)/2;
            }
            else
            {
                notLabel_rect.origin.y = (1024-56-64-40)/2;
            }
            self.notingLabel = [[UILabel alloc] initWithFrame:notLabel_rect];
            [self.notingLabel setTextColor:[UIColor grayColor]];
            [self.notingLabel setFont:[UIFont systemFontOfSize:18]];
            [self.notingLabel setTextAlignment:NSTextAlignmentCenter];
            [self.nothingView addSubview:self.notingLabel];
            
            //[self.notingLabel setHidden:YES];
        }
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView setHidden:NO];
        //[self.tableView setHidden:YES];
        [self.notingLabel setText:@"暂无文件"];
    }else
    {
        [self.tableView bringSubviewToFront:self.nothingView];
        [self.nothingView setHidden:YES];
        //[self.tableView setHidden:NO];
        [self.notingLabel setText:@"暂无文件"];
    }
}
-(void)newFinderSucess
{
    [self operateUpdate];
}
-(void)newFinderUnsucess;
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)operateSucess:(NSDictionary *)datadic
{
    [self openFinderSucess:datadic];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    
    [self updateSelected];
}
-(void)renameSucess
{
    [self operateUpdate];
}
-(void)renameUnsucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)removeSucess
{
//    if (self.willDeleteObjects) {
//        [self removeFromDicWithObjects:self.willDeleteObjects];
//        [self.tableView reloadData];
//    }
    
    //[self.tableView reloadData];
    [self operateUpdate];
//    if (self.hud) {
//        [self.hud removeFromSuperview];
//    }
//    self.hud=nil;
//    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//    [self.view.superview addSubview:self.hud];    [self.hud show:NO];
//    self.hud.labelText=@"操作成功";
//    self.hud.mode=MBProgressHUDModeText;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:1.0f];
}
-(void)removeUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
    [self updateFileList];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)Unsucess:(NSString *)strError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
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
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)moveUnsucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)moveSucess
{
    [self operateUpdate];
}
-(void)showMessage:(NSString *)message
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=message;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1];
}
#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
 //   [self.ctrlView setHidden:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
//        if (self.selectedIndexPath) {
//            //[self hideOptionCell];
//            return;
//        }
        [self loadImagesForOnscreenRows];
    }
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if (self.selectedIndexPath) {
//        //[self hideOptionCell];
//        return;
//    }
    [self loadImagesForOnscreenRows];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
            if (dic==nil) {
                break;
            }
            NSString *fmime=[[dic objectForKey:@"f_mime"] lowercaseString];
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"]){
                
                NSString *compressaddr=[dic objectForKey:@"fthumb"];
                assert(compressaddr!=nil);
                compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
                NSString *path=[YNFunctions getIconCachePath];
                path=[path stringByAppendingPathComponent:compressaddr];
                
                //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
                {
                    NSLog(@"将要下载的文件：%@",path);
                    [self startIconDownload:dic forIndexPath:indexPath];
                }
            }
        }
    }
}
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
        BOOL isSelect=NO;
        if (self.tableView.editing) {
            NSArray *array=[self selectedIndexPaths];
            for (NSIndexPath *index in array) {
                if (iconDownloader.indexPathInTableView.row==index.row) {
                    isSelect=YES;
                }
            }
            self.selectedFIDs=[self selectedIDs];
        }
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
        if (self.tableView.editing&&isSelect) {
            [self.tableView selectRowAtIndexPath:iconDownloader.indexPathInTableView animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTagDeleteOne:
        {
        }
        case kAlertTagRename:
        {
            if (buttonIndex==1) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
                NSString *name=[dic objectForKey:@"fname"];
                NSString *f_id=[dic objectForKey:@"fid"];
                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
                if (![fildtext isEqualToString:name]) {
                    NSLog(@"重命名");
                    [self.fm cancelAllTask];
                    self.fm=[[SCBFileManager alloc] init];
                    [self.fm renameWithID:f_id newName:fildtext sID:self.spid];
                    [self.fm setDelegate:self];
                }
                NSLog(@"点击确定");
            }else
            {
                NSLog(@"点击其它");
            }
            //[self hideOptionCell];
            break;
        }
        case kAlertTagMailAddr:
        {
//            if (buttonIndex==1) {
//                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
//                if (![self checkIsEmail:fildtext])
//                {
//                    if (self.hud) {
//                        [self.hud removeFromSuperview];
//                    }
//                    self.hud=nil;
//                    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//                    [self.view.superview addSubview:self.hud];
//                    [self.hud show:NO];
//                    self.hud.labelText=@"输入的邮箱地址非法";
//                    //self.hud.labelText=error_info;
//                    self.hud.mode=MBProgressHUDModeText;
//                    self.hud.margin=10.f;
//                    [self.hud show:YES];
//                    [self.hud hide:YES afterDelay:1.0f];
//                    return;
//                }
//                if (self.tableView.editing) {
//                    NSMutableArray *f_ids=[NSMutableArray array];
//                    BOOL hasDir=NO;
//                    for (int i=0;i<self.m_fileItems.count;i++) {
//                        FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//                        if (fileItem.checked) {
//                            NSDictionary *dic=[self.listArray objectAtIndex:i];
//                            NSString *f_id=[dic objectForKey:@"f_id"];
//                            NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
//                            if (![f_mime isEqualToString:@"directory"]) {
//                                [f_ids addObject:f_id];
//                            }else
//                            {
//                                hasDir=YES;
//                            }
//                        }
//                    }
//                    SCBLinkManager *lm_temp=[[[SCBLinkManager alloc] init] autorelease];
//                    [lm_temp setDelegate:self];
//                    [lm_temp releaseLinkEmail:f_ids l_pwd:@"a1b2" receiver:@[fildtext]];
//                    
//                }else
//                {
//                    if (self.selectedIndexPath) {
//                        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
//                        NSString *f_id=[dic objectForKey:@"f_id"];
//                        
//                        SCBLinkManager *lm_temp=[[[SCBLinkManager alloc] init] autorelease];
//                        [lm_temp setDelegate:self];
//                        //                        [lm_temp linkWithIDs:@[f_id]];
//                        [lm_temp releaseLinkEmail:@[f_id] l_pwd:@"a1b2" receiver:@[fildtext]];
//                        [self hideOptionCell];
//                    }
//                }
//                
//                NSLog(@"点击确定");
//            }else
//            {
//                NSLog(@"点击其它");
//            }
//            [self hideOptionCell];
            break;
        }
        case kAlertTagDeleteMore:
        {
            break;
        }
        case kAlertTagNewFinder:
        {
            if (buttonIndex==1) {
                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
                if (![fildtext isEqualToString:@""]) {
                    NSLog(@"重命名");
                    [self.fm cancelAllTask];
                    self.fm=[[SCBFileManager alloc] init];
                    [self.fm newFinderWithName:fildtext pID:self.f_id sID:self.spid];
                    [self.fm setDelegate:self];
                }else
                {
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    self.hud=[[MBProgressHUD alloc] initWithWindow:[[[UIApplication sharedApplication] delegate] window]];
                    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件名不能为空";
                    self.hud.mode=MBProgressHUDModeText;
                    self.hud.margin=10.f;
                    [self.hud setYOffset:-285];
                    [self.hud show:YES];
                    [self.hud hide:YES afterDelay:1.0f];
                    [self newFinder:nil];
                }
            }else
            {
                NSLog(@"点击其它");
            }
            //[self hideOptionCell];
            break;
        }
        default:
            break;
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    switch ([actionSheet tag]) {
        case kActionSheetTagSort:
        {
            if (buttonIndex==0) {
                //时间排序
                [YNFunctions setDesc:@"time"];
                [self updateFileList];
            }else if(buttonIndex==1)
            {
                //名称排序
                [YNFunctions setDesc:@"name"];
                [self updateFileList];
            }else if (buttonIndex==2)
            {
                //大小排序
                [YNFunctions setDesc:@"size"];
                [self updateFileList];
            }
        }
            break;
        case kActionSheetTagSend:
        {
            switch (buttonIndex) {
                case 0:
                {
                    //内部分享
                    [self qiyeShared];
                }
                    break;
                case 1:
                {
                    //邮件外链
                    [self emailLinkShared];
                }
                    break;
                case 2:
                {
                    //短信分享
                    self.shareType=kShareTypeMessage;
                    [self createLink];
                }
                    break;
                case 3:
                {
                    //复制连接
                    self.shareType=kShareTypeCopyLink;
                    [self createLink];
                }
                    break;
                case 4:
                {
                    //其他分享
                    self.shareType=kShareTypeOther;
                    [self createLink];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kActionSheetTagSendHasDir:
        {
            switch (buttonIndex) {
                case 0:
                {
                    //邮件外链
                    [self emailLinkShared];
                }
                    break;
                case 1:
                {
                    //短信分享
                    self.shareType=kShareTypeMessage;
                    [self createLink];
                }
                    break;
                case 2:
                {
                    //复制链接
                    self.shareType=kShareTypeCopyLink;
                    [self createLink];
                }
                    break;
                case 3:
                {
                    //其它分享
                    self.shareType=kShareTypeOther;
                    [self createLink];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kActionSheetTagSendSubject:
        {
            switch (buttonIndex) {
                case 0:
                {
                    //分享至专题
                    [self publishToSubject];
                }
                    break;
                case 1:
                {
                    //内部分享
                    [self qiyeShared];
                }
                    break;
                case 2:
                {
                    //邮件外链
                    [self emailLinkShared];
                }
                    break;
                case 3:
                {
                    //短信分享
                    self.shareType=kShareTypeMessage;
                    [self createLink];
                }
                    break;
                case 4:
                {
                    //复制连接
                    self.shareType=kShareTypeCopyLink;
                    [self createLink];
                }
                    break;
                case 5:
                {
                    //其他分享
                    self.shareType=kShareTypeOther;
                    [self createLink];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kActionSheetTagSendSubjectHasDir:
        {
            switch (buttonIndex) {
                case 0:
                {
                    //分享至专题
                    [self publishToSubject];
                }
                case 1:
                {
                    //邮件外链
                    [self emailLinkShared];
                }
                    break;
                case 2:
                {
                    //短信分享
                    self.shareType=kShareTypeMessage;
                    [self createLink];
                }
                    break;
                case 3:
                {
                    //复制链接
                    self.shareType=kShareTypeCopyLink;
                    [self createLink];
                }
                    break;
                case 4:
                {
                    //其它分享
                    self.shareType=kShareTypeOther;
                    [self createLink];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kActionSheetTagDeleteOne:
        {
            if (buttonIndex==0) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
                NSString *f_id=[dic objectForKey:@"fid"];
                [self.fm cancelAllTask];
                self.fm=[[SCBFileManager alloc] init];
                self.fm.delegate=self;
                
                NSMutableArray *ids=[[NSMutableArray alloc] init];
                if (self.tableView.isEditing) {
                    [self.fm removeFileWithIDs:[self selectedIDs]];
                    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
                        NSDictionary *dic=[self.listArray objectAtIndex:indexpath.row];
                        [ids addObject:dic];
                    }
                }else
                {
                    [self.fm removeFileWithIDs:@[f_id]];
                    [ids addObject:dic];
                }
                [self removesBaseFile:ids];
                [self editFinished];
            }
//            [self hideOptionCell];
            break;
        }
        case kActionSheetTagDeleteMore:
        {
            break;
        }
        case kActionSheetTagMore:
            if ([self.roletype isEqualToString:@"2"]) {
                //个人空间
                if (buttonIndex==0) {
                    [self toCopy:nil];
                }else if(buttonIndex==1)
                {
                    [self toMove:nil];
                }else if(buttonIndex==2)
                {
                    [self toRename:nil];
                }
            }else
            {
                //管理员空间
                if (buttonIndex==0) {
                    [self toCopy:nil];
                }else if(buttonIndex==1)
                {
                    [self toMove:nil];
                }else if(buttonIndex==2)
                {
                    [self toRename:nil];
                }            }
            break;
        case kActionSheetTagShare:
            {
            }
            break;
        case kActionSheetTagPhoto:
        {
        }
            break;
        case kActionSheetTagUpload:
        {
            if (buttonIndex==0)
            {
                //拍照上传
                UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                
                //imagePicker.mediaTypes=[NSArray arrayWithObject:@"public.photo"];
                imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
                
                imagePicker.allowsEditing=NO;
                imagePicker.showsCameraControls=YES;
                imagePicker.cameraViewTransform=CGAffineTransformIdentity;
                
                // not all devices have two cameras or a flash so just check here
                if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] ) {
                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront] ) {
                        //                        cameraSelectionButton.alpha = 1.0;
                        //                        showCameraSelection = YES;
                    }
                } else {
                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                if ( [UIImagePickerController isFlashAvailableForCameraDevice:imagePicker.cameraDevice] ) {
                    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                    //                    flashModeButton.alpha = 1.0;
                    //                    showFlashMode = YES;
                }
                
                //                imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
                
                imagePicker.delegate = self;
                imagePicker.wantsFullScreenLayout = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }else if(buttonIndex==1)
            {
                //本机相册
                QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
                AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
                app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.old_file_url];
                imagePickerController.delegate = self;
                imagePickerController.allowsMultipleSelection = YES;
                imagePickerController.f_id  = self.f_id;
                imagePickerController.f_name = self.title;
                imagePickerController.space_id = self.spid;
                [imagePickerController requestFileDetail];
                [imagePickerController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:imagePickerController animated:NO];
            }
        }
            break;
        default:
            break;
    }
}

-(void)removesBaseFile:(NSMutableArray *)removesArray
{
    for(int i=0;i<removesArray.count;i++)
    {
        NSDictionary *dic = [removesArray objectAtIndex:i];
        //获取数据
        NSString *fileName = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
        NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
        NSString *documentDir = [YNFunctions getFMCachePath];
        NSArray *array=[fileName componentsSeparatedByString:@"/"];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
        NSString *file_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        //查询本地是否已经有该图片
        BOOL bl = [NSString image_exists_FM_file_path:file_path];
        if(bl)
        {
            NSFileManager *filemgr = [NSFileManager defaultManager];
            if([filemgr fileExistsAtPath:file_path])
            {
                BOOL isDelete = [filemgr removeItemAtPath:file_path error:nil];
                NSLog(@"删除文件是否成功：%i",isDelete);
            }
        }
    }
}
#pragma mark - UIImagePickerControllerDelegate
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            NSString *filePath=[YNFunctions getTempCachePath];
            NSDateFormatter *dateFormate=[[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yy-MM-dd HH mm ss"];
            
            NSString *fileName=[NSString stringWithFormat:@"%@.jpg",[dateFormate stringFromDate:[NSDate date]]];
            filePath=[filePath stringByAppendingPathComponent:fileName];
            BOOL result=[UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
            if (result) {
                NSLog(@"文件保存成功");
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate.uploadmanage uploadFilePath:filePath toFileID:self.f_id withSpaceID:self.spid];
            }else
            {
                NSLog(@"文件保存失败");
            }
        }
    });
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController loadView];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController loadView];
    }];
}
#pragma mark - MFMessageComposeViewController
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	
	NSString *resultValue=@"";
	switch (result)
	{
		case MessageComposeResultCancelled:
			resultValue = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			resultValue = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			resultValue = @"Result: SMS sending failed";
			break;
		default:
			resultValue = @"Result: SMS not sent";
			break;
	}
    NSLog(@"%@",resultValue);
	[controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)addSharedFileView:(NSDictionary *)dictionary
{
    [self.FileEmialViewDelegate addSharedFileView:dictionary];
}

#pragma mark - iPad旋转方法
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

//视图旋转完成之后自动调用
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIActionSheet *actionsheet = [app.action_array lastObject];
    if(actionsheet)
    {
        [actionsheet dismissWithClickedButtonIndex:-1 animated:NO];
        [actionsheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

-(void)updateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.shareType==kShareTypeShare) {
        return;
    }
    CGRect view_rect = self.view.frame;
    view_rect.size.width = 320;
    [self.view setFrame:view_rect];
    CGRect editView_rect = self.moreEditBar.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            editView_rect.origin.y = 768-56;
        }
        else
        {
            editView_rect.origin.y = 768-56;
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            editView_rect.origin.y = 1024-56;
        }
        else
        {
            editView_rect.origin.y = 1024-56;
        }
    }
    [self.moreEditBar setFrame:editView_rect];
    
    
    CGRect self_rect = self.tableView.frame;
    self_rect.size.width = 320;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self_rect.size.height = 768-56-64;
        }
        else
        {
            self_rect.size.height = 768-56-64;
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self_rect.size.height = 1024-56-64;
        }
        else
        {
            self_rect.size.height = 1024-56-64;
        }
    }
    [self.tableView setFrame:self_rect];
    
    CGRect notLabel_rect = self.notingLabel.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        notLabel_rect.origin.y = (768-56-64-40)/2;
    }
    else
    {
        notLabel_rect.origin.y = (1024-56-64-40)/2;
    }
    [self.notingLabel setFrame:notLabel_rect];
    
    CGRect noting_rect = self.nothingView.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        noting_rect.size.height = 768-56-64;
    }
    else
    {
        noting_rect.size.height = 1024-56-64;
    }
    [self.nothingView setFrame:noting_rect];
}

#pragma mark 当用户切换图片是，视图选择项也发生变化
-(void)updateSelected
{
    if(self.tableView.editing)
    {
        return;
    }
    UIViewController *vc=self.splitViewController.viewControllers.lastObject;
    if ([vc isKindOfClass:[SubjectDetailTabBarController class]]) {
        return;
    }
    if(tableViewSelectedTag!=-1 && self.listArray.count>tableViewSelectedTag)
    {
        BOOL isHave = NO;
        for(int i=0;i<self.listArray.count;i++)
        {
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *fid = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
            if([fid isEqualToString:tableViewSelectedFid])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                isHave = YES;
                break;
            }
        }
        if(!isHave)
        {
            NSDictionary *dic=[self.listArray objectAtIndex:tableViewSelectedTag];
            NSString *fname=[dic objectForKey:@"fname"];
            NSString *fmime=[[fname pathExtension] lowercaseString];
            NSLog(@"fmime:%@",fmime);
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tableViewSelectedTag inSection:0];
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
        }
    }
    else if(tableViewSelectedTag!=-1 && self.listArray.count>self.tableView.visibleCells.count-1)
    {
        NSDictionary *dic=[self.listArray objectAtIndex:self.tableView.visibleCells.count-1];
        NSString *fname=[dic objectForKey:@"fname"];
        NSString *fmime=[[fname pathExtension] lowercaseString];
        NSLog(@"fmime:%@",fmime);
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tableView.visibleCells.count-1 inSection:0];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

@end
