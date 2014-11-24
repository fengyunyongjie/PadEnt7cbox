//
//  OtherBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import "OtherBrowserViewController.h"
#import "QLBrowserViewController.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "FileListViewController.h"

#define TabBarHeight 60
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
@interface OtherBrowserViewController ()
@property (strong,nonatomic) DwonFile *downImage;
@end

@implementation OtherBrowserViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [self download:nil];
}
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.downImage cancelDownload];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
         self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    } else {
        
        float topHeigth = 20;
        if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
        {
            topHeigth = 0;
        }
        self.navigationController.navigationBarHidden = YES;
        UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, topHeigth, self.view.frame.size.width, 44)];
        UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Title.png"]];
        niv.frame=nbar.frame;
        [nbar addSubview:niv];
        [self.view addSubview: nbar];
        
        //标题
        self.titleLabel=[[UILabel alloc] init];
        self.titleLabel.text=self.title;
        self.titleLabel.font=[UIFont boldSystemFontOfSize:18];
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
        self.titleLabel.backgroundColor=[UIColor clearColor];
        self.titleLabel.frame=CGRectMake(80, topHeigth, 160, 44);
        [nbar addSubview:self.titleLabel];
        //把色值转换成图片
        CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
        UIGraphicsBeginImageContext(rect_image.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       [hilighted_color CGColor]);
        CGContextFillRect(context, rect_image);
        UIImage * imge = [[UIImage alloc] init];
        imge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //返回按钮
        if(1)
        {
            UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
            UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, topHeigth+(44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
            [back_button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
            [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
            [back_button setImage:back_image forState:UIControlStateNormal];
            [nbar addSubview:back_button];
        }
    }
   
    
    self.isFinished=NO;
    [self updateUI];
//    [self showDoc];
    
}

- (void)updateUI
{
    NSString *fname=[self.dataDic objectForKey:@"fname"];
    NSString *fmime=[[fname pathExtension] lowercaseString];
    UIImage *fileImage = nil;
    if ([fmime isEqualToString:@"doc"]||
        [fmime isEqualToString:@"docx"]||
        [fmime isEqualToString:@"rtf"])
    {
        fileImage = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        fileImage = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        fileImage = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        fileImage = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        fileImage = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        fileImage = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        fileImage = [UIImage imageNamed:@"file_txt.png"];
    }else
    {
        fileImage = [UIImage imageNamed:@"file_other.png"];
    }
    [self.iconImageView setImage:fileImage];
}

-(IBAction)download:(id)sender
{
    [self.downloadProgress setHidden:NO];
    [self.downloadLabel setHidden:NO];
    [self.downloadProgress setProgress:0.0f];
    
    NSString *fileSize = [self.dataDic objectForKey:@"filesize"];
    
    [self.downloadLabel setText:[NSString stringWithFormat:@"正在下载...(0B/%@)",fileSize]];
    [self toDownloading];
}

-(void)toDownloading
{
    if (self.downImage==nil) {
        NSString *file_id = [self.dataDic objectForKey:@"fid"];
        NSString *f_name = [self.dataDic objectForKey:@"fname"];
        NSInteger size = [[self.dataDic objectForKey:@"fsize"] integerValue];
        self.downImage = [[DwonFile alloc] init];
        [self.downImage setFile_id:file_id];
        [self.downImage setFileName:f_name];
        [self.downImage setFileSize:size];
        [self.downImage setDelegate:self];
        [self.downImage startDownload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)back:(id)sender
{
    [self.downImage cancelDownload];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SCBDownloaderDelegate Methods
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    [self.downloadProgress setHidden:YES];
    [self.downloadLabel setText:@"下载完成"];
//    [self dismissViewControllerAnimated:NO completion:^{
//        [self.dpDelegate downloadFinished:self.dataDic];
//    }];
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    long t_size=[[self.dataDic objectForKey:@"fsize"] intValue];
    [self.downloadProgress setProgress:(float)downSize/t_size];
    NSString *s_size=[YNFunctions convertSize:[NSString stringWithFormat:@"%i",downSize]];
    NSString *s_tsize=[YNFunctions convertSize:[NSString stringWithFormat:@"%ld",t_size]];
    NSString *text=[NSString stringWithFormat:@"正在下载...(%@/%@)",s_size,s_tsize];
    [self.downloadLabel setText:text];
}

- (void)finished
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.dpDelegate downloadFinished:self.dataDic];
    }];
}

- (void)downFinish:(NSString *)baseUrl
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        [self finished];

    } else {
        [self showDoc];

    }
}

-(void)showDoc
{
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *f_name=[self.dataDic objectForKey:@"fname"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:createPath];
    self.savePath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]) {
        [self performSelector:@selector(showNewView) withObject:self afterDelay:1.0f];
    }
}

-(void)showNewView
{
    NSLog(@"显示新的视图");
    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
    browser.dataSource=browser;
    browser.delegate=browser;
    browser.title=[self.dataDic objectForKey:@"fname"];
    browser.filePath=self.savePath;
    browser.fileName=[self.dataDic objectForKey:@"fname"];
    //[self dismissViewControllerAnimated:NO completion:nil];
    if(isBack)
    {
        return;
    }
    browser.currentPreviewItemIndex=0;
    [self presentViewController:browser animated:YES completion:^(void){
        [self.downloadProgress setHidden:YES];
        [self.downloadLabel setText:@""];
        [self.downloadLabel setHidden:NO];
    }];
    NSLog(@"显示成功");
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
#pragma mark - QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    
}
// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *fileURL = nil;
    fileURL=[NSURL fileURLWithPath:self.savePath];
    return fileURL;
}


-(void)didFailWithError
{
    
}
//上传失败
-(void)upError{}
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

@end
