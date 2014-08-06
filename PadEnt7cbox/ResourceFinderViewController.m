//
//  ResourceFinderViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-30.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "ResourceFinderViewController.h"
#import "ResourceFileCell.h"
#import "SCBSubjectManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "PhotoLookViewController.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "DownList.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "NSString+Format.h"
#import "MainViewController.h"
#import "SCBFileManager.h"

@interface ResourceFinderViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate,IconDownloaderDelegate,DownloadProgressDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSDictionary *dataDic;
@property(strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) NSArray *selectids;
@property (nonatomic,strong) SCBFileManager *fm_move;
@end

@implementation ResourceFinderViewController

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
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 操作方法
- (void)updateList {
    SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
    sm.delegate = self;
    [sm getResourceFileWithSubjectId:self.subjectID f_id:self.fID];
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
        flvc.type=kTypeResave;
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        [self presentViewController:nav animated:YES completion:nil];
    }
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
    ResourceFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"ResourceFileCell"  owner:self options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *fisdir=[dic objectForKey:@"type"];
    int isPublish = [[dic objectForKey:@"isPublisher"] intValue];
    NSString *fname=[dic objectForKey:@"file_name"];
    cell.fileNameLabel.text=fname;
    [cell.downloadButton addTarget:self action:@selector(downloadAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.resaveButton addTarget:self action:@selector(resaveAction:event:) forControlEvents:UIControlEventTouchUpInside];
    if (fisdir.intValue == 1) {
        //文件夹
        cell.iconImageView.image=[UIImage imageNamed:@"file_folder.png"];
        cell.downloadButton.hidden=YES;
        if (isPublish == 1) {
            //不可以转存
        } else {
            //可以转存
        }
    }else{
//        cell.resaveButton.hidden=YES;
        NSString *fmime=[dic objectForKey:@"file_mime"];
        fmime = [fmime lowercaseString];
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
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
    NSString *fisdir=[dic objectForKey:@"type"];
    NSString *fname = [dic objectForKey:@"file_name"];
    if (fisdir.intValue == 1) {
        //打开目录
        ResourceFinderViewController *finderViewController=[ResourceFinderViewController new];
        finderViewController.subjectID=self.subjectID;
        finderViewController.fID=[dic objectForKey:@"file_id"];
        finderViewController.isPublisher=self.isPublisher;
        finderViewController.title=fname;
        [self.navigationController pushViewController:finderViewController animated:YES];
    }else
    {
        NSString *fmime=[dic objectForKey:@"file_mime"];
        
        fmime = [fmime lowercaseString];
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"]){
            
            int row = 0;
            if(indexPath.row<[self.listArray count])
            {
                NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                for(int i=0;i<[self.listArray count];i++) {
                    NSDictionary *diction = [self.listArray objectAtIndex:i];
                    NSString *fname_ = [diction objectForKey:@"file_name"];
                    if(([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"]))
                    {
                        DownList *list = [[DownList alloc] init];
                        list.d_file_id = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_id"]];
                        list.d_thumbUrl = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_thumb"]];
                        if([list.d_thumbUrl length]==0)
                        {
                            list.d_thumbUrl = @"0";
                        }
                        list.d_name = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_name"]];
                        list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
                        list.d_downSize = [[diction objectForKey:@"file_size"] integerValue];
                        [tableArray addObject:list];
                        if(row==0 && [fname isEqualToString:fname_])
                        {
                            row = [tableArray count]-1;
                        }
                    }
                }
                if([tableArray count]>0)
                {
                    PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                    [look setCurrPage:row];
                    [look setTableArray:tableArray];
                    [self presentViewController:look animated:YES completion:nil];
                }
            }
        }else{
            //打开其它文件
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
    return 50;
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

-(void)didGetResourceFile:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"list"];
    [self.tableView reloadData];
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
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
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
@end
