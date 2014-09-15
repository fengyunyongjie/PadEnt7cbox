//
//  AdressBookListViewController.m
//  icoffer
//
//  Created by Yangsl on 14-8-27.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "AdressBookListViewController.h"
#import "AddressBookUser.h"
#import "AddressBookDept.h"
#import "contactTableViewCell.h"
#import "AppDelegate.h"
#import "MyTabBarViewController.h"
#import "SCBSession.h"
#import "IconDownloader.h"
#import "YNFunctions.h"

#define detailVTag 9000

static float boderHeigth = 20;
static float labelHeight = 40;
static float imageHeight = 100;

@interface AdressBookListViewController ()
@property (nonatomic, retain) UIToolbar *toolbar;
@property (assign) NSInteger selectedNum;
@property (nonatomic, retain) UIButton *btn_send;
@property (nonatomic, retain) UIButton *searchBtn;
@property (nonatomic, retain) UIView *shadowView;
@end

@implementation AdressBookListViewController
@synthesize control,select_dept_id,isSendMessage,isShowRecent,searchView,searchBar,isNotFirstFloder,imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)viewDidLayoutSubviews {
    
    CGRect r=self.view.frame;
    self.view.frame=r;
    if (!isShowRecent) {
        if (isSendMessage) {
            self.table_view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.toolbar.frame=CGRectMake(0, (r.size.height-60), 320, 60);
        } else {
            self.table_view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
        }
    } else {
        if (isSendMessage) {
            self.table_view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        } else {
            self.table_view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);

        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedNum = 0;
    self.isNotFirstSearch = NO;
    //tableview
    self.table_view = [[UITableView alloc] init];
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    self.table_view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height);
    [self.table_view setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.table_view];
    //customSelectButton 屏掉最近呼出
//    CGRect customRect = CGRectMake(0, 0, 320, 40);
//    self.customSelectButton = [[CustomSelectButton alloc] initWithFrame:customRect leftText:@"最近呼出" rightText:@"通讯录" isShowLeft:isShowRecent];
//    [self.customSelectButton setDelegate:self];
//    UIColor *stbgColor=[UIColor whiteColor];
//    UIColor *stTextColor=[UIColor colorWithRed:26/255.0f green:42/255.0f blue:108/255.0f alpha:1];
//    [self.customSelectButton setBackgroundColor:stbgColor];
//    [self.customSelectButton.left_button setTitleColor:stTextColor forState:UIControlStateNormal];
//    [self.customSelectButton.right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:self.customSelectButton];
//    //左右滑动效果
//    UISwipeGestureRecognizer *recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeFrom)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [[self view] addGestureRecognizer:recognizer];
//    recognizer = nil;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeFrom)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [[self view] addGestureRecognizer:recognizer];
    //返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    //right navigationItem
    [self updateRightNavigationItems];
    
    //nothing view
    if (self.nothingView == nil) {
        
        CGRect nothingRect = CGRectMake(0, (564-(labelHeight+imageHeight+boderHeigth))/2, 320, labelHeight+imageHeight+boderHeigth);
        self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
        [self.table_view addSubview:self.nothingView];
        [self.table_view bringSubviewToFront:self.nothingView];
    }

    [self isSelectedLeft:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.notWriteUIViewController = NO;
    [super viewWillAppear:animated];
}

//查询
- (NSMutableArray *)selectAllForName:(NSString *)select_name
{
    if(isNotFirstFloder)
    {
        AddressBookUser *user = [[AddressBookUser alloc] init];
        return [user selectAddressBookUserListForString:select_name forWithDeptId:select_dept_id];
    }
    else
    {
        AddressBookUser *user = [[AddressBookUser alloc] init];
        return [user selectAddressBookUserListForString:select_name];
    }
}

//获取通讯录
- (void)updateAddressList {
    AddressBookDept *list = [[AddressBookDept alloc] init];
    list.dept_id = self.select_dept_id;
    NSMutableArray *array = [list selectAllAddressBookDeptList];
    if(isShowRecent)
    {
        return;
    }
    self.tableArray = array;
    if (self.tableArray.count<1) {
    
        CGRect r=self.view.frame;
        r.size.height=[[UIScreen mainScreen] bounds].size.height;
        CGRect nothingRect = CGRectMake(0, (564-(labelHeight+imageHeight+boderHeigth))/2, 320, labelHeight+imageHeight+boderHeigth);
        self.nothingView.frame = nothingRect;
        [self.nothingView notHiddenView];
        [self.nothingView.notingLabel setText:@"暂无通讯录，请刷新试一下"];
        [self.table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else
    {
        [self.nothingView hiddenView];
        self.table_view.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

    [self.table_view reloadData];
}

//从web获取通讯录
- (void)getWebData
{
    SCBAddressBookManager *abManager = [[SCBAddressBookManager alloc] init];
    [abManager setDelegate:self];
    [abManager requestAddressBookUser];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"数据正在加载中......";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
}

//获取最近通话记录
- (void)updateRecentList {
    AddressBookUser *list = [[AddressBookUser alloc] init];
    list.call_phone_account = [[SCBSession sharedSession] userName];
    self.recentArray = [list selectAllRecentPhoneList];
    if (self.recentArray.count<1) {
        CGRect r=self.view.frame;
        CGRect nothingRect = CGRectMake(0, (564-(labelHeight+imageHeight+boderHeigth))/2, 320, labelHeight+imageHeight+boderHeigth);
        self.nothingView.frame = nothingRect;
        [self.nothingView notHiddenView];
        [self.nothingView.notingLabel setText:@"暂无呼出记录"];
        [self.table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else
    {
        [self.nothingView hiddenView];
        self.table_view.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    [self.table_view reloadData];
}

- (void)updateRightNavigationItems {
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    if (isShowRecent) {
        UIButton*rightButton2 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,27,40)];
        [rightButton2 setImage:[UIImage imageNamed:@"address_more_top_sendAll.png"] forState:UIControlStateNormal];
        [rightButton2 addTarget:self action:@selector(sendMessageAll) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton2];
        self.navigationItem.rightBarButtonItem = rightItem2;

    } else {
        UIButton*rightButton2 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,27,40)];
        [rightButton2 setImage:[UIImage imageNamed:@"address_more_top_sendAll.png"] forState:UIControlStateNormal];
        [rightButton2 addTarget:self action:@selector(sendMessageAll) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton2];
        UIButton *rightButton1 = [[UIButton alloc]initWithFrame:CGRectMake(0,0,27,40)];
        [rightButton1 setImage:[UIImage imageNamed:@"address_more_toprefresh.png"] forState:UIControlStateNormal];
        [rightButton1 addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightButton1];
        self.navigationItem.rightBarButtonItems = @[rightItem1];
    }
}

//创建searchbar
- (void)creatSearchView {
    if (self.searchView) {
        [self.searchView removeFromSuperview];
        self.searchView = nil;
    }
    self.shadowView.hidden = YES;
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(275, 0, 40, 40)];
    [self.searchBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.searchBtn setTitleColor:[UIColor colorWithRed:54.0/255.0 green:140.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.searchBtn addTarget:self action:@selector(lookUpClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn setHidden:YES];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 5, 310, 30)];
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setTranslucent:YES];
    [self.searchBar setBarStyle:UIBarStyleDefault];
    self.searchBar.delegate = self;
    
    [[[[self.searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.background = nil;
    searchField.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    
    UIColor *lineColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];;
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchView.frame.size.width, 1)];
    line1.backgroundColor = lineColor;
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.searchView.frame.size.height-1, self.searchView.frame.size.width, 1)];
    line2.backgroundColor = lineColor;
    
    self.searchView.backgroundColor = [UIColor whiteColor];
//    [self.searchView addSubview:line1];
    [self.searchView addSubview:line2];
    [self.searchView addSubview:self.searchBar];
    [self.searchView addSubview:self.searchBtn];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect rect = CGRectMake(5, 5, 270, 30);
    [self.searchBar setFrame:rect];
    [self.searchBtn setHidden:NO];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
     NSString *text = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length == 0 || !text) {
        self.searchBar.text = nil;
        [self.searchBar resignFirstResponder];
        
        CGRect rect = CGRectMake(5, 5, 310, 30);
        [self.searchBar setFrame:rect];
        [self.searchBtn setHidden:YES];
    } else {
        [self lookUpClick:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    CGRect rect = CGRectMake(5, 5, 270, 30);
    [self.searchBar setFrame:rect];
    [self.searchBtn setHidden:NO];
    
     NSString *text = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length == 0 || !text) {
        [self.searchBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self updateAddressList];
    } else {
        [self.searchBtn setTitle:@"查询" forState:UIControlStateNormal];
    }
    
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (range.location > 19 && ![text isEqualToString:@"\n"]){ //限定只能输入20位
        return NO;
    }
    return YES;
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {

    if (self.shadowView == nil) {
        self.shadowView = [[UIView alloc] initWithFrame:self.table_view.frame];
        self.shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView.alpha = 0.3;
        UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShadowView)];
        [self.shadowView addGestureRecognizer:singleTouch];
        [self.view addSubview:self.shadowView];
    }
    self.shadowView.hidden = NO;
    return YES;
}

