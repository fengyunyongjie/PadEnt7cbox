//
//  MainViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "MainViewController.h"
#import "SCBFileManager.h"
#import "YNFunctions.h"
#import "SelectFileListViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTabBarViewController.h"
#import "MySplitViewController.h"
#import "CustomJinDu.h"
#import "NSString+Format.h"

#define AUTHOR_MENU @"AuthorMenus"
@interface MainViewController()<SCBFileManagerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) NSArray *commitList;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIBarButtonItem *backBarButtonItem;
@end

@implementation MainViewController
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
- (void)viewDidLayoutSubviews
{
    if (self.tabBarController==nil) {
        self.view.backgroundColor=[UIColor grayColor];
        self.tableView.backgroundColor=[UIColor whiteColor];
    }
    if (self.type==kTypeShare) {
        int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}
- (void)viewDidAppear:(BOOL)animated
{

}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (self.type==kTypeCommit||self.type==kTypeResave||self.type==kTypeUpload||self.type==kTypeMove||self.type==kTypeCopy) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dissmissSelf:)]];
    }else
    {
        //        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,40)];
        //        [rightButton setImage:[UIImage imageNamed:@"title_upload_nor@2x.png"] forState:UIControlStateNormal];
        //        [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
        //        [rightButton addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
        //        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        //        self.navigationItem.rightBarButtonItem=rightItem;
    }
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        //禁用滑动返回
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.dirType==kTypeEnt) {
        //初始化返回按钮
        UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
        [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
        [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchDown];
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
    }

    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)uploadAction:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片并上传",@"从本机相册选择", nil];
    [actionSheet setTag:1];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
    //    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    //    imagePickerController.delegate = self;
    //    imagePickerController.allowsMultipleSelection = YES;
    //    AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
    //    app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.space_name];
    //    imagePickerController.f_id = @"0";
    //    imagePickerController.f_name = [NSString formatNSStringForOjbect:app_delegate.space_name];
    //    imagePickerController.space_id = [NSString formatNSStringForOjbect:app_delegate.space_id];
    //    [imagePickerController requestFileDetail];
    //    [imagePickerController setHidesBottomBarWhenPushed:YES];
    //    [self.navigationController pushViewController:imagePickerController animated:NO];
}

