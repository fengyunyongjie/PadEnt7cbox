//
//  UpDownloadViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-29.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UpDownloadViewController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "YNFunctions.h"
#import "PhotoLookViewController.h"
#import "OtherBrowserViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MyTabBarViewController.h"
#import "MySplitViewController.h"
#import "OpenFileViewController.h"
#import "DetailViewController.h"
#import "PartitionViewController.h"
#import "MySplitViewController.h"
#import "MyTabBarViewController.h"
#import "CutomNothingView.h"

#define UpTabBarHeight (49+20+44)
#define kActionSheetTagDelete 77
#define kActionSheetTagAllDelete 78
#define kActionSheetTagUpload 79

@interface UpDownloadViewController ()
@property (strong,nonatomic) CutomNothingView *nothingView;
@end

@implementation UpDownloadViewController
@synthesize table_view,upLoading_array,upLoaded_array,downLoading_array,downLoaded_array,customSelectButton,isShowUpload,deleteObject,menuView,editView,rightItem,hud,btnStart,selectAllIds,btn_del,selectTableViewFid;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self hideMenu];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    selectTableViewRow = -1;
    self.isMultEditing=NO;
//    UISwipeGestureRecognizer *recognizer;
//    
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeFrom)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [[self view] addGestureRecognizer:recognizer];
//    recognizer = nil;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeFrom)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [[self view] addGestureRecognizer:recognizer];
    
    NSMutableArray *items=[NSMutableArray array];
    UIButton*rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,40)];
    [rightButton1 setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
    [rightButton1 setBackgroundImage:[UIImage imageNamed:@"title_more_se.png"] forState:UIControlStateHighlighted];
    [rightButton1 addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton1];
    [items addObject:rightItem1];
    
//    UIButton*rightButton2 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,40)];
//    [rightButton2 setImage:[UIImage imageNamed:@"title_upload_nor@2x.png"] forState:UIControlStateNormal];
//    [rightButton2 setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
//    [rightButton2 addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton2];
//    [items addObject:rightItem2];
    
    self.navigationItem.rightBarButtonItems = items;
    
    isShowUpload = YES;
    UIColor *stbgColor=[UIColor whiteColor]; //[UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1]; //[UIColor lightGrayColor]
    UIColor *stTextColor=[UIColor colorWithRed:85/255.0f green:103/255.0f blue:126/255.0f alpha:1];
    CGRect customRect = CGRectMake(0, 0, 320, 40);
    self.customSelectButton = [[CustomSelectButton alloc] initWithFrame:customRect leftText:@"正在上传" rightText:@"正在下载" isShowLeft:isShowUpload];
    [self.customSelectButton setDelegate:self];
    [self.customSelectButton setBackgroundColor:stbgColor];
    [self.customSelectButton.left_button setTitleColor:stTextColor forState:UIControlStateNormal];
    [self.customSelectButton.right_button setTitleColor:stTextColor forState:UIControlStateNormal];
    [self.view addSubview:self.customSelectButton];
    CGRect table_rect = CGRectMake(0, customRect.origin.y+customRect.size.height, 320, self.view.frame.size.height-(customRect.origin.y+customRect.size.height)-TabBarHeight+10);
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        table_rect.size.height = table_rect.size.height+TabBarHeight-10;
    }
    self.table_view = [[UITableView alloc] initWithFrame:table_rect];
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    [self.view addSubview:self.table_view];
}

-(void)uploadAction:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片并上传",@"从本机相册选择", nil];
    [actionSheet setTag:kActionSheetTagUpload];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    imagePickerController.f_id  =  @"0";
//    AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
//    app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.space_name];
//    imagePickerController.f_name = [NSString formatNSStringForOjbect:app_delegate.space_name];
//    imagePickerController.space_id = [NSString formatNSStringForOjbect:app_delegate.space_id];;
//    [imagePickerController requestFileDetail];
//    [imagePickerController setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:imagePickerController animated:NO];
}

-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.uploadmanage changeUpload:array_ changeDeviceName:device_name changeFileId:f_id changeSpaceId:s_id];
}

-(void)viewDidAppear:(BOOL)animated
{
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    if (self.nothingView) {
        [self.table_view bringSubviewToFront:self.nothingView];
    }
}