- (void)tapShadowView {
    NSString *text = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length ==0 || !text) {
        [self.searchBar resignFirstResponder];
        self.shadowView.hidden = YES;
        
        CGRect rect = CGRectMake(5, 5, 310, 30);
        [self.searchBar setFrame:rect];
        [self.searchBtn setHidden:YES];
        self.shadowView.hidden = YES;
    }
}


//搜索
- (void)lookUpClick:(id)sender {
    self.isNotFirstSearch = YES;
    if([self.searchBtn.titleLabel.text isEqualToString:@"取消"])
    {
        CGRect rect = CGRectMake(5, 5, 310, 30);
        [self.searchBar setFrame:rect];
        [self.searchBtn setHidden:YES];
    }
    
    self.shadowView.hidden = YES;
    [self.nothingView hiddenView];
    [self.searchBar resignFirstResponder];
    NSString *text = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length ==0 || !text) {
        self.searchBar.text = nil;
        [self updateAddressList];
        return;
    }
    else
    {
        self.tableArray = [self selectAllForName:text];
        if (self.tableArray.count < 1) {
            CGRect r=self.view.frame;
            r.size.height=[[UIScreen mainScreen] bounds].size.height;
            CGRect nothingRect = CGRectMake(0, (564-(labelHeight+imageHeight+boderHeigth))/2, 320, labelHeight+imageHeight+boderHeigth);
            self.nothingView.frame = nothingRect;
            [self.nothingView notHiddenView];
            [self.nothingView.notingLabel setText:@"暂无匹配的人员信息"];
            [self.table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }else
        {
            [self.nothingView hiddenView];
            self.table_view.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }

    }
    [self.table_view reloadData];
}


