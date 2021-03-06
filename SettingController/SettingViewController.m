//
//  SettingViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "APService.h"
#import "SCBAccountManager.h"
#import "YNFunctions.h"
#import "PConfig.h"
#import "MBProgressHUD.h"
#import "LTHPasscodeViewController.h"
#import "PasswordController.h"
#import "SCBSession.h"
#import "DBSqlite3.h"
#import "MyTabBarViewController.h"
#import "UserInfo.h"
#import "UpDownloadViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "QLBrowserViewController.h"
#import "PasswordManager.h"
#import "PasswordList.h"
#import "MySplitViewController.h"
#import "DetailViewController.h"
#import "SCBFileManager.h"
#import "NSString+Format.h"

typedef enum{
    kAlertTypeNewVersion,
    kAlertTypeNoNewVersion,
    kAlertTypeHideFeature,
    kAlertTypeMustUpdate,
    kAlertTypeClear,
}kAlertType;
typedef enum{
    kActionSheetTypeExit,
    kActionSheetTypeClear,
    kActionSheetTypeWiFi,
    kActionSheetTypeAuto,
    kActionSheetTypeHideFeature,
    kActionSheetTypeInContent,
}kActionSheetType;
@interface SettingViewController ()<SCBAccountManagerDelegate>
{
    BOOL isHideTabBar;
    float oldTabBarHeight;
}
@property (strong,nonatomic) NSString *nickname;
@property (strong,nonatomic) NSString *space_total;
@property (strong,nonatomic) NSString *space_used;
@property (strong,nonatomic) SCBAccountManager *am;
@property (strong,nonatomic) NSDictionary *datadic;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (strong,nonatomic) NSString *entname;

@end

@implementation SettingViewController

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.space_used=@"";
    self.space_total=@"";
    
    UIButton *exitButton=[UIButton buttonWithType:UIButtonTypeCustom];

    [exitButton setTitle:@"退出当前帐号" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitButton setBackgroundColor:[UIColor clearColor]];
//    [exitButton setImage:[UIImage imageNamed:@"set_quit_nor.png"] forState:UIControlStateNormal];
//    [exitButton setImage:[UIImage imageNamed:@"set_quit_se.png"] forState:UIControlStateHighlighted];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"set_quit_nor.png"] forState:UIControlStateNormal];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"set_quit_se.png"] forState:UIControlStateHighlighted];
    int y=self.tableView.frame.size.height-30;
    y=638;
    [exitButton setFrame:CGRectMake(12.5f, y, 295,50)];
    [exitButton addTarget:self action:@selector(exitAccount:) forControlEvents:UIControlEventTouchUpInside];
    [exitButton setTag:10000];
    [self.tableView addSubview:exitButton];
    [self.tableView bringSubviewToFront:exitButton];
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(posterDidCode10Notification:) name:PosterCode10Notification object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self updateData];
    [self calcCacheSize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateData
{
    self.am=[[SCBAccountManager alloc] init];
    [self.am setDelegate:self];
    [self.am getUserInfo];
}
-(void)calcCacheSize
{
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *cachePath=[paths objectAtIndex:0];
    
    double cacheSize = 0.0f;// [Function getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getFMCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getIconCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getKeepCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getTempCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    cachePath = [YNFunctions getProviewCachePath];
    cacheSize += [YNFunctions getDirectorySizeForPath:cachePath];
    locationCacheSize=cacheSize;
    [self.tableView reloadData];
}
- (IBAction)hideTabBar:(id)sender
{
    isHideTabBar=!isHideTabBar;
    
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
- (void)switchChange:(id)sender
{
    int tag=[(UISwitch*)sender tag];
    switch (tag) {
        case 0:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            NSString *onStr = [NSString stringWithFormat:@"%d",theSwith.isOn];
            if ([YNFunctions isOnlyWifi] && !theSwith.isOn) {
                //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                //                                                                    message:@"这可能会产生流量费用，您是否要继续？"
                //                                                                   delegate:self
                //                                                          cancelButtonTitle:@"取消"
                //                                                          otherButtonTitles:@"继续", nil];
                //                alertView.tag=kAlertTypeWiFi;
                //                [alertView show];
                //                [alertView release];
                UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"这可能会产生流量费用，您是否要继续？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续" otherButtonTitles: nil];
                [actionSheet setTag:kActionSheetTypeWiFi];
                [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
                if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
                    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                }else
                {
                    if (self.splitViewController) {
                        [actionSheet showInView:self.splitViewController.view];
                    }else
                    {
                        [actionSheet showInView:self.view];
                    }
                }
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.action_array addObject:actionSheet];
            }else if(![YNFunctions isOnlyWifi] && theSwith.isOn)
            {
                [YNFunctions setIsOnlyWifi:YES];
                //                if(![self isConnection])
                //                {
                //                    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //                    [appleDate.autoUpload setIsStopCurrUpload:YES];
                //                }
                //
                //                if ([YNFunctions networkStatus]==ReachableViaWWAN) {
                //                    [[FavoritesData sharedFavoritesData] stopDownloading];
                //                }
            }
            NSLog(@"打开或关闭仅Wifi:: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"]);
        }
            break;
        case 2:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            if (theSwith.on) {
                //开启消息提醒
                NSLog(@"开启消息提醒");
            }else
            {
                NSLog(@"关闭消息提醒");
            }
            [YNFunctions setIsMessageAlert:theSwith.on];
            if ([YNFunctions isMessageAlert]) {
                // Required
                [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                               UIRemoteNotificationTypeSound |
                                                               UIRemoteNotificationTypeAlert)];
                
                NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] entjpush]];
                [APService setTags:nil alias:alias];
                NSLog(@"设置别名成功：%@",alias);
            }else
            {
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
        }
            break;
        case 4:
        {
            UISwitch *theSwith = (UISwitch *)sender;
            if (theSwith.on) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"switch_upload"];
            }else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"switch_upload"];
            }
        }
            break;
        default:
            break;
    }
}
- (void)clearCache
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存，释放本机空间"
                                                        message:@"下载或查看过的文件需要重新下载"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.alertViewArray addObject:alertView];
    [alertView show];
    [alertView setTag:kAlertTypeClear];