-(void)menuAction:(id)sender
{
    if (!self.menuView) {
        int Height=1024;
        self.menuView =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, Height, Height)];
        //[self.menuView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        UIControl *grayView=[[UIControl alloc] initWithFrame:CGRectMake(0, 64, Height, Height)];
        [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        [grayView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:grayView];
        CGSize btnSize=CGSizeMake(320, 45);
        UIButton *btnEdit,*btnUpload;
        
        UIColor *titleColor=[UIColor colorWithRed:83/255.0f green:113/255.0f blue:190/255.0f alpha:1];
        
        //        btnUpload=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)];
        //        [btnUpload setImage:[UIImage imageNamed:@"title_upload.png"] forState:UIControlStateHighlighted];
        //        [btnUpload setImage:[UIImage imageNamed:@"title_upload.png"] forState:UIControlStateNormal];
        //        [btnUpload setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
        //        [btnUpload setTitle:@"  上传" forState:UIControlStateNormal];
        //        [btnUpload setTitleColor:titleColor forState:UIControlStateNormal];
        //        [btnUpload setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        //        [btnUpload addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 0*btnSize.height+64, btnSize.width, btnSize.height)];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
        [btnEdit setTitle:@"  编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:titleColor forState:UIControlStateNormal];
        [btnEdit setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnStart=[[UIButton alloc] initWithFrame:CGRectMake(0, 1*btnSize.height+64, btnSize.width, btnSize.height)];
        [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateHighlighted];
        [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateNormal];
        [btnStart setBackgroundImage:[UIImage imageNamed:@"menu_3.png"] forState:UIControlStateNormal];
        [btnStart setTitle:@"  全部开始" forState:UIControlStateNormal];
        [btnStart setTitleColor:titleColor forState:UIControlStateNormal];
        [btnStart setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnStart addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //[self.menuView addSubview:btnUpload];
        [self.menuView addSubview:btnEdit];
        [self.menuView addSubview:btnStart];
        [self.menuView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarController.view.superview addSubview:self.menuView];
    }
    else
    {
        [self.menuView setHidden:!self.menuView.hidden];
    }
    
    NSLog(@"self.menuView.hidden:%i",self.menuView.hidden);
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if(isShowUpload)
    {
        if(delegate.uploadmanage.isStart)
        {
            [btnStart setImage:[UIImage imageNamed:@"title_allpasue.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_allpasue.png"] forState:UIControlStateNormal];
            [btnStart setTitle:@"  全部暂停" forState:UIControlStateNormal];
            //            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
        else
        {
            [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateNormal];
            [btnStart setTitle:@"  全部开始" forState:UIControlStateNormal];
            //            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
    }
    else
    {
        if(delegate.downmange.isStart)
        {
            [btnStart setImage:[UIImage imageNamed:@"title_allpasue.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_allpasue.png"] forState:UIControlStateNormal];
            [btnStart setTitle:@"  全部暂停" forState:UIControlStateNormal];
            //            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
        else
        {
            [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_allstart.png"] forState:UIControlStateNormal];
            [btnStart setTitle:@"  全部开始" forState:UIControlStateNormal];
            //            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
    }
}

-(void)editAction:(id)sender
{
    [self.menuView setHidden:YES];
    if(isShowUpload)
    {
        if([self.upLoaded_array count] == 0 && [self.upLoading_array count] == 0)
        {
            [self.table_view setEditing:NO animated:YES];
        }
        else
        {
            [self.table_view setEditing:!self.table_view.editing animated:YES];
        }
    }
    else
    {
        if([self.downLoaded_array count] == 0 && [self.downLoading_array count] == 0)
        {
            [self.table_view setEditing:NO animated:YES];
        }
        else
        {
            [self.table_view setEditing:!self.table_view.editing animated:YES];
        }
    }
    
    
    
    [self.table_view reloadData];
    [self updateLoadData];
    
    BOOL isHideTabBar=self.table_view.editing;
    self.isMultEditing=self.table_view.editing;
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    [self.tabBarController.tabBar setHidden:isHideTabBar];
    
//    for(UIView *view in self.tabBarController.view.subviews)
//    {
//        if([view isKindOfClass:[UITabBar class]])
//        {
//            if (isHideTabBar) { //if hidden tabBar
//                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height+10, view.frame.size.width, view.frame.size.height)];
//            }else {
//                NSLog(@"isHideTabBar %@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, [[UIScreen mainScreen]bounds].size.height-49, view.frame.size.width, view.frame.size.height)];
//            }
//        }else
//        {
//            if (isHideTabBar) {
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[UIScreen mainScreen]bounds].size.height)];
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//            }else {
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,[[UIScreen mainScreen]bounds].size.height-49)];
//            }
//        }
//    }
    
    if(self.editView == nil)
    {
        self.editView = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, 320, 49)];
        [self.editView setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forState:UIControlStateNormal];
        [self.editView addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarController.view addSubview:self.editView];
        //删除
        self.btn_del=[[UIButton alloc] initWithFrame:CGRectMake((320-29)/2, 5, 29, 39)];
        [self.btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
        [self.btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
        [self.btn_del addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.editView addSubview:self.btn_del];
    }
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    //隐藏按钮
    if (isHideTabBar) {
        [self.editView setHidden:NO];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItems:@[]];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    }
    else
    {
        [self.editView setHidden:YES];
        [self.selectAllIds removeAllObjects];
        [self.navigationItem setLeftBarButtonItem:nil];
        
        NSMutableArray *items=[NSMutableArray array];
        UIButton*rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,40)];
        [rightButton1 setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
        [rightButton1 setBackgroundImage:[UIImage imageNamed:@"title_more_se.png"] forState:UIControlStateHighlighted];
        [rightButton1 addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton1];
        [items addObject:rightItem1];
        
//        UIButton*rightButton2 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,40)];
//        [rightButton2 setImage:[UIImage imageNamed:@"title_upload_nor@2x.png"] forState:UIControlStateNormal];
//        [rightButton2 setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
//        [rightButton2 addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton2];
//        [items addObject:rightItem2];
        
        self.navigationItem.rightBarButtonItems = items;
    }
}

