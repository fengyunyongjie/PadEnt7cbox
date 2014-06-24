//
//  EmailListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "EmailListViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "EmailDetailViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "CustomSelectButton.h"
#import "MyTabBarViewController.h"
#import "AppDelegate.h"

enum{
    kActionSheetTagDeleteOne,
    kActionSheetTagDeletaAll,
};

@interface EmailListViewController ()<SCBEmailManagerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,CustomSelectButtonDelegate>
@property (strong,nonatomic) SCBEmailManager *em;
@property(strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIToolbar *moreEditBar;
@property (strong,nonatomic) UILabel * notingLabel;
@property (strong,nonatomic) UIView *nothingView;
@end

@implementation EmailListViewController
@synthesize customSelectButton,isShowEmail;

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
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height);
    
    isShowEmail = YES;
    CGRect customRect = CGRectMake(0, 0, 320, 40);
    self.customSelectButton = [[CustomSelectButton alloc] initWithFrame:customRect leftText:@"收件箱" rightText:@"发件箱" isShowLeft:isShowEmail];
    [self.customSelectButton setDelegate:self];
    UIColor *stbgColor=[UIColor whiteColor]; //[UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1]; //[UIColor lightGrayColor]
    UIColor *stTextColor=[UIColor colorWithRed:85/255.0f green:103/255.0f blue:126/255.0f alpha:1];
    [self.customSelectButton setBackgroundColor:stbgColor];
    [self.customSelectButton.left_button setTitleColor:stTextColor forState:UIControlStateNormal];
    [self.customSelectButton.right_button setTitleColor:stTextColor forState:UIControlStateNormal];
    [self.view addSubview:self.customSelectButton];
    
    NSMutableArray *items=[NSMutableArray array];
    UIButton*rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,40)];
    [rightButton1 setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
    [rightButton1 setBackgroundImage:[UIImage imageNamed:@"title_more_se.png"] forState:UIControlStateHighlighted];
    [rightButton1 addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton1];
    [items addObject:rightItem1];
    
    self.rightItems=items;
    self.navigationItem.rightBarButtonItems = items;
    
    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    //左右滑动效果
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    recognizer = nil;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateEmailList];
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}
-(void)viewDidLayoutSubviews
{
//    CGRect r=self.view.frame;
//    self.tableView.frame=CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-60-40);
//    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
//    NSLog(@"self.tableview.frame:%@",NSStringFromCGRect(self.tableView.frame));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark CustomSelectButtonDelegate -------------------

-(void)isSelectedLeft:(BOOL)bl
{
    isShowEmail = bl;
    
    [self updateEmailList];
    if (self.tableView.isEditing) {
        [self editAction:nil];
    }
    [self.tableView reloadData];
}

-(void)leftSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:NO];
}

