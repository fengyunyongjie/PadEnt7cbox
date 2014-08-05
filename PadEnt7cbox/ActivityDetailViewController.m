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
#import "MainViewController.h"
#import "SCBFileManager.h"
#import "DownList.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "NSString+Format.h"
#import "ResourceFinderViewController.h"
#import "PhotoLookViewController.h"
#import "YNFunctions.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "SCBSubjectManager.h"

typedef enum{
    kActionTypeOpen,
    kActionTypeDownload,
    kActionTypeResave,
    kActionTypeReview,
}ActionType;

@interface ActivityDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AVAudioPlayer  *audioPlayer;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) NSArray *resourceArray;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) NSArray *selectids;
@property (assign,nonatomic) ActionType actionType;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
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
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
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
        NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        NSDictionary *dic=[eveFileUrl objectAtIndex:indexPath.row];
        if (![dic objectForKey:@"resourceid"]) {
            [self showMessage:@"该文件已被删除或取消共享。"];
            return;
        }else
        {
            [self isExistResourceID:[dic objectForKey:@"resourceid"]];
            self.selectedIndexPath=indexPath;
            self.actionType=kActionTypeDownload;
            return;
        }
//        NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_id"]];
//        NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_thumb"]];
//        if([thumb length]==0)
//        {
//            thumb = @"0";
//        }
//        NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_name"]];
//        NSInteger fsize = [[dic objectForKey:@"file_size"] integerValue];
//        
//        DownList *list = [[DownList alloc] init];
//        list.d_name = name;
//        list.d_downSize = fsize;
//        list.d_thumbUrl = thumb;
//        list.d_file_id = file_id;
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSDate *todayDate = [NSDate date];
//        list.d_datetime = [dateFormatter stringFromDate:todayDate];
//        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [delegate.downmange addDownLists:[NSMutableArray arrayWithObjects:list, nil]];
    }
}

- (void)resaveAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        NSDictionary *dic=[eveFileUrl objectAtIndex:indexPath.row];
        if (![dic objectForKey:@"resourceid"]) {
            [self showMessage:@"该文件已被删除或取消共享。"];
            return;
        }else
        {
            [self isExistResourceID:[dic objectForKey:@"resourceid"]];
            self.selectedIndexPath=indexPath;
            self.actionType=kActionTypeResave;
            return;
        }
//        self.selectids=@[[dic objectForKey:@"f_id"]];
//        MainViewController *flvc=[[MainViewController alloc] init];
//        flvc.title=@"选择转存的位置";
//        flvc.delegate=self;
//        flvc.type=kTypeResave;
//        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
//        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
//        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
//        [nav.navigationBar setTintColor:[UIColor whiteColor]];
//        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)reviewAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        NSDictionary *dic=[eveFileUrl objectAtIndex:indexPath.row];
        NSString *urlStr = [dic objectForKey:@"url"];
        NSString *f_isdir=[dic objectForKey:@"f_isdir"];
        
        NSMutableDictionary *resourceDic=[NSMutableDictionary dictionary];
        
        if (![dic objectForKey:@"resourceid"]) {
            [self showMessage:@"该文件已被删除或取消共享。"];
            return;
        }else
        {
            [self isExistResourceID:[dic objectForKey:@"resourceid"]];
            self.selectedIndexPath=indexPath;
            self.actionType=kActionTypeReview;
            return;
        }
//        [resourceDic setObject:[dic objectForKey:@"resourceid"] forKey:@"resource_id"];
//        if (urlStr) {
//            [resourceDic setObject:@3 forKey:@"type"];
//            [resourceDic setObject:[dic objectForKey:@"url"] forKey:@"details"];
//            [resourceDic setObject:[dic objectForKey:@"urlTitle"] forKey:@"file_name"];
//        }else if([f_isdir intValue]==0)
//        {
//            [resourceDic setObject:@1 forKey:@"type"];
//            [resourceDic setObject:[dic objectForKey:@"f_name"] forKey:@"file_name"];
//        }else
//        {
//            [resourceDic setObject:@2 forKey:@"type"];
//            [resourceDic setObject:[dic objectForKey:@"f_name"] forKey:@"file_name"];
//            [resourceDic setObject:[dic objectForKey:@"f_thumb"] forKey:@"f_thumb"];
//        }
//        
//        ResourceCommentViewController *resourceCommentViewController=[ResourceCommentViewController new];
//        resourceCommentViewController.resourceID=[dic objectForKey:@"resourceid"];
//        resourceCommentViewController.resourceDic=resourceDic;
//        resourceCommentViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
//        resourceCommentViewController.modalPresentationStyle=UIModalPresentationPageSheet;
//        [self presentViewController:resourceCommentViewController animated:YES completion:nil];
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

