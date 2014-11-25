//
//  OpenFileViewController.m
//  PadEnt7cbox
//
//  Created by Yangsl on 14-1-8.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "OpenFileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "YNFunctions.h"
#import <QuickLook/QuickLook.h>
#import "QLBrowserViewController.h"
#import "AppDelegate.h"
#import "MySplitViewController.h"
#import "MyTabBarViewController.h"
#import "DetailViewController.h"
#import "FileListViewController.h"
#import "NSString+format.h"

@interface OpenFileViewController ()

@end

@implementation OpenFileViewController
@synthesize  fileImageView,fileNameLabel,progess_imageView,progess2_imageView,dataDic,downImage,isNotLook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect fileImage_rect = CGRectMake(0, 10, 100, 100);
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        fileImage_rect.origin.x = (1024-320-100)/2;
        fileImage_rect.origin.y = (768-44-100-40)/2;
    }
    else
    {
        fileImage_rect.origin.x = (768-320-100)/2;
        fileImage_rect.origin.y = (1024-44-100-40)/2;
    }
    self.fileImageView = [[UIImageView alloc] initWithFrame:fileImage_rect];
    
    NSString *fname=[dataDic objectForKey:@"fname"];
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
    [self.fileImageView setImage:fileImage];
    [self.view addSubview:self.fileImageView];
    
    CGRect fileName_rect = CGRectMake(fileImage_rect.origin.x, fileImage_rect.origin.y+120, 400, 20);
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        fileName_rect.origin.x = (1024-320-400)/2;
    }
    else
    {
        fileName_rect.origin.x = (768-320-400)/2;
    }
    
    self.fileNameLabel = [[UILabel alloc] initWithFrame:fileName_rect];
    [self.fileNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fileNameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self.fileNameLabel setText:self.title];
    [self.view addSubview:self.fileNameLabel];
    
    CGRect progess_rect = CGRectMake(0, fileName_rect.origin.y+40, 250, 5);
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        progess_rect.origin.x = (1024-320-250)/2;
    }
    else
    {
        progess_rect.origin.x = (768-320-250)/2;
    }
    self.progess_imageView = [[UIImageView alloc] initWithFrame:progess_rect];
    [self.progess_imageView setBackgroundColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
    self.progess_imageView.layer.masksToBounds = YES;
    self.progess_imageView.layer.cornerRadius = 4;
    [self.view addSubview:self.progess_imageView];
    
    CGRect progess2_rect = CGRectMake(0, fileName_rect.origin.y+40, 0, 5);
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        progess2_rect.origin.x = (1024-320-250)/2;
    }
    else
    {
        progess2_rect.origin.x = (768-320-250)/2;
    }
    self.progess2_imageView = [[UIImageView alloc] initWithFrame:progess2_rect];
    [self.progess2_imageView setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:127.0/255.0 blue:191.0/255.0 alpha:1]];
    self.progess2_imageView.layer.masksToBounds = YES;
    self.progess2_imageView.layer.cornerRadius = 4;
    [self.view addSubview:self.progess2_imageView];
    
    if(isNotLook)
    {
        [self.fileImageView setHidden:YES];
        [self.progess_imageView setHidden:YES];
        if(self.fileImageView.hidden)
        {
            fileName_rect.origin.y = fileName_rect.origin.y-70;
        }
        [self.fileNameLabel setFrame:fileName_rect];
        [self.fileNameLabel setText:@"权限不足无法预览"];
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        DetailViewController *viewCon = [[DetailViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        NSArray * viewControllers=app.splitVC.viewControllers;
        app.splitVC.viewControllers=@[viewControllers.firstObject,nav];
        return;
    }
    
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSString *localThumbPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:localThumbPath];
    
//    NSString *fthumb=[self.dataDic objectForKey:@"fthumb"];
//    NSString *localThumbPath=[YNFunctions getIconCachePath];
//    fthumb =[YNFunctions picFileNameFromURL:fthumb];
//    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
    NSString *fmine = [[[[NSString formatNSStringForOjbect:[self.dataDic objectForKey:@"fname"]] componentsSeparatedByString:@"."] lastObject] lowercaseString];
    if([self isFileOpen:fmine])
    {
        NSLog(@"是否存在文件：%@",localThumbPath);
        if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath])
        {
            [self.progess_imageView setHidden:YES];
            [self.progess2_imageView setHidden:YES];
        }
        else
        {
            [self.progess_imageView setHidden:NO];
            [self.progess2_imageView setHidden:NO];
            self.downImage = [[DwonFile alloc] init];
            self.downImage.fileName = [NSString formatNSStringForOjbect:[self.dataDic objectForKey:@"fname"]];
            self.downImage.fileSize = [[self.dataDic objectForKey:@"fsize"] integerValue];
            self.downImage.file_id = [NSString formatNSStringForOjbect:[self.dataDic objectForKey:@"fid"]];
            self.downImage.delegate = self;
            [self.downImage startDownload];
        }
    }
    else
    {
        [self.fileImageView setHidden:YES];
        [self.progess_imageView setHidden:YES];
        if(self.fileImageView.hidden)
        {
            fileName_rect.origin.y = fileName_rect.origin.y-70;
        }
        [self.fileNameLabel setFrame:fileName_rect];
        [self.fileNameLabel setText:@"此文件无法预览"];
        
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        DetailViewController *viewCon = [[DetailViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        NSArray * viewControllers=app.splitVC.viewControllers;
        app.splitVC.viewControllers=@[viewControllers.firstObject,nav];
    }
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    DetailViewController *viewCon = [[DetailViewController alloc] init];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    NSArray * viewControllers=app.splitVC.viewControllers;
    app.splitVC.viewControllers=@[viewControllers.firstObject,nav];
}

-(void)cancelDown
{
    if(self.downImage)
    {
        [self.downImage cancelDownload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma DownLoadDelegate --------

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath
{
    
}

-(void)downCurrSize:(NSInteger)currSize
{
    float width = currSize*250.0/self.downImage.fileSize;
    CGRect progess2_rect = self.progess2_imageView.frame;
    progess2_rect.size.width = width;
    [self.progess2_imageView setFrame:progess2_rect];
}

- (void)downFinish:(NSString *)baseUrl
{
    NSLog(@"downFinish:(NSString *)baseUrl");
    CGRect progess2_rect = self.progess2_imageView.frame;
    progess2_rect.size.width = 250;
    [self.progess2_imageView setFrame:progess2_rect];
    
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *f_name=[self.dataDic objectForKey:@"fname"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:createPath];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    
    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
    browser.title=f_name;
    browser.filePath=savedPath;
    browser.fileName=f_name;
    browser.dataSource=browser;
    browser.delegate=browser;
    browser.currentPreviewItemIndex=0;
    CGRect self_rect = CGRectMake(0, 0, 0, 0);
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        self_rect.size.width = 1024-320;
        self_rect.size.height = 768;
    }
    else
    {
        self_rect.size.width = 768-320;
        self_rect.size.height = 1024;
    }
    [browser.view setFrame:self_rect];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    DetailViewController *viewCon = [[DetailViewController alloc] init];
    [viewCon removeAllView];
    [viewCon.view addSubview:browser.view];
    browser.view.frame=viewCon.view.bounds;
    [viewCon showOtherView:browser.title withIsHave:self.isHaveDelete withIsHaveDown:self.isHaveDownload];
    [viewCon addChildViewController:browser];
    viewCon.dataDic=self.dataDic;
    [viewCon showFullView];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    NSArray * viewControllers=app.splitVC.viewControllers;
    app.splitVC.viewControllers=@[viewControllers.firstObject,nav];
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    
}

-(void)didFailWithError
{
    NSLog(@"didFailWithError");
}

//上传失败
-(void)upError
{
    
}

//服务器异常
-(void)webServiceFail
{
    
}

//上传无权限
-(void)upNotUpload
{
    
}

//用户存储空间不足
-(void)upUserSpaceLass
{
    
}

//等待WiFi
-(void)upWaitWiFi
{
    
}

//网络失败
-(void)upNetworkStop
{
    
}

//文件是否可以打开
-(BOOL)isFileOpen:(NSString *)type
{
    if([type isEqualToString:@"doc"] ||
       [type isEqualToString:@"docx"] ||
       [type isEqualToString:@"xls"]||
       [type isEqualToString:@"xlsx"]||
       [type isEqualToString:@"ppt"]||
       [type isEqualToString:@"pptx"]||
       [type isEqualToString:@"pdf"]||
       [type isEqualToString:@"ppt"]||
       [type isEqualToString:@"txt"])
    {
        return YES;
    }
    return NO;
}

@end
