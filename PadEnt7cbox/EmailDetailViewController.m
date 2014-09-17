//
//  EmailDetailViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "EmailDetailViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "SCBFileManager.h"
#import "SCBSession.h"
#import "UIBarButtonItem+Yn.h"
#import "YNNavigationController.h"
#import "MyTabBarViewController.h"
#import "PhotoLookViewController.h"
#import "OtherBrowserViewController.h"
#import "OpenFileViewController.h"
#import "NSString+Format.h"

@implementation FileVieww{
    NSDictionary *_dic;
}
-(id)init
{
    self=[super init];
    if (self) {
    }
    return self;
}
-(void)setButton
{
    self.imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
    self.imageView.image = [UIImage imageNamed:@"add_pic.png"];
    [self addSubview:self.imageView];
}
-(void)setDic:(NSDictionary *)dic
{
    self.dicData=dic;
    self.imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
    self.nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
    self.nameLabel.lineBreakMode=NSLineBreakByTruncatingMiddle;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font=[UIFont systemFontOfSize:12];
    [self addSubview:self.imageView];
    [self addSubview:self.nameLabel];
    
    NSString *fname=[dic objectForKey:@"atta_file_name"];
    NSString *atta_file_size = [dic objectForKey:@"atta_file_size"];
    if([fname isEqual:[NSNull null]] || [atta_file_size isEqual:[NSNull null]])
    {
        return;
    }
    NSString *fmime=[[fname pathExtension] lowercaseString];
    if ([[dic objectForKey:@"atta_file_size"] intValue]==0) {
        self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
    }else
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            NSString *fthumb;
            if([dic objectForKey:@"fthumb"])
            {
                fthumb=[dic objectForKey:@"fthumb"];
            }
            else if([dic objectForKey:@"atta_file_thumb"])
            {
                fthumb=[dic objectForKey:@"atta_file_thumb"];
            }
            NSString *localThumbPath=[YNFunctions getIconCachePath];
            fthumb =[YNFunctions picFileNameFromURL:fthumb];
            localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
            self.imagePath=localThumbPath;
            NSLog(@"是否存在文件：%@",localThumbPath);
            if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
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
                [icon drawInRect:imageRect];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.imageView.image= image;
                
            }else{
                NSLog(@"将要下载的文件：%@",localThumbPath);
                self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
                [self startIconDownload:dic forIndexPath:nil];
            }
        }
        else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_excel.png"];
        }
        else if ([fmime isEqualToString:@"mp3"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_moving.png"];
        }
        else if ([fmime isEqualToString:@"pdf"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_pdf.png"];
        }
        else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_ppt.png"];
        }
        else if([fmime isEqualToString:@"txt"])
        {
            self.imageView.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"file_other.png"];
        }
    self.nameLabel.text=fname;
}
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader * iconDownloader = [[IconDownloader alloc] init];
    iconDownloader.data_dic=dic;
    iconDownloader.indexPathInTableView = indexPath;
    iconDownloader.delegate = self;
    [iconDownloader startDownload];
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.imagePath]&&[UIImage imageWithContentsOfFile:self.imagePath]!=nil) {
        NSLog(@"存在文件：%@",self.imagePath);
        UIImage *icon=[UIImage imageWithContentsOfFile:self.imagePath];
        self.imageView.image= icon;
    }
}
@end
@interface EmailDetailViewController ()<SCBFileManagerDelegate,SCBEmailManagerDelegate,IconDownloaderDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    BOOL _isDetail;
}
@property (strong,nonatomic) SCBEmailManager *em;
@property (strong,nonatomic) SCBEmailManager *em_list;
@property(strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIToolbar *moreEditBar;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong,nonatomic) UIView *headerView;
@property (strong,nonatomic) UIView *footerView;
@property (strong,nonatomic) UILabel *personLabel;
@property (strong,nonatomic) UILabel *receiveLabel;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UILabel *contentLabel;
@property (strong,nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) UIButton *switchButton;
@property (strong,nonatomic) UIView *contentBgView;
@property (strong,nonatomic) UIView *personDetailView;

@property (strong,nonatomic) UITableViewCell *titleCell;
@property (strong,nonatomic) UITableViewCell *personCell;
@property (strong,nonatomic) UITableViewCell *contentCell;
@property (strong,nonatomic) UITableViewCell *filesCell;
@end