-(void)isExistResourceID:(NSString *)resID
{
    SCBSubjectManager *sm=[SCBSubjectManager new];
    sm.delegate=self;
    [sm requestSubjectIsExistWithResouceId:resID];
}

- (void)getFileWithFileId:(NSString *)file_id {
    
    SCBFileManager *fm = [[SCBFileManager alloc] init];
    fm.delegate = self;
    [fm requestEntFileInfo:file_id];
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
    NSString *eveType=[content objectForKey:@"eveType"];
    NSString *eveSeconds=[content objectForKey:@"eveSeconds"];
    
    if (indexPath.section==0) {
        static NSString *cellIdentifier = @"Cell";
        SubjectActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectActivityCell"  owner:self options:nil] lastObject];
            cell.backgroundColor=[UIColor clearColor];
        }
        cell.personLabel.text=[content objectForKey:@"eveName"];
        cell.contentLabel.text=[content objectForKey:@"eveContent"];
        cell.timeLabel.text=[NSString getTimeFormat:[content objectForKey:@"eveTime"]];
        
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
            
            if(cellType==5&&eveType&&eveType.intValue==1)
            {
                cell.contentLabel.hidden=YES;
                cell.resourceImageView.hidden=NO;
                cell.resourceLabel.hidden=NO;
                cell.resourceImageView.image=[UIImage imageNamed:@"sub_yuyin_ico.png"];
                cell.resourceLabel.text=[NSString stringWithFormat:@"%@''",eveSeconds];
            }
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
    if (indexPath.section==0) {
        NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
        NSString *eveType=[content objectForKey:@"eveType"];
        NSString *eveSeconds=[content objectForKey:@"eveSeconds"];
        NSString *eveContent=[content objectForKey:@"eveContent"];
        if (indexPath.row==1) {
            if (eveType&&eveType.intValue==1) {
                //语音评论  播放主意
                [self getFileWithFileId:eveContent];
            }
        }
        return;
    }
    
    NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
    NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
    NSDictionary *dic=[eveFileUrl objectAtIndex:indexPath.row];
    NSString *urlStr = [dic objectForKey:@"url"];
    NSString *f_isdir=[dic objectForKey:@"f_isdir"];
    
    if (![dic objectForKey:@"resourceid"]) {
        [self showMessage:@"该文件已被删除或取消共享。"];
        return;
    }else
    {
        [self isExistResourceID:[dic objectForKey:@"resourceid"]];
        self.selectedIndexPath=indexPath;
        self.actionType=kActionTypeOpen;
        return;
    }
//    [resourceDic setObject:[dic objectForKey:@"resourceid"] forKey:@"resource_id"];
//    if (urlStr) {
//        //打开链接
//        NSString *urlString = [dic objectForKey:@"url"];
//        if (![urlString hasPrefix:@"http://"]) {
//            urlString = [NSString stringWithFormat:@"http://%@",urlString];
//        }
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
//
//    }else if([f_isdir intValue]==0)
//    {
//        //打开目录
//        ResourceFinderViewController *finderViewController=[ResourceFinderViewController new];
//        finderViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
//        finderViewController.fID=[dic objectForKey:@"file_id"];
//        finderViewController.title=[dic objectForKey:@"f_name"];
//        [self.navigationController pushViewController:finderViewController animated:YES];
//    }else
//    {
//        NSString *fname=[dic objectForKey:@"f_name"];
//        NSString *fmime=[[dic objectForKey:@"f_mime"] lowercaseString];
//        NSString *fid=[dic objectForKey:@"f_id"];
//        //打开文件
//        if ([fmime isEqualToString:@"png"]||
//            [fmime isEqualToString:@"jpg"]||
//            [fmime isEqualToString:@"jpeg"]||
//            [fmime isEqualToString:@"bmp"]||
//            [fmime isEqualToString:@"gif"]){
//            //打开图片
//            DownList *list = [[DownList alloc] init];
//            list.d_file_id = fid;
//            list.d_thumbUrl = [dic objectForKey:@"f_thumb"];
//            if([list.d_thumbUrl length]==0)
//            {
//                list.d_thumbUrl = @"0";
//            }
//            list.d_name = fname;
//            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
//            list.d_downSize = [[dic objectForKey:@"file_size"] intValue];
//            
//            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
//            [tableArray addObject:list];
//            if([tableArray count]>0)
//            {
//                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
//                [look setTableArray:tableArray];
//                [self presentViewController:look animated:YES completion:nil];
//            }
//        }else
//        {
//            //打开其它文件
//            NSString *fname=[dic objectForKey:@"f_name"];
//            NSString *fid=[dic objectForKey:@"f_id"];
//            NSString *documentDir = [YNFunctions getFMCachePath];
//            NSArray *array=[fname componentsSeparatedByString:@"/"];
//            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
//            [NSString CreatePath:createPath];
//            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
//                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
//                browser.dataSource=browser;
//                browser.delegate=browser;
//                browser.currentPreviewItemIndex=0;
//                browser.title=fname;
//                browser.filePath=savedPath;
//                browser.fileName=fname;
//                [self presentViewController:browser animated:YES completion:nil];
//            } else {
//                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
//                NSArray *values = [NSArray arrayWithObjects:fname,fid,[dic objectForKey:@"file_size"], nil];
//                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
//                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
//                
//                otherBrowser.dataDic=d;
//                otherBrowser.title=fname;
//                otherBrowser.dpDelegate=self;
//                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:otherBrowser];
//                [self presentViewController:nav animated:YES completion:nil];
//            }
//        }
//    }
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

-(void)didSubjectIsExist:(NSDictionary *)datadic
{
    if ([datadic objectForKey:@"code"]&&[[datadic objectForKey:@"code"] intValue]==0) {
        if (!self.selectedIndexPath) {
            return;
        }
        NSInteger fsize=[[datadic objectForKey:@"fsize"] integerValue];
        
        if (self.actionType==kActionTypeOpen) {
            NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic=[eveFileUrl objectAtIndex:self.selectedIndexPath.row];
            NSString *urlStr = [dic objectForKey:@"url"];
            NSString *f_isdir=[dic objectForKey:@"f_isdir"];
            
            NSMutableDictionary *resourceDic=[NSMutableDictionary dictionary];
            
            if (![dic objectForKey:@"resourceid"]) {
                [self showMessage:@"该文件已被删除或取消共享。"];
                return;
            }
            [resourceDic setObject:[dic objectForKey:@"resourceid"] forKey:@"resource_id"];
            if (urlStr) {
                //打开链接
                NSString *urlString = [dic objectForKey:@"url"];
                if (![urlString hasPrefix:@"http://"]) {
                    urlString = [NSString stringWithFormat:@"http://%@",urlString];
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                
            }else if([f_isdir intValue]==0)
            {
                //打开目录
                ResourceFinderViewController *finderViewController=[ResourceFinderViewController new];
                finderViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
                finderViewController.fID=[dic objectForKey:@"f_id"];
                finderViewController.title=[dic objectForKey:@"f_name"];
                [self.navigationController pushViewController:finderViewController animated:YES];
            }else
            {
                NSString *fname=[dic objectForKey:@"f_name"];
                NSString *fmime=[[dic objectForKey:@"f_mime"] lowercaseString];
                NSString *fid=[dic objectForKey:@"f_id"];
                //打开文件
                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"]){
                    //打开图片
                    DownList *list = [[DownList alloc] init];
                    list.d_file_id = fid;
                    list.d_thumbUrl = [dic objectForKey:@"f_thumb"];
                    if([list.d_thumbUrl length]==0)
                    {
                        list.d_thumbUrl = @"0";
                    }
                    list.d_name = fname;
                    list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
                    list.d_downSize = fsize;
                    
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
                    NSString *fname=[dic objectForKey:@"f_name"];
                    NSString *fid=[dic objectForKey:@"f_id"];
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
                        NSArray *values = [NSArray arrayWithObjects:fname,fid,@(fsize), nil];
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

        }else if (self.actionType==kActionTypeDownload)
        {
            NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic=[eveFileUrl objectAtIndex:self.selectedIndexPath.row];
            if (![dic objectForKey:@"resourceid"]) {
                [self showMessage:@"该文件已被删除或取消共享。"];
                return;
            }
            NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_id"]];
            NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_thumb"]];
            if([thumb length]==0)
            {
                thumb = @"0";
            }
            NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"f_name"]];
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
        }else if (self.actionType==kActionTypeResave)
        {
            NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic=[eveFileUrl objectAtIndex:self.selectedIndexPath.row];
            if (![dic objectForKey:@"resourceid"]) {
                [self showMessage:@"该文件已被删除或取消共享。"];
                return;
            }
            self.selectids=@[[dic objectForKey:@"f_id"]];
            MainViewController *flvc=[[MainViewController alloc] init];
            flvc.title=@"选择转存的位置";
            flvc.delegate=self;
            flvc.type=kTypeResave;
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
            [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
            [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
            //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
            [nav.navigationBar setTintColor:[UIColor whiteColor]];
            [self presentViewController:nav animated:YES completion:nil];
        }else if (self.actionType==kActionTypeReview)
        {
            NSDictionary *content=[NSString stringWithDictionS:[self.dic objectForKey:@"content"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic=[eveFileUrl objectAtIndex:self.selectedIndexPath.row];
            NSString *urlStr = [dic objectForKey:@"url"];
            NSString *f_isdir=[dic objectForKey:@"f_isdir"];
            
            NSMutableDictionary *resourceDic=[NSMutableDictionary dictionary];
            
            if (![dic objectForKey:@"resourceid"]) {
                [self showMessage:@"该文件已被删除或取消共享。"];
                return;
            }
            [resourceDic setObject:[dic objectForKey:@"resourceid"] forKey:@"resource_id"];
            if (urlStr) {
                [resourceDic setObject:@3 forKey:@"type"];
                [resourceDic setObject:[dic objectForKey:@"url"] forKey:@"details"];
                [resourceDic setObject:[dic objectForKey:@"urlTitle"] forKey:@"file_name"];
            }else if([f_isdir intValue]==0)
            {
                [resourceDic setObject:@1 forKey:@"type"];
                [resourceDic setObject:[dic objectForKey:@"f_name"] forKey:@"file_name"];
            }else
            {
                [resourceDic setObject:@2 forKey:@"type"];
                [resourceDic setObject:[dic objectForKey:@"f_name"] forKey:@"file_name"];
                [resourceDic setObject:[dic objectForKey:@"f_thumb"] forKey:@"f_thumb"];
            }
            
            ResourceCommentViewController *resourceCommentViewController=[ResourceCommentViewController new];
            resourceCommentViewController.resourceID=[dic objectForKey:@"resourceid"];
            resourceCommentViewController.resourceDic=resourceDic;
            resourceCommentViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
            resourceCommentViewController.modalPresentationStyle=UIModalPresentationPageSheet;
            [self presentViewController:resourceCommentViewController animated:YES completion:nil];
        }
    }else
    {
        [self showMessage:@"该文件已被删除或取消共享。"];
    }
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

- (void)getFileEntInfo:(NSDictionary *)dictionary {
    [self downLoad:dictionary];
}

- (void)downLoad:(NSDictionary *)dic {
    
    NSString *file_id = [dic objectForKey:@"fid"];
    NSString *f_name = [dic objectForKey:@"fname"];
    NSInteger size = [[dic objectForKey:@"fsize"] integerValue];
    DwonFile *down = [[DwonFile alloc] init];
    [down setFile_id:file_id];
    [down setFileName:f_name];
    [down setFileSize:size];
    [down setDelegate:self];
    [down startDownload];
}

- (void)downFinish:(NSString *)baseUrl {
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:baseUrl];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer play];
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{}
-(void)downCurrSize:(NSInteger)currSize
{}
-(void)didFailWithError
{
    [self showMessage:@"播放语音失败"];
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
@end