-(void)hideMenu
{
    [self.menuView setHidden:YES];
}

-(void)start:(id)sender
{
    [self.menuView setHidden:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(isShowUpload)
    {
        if(!appDelegate.uploadmanage.isStart)
        {
            [appDelegate.uploadmanage start];
        }
        else
        {
            [appDelegate.uploadmanage stopAllUpload];
        }
    }
    else
    {
        if(!appDelegate.downmange.isStart)
        {
            [appDelegate.downmange start];
        }
        else
        {
            [appDelegate.downmange stopAllDown];
        }
    }
}

-(void)deleteAll:(id)sender
{
    if (self.table_view.editing) {
        NSArray *array=[self.table_view indexPathsForSelectedRows];
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
            [appDelegate.window addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [actionSheet setTag:kActionSheetTagAllDelete];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.action_array addObject:actionSheet];
        }
    }
}

-(void)selectAllCell:(id)sender
{
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectAllCell:)]];
    [self updateSelectIndexPath];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    NSLog(@"进来");
}

-(void)updateSelectIndexPath
{
    self.selectAllIds = [self getSelectedIds];
}

-(void)updateLoadData
{
    if(!self.table_view.editing)
    {
        return;
    }
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                UpLoadList *list = [self.upLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                       [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                UpLoadList *list = [self.upLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                DownList *list = [self.downLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                DownList *list = [self.downLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                DownList *list = [self.downLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                DownList *list = [self.downLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
    }
}

-(void)cancelSelectAllCell:(id)sender
{
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES];
            }
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    [self updateSelectIndexPath];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self isSelectedLeft:isShowUpload];
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateTableViewCount
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.downmange updateLoad];
    [delegate.uploadmanage updateLoad];
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [delegate.uploadmanage.uploadArray count]+[delegate.downmange.downingArray count];
    MyTabBarViewController *tabbar = [delegate.splitVC.viewControllers firstObject];
    [tabbar addUploadNumber:app.applicationIconBadgeNumber];
    
    NSString *leftTitle;
    if([upLoading_array count]>0)
    {
        leftTitle = [NSString stringWithFormat:@"正在上传(%i)",[upLoading_array count]];
    }
    else
    {
        leftTitle = @"上传";
    }
    NSString *rightTitle;
    if([downLoading_array count]>0)
    {
        rightTitle = [NSString stringWithFormat:@"正在下载(%i)",[downLoading_array count]];
    }
    else
    {
        rightTitle = @"下载";
    }
    [self.customSelectButton updateCount:leftTitle downCount:rightTitle];
}

//显示数据正在加载中....
-(void)showLoadData
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"数据正在加载中......";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
}
-(void)createNothingView
{
    if (!self.nothingView) {
        float boderHeigth = 20;
        float labelHeight = 40;
        float imageHeight = 100;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        CGRect nothingRect = CGRectMake(0, 0, 320, h-164);
        self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
        [self.table_view addSubview:self.nothingView];
        [self.table_view bringSubviewToFront:self.nothingView];
        [self.nothingView hiddenView];
        [self.nothingView.notingLabel setText:@""];
    }
}
#pragma mark CustomSelectButtonDelegate -------------------

-(void)isSelectedLeft:(BOOL)bl
{
    NSLog(@"滑动：%i",bl);
    if(self.table_view.editing && bl!=isShowUpload)
    {
        [self editAction:nil];
    }
    isShowUpload = bl;
    
    [self updateTableViewCount];
    
    if(!bl)
    {
        DownList *list = [[DownList alloc] init];
        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.downLoaded_array == nil)
        {
            self.downLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectDownedAll]];
        }
        else
        {
            DownList *ls = [self.downLoaded_array firstObject];
            if(ls!=nil)
            {
                list.d_id = ls.d_id;
            }
            NSArray *array = [list selectDownedAll];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for(int i=0;i<[array count];i++)
            {
                [indexSet addIndex:i];
            }
            [self.downLoaded_array insertObjects:array atIndexes:indexSet];
        }
    }
    else
    {
        UpLoadList *list = [[UpLoadList alloc] init];
        list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.upLoaded_array == nil)
        {
            self.upLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectUploadListAllAndUploaded]];
        }
        else
        {
            UpLoadList *ls = [self.upLoaded_array firstObject];
            if(ls!=nil)
            {
                list.t_id = ls.t_id;
            }
            NSArray *array = [list selectUploadListAllAndUploaded];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for(int i=0;i<[array count];i++)
            {
                [indexSet addIndex:i];
            }
            [self.upLoaded_array insertObjects:array atIndexes:indexSet];
        }
    }
    [self.table_view reloadData];
    [self updateLoadData];
    
    
    if(isShowUpload)
    {
        if([self.upLoading_array count] == 0 && [self.upLoaded_array count] == 0)
        {
            if (!self.nothingView) {
                [self createNothingView];
            }
            [self.table_view bringSubviewToFront:self.nothingView];
            [self.nothingView notHiddenView];
            [self.nothingView.notingLabel setText:@"上传到云端，数据更安全"];
        }
        else
        {
            [self.nothingView hiddenView];
        }
    }
    else
    {
        if([self.downLoaded_array count] == 0 && [self.downLoading_array count] == 0)
        {
            if (!self.nothingView) {
                [self createNothingView];
            }
            [self.table_view bringSubviewToFront:self.nothingView];
            [self.nothingView notHiddenView];
            [self.nothingView.notingLabel setText:@"保存至本地，没有网络也可以查看"];
        }
        else
        {
            [self.nothingView hiddenView];
        }
    }