-(void)rightSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:YES];
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self updateEmailList];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    //	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark - 操作方法
- (void)updateEmailList
{
    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
    if (isShowEmail) {
        [self.em receiveListWithCursor:0 offset:0 subject:@""];
    }else
    {
        [self.em sendListWithCursor:0 offset:0 subject:@""];
    }
}
- (void)operateUpdate
{
    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
    [self.em operateUpdateWithType:@"2"];
}
-(void)menuAction:(id)sender
{
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        self.menuView=nil;
    }
    if (!self.menuView) {
        int Height=1024;
        self.menuView =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, Height, Height)];
        //[self.menuView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        UIControl *grayView=[[UIControl alloc] initWithFrame:CGRectMake(0, 64, Height, Height)];
        [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
        [grayView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:grayView];
        CGSize btnSize=CGSizeMake(320, 45);
        UIButton *btnNewFinder,*btnEdit,*btnSort,*btnUpload,*btnClearAll;
        UIColor *titleColor=[UIColor colorWithRed:83/255.0f green:113/255.0f blue:190/255.0f alpha:1];
        btnUpload=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)];
        [btnUpload setImage:[UIImage imageNamed:@"title_read.png"] forState:UIControlStateHighlighted];
        [btnUpload setImage:[UIImage imageNamed:@"title_read.png"] forState:UIControlStateNormal];
        [btnUpload setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
        [btnUpload setTitle:@"  全部标为已读" forState:UIControlStateNormal];
        [btnUpload setTitleColor:titleColor forState:UIControlStateNormal];
        [btnUpload setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnUpload addTarget:self action:@selector(markAllAsRead:) forControlEvents:UIControlEventTouchUpInside];
        
        btnClearAll=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)];
        [btnClearAll setImage:[UIImage imageNamed:@"title_alldel.png"] forState:UIControlStateHighlighted];
        [btnClearAll setImage:[UIImage imageNamed:@"title_alldel.png"] forState:UIControlStateNormal];
        [btnClearAll setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
        [btnClearAll setTitle:@"  全部清空" forState:UIControlStateNormal];
        [btnClearAll setTitleColor:titleColor forState:UIControlStateNormal];
        [btnClearAll setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnClearAll addTarget:self action:@selector(clearAllEmail:) forControlEvents:UIControlEventTouchUpInside];
        
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 1*btnSize.height, btnSize.width, btnSize.height)];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_edit.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
        [btnEdit setTitle:@"  编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:titleColor forState:UIControlStateNormal];
        [btnEdit setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray *array=[NSMutableArray array];
        if (isShowEmail) {
            [array addObject:btnUpload];
        }else
        {
            [array addObject:btnClearAll];
        }
        
        [array addObject:btnEdit];
        for (int i=0; i<array.count; i++) {
            UIButton *btn=[array objectAtIndex:i];
            btn.frame= CGRectMake(0, i*btnSize.height+64, btnSize.width, btnSize.height);
            if (i==0) {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_1.png"] forState:UIControlStateNormal];
            }else if(i==array.count-1)
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_3.png"] forState:UIControlStateNormal];
            }else
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_2.png"] forState:UIControlStateNormal];
            }
            [self.menuView addSubview:btn];
        }
        //        [self.menuView addSubview:btnUpload];
        //        [self.menuView addSubview:btnNewFinder];
        //        [self.menuView addSubview:btnEdit];
        //        [self.menuView addSubview:btnSort];
        
        [self.menuView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarController.view.superview addSubview:self.menuView];
        [self.menuView setHidden:YES];
    }
    [self.menuView setHidden:!self.menuView.hidden];
}
-(void)hideMenu
{
    [self.menuView setHidden:YES];
}

