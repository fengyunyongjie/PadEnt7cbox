//
//  SubJectNewDetailViewController.m
//  icoffer
//
//  Created by Yangsl on 14-7-11.
//  Copyright (c) 2014年 All rights reserved.
//

#import "IPSubJectNewDetailViewController.h"
#import "NSString+Format.h"
#import "LookDownFile.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "IPSCBSubJectManager.h"
#import "MainViewController.h"
#import "YNNavigationController.h"
#import "IPSubJectDetailCommentViewController.h"
#import "PhotoLookViewController.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "IPSubJectFileListViewController.h"

@interface IPSubJectNewDetailViewController ()

@end

@implementation IPSubJectNewDetailViewController
@synthesize tableView,dictionary,touchControl,tableArray,editToolbar,selectedButton,hud,dType,selectedIndexPath,isPublish,audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"专题动态详情";
    //返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect tableviewRect = CGRectMake(0, 0, width, height-44-20);
    self.tableView = [[UITableView alloc] initWithFrame:tableviewRect];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.self.tableView];
    
    if(dictionary)
    {
        NSDictionary *content = [NSString stringWithDictionS:[dictionary objectForKey:@"content"]];
        NSArray *eveFileArray = [content objectForKey:@"eveFileUrl"];
        tableArray = [[NSMutableArray alloc] initWithArray:eveFileArray];
    }
    
    //添加编辑视图
    self.editToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.editToolbar setBackgroundImage:[UIImage imageNamed:@"bk_select.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.editToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_selectTop.png"]];
    [jiantou setFrame:CGRectMake(280, -6, 10, 6)];
    [jiantou setTag:2012];
    [self.editToolbar addSubview:jiantou];
    [self.tableView addSubview:self.editToolbar];
    [self.editToolbar setHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)downButtonClicked
{
    [self touchBegainClick];
    NSDictionary *diction = [self getDictionWithIndexPath:selectedButton.tag];
    [self requestResoucesExist:SJNDTypeSelectedDown resouceId:[diction objectForKey:@"resourceid"]];
}

-(void)requestResoucesExist:(SJNDType)type resouceId:(NSString *)resouceId
{
    self.dType = type;
    IPSCBSubJectManager *subject = [[IPSCBSubJectManager alloc] init];
    [subject setDelegate:self];
    [subject requestSubjectIsExistWithResouceId:resouceId];
}

-(void)copyButtonClicked
{
    [self touchBegainClick];
    NSDictionary *dic = [self getDictionWithIndexPath:selectedButton.tag];
    [self requestResoucesExist:SJNDTypeSelectedCopy resouceId:[dic objectForKey:@"resourceid"]];
}

-(void)commentButtonClicked
{
    [self touchBegainClick];
    NSDictionary *dic = [self getDictionWithIndexPath:selectedButton.tag];
    [self requestResoucesExist:SJNDTypeSelectedComment resouceId:[dic objectForKey:@"resourceid"]];
}

-(void)updaTextImage:(NSString *)fmime view:(UIImageView *)textImageView
{
    if ([fmime isEqualToString:@"doc"]||
        [fmime isEqualToString:@"docx"]||
        [fmime isEqualToString:@"rtf"])
    {
        textImageView.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        textImageView.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        textImageView.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        textImageView.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        textImageView.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        textImageView.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        textImageView.image = [UIImage imageNamed:@"file_txt.png"];
    }
    else
    {
        textImageView.image = [UIImage imageNamed:@"file_other.png"];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView setText:@""];
    [self.touchControl setHidden:NO];
}

-(void)backClicked
{
    //返回上一级
    NSLog(@"返回上一级");
    if(audioPlayer.isPlaying)
    {
        [audioPlayer stop];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)touchBegainClick
{
    [self.editToolbar setHidden:YES];
    [self.touchControl setHidden:YES];
    if(selectedButton)
    {
        [selectedButton setSelected:NO];
    }
}

- (void)downLoadFile:(NSDictionary *)diction withIndexPath:(NSIndexPath *)indexPath
{
    //下载图片
    NSString *f_id = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_id"]];
    NSString *f_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_name"]];
    LookDownFile *downImage = [[LookDownFile alloc] init];
    [downImage setFile_id:f_id];
    [downImage setFileName:f_name];
    [downImage setIndexPath:indexPath];
    [downImage setDelegate:self];
    [downImage startDownload];
}

#pragma mark - LookFileDelegate

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    MainDetailViewCell *cell = (MainDetailViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *textImageView = cell.imageView;
    if([UIImage imageWithContentsOfFile:path])
    {
        textImageView.image = [UIImage imageWithContentsOfFile:path];
    }
    else
    {
        textImageView.image = [UIImage imageNamed:@"file_pic.png"];
    }
}

- (void)downFinish:(NSString *)baseUrl
{
    NSString *fmime=[[baseUrl pathExtension] lowercaseString];
    if([fmime isEqualToString:@"mp3"])
    {
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:baseUrl];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [audioPlayer play];
    }
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    
}

-(void)didFailWithError
{
    
}

