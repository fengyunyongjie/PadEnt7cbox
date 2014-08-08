//
//  SubjectResourceViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectResourceViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SCBSubjectManager.h"
#import "NSString+Format.h"
#import "SubjectResourceCell.h"
#import "YNFunctions.h"
#import "ResourceCommentViewController.h"
#import "ResourceFinderViewController.h"
#import "DownList.h"
#import "PhotoLookViewController.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "SCBFileManager.h"
#import "IconDownloader.h"
#import "AppDelegate.h"
#import "SCBSession.h"

@interface SubjectResourceViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,strong) NSArray *listArray;
@property (nonatomic,strong) SCBSubjectManager *sm_list;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) SCBFileManager *fm_move;
@property (nonatomic,strong) NSArray *selectids;
@property (strong,nonatomic) UILabel * notingLabel;
@property (strong,nonatomic) UIView *nothingView;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@end

@implementation SubjectResourceViewController

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
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
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
    [self.sm_list getResourceListWithSubjectId:[(SubjectDetailTabBarController *)self.tabBarController subjectId] resourceUserIds:@"" resourceType:@"" resourceTitil:@""];
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

-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid
{
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    [self.fm_move resaveFileIDs:self.selectids toPID:f_id sID:spid];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SubjectResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectResourceCell"  owner:self options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
    int commentCount=[[dic objectForKey:@"commentCount"] intValue];
    cell.resourceNameLabel.text=[dic objectForKey:@"file_name"];
    [cell.commentCountButton setTitle:[NSString stringWithFormat:@"%d",commentCount] forState:UIControlStateNormal];
    cell.personLabel.text=[dic objectForKey:@"username"];
    NSString *publishTime = [dic objectForKey:@"publishTime"];
    cell.detailLabel.text=[dic objectForKey:@"details"];
    cell.timeLabel.text=[NSString getTimeFormat:publishTime];
    
    NSString *fname = [dic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    if ([[dic objectForKey:@"isPublisher"] boolValue]) {
//        cell.resaveButton.hidden=YES;
    }
    int file_type = [[dic objectForKey:@"type"] intValue];
    if(file_type == 1) {
        cell.iconImageView.image = [UIImage imageNamed:@"file_folder.png"];
        cell.downloadButton.hidden=YES;
    }else if (file_type == 3) {//链接
        
        cell.iconImageView.image = [UIImage imageNamed:@"sub_link.png"];
        cell.resaveButton.hidden=YES;
        cell.downloadButton.hidden=YES;
    }else { //文件
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"]){
            NSString *fthumb=[dic objectForKey:@"file_thumb"];
            NSString *localThumbPath=[YNFunctions getIconCachePath];
            fthumb =[YNFunctions picFileNameFromURL:fthumb];
            localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
            UIImage *image=[UIImage imageWithContentsOfFile:localThumbPath];
            if (image) {
                cell.iconImageView.image=image;
            }else{
                [self startIconDownload:@{@"fthumb":[dic objectForKey:@"file_thumb"]} forIndexPath:indexPath];
                cell.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
            }
            
        }else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
        }else if ([fmime isEqualToString:@"mp3"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
        }else if ([fmime isEqualToString:@"pdf"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
        }else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
        }else if([fmime isEqualToString:@"txt"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
        }
    }
    [cell.downloadButton addTarget:self action:@selector(downloadAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.resaveButton addTarget:self action:@selector(resaveAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(reviewAction:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
    NSString *fname = [dic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    
    int file_type = [[dic objectForKey:@"type"] intValue];
    if(file_type == 1) {
        //打开目录
        ResourceFinderViewController *finderViewController=[ResourceFinderViewController new];
        finderViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
        finderViewController.fID=[dic objectForKey:@"file_id"];
        finderViewController.title=[dic objectForKey:@"file_name"];
        [self.navigationController pushViewController:finderViewController animated:YES];
    }else if (file_type == 3) {//链接
        //打开链接
        NSString *urlString = [dic objectForKey:@"details"];
        if (![urlString hasPrefix:@"http://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else {
        //打开文件
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"]){
            //打开图片
            DownList *list = [[DownList alloc] init];
            list.d_file_id = [dic objectForKey:@"file_id"];
            list.d_thumbUrl = [dic objectForKey:@"file_thumb"];
            if([list.d_thumbUrl length]==0)
            {
                list.d_thumbUrl = @"0";
            }
            list.d_name = [dic objectForKey:@"file_name"];
            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
            list.d_downSize = [[dic objectForKey:@"file_size"] intValue];
            
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            [tableArray addObject:list];
            if([tableArray count]>0)
            {
                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                [look setTableArray:tableArray];
                [self presentViewController:look animated:YES completion:nil];
            }
        }else
        {
            //打开其它文件
            NSString *fname=[dic objectForKey:@"file_name"];
            NSString *fid=[dic objectForKey:@"file_id"];
            NSString *documentDir = [YNFunctions getFMCachePath];
            NSArray *array=[fname componentsSeparatedByString:@"/"];
            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
            [NSString CreatePath:createPath];
            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                browser.dataSource=browser;
                browser.delegate=browser;
                browser.currentPreviewItemIndex=0;
                browser.title=fname;
                browser.filePath=savedPath;
                browser.fileName=fname;
                [self presentViewController:browser animated:YES completion:nil];
            } else {
                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                NSArray *values = [NSArray arrayWithObjects:fname,fid,[dic objectForKey:@"file_size"], nil];
                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                otherBrowser.dataDic=d;
                otherBrowser.title=fname;
                otherBrowser.dpDelegate=self;
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:otherBrowser];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (void)downloadAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"file_id"]];
        NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"file_thumb"]];
        if([thumb length]==0)
        {
            thumb = @"0";
        }
        NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"file_name"]];
        NSInteger fsize = [[dic objectForKey:@"file_size"] integerValue];
        
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
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.downmange addDownLists:[NSMutableArray arrayWithObjects:list, nil]];
    }
}