//    [self performSelector:@selector(updateSelected) withObject:Nil afterDelay:1.0];
}

-(void)leftSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:NO];
}

-(void)rightSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:YES];
}

#pragma mark UITableViewDelegate ---------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    if(isShowUpload)
    {
        if([upLoading_array count]>0)
        {
            count++;
        }
        if([upLoaded_array count]>0)
        {
            count++;
        }
    }
    else
    {
        if([downLoading_array count]>0)
        {
            count++;
        }
        if([downLoaded_array count]>0)
        {
            count++;
        }
    }
    return count;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect header_rect = CGRectMake(0, 0, 320, 20);
    UILabel *title_leble = [[UILabel alloc] initWithFrame:header_rect];
    NSString *title_State = @"";
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            title_State = [NSString stringWithFormat:@" 正在上传(%i)",[upLoading_array count]];
        }
        else if(type == 2)
        {
            title_State = [NSString stringWithFormat:@" 上传完成(%i)",[upLoaded_array count]];
        }
        else if(type == 3)
        {
            if(section==0 && [upLoading_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 正在上传(%i)",[upLoading_array count]];
            }
            else if(section==1 && [upLoaded_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 上传完成(%i)",[upLoaded_array count]];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            title_State = [NSString stringWithFormat:@" 正在下载(%i)",[downLoading_array count]];
        }
        else if(type == 2)
        {
            title_State = [NSString stringWithFormat:@" 下载完成(%i)",[downLoaded_array count]];
        }
        else if(type == 3)
        {
            if(section==0 && [downLoading_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 正在下载(%i)",[downLoading_array count]];
            }
            else if(section==1 && [downLoaded_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 下载完成(%i)",[downLoaded_array count]];
            }
        }
    }
    
    
    title_leble.text = [NSString formatNSStringForOjbect:title_State];
    [title_leble setTextColor:[UIColor blackColor]];
    [title_leble setBackgroundColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1]];
    [title_leble setFont:[UIFont systemFontOfSize:14]];
    return title_leble;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            count = [upLoading_array count];
        }
        else if(type == 2)
        {
            count = [upLoaded_array count];
        }
        else if(type == 3)
        {
            if(section==0 && [upLoading_array count]>0)
            {
                count = [upLoading_array count];
            }
            else if(section==1 && [upLoaded_array count]>0)
            {
                count = [upLoaded_array count];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            count = [downLoading_array count];
        }
        else if(type == 2)
        {
            count = [downLoaded_array count];
        }
        else if(type == 3)
        {
            if(section==0 && [downLoading_array count]>0)
            {
                count = [downLoading_array count];
            }
            else if(section==1 && [downLoaded_array count]>0)
            {
                count = [downLoaded_array count];
            }
        }
    }
    NSLog(@"count:%i",count);
    return count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadViewCell *cell;
    static NSString *cellString = @"upDownCell";
    cell = [self.table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    int section = indexPath.section;
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            if(section==0 && indexPath.row<[self.upLoading_array count])
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
        }
        else if(type == 3)
        {
            if(section==0 && indexPath.row<[self.upLoading_array count])
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
            else if(section==1 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            if(section==0 && indexPath.row<[self.downLoading_array count])
            {
                DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        else if(type == 3)
        {
            //下载部分
            if(section==0 && indexPath.row<[self.downLoading_array count])
            {
                DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
            else if(section==1 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        
    }
    [cell showEdit:self.table_view.editing];
    [cell setDelegate:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.table_view.isEditing)
    {
        selectTableViewRow = -1;
        [self updateSelectIndexPath];
        return;
    }
    selectTableViewRow = -1;
    if(!isShowUpload)
    {
        NSInteger type = [self getDownType];
        if(type == 2)
        {
            if(indexPath.row < [downLoaded_array count])
            {
                DownList *list = [downLoaded_array objectAtIndex:indexPath.row];
                NSString *f_name=list.d_name;
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSArray *array=[f_name componentsSeparatedByString:@"/"];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,list.d_file_id];
                [NSString CreatePath:createPath];
                NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath])
                {
                    selectTableviewSection = indexPath.section;
                    selectTableViewRow = indexPath.row;
                    NSString *curr_fid = [NSString formatNSStringForOjbect:list.d_file_id];
                    if([selectTableViewFid isEqualToString:curr_fid])
                    {
                        return;
                    }
                    selectTableViewFid = [NSString formatNSStringForOjbect:list.d_file_id];
                    NSString *fmime = [[[f_name componentsSeparatedByString:@"."] lastObject] lowercaseString];
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        int selectRow = 0;
                        NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                        for(int i=0;i<downLoaded_array.count;i++)
                        {
                            DownList *demo = [downLoaded_array objectAtIndex:i];
                            NSString *d_fmime = [[[demo.d_name componentsSeparatedByString:@"."] lastObject] lowercaseString];
                            if ([d_fmime isEqualToString:@"png"]||
                                [d_fmime isEqualToString:@"jpg"]||
                                [d_fmime isEqualToString:@"jpeg"]||
                                [d_fmime isEqualToString:@"bmp"]||
                                [d_fmime isEqualToString:@"gif"])
                            {
                                [tableArray addObject:demo];
                            }
                        }
                        for(int i=0;i<tableArray.count;i++)
                        {
                            DownList *demo = [tableArray objectAtIndex:i];
                            if(demo.d_id == list.d_id)
                            {
                                selectRow = i;
                            }
                        }
                        PartitionViewController *look = [[PartitionViewController alloc] init];
                        [look setCurrPage:selectRow];
                        [look setTableArray:tableArray];
                        look.isHaveDelete = YES;
                        look.isHaveDownload = NO;
                        DetailViewController *viewCon = [[DetailViewController alloc] init];
                        viewCon.isFileManager = NO;
                        [viewCon removeAllView];
                        [viewCon showPhotoView:list.d_name withIsHave:look.isHaveDelete withIsHaveDown:look.isHaveDownload];
                        [viewCon.view addSubview:look.view];
                        [viewCon addChildViewController:look];
                        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        NSArray * viewControllers=self.splitViewController.viewControllers;
                        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    }
                    else
                    {
                        OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
                        NSDictionary *diction = [[NSDictionary alloc] initWithObjectsAndKeys:f_name,@"fname",list.d_file_id,@"fid",savedPath,@"fthumb",[NSNumber numberWithInteger:list.d_downSize],@"fsize", nil];
                        
                        openFileView.dataDic = diction;
                        openFileView.title = f_name;
                        
                        DetailViewController *viewCon = [[DetailViewController alloc] init];
                        viewCon.isFileManager = NO;
                        [viewCon removeAllView];
                        [viewCon.view addSubview:openFileView.view];
                        [viewCon showOtherView:openFileView.title withIsHave:NO withIsHaveDown:NO];
                        [viewCon addChildViewController:openFileView];
                        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        NSArray * viewControllers=self.splitViewController.viewControllers;
                        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    }
                }else
                {
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
                    [appDelegate.window addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件不存在，请重新下载";
                    self.hud.mode=MBProgressHUDModeText;
                    self.hud.margin=10.f;
                    [self.hud show:YES];
                    [self.hud hide:YES afterDelay:1.0f];
                }
            }
        }
        else if(type == 3)
        {
            if(indexPath.section==1 && [downLoaded_array count]>0)
            {
                DownList *list = [downLoaded_array objectAtIndex:indexPath.row];
                NSString *f_name=list.d_name;
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSArray *array=[f_name componentsSeparatedByString:@"/"];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,list.d_file_id];
                [NSString CreatePath:createPath];
                NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath])
                {
                    selectTableviewSection = indexPath.section;
                    selectTableViewRow = indexPath.row;
                    NSString *curr_fid = [NSString formatNSStringForOjbect:list.d_file_id];
                    if([selectTableViewFid isEqualToString:curr_fid])
                    {
                        return;
                    }
                    selectTableViewFid = [NSString formatNSStringForOjbect:list.d_file_id];
                    NSString *fmime = [[[f_name componentsSeparatedByString:@"."] lastObject] lowercaseString];
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        int selectRow = 0;
                        NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                        for(int i=0;i<downLoaded_array.count;i++)
                        {
                            DownList *demo = [downLoaded_array objectAtIndex:i];
                            NSString *d_fmime = [[[demo.d_name componentsSeparatedByString:@"."] lastObject] lowercaseString];
                            if ([d_fmime isEqualToString:@"png"]||
                                [d_fmime isEqualToString:@"jpg"]||
                                [d_fmime isEqualToString:@"jpeg"]||
                                [d_fmime isEqualToString:@"bmp"]||
                                [d_fmime isEqualToString:@"gif"])
                            {
                                [tableArray addObject:demo];
                            }
                        }
                        for(int i=0;i<tableArray.count;i++)
                        {
                            DownList *demo = [tableArray objectAtIndex:i];
                            if(demo.d_id == list.d_id)
                            {
                                selectRow = i;
                            }
                        }
                        PartitionViewController *look = [[PartitionViewController alloc] init];
                        [look setCurrPage:selectRow];
                        [look setTableArray:tableArray];
                        look.isHaveDelete = YES;
                        look.isHaveDownload = NO;
                        DetailViewController *viewCon = [[DetailViewController alloc] init];
                        viewCon.isFileManager = NO;
                        [viewCon removeAllView];
                        [viewCon showPhotoView:list.d_name withIsHave:look.isHaveDelete withIsHaveDown:look.isHaveDownload];
                        [viewCon.view addSubview:look.view];
                        [viewCon addChildViewController:look];
                        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        NSArray * viewControllers=self.splitViewController.viewControllers;
                        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    }
                    else
                    {
                        OpenFileViewController *openFileView = [[OpenFileViewController alloc] init];
                        NSDictionary *diction = [[NSDictionary alloc] initWithObjectsAndKeys:f_name,@"fname",list.d_file_id,@"fid",savedPath,@"fthumb",[NSNumber numberWithInteger:list.d_downSize],@"fsize", nil];
                        
                        openFileView.dataDic = diction;
                        openFileView.title = f_name;
                        
                        DetailViewController *viewCon = [[DetailViewController alloc] init];
                        viewCon.isFileManager = NO;
                        [viewCon removeAllView];
                        viewCon.dataDic=diction;
                        [viewCon.view addSubview:openFileView.view];
                        [viewCon showOtherView:openFileView.title withIsHave:NO withIsHaveDown:NO];
                        [viewCon addChildViewController:openFileView];
                        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
                        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
                        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        NSArray * viewControllers=self.splitViewController.viewControllers;
                        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
                    }
                }else
                {
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
                    [appDelegate.window addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件不存在，请重新下载";
                    self.hud.mode=MBProgressHUDModeText;
                    self.hud.margin=10.f;
                    [self.hud show:YES];
                    [self.hud hide:YES afterDelay:1.0f];
                }
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.table_view.editing)
    {
        [self updateSelectIndexPath];
    }
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMultEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UploadViewCell *cell=(UploadViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [table_view setEditing:NO];
        [cell deleteSelf];
    }
}
-(void)deletCell:(NSObject *)object
{
    deleteObject = object;
    if([deleteObject isKindOfClass:[UpLoadList class]])
    {
        UpLoadList *list = (UpLoadList *)deleteObject;
        if(list.t_state != 1)
        {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你选择的文件中有正在上传的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定移除" otherButtonTitles:nil, nil];
//            [actionSheet setTag:kActionSheetTagDelete];
//            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
            return;
        }
    }
    else if([deleteObject isKindOfClass:[DownList class]])
    {
        DownList *list = (DownList *)deleteObject;
        if(list.d_state != 1 && list.d_state != 4)
        {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你选择的文件中有正在下载的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定移除" otherButtonTitles:nil, nil];
//            [actionSheet setTag:kActionSheetTagDelete];
//            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
            return;
        }
    }
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [actionSheet setTag:kActionSheetTagDelete];
//    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
}

-(NSMutableArray *)getSelectedIds
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i=0;i<self.table_view.indexPathsForSelectedRows.count;i++)
    {
        NSLog(@"多少次：%i",i);
        NSIndexPath *indexPath = [self.table_view.indexPathsForSelectedRows objectAtIndex:i];
        if(isShowUpload)
        {
            NSInteger type = [self getUploadType];
            if(type == 1)
            {
                if(indexPath.row<[self.upLoading_array count])
                {
                    UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 2)
            {
                if(indexPath.row<[self.upLoaded_array count])
                {
                    UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 3)
            {
                if(indexPath.section==0 && indexPath.row<[self.upLoading_array count])
                {
                    UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
                if(indexPath.section==1  && indexPath.row<[self.upLoaded_array count])
                {
                    UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
        }
        else
        {
            NSInteger type = [self getDownType];
            if(type == 1)
            {
                if(indexPath.row<[self.downLoading_array count])
                {
                    DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 2)
            {
                if(indexPath.row<[self.downLoaded_array count])
                {
                    DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 3)
            {
                if(indexPath.section==0 && indexPath.row<[self.downLoading_array count])
                {
                    DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
                if(indexPath.section==1 && indexPath.row<[self.downLoaded_array count])
                {
                    DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
        }
    }
    return array;
}

#pragma makr UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    if(actionSheet.tag == kActionSheetTagDelete && buttonIndex == 0)
    {
        [self deleteList];
    }
    else if(actionSheet.tag == kActionSheetTagAllDelete && buttonIndex == 0)
    {
        [self deleteOldList:self.selectAllIds];
        if(self.table_view.isEditing)
        {
            [self editAction:nil];
        }
    }else if(actionSheet.tag == kActionSheetTagUpload)
    {
        if (buttonIndex==0)
        {
            //拍照上传
            UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
            imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            
            //imagePicker.mediaTypes=[NSArray arrayWithObject:@"public.photo"];
            imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
            
            imagePicker.allowsEditing=NO;
            imagePicker.showsCameraControls=YES;
            imagePicker.cameraViewTransform=CGAffineTransformIdentity;
            
            // not all devices have two cameras or a flash so just check here
            if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] ) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront] ) {
                    //                        cameraSelectionButton.alpha = 1.0;
                    //                        showCameraSelection = YES;
                }
            } else {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            if ( [UIImagePickerController isFlashAvailableForCameraDevice:imagePicker.cameraDevice] ) {
                imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                //                    flashModeButton.alpha = 1.0;
                //                    showFlashMode = YES;
            }
            
            //                imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
            
            imagePicker.delegate = self;
            imagePicker.wantsFullScreenLayout = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }else if(buttonIndex==1)
        {
            //本机相册
            QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsMultipleSelection = YES;
            imagePickerController.f_id  =  @"0";
            AppDelegate *app_delegate = [[UIApplication sharedApplication] delegate];
            app_delegate.file_url = [NSString formatNSStringForOjbect:app_delegate.space_name];
            imagePickerController.f_name = [NSString formatNSStringForOjbect:app_delegate.space_name];
            imagePickerController.space_id = [NSString formatNSStringForOjbect:app_delegate.space_id];;
            [imagePickerController requestFileDetail];
            [imagePickerController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:imagePickerController animated:NO];
        }
    }
}

-(void)deleteList
{
    [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
}

-(void)deleteOldList:(NSMutableArray *)array
{
    if(isShowUpload)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.uploadmanage deletes:array];
    }
    else
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.downmange deletes:array];
    }
    NSLog(@"删除文件大小：%i",[array count]);
    for (int i=0;i<[array count]; i++) {
        NSObject *object = [array objectAtIndex:i];
        if([object isKindOfClass:[UpLoadList class]])
        {
            for(int j=0;j<[upLoading_array count];j++)
            {
                UpLoadList *list = (UpLoadList *)[upLoading_array objectAtIndex:j];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.uploadmanage deleteOneUpload:j];
                    break;
                }
            }
            for(int j=0;j<[upLoaded_array count];j++)
            {
                UpLoadList *list = (UpLoadList *)[upLoaded_array objectAtIndex:j];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    [upLoaded_array removeObjectAtIndex:j];
                    break;
                }
            }
        }
        else if([object isKindOfClass:[DownList class]])
        {
            for(int j=0;j<[downLoading_array count];j++)
            {
                DownList *list = (DownList *)[downLoading_array objectAtIndex:j];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.downmange deleteOneDown:j];
                    break;
                }
            }
            for(int j=0;j<[downLoaded_array count];j++)
            {
                DownList *list = (DownList *)[downLoaded_array objectAtIndex:j];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    [downLoaded_array removeObjectAtIndex:j];
                    break;
                }
            }
        }
    }
    [self isSelectedLeft:isShowUpload];
    [self updateSelected];
}



