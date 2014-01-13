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

@interface OpenFileViewController ()

@end

@implementation OpenFileViewController
@synthesize  fileImageView,fileNameLabel,progess_imageView,progess2_imageView,dataDic,downImage;

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
    [self.fileImageView setImage:[UIImage imageNamed:@"file_other.png"]];
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
    [self.progess_imageView setBackgroundColor:[UIColor grayColor]];
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
    [self.progess2_imageView setBackgroundColor:[UIColor blueColor]];
    self.progess2_imageView.layer.masksToBounds = YES;
    self.progess2_imageView.layer.cornerRadius = 4;
    [self.view addSubview:self.progess2_imageView];
    
    
    NSString *file_id=[self.dataDic objectForKey:@"fid"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSString *localThumbPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:localThumbPath];
    
//    NSString *fthumb=[self.dataDic objectForKey:@"fthumb"];
//    NSString *localThumbPath=[YNFunctions getIconCachePath];
//    fthumb =[YNFunctions picFileNameFromURL:fthumb];
//    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
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
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [app.splitVC.viewControllers lastObject];
    UIViewController *detailView = [NavigationController.viewControllers objectAtIndex:0];
    if([detailView isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *viewCon = (DetailViewController *)detailView;
        [viewCon setDataDic:self.dataDic];
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
    NSLog(@"downCurrSize:%i",currSize);
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
    browser.dataSource=browser;
    browser.delegate=browser;
    browser.currentPreviewItemIndex=0;
    browser.title=f_name;
    browser.filePath=savedPath;
    browser.fileName=f_name;
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
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [app.splitVC.viewControllers lastObject];
    UIViewController *detailView = [NavigationController.viewControllers objectAtIndex:0];
    if([detailView isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *viewCon = (DetailViewController *)detailView;
        [viewCon removeAllView];
        [viewCon.view addSubview:browser.view];
        [viewCon showOtherView:browser.title withIsHave:YES];
        [viewCon addChildViewController:browser];
    }
    
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

@end