//    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"清除缓存后下载或查看过的文件需要重新下载" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"确认清除",@"取消", nil];
//    [actionSheet setTag:kActionSheetTypeClear];
//    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (IBAction)exitAccount:(id)sender
{
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
    //                                                        message:@"确定要退出登录"
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                              otherButtonTitles:@"退出", nil];
    //    [alertView show];
    //    [alertView setTag:kAlertTypeExit];
    //    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否注销" delegate:self cancelButtonTitle:@"否" destructiveButtonTitle:@"是" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTypeExit];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }else
    {
        if (self.splitViewController) {
            [actionSheet showInView:self.splitViewController.view];
        }else
        {
            [actionSheet showInView:self.view];
        }
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array addObject:actionSheet];
}
-(void)checkUpdate
{
    SCBAccountManager *am=[[SCBAccountManager alloc] init];
    am.delegate=self;
    [am checkNewVersion:BUILD_VERSION];
}
-(void)inContent
{
    self.am=nil;
    self.am=[[SCBAccountManager alloc] init];
    [self.am setDelegate:self];
    [self.am getVcard];
    
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在导入……";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
    //[self.hud hide:YES afterDelay:1.0f];
}
-(void)importContent
{
    ABAddressBookRef addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
    [self checkAddressBookAccess];
    
}

// This method is called when the user has granted access to their address book data.
-(void)accessGrantedForAddressBook
{
    // Enable the Add button
    //self.addButton.enabled = YES;
    // Add the Edit button
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Fetch all groups available in address book
    //self.sourcesAndGroups = [self fetchGroupsInAddressBook:self.addressBook];
    //[self.tableView reloadData];
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    SettingViewController * __weak weakSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf accessGrantedForAddressBook];
                                                         
                                                     });
                                                 }
                                             });
}

// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                            message:@"Permission was not granted for Contacts."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}
-(int)import:(CFDataRef)vCardData addressBook:(ABAddressBookRef)addressBook
{
    NSString *path=[YNFunctions getTempCachePath];
    path=[path stringByAppendingPathComponent:@"Vcard.vcf"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *jsonParsingError=nil;
        NSString *vcard=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&jsonParsingError];
        CFDataRef vTheCardData=(__bridge CFDataRef)[vcard dataUsingEncoding:NSUTF8StringEncoding];
        vCardData=vTheCardData;
    }
    if (!vCardData) {
        return -1;
    }
    BOOL isHasGroup=NO;
    ABRecordRef thegoup=NULL;
    CFArrayRef array=ABAddressBookCopyArrayOfAllGroups(addressBook);
    for (id group in (NSArray *)CFBridgingRelease(array)) {
        NSString *name=CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(group),kABGroupNameProperty));
        if ([self.entname isEqualToString:name]) {
            isHasGroup=YES;
            thegoup=CFBridgingRetain(group);
            break;
        }
    }
    if (isHasGroup&&thegoup) {
    }else
    {
        thegoup=ABGroupCreate();
        ABRecordSetValue(thegoup, kABGroupNameProperty, CFBridgingRetain(self.entname), nil);
        ABAddressBookAddRecord(addressBook, thegoup, nil);
    }
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
    for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
        ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
        BOOL isSucced=NO;
        //isSucced=ABRecordSetValue(person,kABGroupNameProperty, CFBridgingRetain(self.entname), nil);
        ABAddressBookAddRecord(addressBook, person, NULL);
        isSucced=NO;
        isSucced=ABGroupAddMember(thegoup, person, nil);
        NSLog(@"成功%d",isSucced);
        ABAddressBookSave(addressBook, nil);
    }
    if(ABAddressBookSave(addressBook, NULL))
    {
        return CFArrayGetCount(vCardPeople);
    }else
    {
        return -1;
    }
    return 0;
}
-(int)import:(CFDataRef)vCardData
{
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            return [self import:vCardData addressBook:addressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
        {
            SettingViewController * __weak weakSelf = self;
            __block int i=0;
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
                if (granted)
                {
                    NSLog(@"granted");
                    i=[weakSelf import:vCardData addressBook:addressBook];
                }
                else
                {
                    NSLog(@"%@", error);
                    i=-1;
                }
            });
            return i;
        }
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有打开通讯录权限"
                                                            message:@"因iOS系统限制，需要读取联系人信息才能导入通讯录\n 步骤：设置-隐私-通讯录-icoffer"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    return -1;
}
-(void)showMessage:(NSString *)message
{
    [self.hud show:NO];
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
    [self.hud hide:YES afterDelay:1];
}
#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
//    switch (section) {
//        case 0:
//            return @"账号信息";
//            break;
//        case 1:
//            return @"设置";
//            break;
//        case 2:
//            return @"关于";
//            break;
//        default:
//            break;
//    }
	return nil;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *bgView=[[UIImageView alloc] initWithFrame:cell.frame];
//        bgView.tag=3;
//        [cell.contentView addSubview:bgView];
        
        UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 260, 20)];
        itemTitleLabel.tag = 1;
        itemTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [cell.contentView addSubview:itemTitleLabel];
        itemTitleLabel.backgroundColor= [UIColor clearColor];
        
        UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 260, 20)];
        descTitleLabel.textAlignment = UITextAlignmentRight;
        descTitleLabel.tag = 2;
        descTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [cell.contentView addSubview:descTitleLabel];
        descTitleLabel.backgroundColor= [UIColor clearColor];
        
        CGRect label_rect = CGRectMake(240, 12, 40, 20);
        UILabel *label = [[UILabel alloc] initWithFrame:label_rect];
