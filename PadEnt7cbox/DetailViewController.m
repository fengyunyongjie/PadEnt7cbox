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

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize titleLabel,splitView_array,isFileManager,downItem,deleteItem,fullItem,dataDic;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect down_rect = CGRectMake(0, 0, 30, 25);
    UIButton *down_button = [[UIButton alloc] initWithFrame:down_rect];
    [down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_nor@2x.png"] forState:UIControlStateNormal];
    [down_button addTarget:self action:@selector(clipClicked) forControlEvents:UIControlEventTouchUpInside];
    self.downItem = [[UIBarButtonItem alloc] initWithCustomView:down_button];
    UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
    [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
    [delete_button addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
    
    CGRect full_rect = CGRectMake(0, 0, 20, 20);
    UIButton *full_button = [[UIButton alloc] initWithFrame:full_rect];
    [full_button setBackgroundImage:[UIImage imageNamed:@"bt_alls_nor@2x.png"] forState:UIControlStateNormal];
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
        [viewCon.view removeFromSuperview];
        [viewCon removeFromParentViewController];
    }
    [self hiddenPhototView];
}

-(void)showPhotoView:(NSString *)title withIsHave:(BOOL)isHaveDelete
{
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
        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar addSubview:titleLabel];
    }
    
    if(!isHaveDelete)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.downItem,nil];
    }
    else
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,self.downItem,nil];
    }
    
    [titleLabel setText:title];
    
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

-(void)showOtherView:(NSString *)title withIsHave:(BOOL)isHaveDown
{
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
        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar addSubview:titleLabel];
    }
    if(!isHaveDown)
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,nil];
    }
    else
    {
        splitView_array = [NSMutableArray arrayWithObjects:self.deleteItem,self.downItem,nil];
    }
    
    [titleLabel setText:title];
    if(isFileManager)
    {
        self.navigationItem.rightBarButtonItems = splitView_array;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
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
        else if([viewCon isKindOfClass:[QLBrowserViewController class]])
        {
            [self deleteCurrFile];
            break;
        }
    }
}

//视图旋转之前自动调用
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
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

@end