#pragma mark CustomSelectButtonDelegate

-(void)isSelectedLeft:(BOOL)bl
{
    isShowRecent = bl;
    self.title = self.navigationTitle;
    self.shadowView.hidden = YES;
    [self.nothingView hiddenView];
    self.table_view.editing = NO;
    [self hideTabbar];
    [self updateRightNavigationItems];
    self.navigationItem.leftBarButtonItem = nil;
    self.table_view.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table_view.scrollsToTop = YES;
    if (!isShowRecent) {
        if (!self.isNotFirstSearch) {
            [self updateAddressList];
            [self creatSearchView];
            [self.view addSubview:self.searchView];

        }
        isSendMessage = NO;
        self.searchView.hidden = NO;
//        [NSThread detachNewThreadSelector:@selector(updateAddressList) toTarget:self withObject:nil];
        UIColor *stTextColor=[UIColor colorWithRed:26/255.0f green:42/255.0f blue:108/255.0f alpha:1];
        [self.customSelectButton.left_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.customSelectButton.right_button setTitleColor:stTextColor forState:UIControlStateNormal];
        [self viewDidLayoutSubviews];

        
    } else {
        //[self.searchView removeFromSuperview];
        //self.searchView = nil;
        self.searchView.hidden = YES;
        [self updateRecentList];
        UIColor *stTextColor=[UIColor colorWithRed:26/255.0f green:42/255.0f blue:108/255.0f alpha:1];
        [self.customSelectButton.left_button setTitleColor:stTextColor forState:UIControlStateNormal];
        [self.customSelectButton.right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self viewDidLayoutSubviews];

    }
    [self.table_view reloadData];

}

-(void)leftSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:NO];
}

-(void)rightSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:YES];
}

