//
//  DetailViewController.m
//  mdtest
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DetailViewController.h"
#import "PartitionViewController.h"
#import "OtherBrowserViewController.h"
#import "OpenFileViewController.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "MySplitViewController.h"
#import "FileListViewController.h"
#import "MyTabBarViewController.h"

#define kActionSheetDeleteFile 1024
#define kActionSheetDeletePhoto 1025

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize titleLabel,splitView_array,isFileManager,downItem,deleteItem,fullItem,dataDic,down_button,hud;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    for(UIViewController *viewCon in self.childViewControllers)
    {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            PartitionViewController *partition = (PartitionViewController *)viewCon;
            [partition willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
            });
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect down_rect = CGRectMake(0, 0, 30, 25);
    self.down_button = [[UIButton alloc] initWithFrame:down_rect];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_nor@2x.png"] forState:UIControlStateNormal];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_se@2x.png"] forState:UIControlStateHighlighted];
    [self.down_button addTarget:self action:@selector(clipClicked) forControlEvents:UIControlEventTouchUpInside];
    self.downItem = [[UIBarButtonItem alloc] initWithCustomView:self.down_button];
    UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_se@2x.png"] forState:UIControlStateHighlighted];
    
    [delete_button addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
    
    CGRect full_rect = CGRectMake(0, 0, 20, 20);
    UIButton *full_button = [[UIButton alloc] initWithFrame:full_rect];
    [full_button setBackgroundImage:[UIImage imageNamed:@"bt_alls_nor@2x.png"] forState:UIControlStateNormal];
    [full_button setBackgroundImage:[UIImage imageNamed:@"bt_alls_se@2x.png"] forState:UIControlStateHighlighted];
    [full_button addTarget:self action:@selector(fullClicked) forControlEvents:UIControlEventTouchUpInside];
    self.fullItem = [[UIBarButtonItem alloc] initWithCustomView:full_button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(void)removeAllView
{
    for(UIViewController *viewCon in self.childViewControllers)
    {
        if([viewCon isKindOfClass:[OtherBrowserViewController class]])
        {
            OtherBrowserViewController *otherBrowser = (OtherBrowserViewController *)viewCon;
            [otherBrowser back:nil];
        }
        else if([viewCon isKindOfClass:[OpenFileViewController class]])
        {
            OpenFileViewController *openFile = (OpenFileViewController *)viewCon;
            [openFile cancelDown];
        }
//        else if([viewCon isKindOfClass:[PartitionViewController class]])
//        {
//            PartitionViewController *partition = (PartitionViewController *)viewCon;
//            [partition cancelDown];
//        }
        [viewCon.view removeFromSuperview];
        [viewCon removeFromParentViewController];
    }
    [self hiddenPhototView];
}

-(void)showPhotoView:(NSString *)title withIsHave:(BOOL)isHaveDelete withIsHaveDown:(BOOL)isHaveDownload
{
    CGRect down_rect = CGRectMake(0, 0, 30, 25);
    
    self.down_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_save_nor@2x.png"] forState:UIControlStateNormal];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_save_se@2x.png"] forState:UIControlStateHighlighted];
    [self.down_button addTarget:self action:@selector(clipClicked) forControlEvents:UIControlEventTouchUpInside];
    self.downItem = [[UIBarButtonItem alloc] initWithCustomView:self.down_button];

    
    UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_se@2x.png"] forState:UIControlStateHighlighted];
    [delete_button addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
    
    if(titleLabel == nil)
    {
        CGRect title_rect = CGRectMake(0, 10, 200, 20);
        UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            title_rect.origin.x = (1024-320-200)/2;
        }
        else
        {
            title_rect.origin.x = (768-320-200)/2;
        }
//        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
//        [titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
//        [titleLabel setTextColor:[UIColor whiteColor]];
//        [self.navigationController.navigationBar addSubview:titleLabel];
        self.navigationItem.title=title;
        
    }
    if([splitView_array count]>0)
    {
        [splitView_array removeAllObjects];
    }
    if(isHaveDelete&&isHaveDownload)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,self.downItem,nil];
    }else if(isHaveDownload)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.downItem,nil];
    }else if(isHaveDelete)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,nil];
    }
    
    