//        label.font = cell.textLabel.font;
//        label.textColor = cell.textLabel.textColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.tag=231;
        [cell.contentView addSubview:label];
    }
    //[cell setBackgroundColor:[UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UILabel *titleLabel = (UILabel *)[cell.contentView  viewWithTag:1];
    UILabel *descLabel  = (UILabel *)[cell.contentView  viewWithTag:2];
    //UIImageView *bgView=(UIImageView *)[cell.contentView viewWithTag:3];
    UILabel *ocLabel=(UILabel *)[cell.contentView viewWithTag:231];
    ocLabel.hidden=YES;
    descLabel.hidden = NO;
    for(UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    //bgView.image=[UIImage imageNamed:@"set_bk_2.png"];
    switch (section) {
        case 0:
        {
            titleLabel.textAlignment = NSTextAlignmentLeft;
            switch (row) {
                case 0:
                {
                    titleLabel.text = @"帐号";
                    descLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
                    descLabel.textColor = [UIColor grayColor];
                }
                    break;
                case 1:
                {
                    titleLabel.text = @"昵称";
                    //                    NSString *spaceInfo;
                    //                    if ([self.space_total isEqualToString:@""]) {
                    //                        spaceInfo=@"获取中...";
                    //                    }else
                    //                    {
                    //                        spaceInfo=[NSString stringWithFormat:@"%@/%@",self.space_used,self.space_total];
                    //                    }
                    //                    descLabel.text=spaceInfo;
                    //
                    descLabel.text=self.nickname;
                    descLabel.textColor = [UIColor grayColor];
                }
                    break;
                case 2:
                {
                    titleLabel.text = @"网盘用量";
                    NSString *spaceInfo;
                    if ([self.space_total isEqualToString:@""]) {
                        spaceInfo=@"获取中...";
                    }else
                    {
                        spaceInfo=[NSString stringWithFormat:@"%@/%@",self.space_used,self.space_total];
                    }
                    descLabel.text=spaceInfo;
                    descLabel.textColor = [UIColor grayColor];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            UISwitch *m_switch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 40, 29)];
//            [m_switch setOnTintColor:[UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]];
            if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
                m_switch.frame=CGRectMake(250, 10, 40, 29);
            }
            [m_switch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            m_switch.on = YES;
            switchTag = row;
            m_switch.tag = row;
            [cell.contentView addSubview:m_switch];
            
            
            descLabel.hidden = YES;
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 2:
                {
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    titleLabel.text =@"密码锁";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    if ([self isOpenLock]) {
                        ocLabel.text = @"开启";
                    }
                    else
                    {
                        ocLabel.text = @"关闭";
                    }
                    ocLabel.textColor = [UIColor grayColor];
                    m_switch.hidden = YES;
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoUpload"];
                    if (switchFlag==nil) {
                        m_switch.on = NO;
                    }
                    else{
                        m_switch.on = [switchFlag boolValue];
                    }
                    ocLabel.hidden=NO;
                    ocLabel.textColor = [UIColor grayColor];
                }
                    break;
                case 0:
                {
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    titleLabel.text = @"仅在Wi-Fi下上传/下载";
                    NSString *switchFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
                    automicOff_button.hidden = NO;
                    if (switchFlag==nil) {
                    }
                    else{
                        m_switch.on = [switchFlag boolValue];
                    }
                    
                }
                    break;
                case 1:
                {
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    titleLabel.text = @"清除缓存";
                    descLabel.hidden = NO;
                    NSString *sizeStr = [NSString stringWithFormat:@"%f",locationCacheSize];
                    descLabel.text = [YNFunctions convertSize:sizeStr];
                    descLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    m_switch.hidden = YES;
                }
                    
                    break;
                case 3:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"导入企业通讯录到本机";
                    m_switch.hidden = YES;
                    break;
                case 4:
                {
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    titleLabel.text = @"使用后台上传/下载";
                    BOOL switchFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"switch_upload"] boolValue];
                    automicOff_button.hidden = NO;
                    m_switch.on = switchFlag;
                }
            }
        }
            break;
            /*        case 2:
             {
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             cell.selectionStyle = UITableViewCellSelectionStyleBlue;
             descLabel.hidden = YES;
             titleLabel.textAlignment = UITextAlignmentLeft;
             titleLabel.text = @"传输管理";
             }
             break;
             */
        case 2:
        {
            
            titleLabel.textAlignment = UITextAlignmentLeft;
            switch (row) {
                case 0:
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    descLabel.hidden = NO;
                    titleLabel.text = @"版本";
                    descLabel.text = VERSION;
                    descLabel.textColor = [UIColor grayColor];
                    break;
                case 1:
                    //bgView.image=[UIImage imageNamed:@"set_bk_3.png"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"评分";
                    break;
                case 2:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    descLabel.hidden = YES;
                    titleLabel.text = @"检查更新";
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 3:
        {
            cell.hidden = YES;
            //重设退出安钮位置
            UIButton *exitButton=(UIButton *)[self.tableView viewWithTag:10000];
            CGRect r=exitButton.frame;
            r.origin.y=self.tableView.contentSize.height-80;
            exitButton.frame=r;
        }
            break;
        default:
            break;
    }
    
    
    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
        //bgView.image=nil;
    }
    cell.backgroundColor=[UIColor whiteColor];
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
            
        case 0:     //账号信息
        {
            switch (row) {
                case 0:
                {
                    //当前用户
                }
                    break;
                case 1:
                {
                    //网盘用量
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:     //设置
        {
            switch (row) {
                case 0:
                {
                    
                }
                    break;
                case 2:
                {
                    //
                    PasswordController *password = [[PasswordController alloc] init];
                    [self.navigationController pushViewController:password animated:YES];
                }
                    
                    break;
                case 1:
                    //清除缓存
                    [self clearCache];
                    break;
                case 3:
                    //导入企业通讯录到本机
                {
                    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"导入企业通讯录到本机" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",nil];
                    [actionSheet setTag:kActionSheetTypeInContent];
                    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
                    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
                        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                    }else
                    {
                        if (self.splitViewController) {
                            [actionSheet showInView:self.splitViewController.view];
                        }else
                        {
                            [actionSheet showInView:self.view];
                        }
                    }
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app.action_array addObject:actionSheet];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 2:     //关于
        {
            
            switch (row) {
                case 0:
                    //版本
                    //                    self.tempCount++;
                    //                    if (self.tempCount>=6) {
                    //                        self.tempCount=0;
                    //                        if ([YNFunctions isOpenHideFeature]) {
                    //                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                    //                                                                                message:@"是否关闭隐藏功能？"
                    //                                                                               delegate:self
                    //                                                                      cancelButtonTitle:@"取消"
                    //                                                                      otherButtonTitles:@"确定", nil];
                    //                            alertView.tag=kAlertTypeHideFeature;
                    //                            [alertView show];
                    //                            [alertView release];
                    //                        }else
                    //                        {
                    //                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                    //                                                                                message:@"是否打开隐藏功能？"
                    //                                                                               delegate:self
                    //                                                                      cancelButtonTitle:@"取消"
                    //                                                                      otherButtonTitles:@"确定", nil];
                    //                            alertView.tag=kAlertTypeHideFeature;
                    //                            [alertView show];
                    //                            [alertView release];
                    //                        }
                    //
                    //                    }
                    break;
                case 1:
                    //评分
                    if ([YNFunctions systemIsLaterThanString:@"7.0"])
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
                    }
                    else
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL6]];
                    }
                    break;
                case 2:
                    //检查更新
                    [self checkUpdate];
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 3:
            break;
        default:
            break;
    }
}
- (void)posterDidCode10Notification:(NSNotification *)note
{
    [self sureExit];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"无访问权限"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
    [alertView show];

}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTypeNewVersion:
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
            }
            break;
        case kAlertTypeMustUpdate:
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
                [self sureExit];
            }else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
                [self sureExit];
            }
            break;
        case kAlertTypeClear:
            if (buttonIndex==1) {
                [self sureClear];
            }
            break;
        default:
            break;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.alertViewArray removeObject:alertView];
}
-(void)sureClear
{
    [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getFMCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getIconCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getKeepCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getTempCachePath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[YNFunctions getProviewCachePath] error:nil];
    [self calcCacheSize];
//    DownList *down = [[DownList alloc] init];
//    [down updateAllClip];
    [self.tableView reloadData];
}
-(void)sureExit
{
//    DBSqlite3 *sql = [[DBSqlite3 alloc] init];
//    [sql cleanSql];
    UserInfo *info = [[UserInfo alloc] init];
    info.user_name = [NSString formatNSStringForOjbect:[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"]];
    info.is_oneWiFi = [YNFunctions isOnlyWifi];
    [info insertUserinfo];
    
    InputViewController *inputView = [[InputViewController alloc] init];
    [inputView controllerClose];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [APService setTags:nil alias:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.uploadmanage stopAllUpload];
    [appDelegate.downmange stopAllDown];
    appDelegate.uploadmanage.isJoin = NO;
    appDelegate.downmange.isStart = NO;
    
    [[LTHPasscodeViewController sharedUser] hiddenPassword];
    [appDelegate finishLogout];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        DetailViewController *viewCon = [[DetailViewController alloc] init];
        viewCon.isFileManager = YES;
        [viewCon removeAllView];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:viewCon];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        NSArray * viewControllers=self.splitViewController.viewControllers;
        self.splitViewController.viewControllers=@[viewControllers.firstObject,nav];
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.action_array removeAllObjects];
    
    switch ([actionSheet tag]) {
        case kActionSheetTypeExit:
            if (buttonIndex == 0) {
                //scBox.UserLogout(callBackLogoutFunc,self);
//                [self sureClear];
                [self sureExit];
            }
            break;
        case kActionSheetTypeClear:
            if (buttonIndex==0) {
                [self sureClear];
            }
            break;
        case kActionSheetTypeWiFi:
            if (buttonIndex==0) {
                [YNFunctions setIsOnlyWifi:NO];
            }
            else
            {
                [YNFunctions setIsOnlyWifi:YES];
            }
            
//            if([self isConnection] && [YNFunctions isAutoUpload])
//            {
//                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                [appleDate.autoUpload start];
//            }
            [self.tableView reloadData];
            break;
        case kActionSheetTypeAuto:
            break;
        case kActionSheetTypeHideFeature:
            break;
        case kActionSheetTypeInContent:
            if (buttonIndex==0) {
                [self inContent];
            }
            break;
        default:
            break;
    }
    
}
#pragma mark - SCBAccountManagerDelegate
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)getUserInfoSucceed:(NSDictionary *)datadic
{
    if (!datadic) {
        return;
    }
    self.nickname=[datadic objectForKey:@"usrturename"];
    self.space_total=[NSString stringWithFormat:@"%d",[[datadic objectForKey:@"usrtotalsize"] intValue]];
    self.space_total=[YNFunctions convertSize:self.space_total];
    self.space_used=[NSString stringWithFormat:@"%d",[[datadic objectForKey:@"usrusedsize"] intValue]];
    self.space_used=[YNFunctions convertSize:self.space_used];
    [self.tableView reloadData];
//    self.dataDic=datadic;
//    if (self.dataDic) {
//        self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
//        if (self.listArray) {
//            NSMutableArray *a=[NSMutableArray array];
//            for (int i=0; i<self.listArray.count; i++) {
//                FileItem *fileItem=[[FileItem alloc]init];
//                [a addObject:fileItem];
//                [fileItem setChecked:NO];
//            }
//            self.userItems=a;
//            [self.tableView reloadData];
//        }
//        NSString *dataFilePath=[YNFunctions getDataCachePath];
//        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
//        NSError *jsonParsingError=nil;
//        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
//        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
//        if (isWrite) {
//            NSLog(@"写入文件成功：%@",dataFilePath);
//        }else
//        {
//            NSLog(@"写入文件失败：%@",dataFilePath);
//        }
//    }else
//    {
//        [self updateList];
//    }
}
-(void)getUserInfoFail
{
    
}
-(void)checkVersionSucceed:(NSDictionary *)datadic
{
    int code=-1;
    code=[[datadic objectForKey:@"code"] intValue];
    if (code==0) {
        int isupdate=-1;//是否强制更新，0不强制，1强制   10月31日，修改为： 强制更新的版本号
        isupdate=[[datadic objectForKey:@"isupdate"] intValue];
        if ([BUILD_VERSION intValue]>=isupdate) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"有新版本，点确定更新"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.alertViewArray addObject:alertView];
            alertView.tag=kAlertTypeNewVersion;
            [alertView show];
        }else if([BUILD_VERSION intValue]<isupdate)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"当前版本需要更新才可以使用，点确定更新"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.alertViewArray addObject:alertView];
            alertView.tag=kAlertTypeMustUpdate;
            [alertView show];

        }
        NSLog(@"有新版本");
    }else if(code==1)
    {
        NSLog(@"失败，服务端异常");
        
    }else if(code==2)
    {
        NSLog(@"无新版本");
        [self showMessage:@"当前是最新版本"];
    }else
    {
        NSLog(@"失败，服务端发生未知错误");
    }
}
-(void)checkVersionFail
{
    [self showMessage:@"检测更新失败"];
}
-(void)getVcardSucceed:(NSDictionary *)datadic
{
//    [self.hud show:NO];
//    if (self.hud) {
//        [self.hud removeFromSuperview];
//    }
//    self.hud=nil;
//    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//    [self.view.superview addSubview:self.hud];
//    [self.hud show:NO];
//    self.hud.labelText=@"正在导入……";
//    self.hud.mode=MBProgressHUDModeIndeterminate;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:5];
    NSString *entname=[datadic objectForKey:@"entname"];
    if (!entname) {
        entname=@"宙合网络科技公司";
    }
    self.entname=entname;
    NSString *vcard=[datadic objectForKey:@"vcard"];
    [self performSelectorInBackground:@selector(importStrVcard:) withObject:vcard];
//    if (vcard) {
//        NSString *path=[YNFunctions getTempCachePath];
//        path=[path stringByAppendingPathComponent:@"Vcard.vcf"];
//        NSError *jsonParsingError=nil;
//        BOOL isWrite=[vcard writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&jsonParsingError];
//        if (isWrite) {
//            NSLog(@"写入文件成功");
//        }else
//        {
//            NSLog(@"写入文件失败");
//        }
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
////            QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
////            browser.dataSource=browser;
////            browser.delegate=browser;
////            browser.currentPreviewItemIndex=0;
////            browser.title=@"通讯录";
////            browser.filePath=path;
////            browser.fileName=@"Vcard.vcf";
////            [self presentViewController:browser animated:YES completion:nil];
//            CFDataRef vCardData=(__bridge CFDataRef)[vcard dataUsingEncoding:NSUTF8StringEncoding];
//            if (vCardData) {
////                __block ;
////                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
////                    
////                });
//                int i=[self import:vCardData];
//                NSString *alertStr=@"";
//                if (i==-1) {
//                    alertStr=@"导入失败";
//                }else
//                {
//                    alertStr=[NSString stringWithFormat:@"成功导入%d个联系人",i];
//                }
//                
//                [self.hud show:NO];
//                if (self.hud) {
//                    [self.hud removeFromSuperview];
//                }
//                self.hud=nil;
//                self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//                [self.view.superview addSubview:self.hud];
//                [self.hud show:NO];
//                self.hud.labelText=alertStr;
//                self.hud.mode=MBProgressHUDModeText;
//                self.hud.margin=10.f;
//                [self.hud show:YES];
//                [self.hud hide:YES afterDelay:2];
//
//            }
//        }
//    }
}
-(void)importSuccess:(NSString *)message
{
    [self.hud show:NO];
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
    [self.hud hide:YES afterDelay:1];
}
-(void)importStrVcard:(NSString *)vcard
{
    if (vcard) {
        NSString *path=[YNFunctions getTempCachePath];
        path=[path stringByAppendingPathComponent:@"Vcard.vcf"];
        NSError *jsonParsingError=nil;
        BOOL isWrite=[vcard writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&jsonParsingError];
        if (isWrite) {
            NSLog(@"写入文件成功");
        }else
        {
            NSLog(@"写入文件失败");
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //            QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
            //            browser.dataSource=browser;
            //            browser.delegate=browser;
            //            browser.currentPreviewItemIndex=0;
            //            browser.title=@"通讯录";
            //            browser.filePath=path;
            //            browser.fileName=@"Vcard.vcf";
            //            [self presentViewController:browser animated:YES completion:nil];
            CFDataRef vCardData=(__bridge CFDataRef)[vcard dataUsingEncoding:NSUTF8StringEncoding];
            if (vCardData) {
                //                __block ;
                //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                //
                //                });
                int i=[self import:vCardData];
                NSString *alertStr=@"";
                if (i==-1) {
                    alertStr=@"导入失败";
                }else
                {
                    alertStr=[NSString stringWithFormat:@"成功导入%d个联系人",i];
                }
                [self performSelectorOnMainThread:@selector(importSuccess:) withObject:alertStr waitUntilDone:NO];
            }
        }
    }else
    {
        [self performSelectorOnMainThread:@selector(importSuccess:) withObject:@"导入失败" waitUntilDone:NO];
    }
}
-(void)getVcardFail
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"导入失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1];
}
-(void)getUserListSucceed:(NSDictionary *)datadic
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在导入……";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:5];
//    self.dataDic=datadic;
//    if (self.dataDic) {
//        self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
//        if (self.listArray) {
//            NSMutableArray *a=[NSMutableArray array];
//            for (int i=0; i<self.listArray.count; i++) {
//                FileItem *fileItem=[[FileItem alloc]init];
//                [a addObject:fileItem];
//                [fileItem setChecked:NO];
//            }
//            self.userItems=a;
//            [self.tableView reloadData];
//        }
//        NSString *dataFilePath=[YNFunctions getDataCachePath];
//        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
//        NSError *jsonParsingError=nil;
//        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
//        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
//        if (isWrite) {
//            NSLog(@"写入文件成功：%@",dataFilePath);
//        }else
//        {
//            NSLog(@"写入文件失败：%@",dataFilePath);
//        }
//    }else
//    {
//        [self updateList];
//    }
}
-(void)getUserListFail
{
}
#pragma mark -
#pragma mark Manage Address Book contacts