-(void)markAllAsRead:(id)sender
{
    [self toSetAllRead:sender];
    [self hideMenu];
}
-(void)clearAllEmail:(id)sender
{
    [self hideMenu];
    if ((isShowEmail&&self.inArray.count!=0)||((!isShowEmail)&&self.outArray.count!=0)) {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除所有内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
        [actionSheet setTag:kActionSheetTagDeletaAll];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}
-(void)selectAllCell:(id)sender
{
    NSArray *array=nil;
    if (isShowEmail) {
        array=self.inArray;
    }else
    {
        array=self.outArray;
    }
    if (array) {
        for (int i=0; i<array.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(deselectAllCell:)]];
}
-(void)deselectAllCell:(id)sender
{
    NSArray *array=nil;
    if (isShowEmail) {
        array=self.inArray;
    }else
    {
        array=self.outArray;
    }
    if (array) {
        for (int i=0; i<array.count; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
}
-(NSArray *)selectedIndexPaths
{
    NSArray *retVal=nil;
    retVal=self.tableView.indexPathsForSelectedRows;
    return retVal;
}
-(NSArray *)selectedIDs
{
    NSArray *array;
    if (isShowEmail) {
        array=self.inArray;
    }else
    {
        array=self.outArray;
    }
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
        NSDictionary *dic=[array objectAtIndex:indexpath.row];
        NSString *fid;
        if (isShowEmail) {
            fid=[dic objectForKey:@"re_id"];
        }else
        {
            fid=[dic objectForKey:@"send_id"];
        }

        [ids addObject:fid];
    }
    return ids;
}
-(void)toResend:(id)sender
{
    
}
-(void)toSetAllRead:(id)sender
{
    [self.em cancelAllTask];
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    if (isShowEmail) {
        [self.em updateReceiveIsReadByUserID];
    }
    [self editFinished];
}
-(void)toSetRead:(id)sender
{
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view.superview addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何邮件";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }
    
    [self.em cancelAllTask];
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    if (isShowEmail) {
        [self.em setReadWithIDs:[self selectedIDs]];
    }
    [self editFinished];

}
-(void)toDelete:(id)sender
{
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view.superview addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何邮件";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //    [alertView show];
    //    [alertView setTag:kAlertTagDeleteOne];
    //    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTagDeleteOne];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
}
-(void)editFinished;
{
    if (self.tableView.isEditing) {
        [self editAction:nil];
    }
}
-(void)editAction:(id)sender
{
    [self hideMenu];
    if (!self.tableView.isEditing && self.inArray.count==0&&self.outArray.count==0) {
        return;
    }
//    CGRect r=self.view.frame;
//    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
//    self.view.frame=r;
//    self.tableView.frame=CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height-49-30);
//    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
//        self.tableView.frame=CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height-49-64-30);
//        self.moreEditBar.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-49, 320, 49);
//    }
//    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
//    NSLog(@"self.table.frame:%@",NSStringFromCGRect(self.tableView.frame));
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    BOOL isHideTabBar=self.tableView.editing;
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
    //isHideTabBar=!isHideTabBar;
    [self.tabBarController.tabBar setHidden:isHideTabBar];
    
    //隐藏返回按钮
    if (isHideTabBar) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:nil];
//        UIBarButtonItem *editItem=[[UIBarButtonItem alloc] initWithTitleStr:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
//        [self.navigationItem setRightBarButtonItem:editItem];
        [self.navigationItem setRightBarButtonItems:self.rightItems];
    }
    if (self.moreEditBar) {
        [self.moreEditBar removeFromSuperview];
        self.moreEditBar=nil;
    }
    if (!self.moreEditBar) {
        self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.tabBarController.view.frame.size.height-56, 320, 56)];
        [self.moreEditBar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.moreEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.moreEditBar setTintColor:[UIColor blueColor]];
        }
        [self.tabBarController.view addSubview:self.moreEditBar];
        //发送 删除 提交 移动 全选
        UIButton *btn_del,*btn_markReaded,*btn_Resend;
        UIBarButtonItem *item_del,*item_flexible,*item_markReaded,*item_Resend;
        
        btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
        [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
        [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
        [btn_del addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
        
        btn_markReaded =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
//        [btn_markReaded setTitle:@"标为已读" forState:UIControlStateNormal];
        [btn_markReaded setImage:[UIImage imageNamed:@"read_nor1.png"] forState:UIControlStateNormal];
        [btn_markReaded setImage:[UIImage imageNamed:@"read_nor1.png"] forState:UIControlStateHighlighted];
        [btn_markReaded addTarget:self action:@selector(toSetRead:) forControlEvents:UIControlEventTouchUpInside];
        item_markReaded=[[UIBarButtonItem alloc] initWithCustomView:btn_markReaded];
        
        btn_Resend =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
//        [btn_Resend setTitle:@"重新发送" forState:UIControlStateNormal];
        [btn_Resend setImage:[UIImage imageNamed:@"resend_nor.png"] forState:UIControlStateNormal];
        [btn_Resend setImage:[UIImage imageNamed:@"resend_se.png"] forState:UIControlStateHighlighted];
        [btn_Resend addTarget:self action:@selector(toResend:) forControlEvents:UIControlEventTouchUpInside];
        item_Resend=[[UIBarButtonItem alloc] initWithCustomView:btn_Resend];
        
        
        item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        if (isShowEmail) {
            [self.moreEditBar setItems:@[item_flexible,item_markReaded,item_flexible,item_del,item_flexible]];
        }else
        {
            [self.moreEditBar setItems:@[item_flexible,item_del,item_flexible]];
        }
    }
    [self.moreEditBar setHidden:!isHideTabBar];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isShowEmail) {
        //收件箱
        if (self.inArray) {
            return self.inArray.count;
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            return self.outArray.count;
        }
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        
        UIImageView *unread_tag=[[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 10, 10)];
        UILabel *lab_role=[[UILabel alloc] initWithFrame:CGRectMake(30, 4, 92, 21)];
        UILabel *lab_title=[[UILabel alloc] initWithFrame:CGRectMake(30, 24, 150, 21)];
        UILabel *lab_time=[[UILabel alloc] initWithFrame:CGRectMake(206, 4, 109, 21)];
        UILabel *lab_econtent=[[UILabel alloc] initWithFrame:CGRectMake(30, 44, 270, 21)];
        UILabel *lab_fileNum=[[UILabel alloc] initWithFrame:CGRectMake(146, 4, 56, 21)];
        UIImageView *file_tag=[[UIImageView alloc] initWithFrame:CGRectMake(125, 7, 15, 15)];
        [cell.contentView addSubview:lab_role];
        [cell.contentView addSubview:lab_title];
        [cell.contentView addSubview:lab_time];
        [cell.contentView addSubview:lab_econtent];
        [cell.contentView addSubview:unread_tag];
        [cell.contentView addSubview:lab_fileNum];
        [cell.contentView addSubview:file_tag];
        
        [lab_role setFont:[UIFont boldSystemFontOfSize:16]];
        [lab_title setFont:[UIFont systemFontOfSize:14]];
        [lab_econtent setFont:[UIFont systemFontOfSize:14]];
        [lab_time setFont:[UIFont systemFontOfSize:13]];
        [lab_fileNum setFont:[UIFont systemFontOfSize:13]];
        
        [lab_econtent setTextColor:[UIColor grayColor]];
        [lab_fileNum setTextColor:[UIColor grayColor]];
        [lab_econtent setNumberOfLines:1];
        
        
        
        
        unread_tag.tag=1;
        lab_role.tag=2;
        lab_title.tag=3;
        lab_time.tag=4;
        lab_econtent.tag=5;
        lab_fileNum.tag=6;
        file_tag.tag=7;
    }
    UIImageView *unread_tag=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *lab_role=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *lab_title=(UILabel *)[cell.contentView viewWithTag:3];
    UILabel *lab_time=(UILabel *)[cell.contentView viewWithTag:4];
    UILabel *lab_econtent=(UILabel *)[cell.contentView viewWithTag:5];
    UILabel *lab_fileNum=(UILabel *)[cell.contentView viewWithTag:6];
    UIImageView *file_tag=(UIImageView *)[cell.contentView viewWithTag:7];
    NSDictionary *dic;
    NSString *econtent;
    int emailCount=0;
    NSString *sendTime;
    int readstate=-1;
    if (isShowEmail) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
            if (dic) {
                NSString *sender=(NSString *)[dic objectForKey:@"sendUserTrueName"];
                 if (![sender isKindOfClass:NSClassFromString(@"NSNull")]) {
                    lab_role.text=sender;
                }else
                {
                    lab_role.text=@"";
                }
                
            }
        }
        lab_title.text=[dic objectForKey:@"re_subject"];
        econtent=[dic objectForKey:@"re_message"];
        emailCount=[[dic objectForKey:@"re_atta_num"] intValue];
        sendTime=[dic objectForKey:@"re_sendtime"];
        readstate=[[dic objectForKey:@"re_isread"] intValue];
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
            if (dic) {
                NSString *sender=(NSString *)[dic objectForKey:@"send_receive_usernames"];
                if (![sender isKindOfClass:NSClassFromString(@"NSNull")]) {
                    lab_role.text=sender;
                }else
                {
                    lab_role.text=@"";
                }
            }
        }
        lab_title.text=[dic objectForKey:@"send_subject"];
        econtent=[dic objectForKey:@"send_message"];
        emailCount=[[dic objectForKey:@"send_atta_num"] intValue];
        sendTime=[dic objectForKey:@"send_sendtime"];
    }
    if (dic) {
//        cell.textLabel.text=[dic objectForKey:@"etitle"];
//        cell.detailTextLabel.text=[dic objectForKey:@"sendtime"];
        
        if ([lab_title.text isEqualToString:@""]) {
            lab_title.text=@"(无标题)";
        }
        if ([econtent isKindOfClass:NSClassFromString(@"NSNull")]) {
            
            lab_econtent.text=@"(无内容)";
        }else if ([econtent isEqualToString:@""])
        {
            lab_econtent.text=@"(无内容)";
        }else
        {
            lab_econtent.text=econtent;
        }
        lab_fileNum.text=[NSString stringWithFormat:@"%d个文件",emailCount];
//        lab_time.text=[dic objectForKey:@"sendtime"];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        NSDateFormatter *oldDateFormatter=[[NSDateFormatter alloc] init];
        [oldDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *oldDate=[oldDateFormatter dateFromString:sendTime];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger thisYear= [components year];
        NSDateComponents *oldComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:oldDate];
        NSInteger oldYear= [oldComponents year];
        if (oldYear<thisYear) {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        }else
        {
            [dateFormatter setDateFormat:@"MM月dd日"];
        }
        lab_time.text=[dateFormatter stringFromDate:oldDate];
        
        if (readstate==0) {
//            cell.imageView.image=[UIImage imageNamed:@"mail_unread.png"];
            unread_tag.image=[UIImage imageNamed:@"mail_unread.png"];
        }else
        {
//            cell.imageView.image=[UIImage imageNamed:@"mail_readed.png"];
            unread_tag.image=[UIImage imageNamed:@"mail_readed.png"];
        }
        file_tag.image=[UIImage imageNamed:@"hasfile.png"];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    self.selectedIndexPath=indexPath;
//    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing) {
        return;
    }
    NSDictionary *dic;
    NSString *eid;
    NSString *etype;
    NSString *title;
    if (isShowEmail) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
        }
        eid=[dic objectForKey:@"re_id"];
        NSString *re_receivetime = [dic objectForKey:@"re_receivetime"];
        if((NSNull *)re_receivetime == [NSNull null])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"个人空间已满或该主题包含的文件过期，请登录www.icoffer.cn处理。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        etype=@"0";
        title=[dic objectForKey:@"re_subject"];
        int readstate=-1;
        readstate=[[dic objectForKey:@"re_isread"] intValue];
        if (readstate==0) {
            [self performSelector:@selector(updateEmailList) withObject:nil afterDelay:1.0];
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
        }
        eid=[dic objectForKey:@"send_id"];
        etype=@"1";
        title=[dic objectForKey:@"send_subject"];
    }
    if (dic) {
        EmailDetailViewController *edvc=[[EmailDetailViewController alloc] init];
        edvc.eid=eid;
        edvc.etype=etype;
        edvc.title=@"";
        //[edvc setHidesBottomBarWhenPushed:YES];
        UINavigationController *nav=(UINavigationController *)[self.splitViewController.viewControllers lastObject];
        [nav setViewControllers:@[edvc]];
//        [self.navigationController pushViewController:edvc animated:YES];
    }
}