-(void)hiddenTabBar:(BOOL)isHideTabBar
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    [self.tabBarController.tabBar setHidden:isHideTabBar];
//    for(UIView *view in self.tabBarController.view.subviews)
//    {
//        if([view isKindOfClass:[UITabBar class]])
//        {
//            if (isHideTabBar) { //if hidden tabBar
//                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height+2, view.frame.size.width, view.frame.size.height)];
//            }else {
//                NSLog(@"isHideTabBar %@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, [[UIScreen mainScreen]bounds].size.height-49, view.frame.size.width, view.frame.size.height)];
//            }
//        }else
//        {
//            if (isHideTabBar) {
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[UIScreen mainScreen]bounds].size.height)];
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//            }else {
//                NSLog(@"%@",NSStringFromCGRect(view.frame));
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,[[UIScreen mainScreen]bounds].size.height-49)];
//            }
//        }
//    }
}

//type ,0:没有数据，1：准备数据，2：完成数据，3：1、2都有
-(NSInteger)getUploadType
{
    NSInteger type = 0;
    if([upLoading_array count]>0)
    {
        type = 1;
    }
    if([upLoaded_array count]>0)
    {
        if(type==1)
        {
            type = 3;
        }
        else
        {
            type = 2;
        }
    }
    return type;
}