//    [titleLabel setText:title];
    
    if(isFileManager)
    {
        self.navigationItem.rightBarButtonItems = splitView_array;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

-(void)hiddenPhototView
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [titleLabel setText:@""];
    self.navigationItem.rightBarButtonItems = nil;
}

-(void)showOtherView:(NSString *)title withIsHave:(BOOL)isHaveDelete withIsHaveDown:(BOOL)isHaveDownload;
{
    CGRect down_rect = CGRectMake(0, 0, 30, 25);
    
    self.down_button = [[UIButton alloc] initWithFrame:down_rect];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_nor@2x.png"] forState:UIControlStateNormal];
    [self.down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_se@2x.png"] forState:UIControlStateHighlighted];
    [self.down_button addTarget:self action:@selector(clipClicked) forControlEvents:UIControlEventTouchUpInside];
    self.downItem = [[UIBarButtonItem alloc] initWithCustomView:self.down_button];
    
    
    UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_se@2x.png"] forState:UIControlStateHighlighted];
    [delete_button addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
    
//    if(titleLabel == nil)
//    {
//        CGRect title_rect = CGRectMake(0, 10, 200, 20);
//        UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
//        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
//        {
//            title_rect.origin.x = (1024-320-200)/2;
//        }
//        else
//        {
//            title_rect.origin.x = (768-320-200)/2;
//        }
//        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
//        [titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
//        [titleLabel setTextColor:[UIColor whiteColor]];
//        [self.navigationController.navigationBar addSubview:titleLabel];
//    }
    if([splitView_array count]>0)
    {
        [splitView_array removeAllObjects];
    }
    if(isHaveDelete&&isHaveDownload)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,self.downItem,nil];
    }else if(isHaveDownload)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.downItem,nil];
    }else if(isHaveDelete)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,nil];
    }
    
//    [titleLabel setText:title];
    self.navigationItem.title=title;
    if(isFileManager)
    {
        self.navigationItem.rightBarButtonItems = splitView_array;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    self.navigationItem.leftBarButtonItem = nil;
}

-(void)showFullView
{
    self.navigationItem.leftBarButtonItem = fullItem;
}

-(void)fullClicked
{
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
    [self presentViewController:browser animated:NO completion:^{}];
}

-(void)clipClicked
{
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            PartitionViewController *parttion = (PartitionViewController *)viewCon;
            [parttion clipClicked:nil];
            break;
        }
    }
}

-(void)deleteClicked
{
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            PartitionViewController *parttion = (PartitionViewController *)viewCon;
            [parttion deleteClicked:nil];
            break;
        }
        else if([viewCon isKindOfClass:[QLBrowserViewController class]] || [viewCon isKindOfClass:[OpenFileViewController class]])
        {
            UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除此文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
            [actionSheet setTag:kActionSheetDeleteFile];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.action_array addObject:actionSheet];
            break;
        }
    }
}

//视图旋转之前自动调用
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

//视图旋转完成之后自动调用
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIActionSheet *actionsheet = [app.action_array lastObject];
    if(actionsheet)
    {
        [actionsheet dismissWithClickedButtonIndex:-1 animated:NO];
        [actionsheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

-(void)updateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect title_rect = self.titleLabel.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        title_rect.origin.x = (1024-320-200)/2;
    }
    else
    {
        title_rect.origin.x = (768-320-200)/2;
    }
    [self.titleLabel setFrame:title_rect];
    [self openFileUpdateViewToInterfaceOrientation:toInterfaceOrientation];
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            PartitionViewController *parttion = (PartitionViewController *)viewCon;
            CGRect jinDu_rect = CGRectMake(0, 0, 350, 50);
            CGRect control_rect = CGRectMake(0, 0, 1024, 768);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                jinDu_rect.origin.x = (1024-350)/2;
                jinDu_rect.origin.y = (768-50)/2;
                control_rect.size.width = 1024;
                control_rect.size.height = 768;
            }
            else
            {
                jinDu_rect.origin.x = (768-350)/2;
                jinDu_rect.origin.y = (1024-50)/2;
                control_rect.size.width = 768;
                control_rect.size.height = 1024;
            }
            [parttion.jinDuView setFrame:jinDu_rect];
            [parttion.jindu_control setFrame:control_rect];
            break;
        }
    }
}

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
}