#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - SCBEmailManagerDelegate
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self doneLoadingTableViewData];
}
-(void)operateSucceed:(NSDictionary *)datadic
{
    [self listEmailSucceed:datadic];
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
-(void)removeEmailSucceed
{
    [self updateEmailList];
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
-(void)removeEmailFail
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
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
-(void)receiveListSucceed:(NSDictionary *)datadic
{
    [self doneLoadingTableViewData];
    self.dataDic=datadic;
    if (self.dataDic) {
        self.inArray=(NSArray *)[self.dataDic objectForKey:@"list"];
        [self.tableView reloadData];
        int notread=[[self.dataDic objectForKey:@"notread"] intValue];
        if (notread>0) {
            
            [self.customSelectButton.left_button setTitle:[NSString stringWithFormat:@"收件箱(%d)",notread] forState:UIControlStateNormal];
            if ([(MyTabBarViewController *)self.tabBarController respondsToSelector:@selector(setHasEmailTagHidden:)]) {
                [(MyTabBarViewController *)self.tabBarController setHasEmailTagHidden:NO];
            }
        }else
        {
            [self.customSelectButton.left_button setTitle:[NSString stringWithFormat:@"收件箱"] forState:UIControlStateNormal];
            if ([(MyTabBarViewController *)self.tabBarController respondsToSelector:@selector(setHasEmailTagHidden:)]) {
                [(MyTabBarViewController *)self.tabBarController setHasEmailTagHidden:YES];
            }
        }
    }
}
-(void)sendListSucceed:(NSDictionary *)datadic
{
    [self doneLoadingTableViewData];
    self.dataDic=datadic;
    if (self.dataDic) {
        self.outArray=(NSArray *)[self.dataDic objectForKey:@"list"];
        [self.tableView reloadData];
    }
}
-(void)listEmailSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
        NSMutableArray *tempInArray=[NSMutableArray array];
        NSMutableArray *tempOutArray=[NSMutableArray array];
        for (NSDictionary *dic in emails)
        {
            int etype=[[dic objectForKey:@"etype"] intValue];
            //etype	邮件类型	String，0为收件箱，1为发件箱
            if (etype ==0) {
                [tempInArray addObject:dic];
            }else if(etype==1)
            {
                [tempOutArray addObject:dic];
            }else
            {
                NSLog(@"邮件类型出错：%d",etype);
            }
        }
        self.inArray=tempInArray;
        self.outArray=tempOutArray;
        [self doneLoadingTableViewData];
        [self.tableView reloadData];

        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"EmailList"]];
        
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
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    switch ([actionSheet tag]) {
        case kActionSheetTagDeleteOne:
        {
            if (buttonIndex==0) {
                [self.em cancelAllTask];
                self.em=[[SCBEmailManager alloc] init];
                self.em.delegate=self;
                if (isShowEmail) {
                    [self.em delReceiveWithID:[self selectedIDs]];
                }else
                {
                    [self.em delSendWithID:[self selectedIDs]];
                }
            }
            [self editFinished];
            break;
        }
        case  kActionSheetTagDeletaAll:
        {
            if (buttonIndex==0) {
                NSMutableArray *ids=[NSMutableArray array];
                if (isShowEmail) {
                    for (NSDictionary *dic in self.inArray) {
                        NSString *fid=[dic objectForKey:@"re_id"];
                        [ids addObject:fid];
                    }
                }else
                {
                    for (NSDictionary *dic in self.outArray) {
                        NSString *fid=[dic objectForKey:@"send_id"];
                        [ids addObject:fid];
                    }
                }
                [self.em cancelAllTask];
                self.em=[[SCBEmailManager alloc] init];
                self.em.delegate=self;
                if (isShowEmail) {
                    [self.em delReceiveWithID:ids];
                }else
                {
//                    [self.em delSendWithID:ids];
                    [self.em delFilesSendByUserId];
                }
            }
            [self editFinished];
            break;
        }
        default:
            break;
    }
}
#pragma mark - iPad旋转方法
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
    CGRect view_rect = self.view.frame;
    view_rect.size.width = 320;
    [self.view setFrame:view_rect];
    CGRect editView_rect = self.moreEditBar.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            editView_rect.origin.y = 768-56;
        }
        else
        {
            editView_rect.origin.y = 768-56;
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            editView_rect.origin.y = 1024-56;
        }
        else
        {
            editView_rect.origin.y = 1024-56;
        }
    }
    [self.moreEditBar setFrame:editView_rect];
    
    
    CGRect self_rect = self.tableView.frame;
    self_rect.size.width = 320;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self_rect.size.height = 768-56-64-self.customSelectButton.frame.size.height;
        }
        else
        {
            self_rect.size.height = 768-56-64-self.customSelectButton.frame.size.height;
        }
    }
    else
    {
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            self_rect.size.height = 1024-56-64-self.customSelectButton.frame.size.height;
        }
        else
        {
            self_rect.size.height = 1024-56-64-self.customSelectButton.frame.size.height;
        }
    }
    [self.tableView setFrame:self_rect];
    
    CGRect notLabel_rect = self.notingLabel.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        notLabel_rect.origin.y = (768-56-64-40)/2;
    }
    else
    {
        notLabel_rect.origin.y = (1024-56-64-40)/2;
    }
    [self.notingLabel setFrame:notLabel_rect];
    
    CGRect noting_rect = self.nothingView.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        noting_rect.size.height = 768-56-64;
    }
    else
    {
        noting_rect.size.height = 1024-56-64;
    }
    [self.nothingView setFrame:noting_rect];
}
@end