#pragma mark-UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isShowRecent) {
        return self.recentArray.count;
    } else {
        return [self.tableArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isShowRecent) {
        if(indexPath.row < self.recentArray.count) {
            NSObject *obj = [self.recentArray objectAtIndex:indexPath.row];
            UITableViewCell *cell;
            static NSString *CellIdentifier = @"Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)  {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.tag = 1;
                
                UIImageView *thumbImageV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 35, 35)];
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 5, 147, 21)];
                nameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
                nameLabel.font = [UIFont systemFontOfSize:16];
                UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 24, 113, 21)];
                telLabel.textColor = [UIColor grayColor];
                telLabel.font = [UIFont systemFontOfSize:14];
                UILabel *jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(178, 24, 134, 21)];
                jobLabel.textColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
                jobLabel.textAlignment = NSTextAlignmentRight;
                jobLabel.font = [UIFont systemFontOfSize:14];
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(226, 5, 87, 21)];
                dateLabel.textColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
                dateLabel.textAlignment = NSTextAlignmentRight;
                dateLabel.font = [UIFont systemFontOfSize:12];
                
                thumbImageV.tag = 1;
                nameLabel.tag = 2;
                telLabel.tag = 3;
                jobLabel.tag = 4;
                dateLabel.tag = 5;
                
                [cell.contentView addSubview:thumbImageV];
                [cell.contentView addSubview:nameLabel];
                [cell.contentView addSubview:telLabel];
                [cell.contentView addSubview:jobLabel];
                [cell.contentView addSubview:dateLabel];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            AddressBookUser *user = (AddressBookUser *)obj;
            UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1];
            NSLog(@"user.user_picPath:%@",user.user_picPath);
            //判断图片是否存在
            NSString *fthumb_name = [NSString stringWithFormat:@"%@",user.user_picPath];
            NSString *localThumbPath=[YNFunctions getIconCachePath];
            NSString *fthumb =[YNFunctions picFileNameFromURL:fthumb_name];
            localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
            if([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil)
            {
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
                imageV.image = image;
            }
            else
            {
                imageV.image = [UIImage imageNamed:@"address_thumbnail"];
                if(![user.user_picPath isEqualToString:@"default"])
                {
                    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:fthumb_name,@"fthumb", nil];
                    [self startIconDownload:dic forIndexPath:indexPath];
                }
            }
            
            imageV.layer.masksToBounds = YES;
            imageV.layer.cornerRadius = imageV.bounds.size.width/2;
            UILabel *name = (UILabel *)[cell.contentView viewWithTag:2];
            name.text = user.user_trueName;
            UILabel *tel = (UILabel *)[cell.contentView viewWithTag:3];
            tel.text = user.user_phone;
            UILabel *job = (UILabel *)[cell.contentView viewWithTag:4];
            job.text = user.user_post;
            UILabel *date = (UILabel *)[cell.contentView viewWithTag:5];
            date.text = [NSString getAddressBookTimeFormat:user.user_createTime];
            
            return cell;
        }
    
    } else {
        if(indexPath.row < self.tableArray.count)
        {
            NSObject *obj = [self.tableArray objectAtIndex:indexPath.row];
            UITableViewCell *cell;
            if([obj isKindOfClass:[AddressBookUser class]])
            {
                static NSString *CellIdentifier = @"addCell";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)  {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.tag = 1;
                    
                    UIImageView *thumbImageV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 35, 35)];
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 5, 147, 21)];
                    nameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
                    nameLabel.font = [UIFont systemFontOfSize:16];
                    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 24, 113, 21)];
                    telLabel.textColor = [UIColor grayColor];
                    telLabel.font = [UIFont systemFontOfSize:14];
                    UILabel *jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(178, 24, 134, 21)];
                    jobLabel.textColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
                    jobLabel.textAlignment = NSTextAlignmentRight;
                    jobLabel.font = [UIFont systemFontOfSize:14];
                   
                    thumbImageV.tag = 1;
                    nameLabel.tag = 2;
                    telLabel.tag = 3;
                    jobLabel.tag = 4;
                    
                    [cell.contentView addSubview:thumbImageV];
                    [cell.contentView addSubview:nameLabel];
                    [cell.contentView addSubview:telLabel];
                    [cell.contentView addSubview:jobLabel];
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                AddressBookUser *user = (AddressBookUser *)obj;
                UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1];
                NSLog(@"user.user_picPath:%@",user.user_picPath);
                //判断图片是否存在
                NSString *fthumb_name = [NSString stringWithFormat:@"%@",user.user_picPath];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                NSString *fthumb =[YNFunctions picFileNameFromURL:fthumb_name];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil)
                {
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
                    imageV.image = image;
                }
                else
                {
                    imageV.image = [UIImage imageNamed:@"address_thumbnail"];
                    if(![user.user_picPath isEqualToString:@"default"])
                    {
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:fthumb_name,@"fthumb", nil];
                        [self startIconDownload:dic forIndexPath:indexPath];
                    }
                }
                
                imageV.layer.masksToBounds = YES;
                imageV.layer.cornerRadius = imageV.bounds.size.width/2;
                UILabel *name = (UILabel *)[cell.contentView viewWithTag:2];
                name.text = user.user_trueName;
                UILabel *tel = (UILabel *)[cell.contentView viewWithTag:3];
                tel.text = user.user_phone;
                UILabel *job = (UILabel *)[cell.contentView viewWithTag:4];
                job.text = user.user_post;
                
            }
            else if([obj isKindOfClass:[AddressBookDept class]])
            {
                static NSString *CellIdentifier = @"Cell1";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)  {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.tag = 2;
                    
                    UIImageView *thumbImageV = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 35, 35)];
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 5, 147, 21)];
                    nameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
                    nameLabel.font = [UIFont systemFontOfSize:16];
                    
                    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 24, 147, 21)];
                    numLabel.textColor = [UIColor grayColor];
                    numLabel.font = [UIFont systemFontOfSize:14];
                    
                    thumbImageV.tag = 1;
                    nameLabel.tag = 2;
                    numLabel.tag = 3;
                    
                    [cell.contentView addSubview:thumbImageV];
                    [cell.contentView addSubview:nameLabel];
                    [cell.contentView addSubview:numLabel];
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                }
                
                AddressBookDept *dept = (AddressBookDept *)obj;
                UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:1];
                imageV.image = [UIImage imageNamed:@"address_department"];
                imageV.layer.masksToBounds = YES;
                imageV.layer.cornerRadius = imageV.bounds.size.width/2;
                UILabel *name = (UILabel *)[cell.contentView viewWithTag:2];
                name.text = [NSString stringWithFormat:@"%@",dept.dept_name];
                UILabel *num = (UILabel *)[cell.contentView viewWithTag:3];
                num.text = [NSString stringWithFormat:@"%i人",dept.dept_number];
            }
            return cell;
        }

    }
    return nil;
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
    if(indexPath == nil)
    {
        ContactDetailView *detailV = (ContactDetailView *)[self.control viewWithTag:detailVTag];
        //判断图片是否存在
        NSString *fthumb_name = [NSString stringWithFormat:@"%@",detailV.bookUser.user_picPath];
        NSString *localThumbPath=[YNFunctions getIconCachePath];
        NSString *fthumb =[YNFunctions picFileNameFromURL:fthumb_name];
        localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
        if([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil)
        {
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
            detailV.thumbImageV.image = image;
        }
    }
    else
    {
        IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader != nil)
        {
            [self.table_view reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark-UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSObject *obj;
    if (self.table_view.editing) {
        if (isShowRecent) {
            obj = [self.recentArray objectAtIndex:indexPath.row];
        } else {
            obj = [self.tableArray objectAtIndex:indexPath.row];
        }
        
        if ([obj isKindOfClass:[AddressBookUser class]])
        {
            AddressBookUser *user = (AddressBookUser *)obj;
            user.checked = YES;
        }
        else
        {
            AddressBookDept *dept = (AddressBookDept *)obj;
            dept.checked = YES;
        }
        [self updateSelectNums];
        
    } else {
        if (cell.tag == 1) {
            NSObject *obj;
            if (isShowRecent) {
                obj = [self.recentArray objectAtIndex:indexPath.row];
            } else {
                obj = [self.tableArray objectAtIndex:indexPath.row];
            }
            AddressBookUser *user = (AddressBookUser *)obj;
//            [self showOpenHone:user];
        } else {
            //部门
            if(indexPath.row < self.tableArray.count)
            {
                NSObject *obj = [self.tableArray objectAtIndex:indexPath.row];
                if([obj isKindOfClass:[AddressBookDept class]])
                {
                    AdressBookListViewController *abList = [[AdressBookListViewController alloc] init];
                    AddressBookDept *list = (AddressBookDept *)obj;
                    abList.select_dept_id = list.dept_id;
                    abList.title = [NSString stringWithFormat:@"%@",list.dept_name];
                    abList.isShowRecent = NO;
                    abList.isSendMessage = NO;
                    abList.isNotFirstFloder = YES;
                    abList.navigationTitle = [NSString stringWithFormat:@"%@",list.dept_name];
                    [self.navigationController pushViewController:abList animated:YES];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.table_view.editing) {
        NSObject *obj;
        if (isShowRecent) {
            obj = [self.recentArray objectAtIndex:indexPath.row];
        } else {
            obj = [self.tableArray objectAtIndex:indexPath.row];
        }
        if ([obj isKindOfClass:[AddressBookUser class]]) {
            AddressBookUser *user = (AddressBookUser *)obj;
            user.checked = NO;
        } else {
            AddressBookDept *dept = (AddressBookDept *)obj;
            dept.checked = NO;
        }
        [self updateSelectNums];
    }
}

//refresh
- (void)refreshAction {
    [self getWebData];
}

//短信群发
- (void)sendMessageAll {
    if (isShowRecent) {
        self.title = @"最近呼出";
    }
    self.customSelectButton.hidden = YES;
    self.shadowView.hidden = YES;
    self.selectedNum = 0;
    isSendMessage = YES;
    self.searchView.hidden = YES;
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSendMessage)];
    [self.table_view setEditing:YES animated:YES];
    
    [self hideTabbar];
    if (self.toolbar) {
        [self.toolbar removeFromSuperview];
        self.toolbar=nil;
    }
    if (!self.toolbar) {
        self.toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49)];
        [self.toolbar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.view addSubview:self.toolbar];
        
        //toolbar
        UIButton *btn_cancel;
        UIBarButtonItem  *item_cancel, *item_send;
        self.btn_send =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
        [self.btn_send setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [self.btn_send setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [self.btn_send setTitle:[NSString stringWithFormat:@"发送短信(%d人)",self.selectedNum] forState:UIControlStateNormal];
        [self.btn_send addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        item_send=[[UIBarButtonItem alloc] initWithCustomView:self.btn_send];
        
        btn_cancel =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
        [btn_cancel setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [btn_cancel setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [btn_cancel setTitle:@"取 消" forState:UIControlStateNormal];
        [btn_cancel addTarget:self action:@selector(cancelSendMessage) forControlEvents:UIControlEventTouchUpInside];
        item_cancel=[[UIBarButtonItem alloc] initWithCustomView:btn_cancel];
        UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.toolbar setItems:@[fix,item_cancel,fix,item_send,fix]];
    
    }

}

- (void)updateSelectNums {
    
    self.selectedNum = 0;
    if (isShowRecent) {
        for (int i=0; i<self.recentArray.count; i++) {
            NSObject *obj = self.recentArray[i];
            if ([obj isKindOfClass:[AddressBookUser class]]) {
                AddressBookUser *user = (AddressBookUser *)obj;
                if (user.checked) {
                    self.selectedNum ++;
                }
            } else {
                AddressBookDept *dept = (AddressBookDept *)obj;
                if (dept.checked) {
                    self.selectedNum = self.selectedNum + dept.dept_number;
                }
            }
        }

    } else {
        for (int i=0; i<self.tableArray.count; i++) {
            NSObject *obj = self.tableArray[i];
            if ([obj isKindOfClass:[AddressBookUser class]]) {
                AddressBookUser *user = (AddressBookUser *)obj;
                if (user.checked) {
                    self.selectedNum ++;
                }
            } else {
                AddressBookDept *dept = (AddressBookDept *)obj;
                if (dept.checked) {
                    self.selectedNum = self.selectedNum + dept.dept_number;
                }
            }
        }

    }
    
    [self.btn_send setTitle:[NSString stringWithFormat:@"发送短信(%d人)",self.selectedNum] forState:UIControlStateNormal];
    
    if (isShowRecent) {
        if (self.table_view.indexPathsForSelectedRows.count != self.recentArray.count) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAllCell:)];
        }
    } else {
        if (self.table_view.indexPathsForSelectedRows.count != self.tableArray.count ) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAllCell:)];
        }
    }
    
}

