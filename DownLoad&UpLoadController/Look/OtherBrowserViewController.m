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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
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
//    [self showDoc];
    [self finished];
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