- (void)resaveAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        self.selectids=@[[dic objectForKey:@"file_id"]];
        MainViewController *flvc=[[MainViewController alloc] init];
        flvc.title=@"选择转存的位置";
        flvc.delegate=self;
        flvc.type=kTypeCopy;
        flvc.targetsArray=self.selectids;
        flvc.isHasSelectFile=![[dic objectForKey:@"type"] intValue]==1;
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)reviewAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        
        ResourceCommentViewController *resourceCommentViewController=[ResourceCommentViewController new];
        resourceCommentViewController.resourceID=[dic objectForKey:@"resource_id"];
        resourceCommentViewController.resourceDic=dic;
        resourceCommentViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
        resourceCommentViewController.delegate=self;
        resourceCommentViewController.modalPresentationStyle=UIModalPresentationPageSheet;
        [self presentViewController:resourceCommentViewController animated:YES completion:nil];
    }
}

#pragma mark - SCBSubjectManagerDelegate
-(void)didGetResourceList:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"list"];
    if (self.listArray.count>0) {
        [self.nothingView setHidden:YES];
        [self.tableView reloadData];
    }else
    {
        if (!self.nothingView) {
            self.nothingView=[[UIView alloc] initWithFrame:self.tableView.frame];
            [self.nothingView setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:self.nothingView];
            
            CGRect notingRect = CGRectMake(0, (self.view.frame.size.height-40)/2, self.nothingView.bounds.size.width, 40);
            self.notingLabel = [[UILabel alloc] initWithFrame:notingRect];
            [self.notingLabel setTextColor:[UIColor grayColor]];
            [self.notingLabel setFont:[UIFont systemFontOfSize:18]];
            [self.notingLabel setTextAlignment:NSTextAlignmentCenter];
            [self.nothingView addSubview:self.notingLabel];
        }
        [self.view bringSubviewToFront:self.nothingView];
        [self.nothingView setHidden:NO];
        [self.notingLabel setText:@"暂无文件"];
    }
}

-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}

#pragma mark -DownloadProgressDelegate
-(void)downloadFinished:(NSDictionary *)dataDic
{
    NSString *name = [dataDic objectForKey:@"fname"];
    NSString *fid = [dataDic objectForKey:@"fid"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
    [NSString CreatePath:createPath];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    
    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
    browser.dataSource=browser;
    browser.delegate=browser;
    browser.currentPreviewItemIndex=0;
    browser.title=name;
    browser.filePath=savedPath;
    browser.fileName=name;
    [self presentViewController:browser animated:NO completion:nil];
}

#pragma mark - SCBFileManagerDelegate
-(void)moveUnsucess
{
    [self showMessage:@"操作失败"];
}
-(void)moveSucess
{
    [self showMessage:@"操作成功"];
}

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}

-(void)downFileSuccess:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:[NSString stringWithFormat:@"%@ 下载完成",name]];
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        delegate.downmange.managerDelegate = nil;
    });
}

-(void)downFileunSuccess:(NSString *)name
{
    [self showMessage:[NSString stringWithFormat:@"%@ 下载失败",name]];
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
}
@end