//发送
- (void)sendMessage {
    
    if (self.selectedNum != 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定发送短信至选中项?" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            NSMutableArray *sendArray = [NSMutableArray array];
            if (isShowRecent) {
                for (int i=0; i<self.recentArray.count; i++) {
                    NSObject *obj = self.recentArray[i];
                    AddressBookUser *user = (AddressBookUser *)obj;
                    if (user.checked) {
                        [sendArray addObject:user.user_phone];
                    }
                }
            } else {
                for (int i=0; i<self.tableArray.count; i++) {
                    NSObject *obj = self.tableArray[i];
                    if ([obj isKindOfClass:[AddressBookUser class]]) {
                        AddressBookUser *user = (AddressBookUser *)obj;
                        if (user.checked) {
                            [sendArray addObject:user.user_phone];
                        }
                    } else {
                        AddressBookDept *dept = (AddressBookDept *)obj;
                        if (dept.checked) {
                            AddressBookUser *bookUser = [[AddressBookUser alloc] init];
                            bookUser.dept_id = dept.dept_id;
                            dept.userArray = [bookUser selectAddressBookUserListForDept];
                            for (int i = 0; i < dept.userArray.count; i++) {
                                AddressBookUser *user = dept.userArray[i];
                                [sendArray addObject:user.user_phone];
                            }
                        }
                    }
                }
            }
           
            
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                picker.navigationBar.tintColor = [UIColor blackColor];
                picker.recipients = [NSArray arrayWithArray:sendArray];
                [self presentViewController:picker animated:YES completion:nil];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.messageArray addObject:picker];
                app.notWriteUIViewController = YES;
            }

        }
            break;
        case 1:
            [alertView removeFromSuperview];
            break;
        default:
            break;
    }
}