-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.uploadmanage changeUpload:array_ changeDeviceName:device_name changeFileId:f_id changeSpaceId:s_id];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateFileList];
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateFileList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:AUTHOR_MENU]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.listArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
//        if (self.type==kTypeUpload) {
//            NSMutableArray *array=[NSMutableArray array];
//            for (NSDictionary *dic in self.listArray) {
//                NSString *roletype=[dic objectForKey:@"roletype"];
//                if([roletype intValue]!=1&&[roletype intValue]!=2)
//                {
//                    [array addObject:dic];
//                }
//            }
//            self.listArray=array;
//        }
        if (self.listArray) {
            [self.tableView reloadData];
        }
    }
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    NSString *item=@"";
    switch (self.type) {
        case kTypeCopy:
            item=@"upload,mkdir";
            [self.fm authorMenus:item];
            break;
        case kTypeMove:
            item=@"upload,mkdir";
            [self.fm authorMenus:item];
            break;
        case kTypeUpload:
            item=@"upload";
            [self.fm authorMenus:item];
            break;
        case kTypeShare:
            item=@"publiclink";
            [self.fm authorMenus:item];
            break;
        default:
            [self.fm authorMenus];
            break;
    }
    
}
-(void)dissmissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
    [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
        if (self.dirType==kTypeRoot) {
            return 2;
        }else if(self.dirType==kTypeEnt){
            return self.listArray.count-1;
        }
        if (self.type==kTypeCommit) {
            NSMutableArray *array=[NSMutableArray array];
            for (NSDictionary *dic in self.listArray) {
                NSString *roleType=[dic objectForKey:@"roletype"];
                if ([roleType isEqualToString:@"0"]||[roleType isEqualToString:@"1"]) {
                    [array addObject:dic];
                }
            }
            self.commitList=array;
            return self.commitList.count;
        }else if(self.type==kTypeResave)
        {
            return 1;
        }
        return self.listArray.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
        CGRect titleRect=CGRectMake(70, 10, 200, 21);
        CGRect detailRect=CGRectMake(70, 30, 200, 21);
        if (self.dirType==kTypeRoot) {
            titleRect=CGRectMake(70, 20, 115, 21);
            detailRect=CGRectMake(190, 20, 115, 21);
        }
        UILabel *textLabel=[[UILabel alloc] initWithFrame:titleRect];
        UILabel *detailTextLabel=[[UILabel alloc] initWithFrame:detailRect];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:detailTextLabel];
        imageView.tag=1;
        textLabel.tag=2;
        detailTextLabel.tag=3;
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [detailTextLabel setFont:[UIFont systemFontOfSize:10]];
        [detailTextLabel setTextColor:[UIColor grayColor]];
        
        CGRect progress_rect = CGRectMake(190, 35, 115, 3);
        CustomJinDu *jinDuView = [[CustomJinDu alloc] initWithFrame:progress_rect];
        jinDuView.tag=4;
        [jinDuView setFrame:progress_rect];
        [cell.contentView addSubview:jinDuView];
    }
    CustomJinDu *jinDuView = (CustomJinDu *)[cell.contentView viewWithTag:4];
    [jinDuView setHidden:YES];
    
    UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailTextLabel=(UILabel *)[cell.contentView viewWithTag:3];
    if (self.listArray) {
        if(self.dirType==kTypeRoot&&indexPath.row==1){
            imageView.image=[UIImage imageNamed:@"bizfiles.png"];
            textLabel.text=@"公司文件";
            detailTextLabel.text=nil;
            return cell;
        }
        NSDictionary *dic;
        if (self.type==kTypeCommit) {
            dic=[self.commitList objectAtIndex:indexPath.row];
        }else{
            dic=[self.listArray objectAtIndex:indexPath.row];
        }
        if (self.dirType==kTypeEnt)
        {
            dic=[self.listArray objectAtIndex:indexPath.row+1];
        }
        if (dic) {
            textLabel.text=[dic objectForKey:@"spname"];
            //加载工作区图标
            imageView.image=[UIImage imageNamed:@"ownerfiles.png"];
            if (self.dirType==kTypeEnt)
            {
                imageView.image=[UIImage imageNamed:@"bizlib.png"];
            }
            //显示工作区大小
            float totalspace=[[dic objectForKey:@"totalspace"] floatValue];
            float usedspace=[[dic objectForKey:@"usedspace"] floatValue];
            NSString *totalspacestr=[dic objectForKey:@"totalspacestr"];
            NSString *usedspacestr=[dic objectForKey:@"usedspacestr"];
            if (totalspacestr==nil||usedspacestr==nil) {}
            else
            {
                CGRect detailRect=CGRectMake(70, 30, 200, 21);
                if (self.dirType==kTypeRoot) {
                    detailRect=CGRectMake(190, 10, 115, 21);
                    float f = usedspace / totalspace;
                    if(f>=0.8)
                    {
                        [jinDuView setCurrColor:[UIColor redColor]];
                    }
                    else
                    {
                        [jinDuView setCurrColor:[UIColor colorWithRed:73.0/255.0 green:127.0/255.0 blue:191.0/255.0 alpha:1]];
                    }
                    [jinDuView setCurrFloat:f];
                    [jinDuView setHidden:NO];
                }
                [detailTextLabel setFrame:detailRect];
                detailTextLabel.text=[NSString stringWithFormat:@"%@/%@",usedspacestr,totalspacestr];
//                detailTextLabel.text=[NSString stringWithFormat:@"%@/%@",@"1024.00GB",@"1024.00GB"];
                
            }
            
        }
    }
    [detailTextLabel setTextColor:[UIColor grayColor]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dirType==kTypeRoot&&indexPath.row==1) {
        MainViewController *vc=[[MainViewController alloc] init];
        vc.title=@"公司文件";
        vc.dirType=kTypeEnt;
        vc.delegate=self.delegate;
        vc.sharedEmialViewDelegate=self;
        vc.type=self.type;
        vc.targetsArray=self.targetsArray;
        vc.isHasSelectFile=self.isHasSelectFile;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    
    if (self.listArray) {
        NSDictionary *dic;
        if (self.type==kTypeCommit) {
            dic=[self.commitList objectAtIndex:indexPath.row];
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=[dic objectForKey:@"roletype"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeCommit;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else if(self.type==kTypeResave)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=[dic objectForKey:@"roletype"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeResave;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else if(self.type==kTypeUpload)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (self.dirType==kTypeEnt)
            {
                dic=[self.listArray objectAtIndex:indexPath.row+1];
            }
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
                if (self.dirType==kTypeEnt)
                {
                    flVC.roletype=@"1";
                }
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeUpload;
                flVC.rootName=[dic objectForKey:@"spname"];
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else if(self.type==kTypeMove)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (self.dirType==kTypeEnt)
            {
                dic=[self.listArray objectAtIndex:indexPath.row+1];
            }
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeMove;
                flVC.targetsArray=self.targetsArray;
                flVC.rootName=[dic objectForKey:@"spname"];
                flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
                flVC.isHasSelectFile=self.isHasSelectFile;
                if (self.dirType==kTypeEnt)
                {
                    flVC.roletype=@"1";
                }
                [self.navigationController pushViewController:flVC animated:YES];
            }
            
        }else if(self.type==kTypeCopy)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (self.dirType==kTypeEnt)
            {
                dic=[self.listArray objectAtIndex:indexPath.row+1];
            }
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeCopy;
                flVC.targetsArray=self.targetsArray;
                flVC.rootName=[dic objectForKey:@"spname"];
                flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
                flVC.isHasSelectFile=self.isHasSelectFile;
                if (self.dirType==kTypeEnt)
                {
                    flVC.roletype=@"1";
                }
                [self.navigationController pushViewController:flVC animated:YES];
            }
            
        }else if(self.type==kTypeDefault)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (self.dirType==kTypeEnt)
            {
                dic=[self.listArray objectAtIndex:indexPath.row+1];
            }
            if (dic) {
                FileListViewController *flVC=[[FileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
                if (self.dirType==kTypeEnt)
                {
                    flVC.roletype=@"1";
                }
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else if (self.type==kTypeShare)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (self.dirType==kTypeEnt)
            {
                dic=[self.listArray objectAtIndex:indexPath.row+1];
            }
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeShare;
                flVC.targetsArray=self.targetsArray;
                flVC.rootName=[dic objectForKey:@"spname"];
                flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
                flVC.isHasSelectFile=self.isHasSelectFile;
                if (self.dirType==kTypeEnt)
                {
                    flVC.roletype=@"1";
                }
                flVC.selectFileEmialViewDelegate=self;
                [self.navigationController pushViewController:flVC animated:YES];
            }

        }
    }
}