// Create and add a new group to the address book database
-(void)addGroup:(NSString *)name fromAddressBook:(ABAddressBookRef)myAddressBook
{
//    BOOL sourceFound = NO;
//    if ([name length] != 0)
//    {
//        ABRecordRef newGroup = ABGroupCreate();
//        CFStringRef newName = CFBridgingRetain(name);
//        ABRecordSetValue(newGroup,kABGroupNameProperty,newName,NULL);
//        
//        // Add the new group
//		ABAddressBookAddRecord(myAddressBook,newGroup, NULL);
//		ABAddressBookSave(myAddressBook, NULL);
//        CFRelease(newName);
//        
//        // Get the ABSource object that contains this new group
//		ABRecordRef groupSource = ABGroupCopySource(newGroup);
//		// Fetch the source name
//		NSString *sourceName = [self nameForSource:groupSource];
//        CFRelease(groupSource);
//        
//        // Look for the above source among the sources in sourcesAndGroups
//        for (MySource *source in self.sourcesAndGroups)
//        {
//            if ([source.name isEqualToString:sourceName])
//            {
//                // Associate the new group with the found source
//                [source.groups addObject:CFBridgingRelease(newGroup)];
//                // Set sourceFound to YES if sourcesAndGroups already contains this source
//                sourceFound = YES;
//            }
//        }
//        // Add this source to sourcesAndGroups
//		if (!sourceFound)
//		{
//			NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:CFBridgingRelease(newGroup), nil];
//			MySource *newSource = [[MySource alloc] initWithAllGroups:mutableArray name:sourceName];
//		    [self.sourcesAndGroups addObject:newSource];
//		}
//    }
}