@implementation EmailDetailViewController

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
    
    if ([self.etype intValue]==1) {
        UIBarButtonItem *send=[[UIBarButtonItem alloc] initWithTitleStr:@"重新发送" style:UIBarButtonItemStylePlain target:self action:@selector(reSendAction:)];
        [self.navigationItem setRightBarButtonItem:send];
    }
    
    _isDetail=NO;
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    
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
}
-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if (!self.moreEditBar) {
        self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49)];
        [self.moreEditBar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.moreEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.moreEditBar setTintColor:[UIColor blueColor]];
        }
        [self.view addSubview:self.moreEditBar];
        //发送 删除 提交 移动 全选
        UIButton *btn_download ,*btn_resave;
        UIBarButtonItem  *item_download, *item_resave,*item_flexible;
        
        btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
//        [btn_resave setImage:[UIImage imageNamed:@"zc_nor.png"] forState:UIControlStateNormal];
//        [btn_resave setImage:[UIImage imageNamed:@"zc_se.png"] forState:UIControlStateHighlighted];
        [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [btn_resave setTitle:@"转存" forState:UIControlStateNormal];
        [btn_resave addTarget:self action:@selector(toResave:) forControlEvents:UIControlEventTouchUpInside];
        item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
        
        btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
//        [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
//        [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
        [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [btn_download setTitle:@"下载" forState:UIControlStateNormal];
        [btn_download addTarget:self action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
        item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
        
        item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        [self.moreEditBar setItems:@[item_flexible,item_resave,item_flexible]];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isFileShare = NO;
    [self updateEmailList];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}
-(void)viewDidLayoutSubviews
{
    CGRect r=self.view.frame;
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.moreEditBar.frame=CGRectMake(0, self.view.frame.size.height-self.moreEditBar.frame.size.height, self.view.frame.size.width, self.moreEditBar.frame.size.height);
    [self.moreEditBar setHidden:YES];
    [self reloadFiles];
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
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.EmailFileList",self.eid]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.fileArray=[NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError]];
        if (self.fileArray) {
            [self.tableView reloadData];
        }
    }

    
    [self.em_list cancelAllTask];
    self.em_list=nil;
    self.em_list=[[SCBEmailManager alloc] init];
    [self.em_list setDelegate:self];
    [self.em_list fileListWithID:self.eid];
}
- (void)updateEmailList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.Email%@",self.eid,self.etype]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.fileArray=[NSMutableArray arrayWithArray:[self.dataDic objectForKey:@"list"]];
            [self.tableView reloadData];
        }
    }
    
    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