#pragma mark - MFMessageComposeViewController
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	
	NSString *resultValue=@"";
	switch (result)
	{
		case MessageComposeResultCancelled:
			resultValue = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			resultValue = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			resultValue = @"Result: SMS sending failed";
			break;
		default:
			resultValue = @"Result: SMS not sent";
			break;
	}
    NSLog(@"%@",resultValue);
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if(app.messageArray.count>0)
    {
        [app.messageArray removeAllObjects];
    }
    
	[controller dismissViewControllerAnimated:YES completion:nil];
    [self cancelSendMessage];
}


//取消发送
- (void)cancelSendMessage {
    
    self.customSelectButton.hidden = NO;
    self.title = self.navigationTitle;
    isSendMessage = NO;
    if (!isShowRecent) {
        [self viewDidLayoutSubviews];
        [self creatSearchView];
        [self.view addSubview:self.searchView];
    }
    self.table_view.editing = NO;
    self.navigationItem.leftBarButtonItem = nil;
    [self updateRightNavigationItems];
    
    [self hideTabbar];
    [self.toolbar removeFromSuperview];

}


//全选
-(void)selectAllCell:(id)sender {
    
    if (isShowRecent) {
        if (self.recentArray.count > 0) {
            for (int i=0; i<self.recentArray.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                NSObject *obj = self.recentArray[i];
                if ([obj isKindOfClass:[AddressBookUser class]]) {
                    AddressBookUser *user = (AddressBookUser *)obj;
                    user.checked = YES;
                } else {
                    AddressBookDept *dept = (AddressBookDept *)obj;
                    dept.checked = YES;
                }
            }
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAllCell:)];
            [self updateSelectNums];

        }
    } else {
        if (self.tableArray.count > 0) {
            for (int i=0; i<self.tableArray.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                NSObject *obj = self.tableArray[i];
                if ([obj isKindOfClass:[AddressBookUser class]]) {
                    AddressBookUser *user = (AddressBookUser *)obj;
                    user.checked = YES;
                } else {
                    AddressBookDept *dept = (AddressBookDept *)obj;
                    dept.checked = YES;
                }
            }
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAllCell:)];
            [self updateSelectNums];

        }
    }
   
}