#pragma mark - SCBFileManagerDelegate
-(void)authorMenusSuccess:(NSData*)data
{
    NSError *jsonParsingError=nil;
    self.listArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if (self.listArray) {
//        if (self.type==kTypeUpload) {
//            NSMutableArray *array=[NSMutableArray array];
//            for (NSDictionary *dic in self.listArray) {
//                NSString *roletype=[dic objectForKey:@"roletype"];
//                if([roletype intValue]!=1&&[roletype intValue]!=2)
//                {
//                    [array addObject:dic];
//                }
//            }
//            self.listArray=array;
//        }
        [self.tableView reloadData];
        
        if([self.listArray count]>0)
        {
            NSDictionary *dic=[self.listArray objectAtIndex:0];
            if (dic) {
                AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
                app_delegate.space_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"spid"]];
                app_delegate.space_name=[NSString formatNSStringForOjbect:[dic objectForKey:@"spname"]];
            }
        }
        
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:AUTHOR_MENU]];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateFileList];
    }
    [self doneLoadingTableViewData];
}
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
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    switch ([actionSheet tag]) {
        case 1:
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
                imagePickerController.delegate = self;
                imagePickerController.allowsMultipleSelection = YES;
                AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
                app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.space_name];
                imagePickerController.f_id = @"0";
                imagePickerController.f_name = [NSString formatNSStringForOjbect:app_delegate.space_name];
                imagePickerController.space_id = [NSString formatNSStringForOjbect:app_delegate.space_id];
                [imagePickerController requestFileDetail];
                [imagePickerController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:imagePickerController animated:NO];
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
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [delegate.uploadmanage uploadFilePath:filePath toFileID:@"0" withSpaceID:delegate.space_id];
            }else
            {
                NSLog(@"文件保存失败");
            }
        }
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)addSharedFileView:(NSDictionary *)dictionary
{
    [self.sharedEmialViewDelegate addSharedFileView:dictionary];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - iPad 转屏代码
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
    if (self.type==kTypeShare) {
        return;
    }
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MyTabBarViewController *tabbar = [appleDate.splitVC.viewControllers firstObject];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 768-49);
        }else
        {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 768-49);
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 1024-49);
        }else
        {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 1024-49);
        }
    }
}

@end