// Remove a group from the given address book
- (void)deleteGroup:(ABRecordRef)group fromAddressBook:(ABAddressBookRef)myAddressBook
{
	ABAddressBookRemoveRecord(myAddressBook, group, NULL);
	ABAddressBookSave(myAddressBook, NULL);
}


// Return a list of groups organized by sources
- (NSMutableArray *)fetchGroupsInAddressBook:(ABAddressBookRef)myAddressBook
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    // Get all the sources from the address book
	NSArray *allSources = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllSources(myAddressBook));
    if ([allSources count] >0)
    {
        for (id aSource in allSources)
        {
            ABRecordRef source = (ABRecordRef)CFBridgingRetain(aSource);
            // Fetch all groups included in the current source
            CFArrayRef result = ABAddressBookCopyArrayOfAllGroupsInSource (myAddressBook, source);
            // The app displays a source if and only if it contains groups
            if ((result) && (CFArrayGetCount(result) > 0))
            {
                NSMutableArray *groups = [(__bridge NSArray *)result mutableCopy];
                // Fetch the source name
//                NSString *sourceName = [self nameForSource:source];
//                //Create a MySource object that contains the source name and all its groups
//                MySource *source = [[MySource alloc] initWithAllGroups:groups name:sourceName];
                
                // Save the source object into the array
//                [list addObject:source];
            }
            if (result)
            {
                CFRelease(result);
            }
            CFRelease(source);
        }
    }
    
    return list;
}

-(BOOL)isOpenLock
{
    PasswordManager *manager = [[PasswordManager alloc] init];
    PasswordList *list = [[PasswordList alloc] init];
    list.is_open = YES;
    list.p_ure_id = [[SCBSession sharedSession] userId];
    NSArray *array = [manager selectPasswordListIsHave:list];
    if([array count]>0)
    {
        return YES;
    }
    return NO;
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
    CGRect self_rect = self.tableView.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        self_rect.size.height = 768;
    }
    else
    {
        self_rect.size.height = 1024;
    }
    [self.tableView setFrame:self_rect];
}

@end