//取消全选
- (void)cancelAllCell:(id)sender {
    self.selectedNum = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)];
    if (isShowRecent) {
        if (self.recentArray) {
            for (int i=0; i<self.recentArray.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
                NSObject *obj = self.recentArray[i];
                if ([obj isKindOfClass:[AddressBookUser class]]) {
                    AddressBookUser *user = (AddressBookUser *)obj;
                    user.checked = NO;
                } else {
                    AddressBookDept *dept = (AddressBookDept *)obj;
                    dept.checked = NO;
                }
            }
        }

    } else {
        if (self.tableArray) {
            for (int i=0; i<self.tableArray.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
                NSObject *obj = self.tableArray[i];
                if ([obj isKindOfClass:[AddressBookUser class]]) {
                    AddressBookUser *user = (AddressBookUser *)obj;
                    user.checked = NO;
                } else {
                    AddressBookDept *dept = (AddressBookDept *)obj;
                    dept.checked = NO;
                }
            }
        }

    }
    [self updateSelectNums];

}

- (void)hideTabbar {
    BOOL isHideTabBar=self.table_view.editing;
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
        [self.toolbar removeFromSuperview];
    }
//    [appleDate.myTabBarVC setHidesTabBarWithAnimate:isHideTabBar];
    [self.tabBarController.tabBar setHidden:isHideTabBar];
}