//    [self.em detailEmailWithID:self.eid type:self.etype];
    if ([self.etype intValue]==0) {
        [self.em viewReceiveWithID:self.eid];
    }else
    {
        [self.em viewSendWithID:self.eid];
    }
}
-(void)reSendAction:(id)sender
{
    UIControl *control=(UIControl *)sender;
    [control setEnabled:NO];
    
    NSDictionary *dic=[self.dataDic objectForKey:@"obj"];
    NSString *title;
    NSString *content;
    NSString *sendName;
    NSString *sendEmail;
    NSString *receiveNames;
    NSString *receiveEmails;
    NSString *receiveIDs;
    NSString *time;
    if ([self.etype intValue]==0) {
        title=[dic objectForKey:@"re_subject"];
        content=[dic objectForKey:@"re_message"];
        sendName=[dic objectForKey:@"sendUserTrueName"];
        sendEmail=[dic objectForKey:@"sendUserEmail"];
        receiveNames=[dic objectForKey:@"re_receive_usernames"];
        receiveEmails=[dic objectForKey:@"re_receive_emails"];
        time=[dic objectForKey:@"re_sendtime"];
        receiveIDs=[dic objectForKey:@"re_receive_users"];
    }else
    {
        title=[dic objectForKey:@"send_subject"];
        content=[dic objectForKey:@"send_message"];
        sendName=[dic objectForKey:@"sendUserTrueName"];
        sendEmail=[dic objectForKey:@"sendUserEmail"];
        receiveNames=[dic objectForKey:@"send_receive_usernames"];
        receiveEmails=[dic objectForKey:@"send_receive_emails"];
        time=[dic objectForKey:@"send_sendtime"];
        receiveIDs=[dic objectForKey:@"send_receive_users"];
    }
    NSArray *re_ids=[receiveIDs componentsSeparatedByString:@","];
    NSArray *emailArray=[receiveEmails componentsSeparatedByString:@" "];
    NSArray *namesArray=[receiveNames componentsSeparatedByString:@" "];
    NSMutableArray *fileids=[NSMutableArray array];
    for (NSDictionary *dic in self.fileArray) {
        NSString *fid=[dic objectForKey:@"atta_fileid"];
        [fileids addObject:fid];
    }
    
    SCBEmailManager *em=[[SCBEmailManager alloc] init];
    em.delegate=self;
    [em sendFilesWithSubject:title userids:re_ids usernames:namesArray useremails:emailArray sendfiles:fileids message:content];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在发送...";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
}
-(NSArray *)selectedIDs
{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
//        if (indexpath.section!=5) {
//            continue;
//        }
        NSDictionary *dic=[self.fileArray objectAtIndex:indexpath.row];
        NSString *fid=[dic objectForKey:@"atta_id"];
        [ids addObject:fid];
    }
    return ids;
}
-(NSArray *)selectedIndexPaths
{
    NSArray *retVal=nil;
    retVal=self.tableView.indexPathsForSelectedRows;
    return retVal;
}
-(void)toDownload:(id)sender
{
    if (self.tableView.isEditing) {
        
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            [self showMessage:@"未选中任何文件（夹）"];
            return;
        }
        
        NSArray *selectArray=[self selectedIndexPaths];
        for (NSIndexPath *indexPath in selectArray) {
            NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
            
            long fsize=[[dic objectForKey:@"fsize"] longValue];

            BOOL isDir;
            if (fsize==0) {
                [self showMessage:@"不能下载文件夹"];
                return;
            }
        }
        for (NSIndexPath *indexPath in selectArray) {
            NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
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
}
-(void)toCopyFiles:(NSArray *)fids
{
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择转存的位置";
    flvc.delegate=self;
    flvc.type=kTypeCopy;
    flvc.isHasSelectFile=YES;
    flvc.targetsArray=fids;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isFileShare = YES;
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)toResave:(id)sender
{
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            [self showMessage:@"未选中任何文件（夹）"];
            return;
        }
    }
    NSLog(@"转存");
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择转存的位置";
    flvc.delegate=self;
    flvc.type=kTypeCopy;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    //    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)loadEmail
{
    NSDictionary *dic=[self.dataDic objectForKey:@"obj"];
    if (self.headerView&&dic) {
        //[dic objectForKey:@"receivelist"];
//        int etype=[[dic objectForKey:@"etype"] intValue];
//        if (etype==0) {
//            self.personLabel.text=[dic objectForKey:@"sender"];
//        }else
//        {
//            self.personLabel.text=[dic objectForKey:@"receivelist"];
//        }
        if ([self.etype intValue]==0) {
            self.personLabel.text=[NSString stringWithFormat:@"发件人：%@",[dic objectForKey:@"sendUserTrueName"]];
            self.receiveLabel.text=[NSString stringWithFormat:@"收件人：%@",[dic objectForKey:@"re_receive_usernames"]];
            self.titleLabel.text=[dic objectForKey:@"re_subject"];
            self.timeLabel.text=[dic objectForKey:@"re_sendtime"];
            self.contentLabel.text=[dic objectForKey:@"re_message"];
        }else
        {
            self.personLabel.text=[NSString stringWithFormat:@"发件人：%@",[dic objectForKey:@"sendUserTrueName"]];
            self.receiveLabel.text=[NSString stringWithFormat:@"收件人：%@",[dic objectForKey:@"send_receive_usernames"]];
            self.titleLabel.text=[dic objectForKey:@"send_subject"];
            self.timeLabel.text=[dic objectForKey:@"send_sendtime"];
            self.contentLabel.text=[dic objectForKey:@"send_message"];
        }
    }
}
-(void)switchAction:(id)sender
{
    _isDetail=!_isDetail;
    if (_isDetail) {
        [self.switchButton setTitle:@"隐藏详情" forState:UIControlStateNormal];
    }else
    {
        [self.switchButton setTitle:@"显示详情" forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}
-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid
{
    NSDictionary *dic=[self.fileArray objectAtIndex:self.selectedIndexPath.row];
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
        [self.fm_move resaveFileIDs:@[fid] toPID:f_id  sID:spid];
    }
    
}
- (void)reloadFiles
{
    UIView *_filesView=self.filesCell.contentView;
    for (UIView *view in _filesView.subviews) {
        [view removeFromSuperview];
    }
    int numPerRow=self.view.bounds.size.width/80;
    BOOL isReSend = NO;
    for (int i=0; i<self.fileArray.count;) {
        NSDictionary *dic = [self.fileArray objectAtIndex:i];
//        NSLog(@"dic:%@",dic);
        NSString *atta_deltime = [dic objectForKey:@"atta_deltime"];
        NSString *f_state = [dic objectForKey:@"f_state"];
        BOOL isFState = NO;
        if(![f_state isEqual:[NSNull null]] && ![f_state isEqualToString:@"(null)"] && [f_state isEqualToString:@"0"])
        {
            isReSend = YES;
        }
        else
        {
            isFState = YES;
        }
        BOOL bl = YES;
        if(![atta_deltime isEqual:[NSNull null]])
        {
            bl = NO;
            [self.fileArray removeObjectAtIndex:i];
            continue;
        }
        
        int row=i/numPerRow;
        int column=i%numPerRow;
        FileVieww *fv=[[FileVieww alloc] initWithFrame:CGRectMake(column*(self.view.bounds.size.width/numPerRow), row*(100)+30, self.view.bounds.size.width/numPerRow, 100)];
        [fv setDic:[self.fileArray objectAtIndex:i]];
        [fv setIndex:i];
        if ([self.etype intValue]==0) {
            [fv addTarget:self action:@selector(fileTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_filesView addSubview:fv];
        if(bl)
        {
            i++;
        }
    }

    if([self.etype intValue]==1)
    {
        if (isReSend) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }else
        {
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
    }
}
- (void)fileTouch:(id)sender
{
    FileVieww *fv=(FileVieww *)sender;
    UIActionSheet *as=[[UIActionSheet alloc] initWithTitle:fv.nameLabel.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"预览",@"下载",@"转存", nil];
    [as setTag:fv.index];
    [as showInView:[[UIApplication sharedApplication] keyWindow]];
}
- (void)checkNotReadEmail
{
    SCBEmailManager *em=[[SCBEmailManager alloc] init];
    em.delegate=self;
    [em notReadCount];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    // fixed font style. use custom view (UILabel) if you want something different
////    switch (section) {
////        case 0:
////            return @"发送人：";
////            break;
////        case 1:
////            return @"接收人：";
////            break;
////        case 2:
////            return @"标题：";
////            break;
////        case 3:
////            return @"时间：";
////            break;
////        case 4:
////            return @"内容：";
////            break;
////        case 5:
////            return @"文件：";
////            break;
////        default:
////            break;
////    }
//    return @"";
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.dataDic) {
        NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
    NSDictionary *dic=[self.dataDic objectForKey:@"obj"];
    NSString *title;
    NSString *content;
    NSString *sendName;
    NSString *sendEmail;
    NSString *receiveNames;
    NSString *receiveEmails;
    NSString *time;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        if ([self.etype intValue]==0) {
            title=[dic objectForKey:@"re_subject"];
            content=[dic objectForKey:@"re_message"];
            sendName=[dic objectForKey:@"sendUserTrueName"];
            sendEmail=[dic objectForKey:@"sendUserEmail"];
            receiveNames=[dic objectForKey:@"re_receive_usernames"];
            receiveEmails=[dic objectForKey:@"re_receive_emails"];
            time=[dic objectForKey:@"re_sendtime"];
        }else
        {
            title=[dic objectForKey:@"send_subject"];
            content=[dic objectForKey:@"send_message"];
            sendName=[dic objectForKey:@"sendUserTrueName"];
            sendEmail=[dic objectForKey:@"sendUserEmail"];
            receiveNames=[dic objectForKey:@"send_receive_usernames"];
            receiveEmails=[dic objectForKey:@"send_receive_emails"];
            time=[dic objectForKey:@"send_sendtime"];
        }

    }
        switch (indexPath.row) {
        case 0:
        {
            if (self.titleCell==nil) {
                self.titleCell=[[UITableViewCell alloc] init];
                UILabel *title_lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
                [title_lbl setFont:[UIFont boldSystemFontOfSize:17]];
                [title_lbl setNumberOfLines:0];
                [self.titleCell addSubview:title_lbl];
                self.titleLabel=title_lbl;
                //self.titleCell.contentView.layer.borderWidth=0.5;
                //self.titleCell.contentView.layer.borderColor=[UIColor grayColor].CGColor;
            }
            self.titleLabel.text=title;
            return self.titleCell;
        }
            break;
        case 1:
        {
            if (self.personCell==nil) {
                self.personCell=[[UITableViewCell alloc] init];
                UILabel *person_labl=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 220, 50)];
                [person_labl setFont:[UIFont boldSystemFontOfSize:16]];
                [person_labl setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]]];
                self.personLabel=person_labl;
                [self.personCell.contentView addSubview:person_labl];
                
                UIButton *on_off_btn=[[UIButton alloc] initWithFrame:CGRectMake(320-80,0,80,50)];
                [on_off_btn setTitle:@"显示详情" forState:UIControlStateNormal];
                [on_off_btn setTitleColor:[UIColor colorWithRed:79/255.0f green:102/255.0f blue:139/255.0f alpha:1] forState:UIControlStateNormal];
                [on_off_btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
                [on_off_btn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.personCell.contentView addSubview:on_off_btn];
                self.switchButton=on_off_btn;
            }
            if ([self.etype intValue]==0) {
                self.personLabel.text=sendName;
            }else
            {
                self.personLabel.text=receiveNames;
            }
            return self.personCell;
        }
            break;
        case 2:
        {
            if (self.contentCell==nil) {
                self.contentCell=[[UITableViewCell alloc] init];
                UILabel *content_lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
                [content_lbl setFont:[UIFont systemFontOfSize:14]];
                [content_lbl setNumberOfLines:0];
                [content_lbl setLineBreakMode:NSLineBreakByWordWrapping];
                [self.contentCell.contentView addSubview:content_lbl];
                self.contentLabel=content_lbl;
                self.contentCell.contentView.layer.borderWidth=0.5;
                self.contentCell.contentView.layer.borderColor=[UIColor grayColor].CGColor;
            }
            self.contentLabel.text=content;
            return self.contentCell;
        }
            break;
        case 3:
        {
            if (self.filesCell==nil) {
                self.filesCell=[[UITableViewCell alloc] init];
            }
            [self reloadFiles];
            return self.filesCell;
        }
            break;
    }
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            //主题
            if (self.titleLabel==nil) {
                return 50;
            }else
            {
                CGSize theSize = CGSizeMake(300,2000);
                CGSize size=[self.titleLabel sizeThatFits:theSize];
                size.height+=10;
                if (size.height<50) {
                    size.height=50;
                }
                [self.titleLabel setFrame:CGRectMake(10, 0, 300, size.height)];
                return size.height;
            }
            break;
        case 1:
            //收件人/发件人
            if (_isDetail) {
                self.personLabel.hidden=YES;
                if (self.personDetailView==nil&&self.personCell) {
                    self.personDetailView=[[UIView alloc] initWithFrame:CGRectMake(10, 0, 220, 50)];
                    [self.personCell.contentView addSubview:self.personDetailView];
                }
                self.personDetailView.hidden=NO;
                
                NSDictionary *dic=[self.dataDic objectForKey:@"obj"];
                NSString *title;
                NSString *content;
                NSString *sendName;
                NSString *sendEmail;
                NSString *receiveNames;
                NSString *receiveEmails;
                NSString *time;
                
                if ([self.etype intValue]==0) {
                    title=[dic objectForKey:@"re_subject"];
                    content=[dic objectForKey:@"re_message"];
                    sendName=[dic objectForKey:@"sendUserTrueName"];
                    sendEmail=[dic objectForKey:@"sendUserEmail"];
                    receiveNames=[dic objectForKey:@"re_receive_usernames"];
                    receiveEmails=[dic objectForKey:@"re_receive_emails"];
                    time=[dic objectForKey:@"re_sendtime"];
                }else
                {
                    title=[dic objectForKey:@"send_subject"];
                    content=[dic objectForKey:@"send_message"];
                    sendName=[dic objectForKey:@"sendUserTrueName"];
                    sendEmail=[dic objectForKey:@"sendUserEmail"];
                    receiveNames=[dic objectForKey:@"send_receive_usernames"];
                    receiveEmails=[dic objectForKey:@"send_receive_emails"];
                    time=[dic objectForKey:@"send_sendtime"];
                }
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date2 = [dateFormatter dateFromString:time];
                [dateFormatter setDateFormat:@"yyyy年M月d日"];
                time = [dateFormatter stringFromDate:date2];
                
                NSArray *emailArray=[receiveEmails componentsSeparatedByString:@" "];
                NSArray *namesArray=[receiveNames componentsSeparatedByString:@" "];
                for (UIView *view in self.personDetailView.subviews) {
                    [view removeFromSuperview];
                }
                UIFont *sys15=[UIFont systemFontOfSize:15];
                
                UILabel *fjr_lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
                UILabel *fjr_name_lbl=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 220-60, 20)];
                UILabel *fjr_email_lbl=[[UILabel alloc] initWithFrame:CGRectMake(60, 20, 220-60, 20)];
                UILabel *sjr_lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, 60, 20)];
                for (int i=0; i<emailArray.count; i++) {
                    UILabel *sjr_name_lbl=[[UILabel alloc] initWithFrame:CGRectMake(60, (i+1)*40, 220-60, 20)];
                    UILabel *sjr_email_lbl=[[UILabel alloc] initWithFrame:CGRectMake(60, (i+1)*40+20, 220-60, 20)];
                    sjr_name_lbl.text=namesArray[i];
                    sjr_email_lbl.text=emailArray[i];
                    [self.personDetailView addSubview:sjr_name_lbl];
                    [self.personDetailView addSubview:sjr_email_lbl];
                    [sjr_name_lbl setFont:sys15];
                    [sjr_email_lbl setFont:[UIFont systemFontOfSize:14]];
                    [sjr_email_lbl setTextColor:[UIColor grayColor]];
                }
                UILabel *sj_lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, (emailArray.count+1)*40, 60, 20)];
                UILabel *sj_content_lbl=[[UILabel alloc] initWithFrame:CGRectMake(60, (emailArray.count+1)*40, 220-60, 20)];
                fjr_lbl.text=@"发件人";
                sjr_lbl.text=@"收件人";
                sj_lbl.text=@"时间";
                fjr_name_lbl.text=sendName;
                fjr_email_lbl.text=sendEmail;
                sj_content_lbl.text=time;
                [fjr_lbl setFont:sys15];
                [fjr_lbl setTextColor:[UIColor grayColor]];
                [sjr_lbl setFont:sys15];
                [sjr_lbl setTextColor:[UIColor grayColor]];
                [sj_lbl setFont:sys15];
                [sj_lbl setTextColor:[UIColor grayColor]];
                [fjr_email_lbl setFont:[UIFont systemFontOfSize:14]];
                [fjr_email_lbl setTextColor:[UIColor grayColor]];
                [sj_content_lbl setFont:sys15];
                [sj_content_lbl setTextColor:[UIColor grayColor]];
                [fjr_name_lbl setFont:sys15];
                
                [self.personDetailView addSubview:fjr_lbl];
                [self.personDetailView addSubview:fjr_name_lbl];
                [self.personDetailView addSubview:fjr_email_lbl];
                [self.personDetailView addSubview:sjr_lbl];
                [self.personDetailView addSubview:sj_lbl];
                [self.personDetailView addSubview:sj_content_lbl];
                return 60+(emailArray.count*40);
            }else
            {
                self.personLabel.hidden=NO;
                self.personDetailView.hidden=YES;
                return 50;
            }
            break;
        case 2:
            //邮件内容
            if (self.contentLabel==nil) {
                return 50;
            }else
            {
                CGSize theSize = CGSizeMake(300,2000);
                CGSize size=[self.contentLabel sizeThatFits:theSize];
                size.height+=10;
                if (size.height<50) {
                    size.height=50;
                }
                [self.contentLabel setFrame:CGRectMake(10, 0, 300, size.height)];
                return size.height;
            }
            break;
        case 3:
            //附件
            if (self.fileArray==nil) {
                return 200;
            }else
            {
                int numPerRow=self.view.bounds.size.width/80;
                return (self.fileArray.count/numPerRow*100+150);
            }
            break;
        default:
            break;
    }
    return 0;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    //计算收件人高度