-(void)openFileUpdateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[OpenFileViewController class]])
        {
            OpenFileViewController *openFile = (OpenFileViewController *)viewCon;
            CGRect fileImage_rect = CGRectMake(0, 10, 100, 100);
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
            [openFile.fileImageView setFrame:fileImage_rect];
            CGRect fileName_rect = CGRectMake(fileImage_rect.origin.x, fileImage_rect.origin.y+120, 400, 20);
            if(openFile.fileImageView.hidden)
            {
                fileName_rect.origin.y = fileName_rect.origin.y-70;
            }
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                fileName_rect.origin.x = (1024-320-400)/2;
            }
            else
            {
                fileName_rect.origin.x = (768-320-400)/2;
            }
            [openFile.fileNameLabel setFrame:fileName_rect];
            CGRect progess_rect = CGRectMake(0, fileName_rect.origin.y+40, 250, 5);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                progess_rect.origin.x = (1024-320-250)/2;
            }
            else
            {
                progess_rect.origin.x = (768-320-250)/2;
            }
            [openFile.progess_imageView setFrame:progess_rect];
            CGRect progess2_rect = CGRectMake(0, fileName_rect.origin.y+40, 0, 5);
            if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                progess2_rect.origin.x = (1024-320-250)/2;
            }
            else
            {
                progess2_rect.origin.x = (768-320-250)/2;
            }
            [openFile.progess2_imageView setFrame:progess2_rect];
            break;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

-(void)deleteCurrFile
{
    NSString *f_id=[self.dataDic objectForKey:@"fid"];
    [self.fm cancelAllTask];
    self.fm=[[SCBFileManager alloc] init];
    self.fm.delegate=self;
    [self.fm removeFileWithIDs:@[f_id]];
    
    NSDictionary *dic = self.dataDic;
    //获取数据
    NSString *fileName = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
    NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[fileName componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    NSString *file_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    //查询本地是否已经有该图片
    BOOL bl = [NSString image_exists_FM_file_path:file_path];
    if(bl)
    {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if([filemgr fileExistsAtPath:file_path])
        {
            BOOL isDelete = [filemgr removeItemAtPath:file_path error:nil];
            NSLog(@"删除文件是否成功：%i",isDelete);
        }
    }
}

-(void)networkError{}
-(void)authorMenusSuccess:(NSData*)data{}
-(void)searchSucess:(NSDictionary *)datadic{}
-(void)operateSucess:(NSDictionary *)datadic{}
-(void)openFinderSucess:(NSDictionary *)datadic{}
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary{}
//打开文件个人信息
-(void)getFileEntInfo:(NSDictionary *)dictionary{}
-(void)openFinderUnsucess{}
-(void)removeSucess
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [app.splitVC.viewControllers lastObject];
    UIViewController *detailView = [NavigationController.viewControllers objectAtIndex:0];
    if([detailView isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *viewCon = (DetailViewController *)detailView;
        [viewCon removeAllView];
    }else
    {
        DetailViewController *viewCon = [[DetailViewController alloc] init];
//        [NavigationController setViewControllers:@[viewCon] animated:NO];
        [NavigationController setViewControllers:nil];
        [NavigationController pushViewController:viewCon animated:NO];
    }
    MyTabBarViewController *tabbar = [app.splitVC.viewControllers firstObject];
    UINavigationController *NavigationController2 = [[tabbar viewControllers] objectAtIndex:0];
    for(int i=NavigationController2.viewControllers.count-1;i>0;i--)
    {
        FileListViewController *fileList = [NavigationController2.viewControllers objectAtIndex:i];
        if([fileList isKindOfClass:[FileListViewController class]])
        {
            [fileList operateUpdate];
            break;
        }
    }
}
-(void)removeUnsucess{}
-(void)renameSucess{}
-(void)renameUnsucess{}
-(void)moveSucess{}
-(void)moveUnsucess{}
-(void)newFinderSucess{}
-(void)newFinderUnsucess{}
-(void)Unsucess:(NSString *)strError{}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    if(buttonIndex == 0)
    {
        [self deleteCurrFile];
    }
}

-(void)saveSuccess
{
    if(self.hud)
    {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"图片已保存至照片库";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.5f];
}

-(void)saveFail
{
    if(self.hud)
    {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"图片保存失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

@end
