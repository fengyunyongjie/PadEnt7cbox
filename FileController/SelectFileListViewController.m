//
//  SelectFileListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-8.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SelectFileListViewController.h"
#import "SCBFileManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "UIBarButtonItem+Yn.h"
#import "QBAssetCollectionViewController.h"
#import "AppDelegate.h"
#import "MySplitViewController.h"
#import "MyTabBarViewController.h"

@interface SelectFileListViewController ()<SCBFileManagerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,QBImageFileViewDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation SelectFileListViewController
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
    [self updateFileList];
}
- (void)viewDidAppear:(BOOL)animated
{
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    //Initialize the toolbar
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    //Calclulate the height of the toolbar
    CGFloat toolbarHeight=[toolbar frame].size.height;
    //Get the bounds of the parent view
    CGRect rootViewBounds=self.view.bounds;
    //Get the height of the parent view
    CGFloat rootViewHeight=CGRectGetHeight(rootViewBounds);
    //Get the width of the parent view
    CGFloat rootViewWidth=CGRectGetWidth(rootViewBounds);
    //Create a rectangle for the toolbar
    CGRect rectArea=CGRectMake(0, rootViewHeight-toolbarHeight, rootViewWidth, toolbarHeight);
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    //Add the toolbar as a subview to the navigation controller.
    [self.view addSubview:toolbar];
    self.toolbar=toolbar;
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    UIButton *btn_download ,*btn_resave;
    UIBarButtonItem  *item_download, *item_resave;
    
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_resave setTitle:@"确 定" forState:UIControlStateNormal];
    [btn_resave addTarget:self action:@selector(moveFileToHere:) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_download setTitle:@"取 消" forState:UIControlStateNormal];
    [btn_download addTarget:self action:@selector(moveCancel:) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    
    //    UIBarButtonItem *ok_btn=[[UIBarButtonItem alloc] initWithTitleStr:@"    确 定    " style:UIBarButtonItemStyleDone target:self action:@selector(moveFileToHere:)];
    //    UIBarButtonItem *cancel_btn=[[UIBarButtonItem alloc] initWithTitleStr:@"    取 消    " style:UIBarButtonItemStyleBordered target:self action:@selector(moveCancel:)];
    UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolbar setItems:@[fix,item_download,fix,item_resave,fix]];
    
    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    //self.backBarButtonItem=backItem;
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }else if(self.f_id.intValue==0&&self.type==kSelectTypeMove)
    {
    }else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [rightButton setImage:[UIImage imageNamed:@"title_bt_new_nor.png"] forState:UIControlStateHighlighted];
    [rightButton setImage:[UIImage imageNamed:@"title_bt_new_se.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //self.navigationItem.rightBarButtonItem=rightItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateFileList
{
    //加载本地缓存文件
    //    NSString *dataFilePath=[YNFunctions getDataCachePath];
    //    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    //    {
    //        NSError *jsonParsingError=nil;
    //        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
    //        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    //        if (self.dataDic) {
    //            self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
    //            if (self.listArray) {
    //                NSMutableArray *array=[[NSMutableArray alloc] init];
    //                for (NSDictionary *dic in self.listArray) {
    //                    NSString *fisdir=[dic objectForKey:@"fisdir"];
    //                    NSString *fid=[dic objectForKey:@"fid"];
    //                    BOOL isTarget=NO;
    //                    if ((self.type==kSelectTypeMove&&self.targetsArray!=nil)) {
    //                        for (NSString *f_id in self.targetsArray) {
    //                            NSString *str1=[NSString stringWithFormat:@"%@",f_id];
    //                            NSString *str2=[NSString stringWithFormat:@"%@",fid];
    //                            if ([str1 isEqualToString:str2]) {
    //                                isTarget=YES;
    //                                break;
    //                            }
    //                        }
    //                    }
    //                    if ([fisdir isEqualToString:@"0"]&&!isTarget) {
    //                        NSString *fcmd=[dic objectForKey:@"fcmd"];
    //                        if ([self.roletype isEqualToString:@"1"]&&[self hasCmd:@"upload" InFcmd:fcmd]&&[self hasCmd:@"mkdir" InFcmd:fcmd]) {
    //                            //[array addObject:dic];
    //                        }else
    //                        {
    //                            [array addObject:dic];
    //                        }
    //                    }
    //                }
    //                self.finderArray=array;
    //                [self.tableView reloadData];
    //            }
    //        }
    //    }
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    //    NSString *authModelID=self.roletype;
    //    if ([authModelID isEqualToString:@"1"]&&[self.f_id intValue]==0) {
    //        authModelID=@"0";
    //    }
    //    [self.fm openFinderWithID:self.f_id sID:self.spid authModelId:authModelID];
    NSString *item=@"";
    switch (self.type) {
        case kSelectTypeCopy:
            item=@"upload,mkdir";
            break;
        case kSelectTypeMove:
            item=@"upload,mkdir";
            break;
        case kSelectTypeUpload:
            item=@"upload";
            break;
        default:
            break;
    }
    [self.fm nodeListWithID:self.f_id sID:self.spid targetFIDS:self.targetsArray itemType:item];
}
- (void)operateUpdate
{
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    //    NSString *authModelID=self.roletype;
    //    if ([authModelID isEqualToString:@"1"]&&[self.f_id intValue]==0) {
    //        authModelID=@"0";
    //    }
    //    [self.fm operateUpdateWithID:self.f_id sID:self.spid authModelId:authModelID];
    NSString *item=@"";
    switch (self.type) {
        case kSelectTypeCopy:
            item=@"upload,mkdir";
            break;
        case kSelectTypeMove:
            item=@"upload,mkdir";
            break;
        case kSelectTypeUpload:
            item=@"upload";
            break;
        default:
            break;
    }
    [self.fm nodeListWithID:self.f_id sID:self.spid targetFIDS:self.targetsArray itemType:item];
}
- (void)moveFileToHere:(id)sender
{
    switch (self.type) {
        case kSelectTypeDefault:
        case kSelectTypeMove:
            if (![self.roletype isEqualToString:@"2"]&&[self.f_id intValue]==0&&self.isHasSelectFile) {
                if (self.hud) {
                    [self.hud removeFromSuperview];
                }
                self.hud=nil;
                self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                [self.view.superview addSubview:self.hud];
                [self.hud show:NO];
                self.hud.labelText=@"文件库根目录下仅允许文件夹!";
                self.hud.mode=MBProgressHUDModeText;
                self.hud.margin=10.f;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:1.0f];
                return;
                
            }
            [self.delegate moveFileToID:self.f_id spid:self.spid];
            break;
        case kSelectTypeCopy:
            if (![self.roletype isEqualToString:@"2"]&&[self.f_id intValue]==0&&self.isHasSelectFile) {
                if (self.hud) {
                    [self.hud removeFromSuperview];
                }
                self.hud=nil;
                self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                [self.view.superview addSubview:self.hud];
                [self.hud show:NO];
                self.hud.labelText=@"文件库根目录下仅允许文件夹!";
                self.hud.mode=MBProgressHUDModeText;
                self.hud.margin=10.f;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:1.0f];
                return;
                
            }
            [self.delegate copyFileToID:self.f_id spid:self.spid];
            break;
        case kSelectTypeCommit:
            [self.delegate commitFileToID:self.f_id sID:self.spid];
            break;
        case kSelectTypeResave:
            [self.delegate resaveFileToID:self.f_id spid:self.spid];
            break;
        case kSelectTypeUpload:
            //            [self.qbDelegate uploadFileder:f_name];
            //            [self.qbDelegate uploadFiledId:f_id];
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.file_url = self.rootName;
            
            [self.delegate uploadFileder:self.title];
            [self.delegate uploadSpid:self.spid];
            [self.delegate uploadFiledId:self.f_id];
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    for(int i=self.navigationController.viewControllers.count-1;i>=0;i--)
    {
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:i];
        if([viewController isKindOfClass:[FileListViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
        else if([viewController isKindOfClass:[QBAssetCollectionViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
    
}
- (void)moveCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    for(int i=self.navigationController.viewControllers.count-1;i>=0;i--)
    {
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:i];
        if([viewController isKindOfClass:[FileListViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
        else if([viewController isKindOfClass:[QBAssetCollectionViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}
-(void)newFinder:(id)sender
{
    NSLog(@"点击新建文件夹");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //[[alert textFieldAtIndex:0] setText:@"新建文件夹"];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [alert show];
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
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.finderArray) {
        return self.finderArray.count;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 5, 200, 21)];
        UILabel *detailTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 30, 200, 21)];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:detailTextLabel];
        imageView.tag=1;
        textLabel.tag=2;
        detailTextLabel.tag=3;
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [detailTextLabel setTextColor:[UIColor grayColor]];
    }
    UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailTextLabel=(UILabel *)[cell.contentView viewWithTag:3];
    if (self.finderArray) {
        NSDictionary *dic=[self.finderArray objectAtIndex:indexPath.row];
        if (dic) {
            textLabel.text=[dic objectForKey:@"fname"];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                imageView.image=[UIImage imageNamed:@"file_folder.png"];
            }
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.finderArray) {
        NSDictionary *dic=[self.finderArray objectAtIndex:indexPath.row];
        if (dic) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=self.spid;
                flVC.f_id=[dic objectForKey:@"fid"];
                flVC.title=[dic objectForKey:@"fname"];
                flVC.fcmd=[dic objectForKey:@"fcmd"];
                flVC.delegate=self.delegate;
                flVC.type=self.type;
                flVC.targetsArray=self.targetsArray;
                flVC.isHasSelectFile=self.isHasSelectFile;
                flVC.rootName = self.rootName;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }
    }
}
#pragma mark - SCBFileManagerDelegate
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
    //    [self doneLoadingTableViewData];
}
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        //        self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
        //        NSMutableArray *array=[[NSMutableArray alloc] init];
        //        for (NSDictionary *dic in self.listArray) {
        //            NSString *fisdir=[dic objectForKey:@"fisdir"];
        //            NSString *fid=[dic objectForKey:@"fid"];
        //            BOOL isTarget=NO;
        //            if ((self.type==kSelectTypeMove&&self.targetsArray!=nil)) {
        //                for (NSString *f_id in self.targetsArray) {
        //                    NSString *str1=[NSString stringWithFormat:@"%@",f_id];
        //                    NSString *str2=[NSString stringWithFormat:@"%@",fid];
        //                    if ([str1 isEqualToString:str2]) {
        //                        isTarget=YES;
        //                        break;
        //                    }
        //                }
        //            }
        //            if ([fisdir isEqualToString:@"0"]&&!isTarget) {
        //                NSString *fcmd=[dic objectForKey:@"fcmd"];
        //                if ([self.roletype isEqualToString:@"1"]&&[self hasCmd:@"upload" InFcmd:fcmd]&&[self hasCmd:@"mkdir" InFcmd:fcmd]) {
        //                    //[array addObject:dic];
        //                }else
        //                {
        //                    [array addObject:dic];
        //                }
        //            }
        //        }
        self.finderArray=self.listArray=(NSArray *)self.dataDic;
        [self.tableView reloadData];
        //        NSString *dataFilePath=[YNFunctions getDataCachePath];
        //        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
        //        NSError *jsonParsingError=nil;
        //        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        //        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        //        if (isWrite) {
        //            NSLog(@"写入文件成功：%@",dataFilePath);
        //        }else
        //        {
        //            NSLog(@"写入文件失败：%@",dataFilePath);
        //        }
    }
    NSLog(@"openFinderSucess:");
}
-(void)operateSucess:(NSDictionary *)datadic
{
    [self openFinderSucess:datadic];
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
    [self.hud hide:YES afterDelay:1.0f];
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
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSString *fildtext=[[alertView textFieldAtIndex:0] text];
        if (![fildtext isEqualToString:@""]) {
            NSLog(@"重命名");
            [self.fm cancelAllTask];
            self.fm=[[SCBFileManager alloc] init];
            [self.fm newFinderWithName:fildtext pID:self.f_id sID:self.spid];
            [self.fm setDelegate:self];
        }
    }else
    {
        NSLog(@"点击其它");
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

-(void)updateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MyTabBarViewController *tabbar = [appleDate.splitVC.viewControllers firstObject];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 768-49-64);
        }else
        {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 768-49-64-20);
        }
        if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.toolbar.frame=CGRectMake(0, 768-49-64-20, 320, 49);
        }else
        {
            self.toolbar.frame=CGRectMake(0, 768-49-64, 320, 49);
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 1024-49-64);
        }else
        {
            self.tableView.frame=CGRectMake(0, 0, tabbar.view.frame.size.width, 1024-49-64-20);
        }
        if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
            self.toolbar.frame=CGRectMake(0, 1024-49-64-20, 320, 49);
        }else
        {
            self.toolbar.frame=CGRectMake(0, 1024-49-64, 320, 49);
        }
    }
}

@end