//上传失败
-(void)downError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"该文件已被删除或取消共享";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
//服务器异常
-(void)webServiceFail{}
//上传无权限
-(void)upNotUpload{}
//用户存储空间不足
-(void)upUserSpaceLass{}
//等待WiFi
-(void)upWaitWiFi{}
//网络失败
-(void)upNetworkStop{}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SCBSubjectManagerDelegate

- (void)getResourceExistSuccess:(NSDictionary *)dictionSize
{
    NSDictionary *diction = [self getDictionWithIndexPath:selectedIndexPath.row];
    NSString *name = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_name"]];
    if([dictionSize objectForKey:@"code"])
    {
        if([[dictionSize objectForKey:@"code"] intValue] == 0)
        {
            if(self.dType == SJNDTypeSelectedCell)
            {
                if([diction objectForKey:@"f_isdir"])
                {
                    if([[diction objectForKey:@"f_isdir"] intValue] == 0)
                    {
                        //文件夹进入
                        IPSubJectFileListViewController *flVC = [[IPSubJectFileListViewController alloc] init];
                        NSString *subject_id = [diction objectForKey:@"subject_id"];
                        flVC.subId = subject_id;
                        flVC.fId = [diction objectForKey:@"f_id"];
                        flVC.title = [diction objectForKey:@"f_name"];
                        [self.navigationController pushViewController:flVC animated:YES];
                    }
                    else
                    {
                        NSString *fmime=[[diction objectForKey:@"f_mime"] lowercaseString];
                        if ([fmime isEqualToString:@"png"]||
                            [fmime isEqualToString:@"jpg"]||
                            [fmime isEqualToString:@"jpeg"]||
                            [fmime isEqualToString:@"bmp"]||
                            [fmime isEqualToString:@"gif"])
                        {
                            //文件预览
                            DownList *list = [[DownList alloc] init];
                            list.d_file_id = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_id"]];
                            list.d_thumbUrl = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_thumb"]];
                            if([list.d_thumbUrl length]==0)
                            {
                                list.d_thumbUrl = @"0";
                            }
                            list.d_name = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_name"]];
                            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
                            list.d_downSize = [[dictionSize objectForKey:@"fsize"] integerValue];
                            PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                            [look setCurrPage:0];
                            [look setTableArray:[NSMutableArray arrayWithObject:list]];
                            [self presentViewController:look animated:YES completion:^{
                                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                            }];
                        }
                        else
                        {
                            NSString *file_id=[diction objectForKey:@"f_id"];
                            NSString *f_name=[diction objectForKey:@"f_name"];
                            NSString *documentDir = [YNFunctions getFMCachePath];
                            NSArray *array=[f_name componentsSeparatedByString:@"/"];
                            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
                            [NSString CreatePath:createPath];
                            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                                browser.dataSource=browser;
                                browser.delegate=browser;
                                browser.title=f_name;
                                browser.filePath=savedPath;
                                browser.fileName=f_name;
                                browser.currentPreviewItemIndex=0;
                                [self presentViewController:browser animated:YES completion:nil];
                            }else
                            {
                                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                                NSArray *values = [NSArray arrayWithObjects:f_name,file_id,[dictionSize objectForKey:@"fsize"], nil];
                                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                                otherBrowser.dataDic=d;
                                otherBrowser.title=f_name;
                                [self presentViewController:otherBrowser animated:YES completion:nil];
                            }
                        }
                    }
                }
                else
                {
                    NSString *urlString = [diction objectForKey:@"url"];
                    if (![urlString hasPrefix:@"http://"]) {
                        urlString = [NSString stringWithFormat:@"http://%@",urlString];
                    }
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
            else if(self.dType == SJNDTypeSelectedDown)
            {
                NSString *fileId = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_id"]];
                NSString *thumb = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_thumb"]];
                if([thumb length]==0)
                {
                    thumb = @"0";
                }
                NSInteger fsize = [[dictionSize objectForKey:@"fsize"] integerValue];
                
                NSMutableArray *tableA = [[NSMutableArray alloc] init];
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
                [tableA addObject:list];
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                delegate.downmange.managerDelegate = self;
                [delegate.downmange addDownLists:tableA];
            }
            else if(self.dType == SJNDTypeSelectedCopy)
            {
                MainViewController *flvc=[[MainViewController alloc] init];
                flvc.title=@"选择转存的位置";
                flvc.delegate=self;
                flvc.type=kTypeCopy;
                NSString *fileId = [NSString formatNSStringForOjbect:[diction objectForKey:@"f_id"]];
                flvc.targetsArray=[NSArray arrayWithObject:fileId];
                YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
                [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                [nav.navigationBar setTintColor:[UIColor whiteColor]];
                [self presentViewController:nav animated:YES completion:nil];
            }
            else
            {
                IPSubJectDetailCommentViewController *s = [[IPSubJectDetailCommentViewController alloc] init];
                NSMutableDictionary *tableDiction = [[NSMutableDictionary alloc] init];
                
                NSDictionary *contentDic = [NSString stringWithDictionS:[self.dictionary objectForKey:@"content"]];
                NSDictionary *fileDic = [self getDictionWithIndexPath:selectedIndexPath.row];
                NSString *urlStr = [fileDic objectForKey:@"url"];
                if (urlStr) {
                    NSString *url = [NSString stringWithFormat:@"%@",urlStr];
                    NSString *name = [NSString stringWithFormat:@"%@",url];
                    [tableDiction setObject:name forKey:@"details"];
                    NSNumber *number = [NSNumber numberWithInt:3];
                    [tableDiction setObject:number forKey:@"type"];

                } else {
                    if([[fileDic objectForKey:@"f_isdir"] intValue] == 0) {
                        //文件夹
                        NSString *f_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_name"]];
                        [tableDiction setObject:f_name forKey:@"file_name"];
                        NSNumber *number = [NSNumber numberWithInt:1];
                        [tableDiction setObject:number forKey:@"type"];
                    } else {
                        NSString *f_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_name"]];
                        [tableDiction setObject:f_name forKey:@"file_name"];
                        NSNumber *number = [NSNumber numberWithInt:2];
                        [tableDiction setObject:number forKey:@"type"];
                    }
                }
                NSString *f_thumb = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_thumb"]];
                [tableDiction setObject:f_thumb forKey:@"f_thumb"];
                NSString *resourceid = [NSString stringWithFormat:@"%@",[diction objectForKey:@"resourceid"]];
                [tableDiction setObject:resourceid forKey:@"resource_id"];
                
                s.parentDic = tableDiction;
                s.parent_indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
                NSString *subject_id = [self.dictionary objectForKey:@"subject_id"];
                s.subjectId = subject_id;
                [self.navigationController pushViewController:s animated:YES];
            }
        }
        else
        {
            [self getResourceExistUnsuccess:nil];
        }
    }
    else
    {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"该文件已被删除或取消共享";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
    
}

- (void)getFileWithFileId:(NSString *)file_id {
    SCBFileManager *fm = [[SCBFileManager alloc] init];
    fm.delegate = self;
    [fm requestEntFileInfo:file_id];
}

#pragma mark - SCBFileManager delegate
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

-(void)downFileSuccess:(NSString *)name
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载完成",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
}

-(void)downFileunSuccess:(NSString *)name
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载失败",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
}

- (void)getResourceExistUnsuccess:(NSString *)error_info
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"该文件已被删除或取消共享。";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [IPSubJectNewDetailViewController getTableViewRow:dictionary];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainDetailViewCell *cell = [[MainDetailViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSLog(@"indexPath:%i",indexPath.row);
    cell.isPublish = isPublish;
    cell.updateViewDelegate = self;
    [cell updateCell:self.dictionary indexPath:indexPath];
    if(cell.accessoryButton)
    {
        [cell.accessoryButton  addTarget:self action:@selector(accessoryButtonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - UpdateViewButtonDelegate

-(void)updateViewOneComment
{
    //评论按钮
    CGRect commentRect = CGRectMake(0, 2, 26, 35);
    UIButton *commentButton = [[UIButton alloc] initWithFrame:commentRect];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_nor.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_sel.png"] forState:UIControlStateHighlighted];
    [commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace                                                                                       target: nil                                                                                       action: nil];
    [self.editToolbar setItems:@[commentItem]];
}

-(void)updateViewOneDown
{
    //下载按钮
    CGRect downRect = CGRectMake(0, 2, 26, 35);
    UIButton *downButton = [[UIButton alloc] initWithFrame:downRect];
    [downButton setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [downButton setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [downButton addTarget:self action:@selector(downButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:downButton];
    [self.editToolbar setItems:@[downItem]];
}

-(void)updateViewOneCopy
{
    //转存按钮
    CGRect copyRect = CGRectMake(0, 2, 26, 35);
    UIButton *copyButton = [[UIButton alloc] initWithFrame:copyRect];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    [self.editToolbar setItems:@[copyItem]];
}

-(void)updateViewCopyComment
{
    //转存按钮
    CGRect copyRect = CGRectMake(0, 2, 26, 35);
    UIButton *copyButton = [[UIButton alloc] initWithFrame:copyRect];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    
    //评论按钮
    CGRect commentRect = CGRectMake(0, 2, 26, 35);
    UIButton *commentButton = [[UIButton alloc] initWithFrame:commentRect];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_nor.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_sel.png"] forState:UIControlStateHighlighted];
    [commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace                                                                                       target: nil                                                                                       action: nil];
    [self.editToolbar setItems:@[copyItem,fixedButton,commentItem]];
}

-(void)updateViewCommentAndDown
{
    //下载按钮
    CGRect downRect = CGRectMake(0, 2, 26, 35);
    UIButton *downButton = [[UIButton alloc] initWithFrame:downRect];
    [downButton setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [downButton setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [downButton addTarget:self action:@selector(downButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:downButton];
    
    //评论按钮
    CGRect commentRect = CGRectMake(0, 2, 26, 35);
    UIButton *commentButton = [[UIButton alloc] initWithFrame:commentRect];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_nor.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_sel.png"] forState:UIControlStateHighlighted];
    [commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace                                                                                       target: nil                                                                                       action: nil];
    [self.editToolbar setItems:@[downItem,fixedButton,commentItem]];
}

-(void)updateViewCopyAndDown
{
    //下载按钮
    CGRect downRect = CGRectMake(0, 2, 26, 35);
    UIButton *downButton = [[UIButton alloc] initWithFrame:downRect];
    [downButton setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [downButton setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [downButton addTarget:self action:@selector(downButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:downButton];
    
    //转存按钮
    CGRect copyRect = CGRectMake(0, 2, 26, 35);
    UIButton *copyButton = [[UIButton alloc] initWithFrame:copyRect];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace                                                                                       target: nil                                                                                       action: nil];
    
    [self.editToolbar setItems:@[downItem,fixedButton,copyButton]];
}

-(void)updateViewOneAll
{
    //下载按钮
    CGRect downRect = CGRectMake(0, 2, 26, 35);
    UIButton *downButton = [[UIButton alloc] initWithFrame:downRect];
    [downButton setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [downButton setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [downButton addTarget:self action:@selector(downButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:downButton];
    
    //转存按钮
    CGRect copyRect = CGRectMake(0, 2, 26, 35);
    UIButton *copyButton = [[UIButton alloc] initWithFrame:copyRect];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    
    //评论按钮
    CGRect commentRect = CGRectMake(0, 2, 26, 35);
    UIButton *commentButton = [[UIButton alloc] initWithFrame:commentRect];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_nor.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"sub_bt_comment_sel.png"] forState:UIControlStateHighlighted];
    [commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace                                                                                       target: nil                                                                                       action: nil];
    [self.editToolbar setItems:@[downItem,fixedButton,copyItem,fixedButton,commentItem]];
}

- (void)accessoryButtonPressedAction: (id)sender
{
    if(self.touchControl==nil)
    {
        //添加触摸按钮
        float width = self.view.frame.size.width;
        float heigth = self.view.frame.size.height;
        if(heigth<self.tableView.contentSize.height)
        {
            heigth = self.tableView.contentSize.height;
        }
        self.touchControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, width, heigth)];
        [self.touchControl addTarget:self action:@selector(touchBegainClick) forControlEvents:UIControlEventTouchDown];
        [self.touchControl setBackgroundColor:[UIColor clearColor]];
        [self.tableView addSubview:self.touchControl];
    }
    [self.touchControl setHidden:NO];
    
    UIButton *button = (UIButton *)sender;
    selectedButton = button;
    [button setSelected:YES];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:button.tag inSection:0];
    self.selectedIndexPath = indexPath;
    MainDetailViewCell *cell = (MainDetailViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"frame:%@",NSStringFromCGRect(cell.frame));
    
    NSInteger number = [self.tableView numberOfRowsInSection:0];
    float editToolbarY = 0;
    if(indexPath.row+1==number && cell.frame.origin.y+40>=self.tableView.frame.size.height)
    {
        editToolbarY = cell.frame.origin.y-40;
        UIImageView *imageView=(UIImageView *)[self.editToolbar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        imageView.frame=CGRectMake(280, 40, 10, 6);
    }
    else
    {
        editToolbarY = cell.frame.origin.y+40;
        UIImageView *imageView=(UIImageView *)[self.editToolbar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        imageView.frame=CGRectMake(280, -6, 10, 6);
    }
    CGRect toolRect = self.editToolbar.frame;
    toolRect.origin.y = editToolbarY;
    [self.editToolbar setFrame:toolRect];
    [self.tableView bringSubviewToFront:self.editToolbar];
    [self.editToolbar setHidden:NO];
}

-(NSDictionary *)getDictionWithIndexPath:(NSInteger)number
{
    NSDictionary *content = [NSString stringWithDictionS:[self.dictionary objectForKey:@"content"]];
    int eventType = [[content objectForKey:@"eveType"] intValue];
    NSString *eveContent = [content objectForKey:@"eveContent"];
    if (eventType == 1 && number-1 == 0)
    {
        NSDictionary *audioDic = [NSDictionary dictionaryWithObjectsAndKeys:eveContent,@"audioID", nil];
        return audioDic;
    }
    
    NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:self.dictionary];
    NSInteger cellRow = 0;
    if(count==2)
    {
        cellRow = number-1;
    }
    else
    {
        cellRow = number-2;
    }
    if(cellRow < [tableArray count])
    {
        NSDictionary *dic = [tableArray objectAtIndex:cellRow];
        return dic;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    NSDictionary *dic = [self getDictionWithIndexPath:indexPath.row];
    if (dic) {
        if([dic objectForKey:@"resourceid"])
        {
            [self requestResoucesExist:SJNDTypeSelectedCell resouceId:[dic objectForKey:@"resourceid"]];
        }
        else if([dic objectForKey:@"audioID"])
        {
            //读取语音
            NSString *audioId = [dic objectForKey:@"audioID"];
            [self getFileWithFileId:audioId];
        }
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[dictionary objectForKey:@"type"] integerValue];
    NSDictionary *content = [NSString stringWithDictionS:[dictionary objectForKey:@"content"]];
    BOOL evenContentBl = NO;
    NSString *eveContent = [content objectForKey:@"eveContent"];
    if([eveContent length]>0 && ![eveContent isEqualToString:@"(null)"] && ![eveContent isEqual:[NSNull null]])
    {
        evenContentBl = YES;
    }
    if(evenContentBl && indexPath.row==1)
    {
        return [NSString getTextHeigth:eveContent andFont:[UIFont boldSystemFontOfSize:15]]+20;
    }
    return 40;
}

+(NSInteger)getCurrDictionCount:(NSDictionary *)dict
{
    NSInteger count = 0;
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    NSDictionary *content = [NSString stringWithDictionS:[dict objectForKey:@"content"]];
    BOOL evenContentBl = NO;
    NSString *eveContent = [content objectForKey:@"eveContent"];
    if([eveContent length]>0 && ![eveContent isEqualToString:@"(null)"] && ![eveContent isEqual:[NSNull null]])
    {
        evenContentBl = YES;
    }
    if(type==0)
    {
        count = 2;
    }
    else if(type==1 || type==2 || type==3 || type==4 || type==5)
    {
        count = 2;
        if(evenContentBl)
        {
            count = 3;
        }
    }
    else if(type==6 || type==7 || type==8 || type==9 || type==10 || type==11 || type==12 || type==13)
    {
        count = 1;
    }
    return count;
}

+(NSInteger)getTableViewRow:(NSDictionary *)dict
{
    NSDictionary *content = [NSString stringWithDictionS:[dict objectForKey:@"content"]];
    NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
    NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:dict];
    count += eveFileUrl.count;
    if(eveFileUrl.count>0)
    {
        count -= 1;
    }
    return count;
}

#pragma mark - 转存delegate

-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid
{
    SCBFileManager *fm_move = [[SCBFileManager alloc] init];
    fm_move.delegate=self;
    NSDictionary *diction = [self getDictionWithIndexPath:selectedButton.tag];
    NSString *fid=[diction objectForKey:@"f_id"];
    NSString *pid = [[SCBSession sharedSession] spaceID];
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
    [self.hud hide:YES afterDelay:1.0f];
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
    [self.hud hide:YES afterDelay:1.0f];
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


@end

@implementation MainDetailViewCell
@synthesize dictionary,accessoryButton,updateViewDelegate,isPublish;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        
    }
    return self;
}

- (void)updateCell:(NSDictionary *)diction indexPath:(NSIndexPath *)indexPath
{
    self.dictionary = [NSDictionary dictionaryWithDictionary:diction];
    NSDictionary *content = [NSString stringWithDictionS:[diction objectForKey:@"content"]];
    NSInteger type = [[diction objectForKey:@"type"] integerValue];
    if(type == 0)
    {
        //仅发言
        [self addType0View:content indexPath:indexPath];
    }
    else if(type == 1 || type == 2 || type == 3 || type == 4 || type == 5)
    {
        //发言+资源
        [self addType2_5View:content indexPath:indexPath];
    }
    else if(type == 6)
    {
        //加入专题
        [self addType6View:content indexPath:indexPath];
    }
    else if(type == 6 || type == 7 || type == 7 || type == 9 || type == 10 || type == 11 || type == 12 || type == 13)
    {
        //信息一行搞定
        [self addType6_13View:content indexPath:indexPath];
    }
}

-(void)addAccButton:(NSIndexPath *)indexPath
{
    if(self.accessoryButton==nil)
    {
        //修改accessoryType
        self.accessoryButton=[[UIButton alloc] init];
        [self.accessoryButton setFrame:CGRectMake(5, 5, 40, 40)];
        [self.accessoryButton setTag:indexPath.row];
        [self.accessoryButton setImage:[UIImage imageNamed:@"sel_nor.png"] forState:UIControlStateNormal];
        [self.accessoryButton setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateHighlighted];
        [self.accessoryButton setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateSelected];
        self.accessoryView = self.accessoryButton;
    }
}

-(void)addType0View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为0的视图
    if(indexPath.row==0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:eveName andFont:[UIFont systemFontOfSize:18]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:18]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:@"说:"];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
        
    }
    else
    {
        NSString *eveContent = [content objectForKey:@"eveContent"];
        float heigth = [NSString getTextHeigth:eveContent andFont:[UIFont boldSystemFontOfSize:15]];
        CGRect speakRect = CGRectMake(15, 5, 290, heigth);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [speakLabel setLineBreakMode:NSLineBreakByWordWrapping];
        speakLabel.numberOfLines = 0;
        [speakLabel setText:[NSString stringWithFormat:@"%@",eveContent]];
        [self addSubview:speakLabel];
    }
}

-(void)addType1View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    [self.updateViewDelegate updateViewOneComment];
    //添加类型为1的视图
    if(indexPath.row==0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getNameWidth:eveName andFont:[UIFont systemFontOfSize:18]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:18]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        NSString *eveTitle = [content objectForKey:@"eveTitle"];
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:eveTitle];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
    }
    else if(indexPath.row==1)
    {
        NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:self.dictionary];
        if(count==2)
        {
            [self.imageView setImage:[UIImage imageNamed:@"link.png"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic = [eveFileUrl firstObject];
            
            NSString *urlTitle = [dic objectForKey:@"urlTitle"];
            CGRect nameRect = CGRectMake(60, 5, [NSString getNameWidth:urlTitle andFont:[UIFont systemFontOfSize:16]], 30);
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
            [nameLabel setFont:[UIFont systemFontOfSize:16]];
            [nameLabel setText:urlTitle];
            [nameLabel setTextColor:[UIColor blackColor]];
            [self addSubview:nameLabel];
            
            NSString *url = [dic objectForKey:@"url"];
            float urlX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
            CGRect urlRect = CGRectMake(urlX, 5, 300-urlX, 30);
            UILabel *urlLabel = [[UILabel alloc] initWithFrame:urlRect];
            [urlLabel setFont:[UIFont systemFontOfSize:14]];
            [urlLabel setText:url];
            [urlLabel setTextColor:[UIColor blueColor]];
            [self addSubview:urlLabel];
            self.backgroundColor = subject_tableviewcell_color;
            
            [self addAccButton:indexPath];
        }
        else
        {
            NSString *eveContent = [content objectForKey:@"eveContent"];
            float heigth = [NSString getTextHeigth:eveContent andFont:[UIFont boldSystemFontOfSize:15]];
            CGRect speakRect = CGRectMake(15, 5, 290, heigth);
            UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
            [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [speakLabel setLineBreakMode:NSLineBreakByWordWrapping];
            speakLabel.numberOfLines = 0;
            [speakLabel setText:[NSString stringWithFormat:@"%@",eveContent]];
            [self addSubview:speakLabel];
        }
    }
    else
    {
        NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:self.dictionary];
        NSInteger indexPathCount = 0;
        if(count==2)
        {
            indexPathCount = indexPath.row-1;
        }
        else
        {
            indexPathCount = indexPath.row-2;
        }
        [self.imageView setImage:[UIImage imageNamed:@"link.png"]];
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        if(indexPathCount<eveFileUrl.count)
        {
            NSDictionary *dic = [eveFileUrl objectAtIndex:indexPathCount];
            NSString *urlTitle = [dic objectForKey:@"urlTitle"];
            CGRect nameRect = CGRectMake(60, 5, [NSString getNameWidth:urlTitle andFont:[UIFont systemFontOfSize:16]], 30);
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
            [nameLabel setFont:[UIFont systemFontOfSize:16]];
            [nameLabel setText:urlTitle];
            [nameLabel setTextColor:[UIColor blackColor]];
            [self addSubview:nameLabel];
            
            NSString *url = [dic objectForKey:@"url"];
            CGRect urlRect = CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width+5, 5, 100, 30);
            UILabel *urlLabel = [[UILabel alloc] initWithFrame:urlRect];
            [urlLabel setFont:[UIFont systemFontOfSize:14]];
            [urlLabel setText:url];
            [urlLabel setTextColor:[UIColor blueColor]];
            [self addSubview:urlLabel];
            self.backgroundColor = subject_tableviewcell_color;
        }
        [self addAccButton:indexPath];
    }
}

-(void)addType2_5View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    [self.updateViewDelegate updateViewOneAll];
    //添加类型为2-5的视图
    if(indexPath.row == 0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:eveName andFont:[UIFont systemFontOfSize:18]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:18]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        NSString *eveTitle = [content objectForKey:@"eveTitle"];
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:eveTitle];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
    }
    else if(indexPath.row==1)
    {
        NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:self.dictionary];
        if(count==2)
        {
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic = [eveFileUrl firstObject];
            NSString *f_name = [dic objectForKey:@"f_name"];
            if([dic objectForKey:@"f_isdir"])
            {
                if([[dic objectForKey:@"f_isdir"] intValue] == 0)
                {
                    //文件夹
                    self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
                    [self addAccButton:indexPath];
                    if(self.isPublish)
                    {
                        [self.updateViewDelegate updateViewOneComment];
                    }
                    else
                    {
                        [self.updateViewDelegate updateViewCopyComment];

                    }
                }
                else
                {
                    //文件
                    NSString *fmime=[[f_name pathExtension] lowercaseString];
                    
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        //下载图片
                        [self downLoadFile:dic];
                    }
                    else
                    {
                        [self updaTextImage:fmime];
                    }
                    [self addAccButton:indexPath];
                    if(self.isPublish)
                    {
                        [self.updateViewDelegate updateViewCommentAndDown];
                    }
                    else
                    {
                        [self.updateViewDelegate updateViewOneAll];
                    }
                }
                //信息名称
                CGRect nameRect = CGRectMake(70, 5, 200, 30);
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
                [nameLabel setFont:[UIFont systemFontOfSize:16]];
                [nameLabel setText:f_name];
                [nameLabel setTextColor:[UIColor blackColor]];
                [self addSubview:nameLabel];
                self.backgroundColor = subject_tableviewcell_color;
            }
            else
            {
                [self addType1View:content indexPath:indexPath];
            }
        }
        else
        {
            int eventType = [[content objectForKey:@"eveType"] intValue];
            if (eventType == 1) {
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 27, 25)];
                imageV.image = [UIImage imageNamed:@"sub_yuyin_ico.png"];
                [self addSubview:imageV];
            } else {
                NSString *eveContent = [content objectForKey:@"eveContent"];
                float heigth = [NSString getTextHeigth:eveContent andFont:[UIFont boldSystemFontOfSize:15]];
                CGRect speakRect = CGRectMake(15, 5, 290, heigth);
                UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
                [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
                [speakLabel setLineBreakMode:NSLineBreakByWordWrapping];
                speakLabel.numberOfLines = 0;
                [speakLabel setText:[NSString stringWithFormat:@"%@",eveContent]];
                [self addSubview:speakLabel];
            }
        }
    }
    else
    {
        NSInteger count = [IPSubJectNewDetailViewController getCurrDictionCount:self.dictionary];
        NSInteger indexPathCount = 0;
        if(count==2)
        {
            indexPathCount = indexPath.row-1;
        }
        else
        {
            indexPathCount = indexPath.row-2;
        }
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        if(indexPathCount<eveFileUrl.count)
        {
            NSDictionary *dic = [eveFileUrl objectAtIndex:indexPathCount];
            NSString *f_name = [dic objectForKey:@"f_name"];
            if([dic objectForKey:@"f_isdir"])
            {
                if([[dic objectForKey:@"f_isdir"] intValue] == 0)
                {
                    //文件夹
                    self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
                    [self addAccButton:indexPath];
                    if(self.isPublish)
                    {
                         [self.updateViewDelegate updateViewOneComment];
                    }
                    else
                    {
                       
                        [self.updateViewDelegate updateViewCopyComment];
                    }
                }
                else
                {
                    //文件
                    NSString *fmime=[[f_name pathExtension] lowercaseString];
                    
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        //下载图片
                        [self downLoadFile:dic];
                    }
                    else
                    {
                        [self updaTextImage:fmime];
                    }
                    [self addAccButton:indexPath];
                    if(self.isPublish)
                    {
                        [self.updateViewDelegate updateViewCommentAndDown];
                    }
                    else
                    {
                        [self.updateViewDelegate updateViewOneAll];
                    }
                }
                
                //信息名称
                CGRect nameRect = CGRectMake(70, 5, 200, 30);
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
                [nameLabel setFont:[UIFont systemFontOfSize:16]];
                [nameLabel setText:f_name];
                [nameLabel setTextColor:[UIColor blackColor]];
                [self addSubview:nameLabel];
                self.backgroundColor = subject_tableviewcell_color;
            }
            else
            {
                [self addType1View:content indexPath:indexPath];
            }
        }
    }
}