//    CGSize theSize = CGSizeMake(300,2000);
//    [self.receiveLabel setNumberOfLines:0];
//    [self.titleLabel setNumberOfLines:0];
//    CGSize sjrSize=[self.receiveLabel sizeThatFits:theSize];
//    if (sjrSize.height<21) {
//        sjrSize.height=21;
//    }
//    CGSize titleSize=[self.titleLabel sizeThatFits:theSize];
//    if (titleSize.height<21) {
//        titleSize.height=21;
//    }
//    self.receiveLabel.frame=CGRectMake(10, 25, 300, sjrSize.height);
//    self.titleLabel.frame=CGRectMake(10, 50+(sjrSize.height-21), 300, titleSize.height);
//    self.timeLabel.frame=CGRectMake(10, 75+(sjrSize.height-21)+(titleSize.height-21), 300, 21);
//
////    CGSize theSize = CGSizeMake(300,2000);
////    CGSize sjrSize=[self.receiveLabel sizeThatFits:theSize];
////    CGSize titleSize=[self.titleLabel sizeThatFits:theSize];
//    if (_isDetail) {
//        [self.contentLabel setNumberOfLines:0];
//        CGSize size = CGSizeMake(300,2000);
//        CGSize bestSize=[self.contentLabel sizeThatFits:size];
//        if (bestSize.height<34) {
//            bestSize.height=34;
//        }
//        self.contentLabel.frame=CGRectMake(10, 100+(sjrSize.height-21)+(titleSize.height-21), bestSize.width, bestSize.height);
//        self.headerView.frame=CGRectMake(0, 0, 320, 150+(bestSize.height-34)+(sjrSize.height-21)+(titleSize.height-21));
//        self.contentBgView.frame=CGRectMake(0, 100+(sjrSize.height-21)+(titleSize.height-21), 320, self.headerView.frame.size.height-(100+(sjrSize.height-21)+(titleSize.height-21)));
//        self.switchButton.frame=CGRectMake(320-60, self.headerView.frame.size.height-21, 50, 21);
//        [self.switchButton setTitle:@"收起" forState:UIControlStateNormal];
//        return self.headerView.frame.size.height;
//    }else
//    {
//        [self.contentLabel setNumberOfLines:2];
//        self.contentLabel.frame=CGRectMake(10, 100+(sjrSize.height-21)+(titleSize.height-21), 300, 34);
//        self.headerView.frame=CGRectMake(0, 0, 320, 150+(sjrSize.height-21)+(titleSize.height-21));
//        self.contentBgView.frame=CGRectMake(0, 100+(sjrSize.height-21)+(titleSize.height-21), 320, 50);
//        self.switchButton.frame=CGRectMake(320-60, self.headerView.frame.size.height-21, 50, 21);
//        [self.switchButton setTitle:@"展开" forState:UIControlStateNormal];
//        return 150+(sjrSize.height-21)+(titleSize.height-21);
//    }
//    return 150;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (self.footerView) {
//        return self.footerView.frame.size.height;
//    }
//    return 100;
//}
#pragma mark - Table view delegate
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
//{
//    NSDictionary *dic=[self.dataDic objectForKey:@"email"];
//    
//    if (!self.headerView) {
//        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
//        UILabel *p_label= [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 300, 21)];
//        UILabel *r_label= [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 300, 21)];
//        UILabel *title_lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 21)];
//        UILabel *time_lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 75, 300, 21)];
//        UILabel *content_lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 34)];
//        
//        [p_label setFont:[UIFont boldSystemFontOfSize:16]];
//        [r_label setFont:[UIFont systemFontOfSize:16]];
//        [title_lbl setFont:[UIFont boldSystemFontOfSize:17]];
//        [content_lbl setFont:[UIFont systemFontOfSize:14]];
//        [time_lbl setFont:[UIFont systemFontOfSize:13]];
//        
//        [p_label setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]]];
//        [r_label setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk_ti.png"]]];
//        [content_lbl setTextColor:[UIColor grayColor]];
//        [time_lbl setTextColor:[UIColor grayColor]];
//        [content_lbl setNumberOfLines:2];
//        
//        [r_label setNumberOfLines:0];
//        [title_lbl setNumberOfLines:0];
//        //[content_lbl setLineBreakMode:NSLineBreakByWordWrapping];
//        
//        [view addSubview:p_label];
//        [view addSubview:r_label];
//        [view addSubview:title_lbl];
//        [view addSubview:time_lbl];
//        [view addSubview:content_lbl];
//        self.receiveLabel=r_label;
//        self.personLabel=p_label;
//        self.titleLabel=title_lbl;
//        self.timeLabel=time_lbl;
//        self.contentLabel=content_lbl;
//        view.backgroundColor=[UIColor whiteColor];
//        
//        UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 100, 320, 50)];
//        bgView.layer.borderWidth=0.5;
//        bgView.layer.borderColor=[UIColor grayColor].CGColor;
//        self.contentBgView=bgView;
//        [view addSubview:bgView];
//        UIButton *on_off_btn=[[UIButton alloc] initWithFrame:CGRectMake(320-50,150-21,50,21)];
//        [on_off_btn setTitle:@"展开" forState:UIControlStateNormal];
//        [on_off_btn setTitleColor:[UIColor colorWithRed:79/255.0f green:102/255.0f blue:139/255.0f alpha:1] forState:UIControlStateNormal];
//        [on_off_btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
//        [on_off_btn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:on_off_btn];
//        self.switchButton=on_off_btn;
//        self.headerView=view;
//    }
//    [self loadEmail];
//    return self.headerView;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
//{
//    if (!self.footerView) {
//        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
////        UIButton *download_button=[[UIButton alloc] initWithFrame:CGRectMake(40, 33, 100, 34)];
////        [download_button setImage:[UIImage imageNamed:@"send_download_nor.png"] forState:UIControlStateNormal];
////        [download_button setImage:[UIImage imageNamed:@"send_download_se.png"] forState:UIControlStateHighlighted];
////        [download_button addTarget:self  action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
////        UIButton *resave_button=[[UIButton alloc] initWithFrame:CGRectMake(180, 33, 100, 34)];
////        [resave_button setImage:[UIImage imageNamed:@"send_zc_nor.png"] forState:UIControlStateNormal];
////        [resave_button setImage:[UIImage imageNamed:@"send_zc_se.png"] forState:UIControlStateHighlighted];
////        [resave_button addTarget:self  action:@selector(toResave:) forControlEvents:UIControlEventTouchUpInside];
////        [view addSubview:download_button];
////        [view addSubview:resave_button];
//        self.footerView=view;
//    }
//    
//    return self.footerView;
//}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    //    self.selectedIndexPath=indexPath;
//    //    [self toMore:self];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
#pragma mark - SCBEmailManagerDelegate
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
-(void)sendFilesSucceed:(NSDictionary *)datadic
{
    [self showMessage:@"发送成功"];
}
-(void)viewReceiveSucceed:(NSDictionary *)datadic
{
    [self detailEmailSucceed:datadic];
    [self checkNotReadEmail];
}
-(void)viewSendSucceed:(NSDictionary *)datadic
{
    [self detailEmailSucceed:datadic];
}
-(void)detailEmailSucceed:(NSDictionary *)datadic
{
    if (datadic) {
        NSMutableArray *array=[NSMutableArray arrayWithArray:[datadic objectForKey:@"list"]];
        if (!array||array.count==0) {
            return;
        }
        self.dataDic=datadic;
        self.fileArray=array;
        [self loadEmail];
        [self.tableView reloadData];
//        [self reloadFiles];
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.Email%@",self.eid,self.etype]]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateEmailList];
    }
    NSLog(@"openFinderSucess:");
}
-(void)fileListSucceed:(NSData *)data
{
    NSError *jsonParsingError=nil;
    self.fileArray=[NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError]];
    if (self.fileArray) {
        [self.tableView reloadData];
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.EmailFileList",self.eid]]];
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

}
-(void)notReadCountSucceed:(NSDictionary *)datadic
{
    int notread=[[datadic objectForKey:@"notread"] intValue];
    MyTabBarViewController *myTabVC=[self.splitViewController.viewControllers objectAtIndex:0];
    if (notread>0) {
        if (myTabVC) {
            [myTabVC setHasEmailTagHidden:NO];
        }
    }else
    {
        if (myTabVC) {
            [myTabVC setHasEmailTagHidden:YES];
        }
    }
}
#pragma mark - SCBEmailManagerDelegate
-(void)moveUnsucess
{
    [self showMessage:@"操作失败"];
}
-(void)moveSucess
{
    [self showMessage:@"操作成功"];
}
-(void)operateUpdate
{
    [self moveSucess];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag=actionSheet.tag;
    if (tag>=0) {
        NSDictionary *dic=self.fileArray[tag];
        NSString *fid=[dic objectForKey:@"atta_fileid"];
        if (buttonIndex==2) {
            //分享选中的文件
            [self toCopyFiles:@[fid]];
        }else if(buttonIndex==1)
        {
            //下载选中的文件
            NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"atta_file_thumb"]];
            if([thumb length]==0)
            {
                thumb = @"0";
            }
            NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"atta_file_name"]];
            NSInteger fsize = [[dic objectForKey:@"atta_file_size"] integerValue];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            DownList *list = [[DownList alloc] init];
            list.d_name = name;
            list.d_downSize = fsize;
            list.d_thumbUrl = thumb;
            list.d_file_id = fid;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *todayDate = [NSDate date];
            list.d_datetime = [dateFormatter stringFromDate:todayDate];
            list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
            [tableArray addObject:list];
            [delegate.downmange addDownLists:tableArray];
        }else if(buttonIndex==0)
        {
            //picture
            NSString *fmine = [dic objectForKey:@"atta_file_mime"];
            NSString *fmime_=[fmine lowercaseString];
            
            NSInteger fsize = [[dic objectForKey:@"atta_file_size"] integerValue];
            NSString *name = [dic objectForKey:@"atta_file_name"];
            NSString *thumb = [dic objectForKey:@"atta_file_thumb"];
            NSString *fid = [dic objectForKey:@"atta_fileid"];
            
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
                    [look setTableArray:tableArray];
                    [self presentViewController:look animated:YES completion:nil];
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
                    browser.currentPreviewItemIndex=0;
                    browser.title=name;
                    browser.filePath=savedPath;
                    browser.fileName=name;
                    [self presentViewController:browser animated:YES completion:nil];
                } else {
                    OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                    NSArray *values = [NSArray arrayWithObjects:name,fid,[dic objectForKey:@"atta_file_size"], nil];
                    NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                    NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                    
                    otherBrowser.dataDic=d;
                    otherBrowser.title=name;
                    otherBrowser.dpDelegate=self;
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:otherBrowser];
                    [self presentViewController:nav animated:YES completion:nil];
//                    OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
//                    openFileView.dataDic = dic;
//                    openFileView.title = name;
//                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:openFileView];
//                    [self presentViewController:nav animated:YES completion:nil];
                }
            }
        }
    }else if(tag==-1)
    {
        
    }
}
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
#pragma mark - Deferred image loading (UIScrollViewDelegate)

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
    return;
    if ([self.fileArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.fileArray objectAtIndex:indexPath.row];
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
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
-(void)showMessage:(NSString *)message
{
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
    [self.hud hide:YES afterDelay:1.0f];
}
@end