//type ,0:没有数据，1：准备数据，2：完成数据，3：1、2都有
-(NSInteger)getDownType
{
    NSInteger type = 0;
    if([downLoading_array count]>0)
    {
        type = 1;
    }
    if([downLoaded_array count]>0)
    {
        if(type==1)
        {
            type = 3;
        }
        else
        {
            type = 2;
        }
    }
    return type;
}

//文件夹不存在
-(void)showFloderNot:(NSString *)alertText
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=alertText;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

//空间不足
-(void)showSpaceNot
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"空间不足";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
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

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    if(!isShowUpload)
    {
        IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader != nil)
        {
            UploadViewCell *cell = (UploadViewCell *)[self.table_view cellForRowAtIndexPath:indexPath];
            if(cell != nil && [cell isKindOfClass:[UploadViewCell class]])
            {
                [cell updateList];
            }
        }
        [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    }
}
#pragma mark - UIImagePickerControllerDelegate
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            NSString *filePath=[YNFunctions getTempCachePath];
            NSDateFormatter *dateFormate=[[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yy-MM-dd HH mm ss"];
            
            NSString *fileName=[NSString stringWithFormat:@"%@.jpg",[dateFormate stringFromDate:[NSDate date]]];
            filePath=[filePath stringByAppendingPathComponent:fileName];
            BOOL result=[UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
            if (result) {
                NSLog(@"文件保存成功");
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate.uploadmanage uploadFilePath:filePath toFileID:@"0" withSpaceID:delegate.space_id];
            }else
            {
                NSLog(@"文件保存失败");
            }
        }
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
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
    CGRect table_rect = self.table_view.frame;
    
    CGRect editView_rect = self.editView.frame;
    editView_rect.size.height = 49;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        editView_rect.origin.y = 768-49;
        table_rect.size.height = 768-self.customSelectButton.frame.size.height-TabBarHeight-49;
    }
    else
    {
        editView_rect.origin.y = 1024-49;
        table_rect.size.height = 1024-self.customSelectButton.frame.size.height-TabBarHeight-49;
    }
    [self.editView setFrame:editView_rect];
    [self.table_view setFrame:table_rect];
}