-(void)showOpenHone:(AddressBookUser *)bookUser
{
    ContactDetailView *detailV = [ContactDetailView instanceDetailView];
    detailV.frame = CGRectMake(self.navigationController.view.frame.size.width/2-detailV.frame.size.width/2, self.navigationController.view.frame.size.height/2-detailV.frame.size.height/2, detailV.frame.size.width, detailV.frame.size.height);
    detailV.bookUser = bookUser;
    detailV.tag = detailVTag;
    detailV.delegate = self;
    detailV.nameLabel.text = bookUser.user_trueName;
    detailV.jobLabel.text = bookUser.user_post;
    detailV.telLabel.text = bookUser.user_phone;
    detailV.departmentLabel.text = bookUser.dept.dept_name;
    //判断图片是否存在
    NSString *fthumb_name = [NSString stringWithFormat:@"%@",bookUser.user_picPath];
    NSString *localThumbPath=[YNFunctions getIconCachePath];
    NSString *fthumb =[YNFunctions picFileNameFromURL:fthumb_name];
    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
    if([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil)
    {
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
        detailV.thumbImageV.image = image;
    }
    else
    {
        detailV.thumbImageV.image = [UIImage imageNamed:@"address_thumb_default.png"];
        if(![bookUser.user_picPath isEqualToString:@"default"])
        {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:fthumb_name,@"fthumb", nil];
            [self startIconDownload:dic forIndexPath:nil];
        }
    }
    
    self.control =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    UIControl *grayView=[[UIControl alloc] initWithFrame:CGRectMake(0, 64, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    [grayView setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.6]];
    [grayView addTarget:self action:@selector(hideV) forControlEvents:UIControlEventTouchUpInside];
    [self.control addSubview:grayView];
    [detailV bringSubviewToFront:self.control];
    [self.control addSubview:detailV];
    [self.tabBarController.view addSubview:self.control];
}

#pragma mark --- ContactDetailViewDelegate

- (void)joinPhone:(AddressBookUser *)bookUser
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",bookUser.user_phone]]];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    bookUser.call_phone_account = [[SCBSession sharedSession] userName];
    [tableArray addObject:bookUser];
    [bookUser insertAllRecentPhoneList:tableArray];
    [self dismissDetailView];
}

- (void)joinEmail:(AddressBookUser *)bookUser
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.navigationBar.tintColor = [UIColor blackColor];
        picker.recipients = [NSArray arrayWithObject:bookUser.user_phone];
        [self presentViewController:picker animated:YES completion:nil];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.messageArray addObject:picker];
        app.notWriteUIViewController = YES;
    }
    [self dismissDetailView];
}

- (void)dismissDetailView {
    [self hideV];
}

-(void)hideV
{
    [self.control setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark SCBAddressBookDelegate ---------

//用户信息
-(void)requestSuccessAddressBookUser:(NSDictionary *)dictionary
{
    NSArray *list=[dictionary objectForKey:@"list"];
    NSDictionary *diction = [list firstObject];
    NSMutableArray *userArray = [diction objectForKey:@"user"];
    AddressBookUser *adUser = [[AddressBookUser alloc] init];
    [adUser deleteAddressBookList];
    userArray = [adUser getUserArray:userArray];
    [adUser insertAllAddressBookUserList:userArray];
    NSMutableArray *deptArray = [diction objectForKey:@"dept"];
    AddressBookDept *dept = [[AddressBookDept alloc] init];
    deptArray = [dept getDeptArray:deptArray];
    [dept insertAllAddressBookDeptList:deptArray];
    [self isSelectedLeft:isShowRecent];
    if (self.hud) {
        [self.hud removeFromSuperview];
        self.hud=nil;
    }
}

-(void)requestFailAddressBookUser:(NSDictionary *)dictionary
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
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.searchBar.resignFirstResponder)
    {
        [self.searchBar resignFirstResponder];
        self.shadowView.hidden = YES;
    }
}

@end