-(void)addType6View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为6的视图
    NSString *eveName = [self.dictionary objectForKey:@"usr_turename"];
    CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:eveName andFont:[UIFont systemFontOfSize:18]], 30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
    [nameLabel setFont:[UIFont systemFontOfSize:18]];
    [nameLabel setText:eveName];
    [nameLabel setTextColor:subject_color];
    [self addSubview:nameLabel];
    
    NSString *eveTitle = [content objectForKey:@"eveTitle"];
    float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
    CGRect speakRect = CGRectMake(speakX, 5, [NSString getTextWidth:eveTitle andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
    [speakLabel setTextColor:[UIColor grayColor]];
    [speakLabel setFont:[UIFont systemFontOfSize:15]];
    [speakLabel setText:eveTitle];
    [self addSubview:speakLabel];
    
    //邀请成员
    NSArray *object = [[content objectForKey:@"object"] componentsSeparatedByString:@" "];
    NSString *toName = [object firstObject];
    float toNameX = speakLabel.frame.origin.x+speakLabel.frame.size.width+5;
    CGRect toNameRect = CGRectMake(toNameX, 5, [NSString getTextWidth:toName andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *toNameLabel = [[UILabel alloc] initWithFrame:toNameRect];
    [toNameLabel setTextColor:subject_color];
    [toNameLabel setFont:[UIFont systemFontOfSize:15]];
    [toNameLabel setText:toName];
    [self addSubview:toNameLabel];
    
    //人数
    NSInteger number = [[content objectForKey:@"number"] integerValue];
    NSString *numberSting = [NSString stringWithFormat:@"共%i人",number];
    float numberX = toNameLabel.frame.origin.x+toNameLabel.frame.size.width+5;
    CGRect numberRect = CGRectMake(numberX, 5, [NSString getTextWidth:numberSting andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:numberRect];
    [numberLabel setTextColor:subject_color];
    [numberLabel setFont:[UIFont systemFontOfSize:15]];
    [numberLabel setText:numberSting];
    [self addSubview:numberLabel];
    
    //操作行为
    NSString *action = [content objectForKey:@"action"];
    float actionX = numberRect.origin.x+numberRect.size.width+5;
    CGRect actionRect = CGRectMake(actionX, 5, [NSString getTextWidth:action andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *actionLabel = [[UILabel alloc] initWithFrame:actionRect];
    [actionLabel setTextColor:[UIColor grayColor]];
    [actionLabel setFont:[UIFont systemFontOfSize:15]];
    [actionLabel setText:action];
    [self addSubview:actionLabel];
    
    //    NSString *subjectName = [content objectForKey:@"subjectName"];
    //    float subjectX = actionRect.origin.x+actionRect.size.width+5;
    //    CGRect subjectRect = CGRectMake(subjectX, 5, 100, 30);
    //    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:subjectRect];
    //    [subjectLabel setTextColor:[UIColor grayColor]];
    //    [subjectLabel setFont:[UIFont systemFontOfSize:15]];
    //    [subjectLabel setText:subjectName];
    //    [self addSubview:subjectLabel];
    
    NSString *eveTime = [content objectForKey:@"eveTime"];
    CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
    [timeLabel setText:[NSString getTimeFormat:eveTime]];
    [timeLabel setTextColor:[UIColor grayColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:timeLabel];
}

-(void)addType6_13View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为6-13的视图
    NSString *eveName = [content objectForKey:@"eveName"];
    CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:eveName andFont:[UIFont systemFontOfSize:18]], 30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
    [nameLabel setFont:[UIFont systemFontOfSize:18]];
    [nameLabel setText:eveName];
    [nameLabel setTextColor:subject_color];
    [self addSubview:nameLabel];
    
    NSString *eveTitle = [content objectForKey:@"eveTitle"];
    float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
    CGRect speakRect = CGRectMake(speakX, 5, [NSString getTextWidth:eveTitle andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
    [speakLabel setTextColor:[UIColor grayColor]];
    [speakLabel setFont:[UIFont systemFontOfSize:15]];
    [speakLabel setText:eveTitle];
    [self addSubview:speakLabel];
    
    NSString *subjectName = [content objectForKey:@"subjectName"];
    float subjectX = speakRect.origin.x+speakRect.size.width+5;
    CGRect subjectRect = CGRectMake(subjectX, 5, 100, 30);
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:subjectRect];
    [subjectLabel setTextColor:[UIColor grayColor]];
    [subjectLabel setFont:[UIFont systemFontOfSize:15]];
    [subjectLabel setText:subjectName];
    [self addSubview:subjectLabel];
    
    NSString *eveTime = [content objectForKey:@"eveTime"];
    CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
    [timeLabel setText:[NSString getTimeFormat:eveTime]];
    [timeLabel setTextColor:[UIColor grayColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:timeLabel];
}

- (void)downLoadFile:(NSDictionary *)diction
{
    //下载图片
    NSString *f_id = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_id"]];
    NSString *f_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_name"]];
    
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
    [NSString CreatePath:createPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    BOOL bl;
    bl = [NSString image_exists_FM_file_path:path];
    if(bl)
    {
        if([UIImage imageWithContentsOfFile:path])
        {
            [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.imageView];
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
        }
        return;
    }
    else
    {
        documentDir = [YNFunctions getProviewCachePath];
        createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
        [NSString CreatePath:createPath];
        path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        //查询本地是否已经有该图片
        bl = [NSString image_exists_at_file_path:path];
        if(bl)
        {
            if([UIImage imageWithContentsOfFile:path])
            {
                [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.imageView];
            }
            else
            {
                self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
            }
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
            LookDownFile *downImage = [[LookDownFile alloc] init];
//            [downImage setIsPic2:YES];
            [downImage setFile_id:f_id];
            [downImage setFileName:f_name];
            [downImage setImageViewIndex:self.imageView.tag];
            [downImage setIndexPath:nil];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
}

-(void)formatPhoto:(UIImage *)image imageView:(UIImageView *)textImageView
{
    UIImage *imageS = nil;
    UIImage *imageV = image;
    float width=100;
    if(imageV.size.width>=imageV.size.height)
    {
        if(imageV.size.height<=width)
        {
            CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.height = width;
            newImageSize.width = width*imageV.size.width/imageV.size.height;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake((newImageSize.width-width)/2, 0, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else if(imageV.size.width<=imageV.size.height)
    {
        if(imageV.size.width<=width)
        {
            CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.width = width;
            newImageSize.height = width*imageV.size.height/imageV.size.width;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake(0, (newImageSize.height-width)/2, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else
    {
        imageS = image;
    }
    [textImageView performSelectorInBackground:@selector(setImage:) withObject:imageS];
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - LookFileDelegate

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.imageView];
}

- (void)downFinish:(NSString *)baseUrl
{
    
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    
}

-(void)didFailWithError
{
    
}

-(void)updaTextImage:(NSString *)fmime
{
    if ([fmime isEqualToString:@"doc"]||
        [fmime isEqualToString:@"docx"]||
        [fmime isEqualToString:@"rtf"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_txt.png"];
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"file_other.png"];
    }
}

@end