#pragma mark 当用户切换图片是，视图选择项也发生变化
-(void)updateSelected
{
    if(self.table_view.editing)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
    if(selectTableViewRow!=-1 && self.downLoaded_array.count>selectTableViewRow)
    {
        BOOL isHave = NO;
        for(int i=0;i<self.downLoaded_array.count;i++)
        {
            DownList *list = [downLoaded_array objectAtIndex:i];
            NSString *fid = [NSString formatNSStringForOjbect:list.d_file_id];
            if([fid isEqualToString:selectTableViewFid])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:selectTableviewSection];
                [self tableView:self.table_view didSelectRowAtIndexPath:indexPath];
                [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                isHave = YES;
                break;
            }
        }
        if(!isHave)
        {
            DownList *list = [downLoaded_array objectAtIndex:selectTableViewRow];
            NSString *fmime=[[list.d_name pathExtension] lowercaseString];
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectTableViewRow inSection:selectTableviewSection];
                [self tableView:self.table_view didSelectRowAtIndexPath:indexPath];
                [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
        }
    }
    else if(selectTableViewRow!=-1 && self.downLoaded_array.count>self.table_view.visibleCells.count-1)
    {
        DownList *list = [downLoaded_array objectAtIndex:self.table_view.visibleCells.count-1];
        NSString *fmime=[[list.d_name pathExtension] lowercaseString];
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.table_view.visibleCells.count-1 inSection:selectTableviewSection];
            [self tableView:self.table_view didSelectRowAtIndexPath:indexPath];
            [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    });
}

-(void)updateJinduData
{
    if(isShowUpload)
    {
        if(self.table_view.visibleCells.count>0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UploadViewCell *cell = (UploadViewCell *)[self.table_view cellForRowAtIndexPath:indexPath];
            if(self.upLoading_array.count>0)
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:0];
                [cell setUploadDemo:list];
            }
        }
    }
    else
    {
        if(self.table_view.visibleCells.count>0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UploadViewCell *cell = (UploadViewCell *)[self.table_view cellForRowAtIndexPath:indexPath];
            if(self.downLoading_array.count>0)
            {
                DownList *list = [self.downLoading_array objectAtIndex:0];
                [cell setDownDemo:list];
            }
        }
    }
}

@end
