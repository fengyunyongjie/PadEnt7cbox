//
//  PasswordController.m
//  ndspro
//
//  Created by Yangsl on 13-10-16.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "PasswordController.h"
#import "APService.h"
#import "AppDelegate.h"
#import "YNFunctions.h"
#import "PasswordList.h"
#import "PasswordManager.h"
#import "SCBSession.h"

@interface PasswordController ()
@property (strong,nonatomic) UIBarButtonItem *backBarButtonItem;
@end

@implementation PasswordController
@synthesize table_view,lockScreen,localV;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"密码锁";
    self.table_view = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table_view.dataSource = self;
    self.table_view.delegate = self;
    [self.view addSubview:self.table_view];
    
    if (![self isOpenLock]) {
        [self showLockSetting:PasswordEditTypeStart];
    }
    
    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.backBarButtonItem=backItem;
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

-(void)showLockSetting:(PasswordEditType)editType
{
//    if(self.lockScreen)
//    {
//        [self.lockScreen removeFromParentViewController];
//        self.lockScreen = nil;
//    }
    self.lockScreen = [[InputViewController alloc] init];
    [self.lockScreen setPasswordDelegate:self];
    self.lockScreen.passwordType = editType;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.lockScreen setBgView:app.window];
    self.lockScreen.view.autoresizesSubviews = YES;
    [self presentViewController:self.lockScreen animated:NO completion:^{}];
//    if(self.localV)
//    {
//        [self.localV removeFromSuperview];
//        self.localV = nil;
//    }
//    self.localV = [[UIView alloc] initWithFrame:app.window.frame];
//    [self.localV setBackgroundColor:[UIColor blackColor]];
//    [self.localV setAlpha:0.4];
//    [app.window addSubview:self.localV];
//    [app.window addSubview:self.lockScreen.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.table_view reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"PassWordCell";
    UITableViewCell *cell = [self.table_view dequeueReusableHeaderFooterViewWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            if ([self isOpenLock]) {
                [cell.textLabel setText:@"关闭密码锁"];
            }
            else
            {
                [cell.textLabel setText:@"开启密码锁"];
            }
        }
            break;
        case 1:
        {
            [cell.textLabel setText:@"修改密码"];
            if ([self isOpenLock]) {
                [cell.textLabel setEnabled:YES];
            }
            else
            {
                [cell.textLabel setEnabled:NO];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:indexPath];
            if([cell.textLabel.text isEqualToString:@"开启密码锁"])
            {
                [self showLockSetting:PasswordEditTypeStart];
            }
            else
            {
                [self showLockSetting:PasswordEditTypeClose];
            }
        }
            break;
        case 1:
        {
            UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:indexPath];
            if(cell.textLabel.enabled)
            {
                [self showLockSetting:PasswordEditTypeUpdate];
            }
        }
            break;
        case 2:
        {
            UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"继续操作将退出当前账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"是否继续？", nil];
            [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
            break;
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
        [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passcodeTimerDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APService setTags:nil alias:nil];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate finishLogout];
    }
}

#pragma mark - ABPadLockScreen Delegate methods
- (void)unlockWasSuccessful
{
    //Perform any action needed when the unlock was successfull (usually remove the lock view and then load another view)
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)unlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber
{
    //Tells you that the user performed an unsuccessfull unlock and tells you the incorrect code and the attempt number. ABLockScreen will display an error if you have
    //set an attempt limit through the datasource method, but you may wish to make a record of the failed attempt.
    
    
}

- (void)unlockWasCancelled
{
    //This is a good place to remove the ABLockScreen
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void)attemptsExpired
{
    //If you want to perform any action when the user has failed all their attempts, do so here. ABLockPad will automatically lock them from entering in any more
    //pins.
    
}

#pragma mark - ABPadLockScreen DataSource methods
- (int)unlockPasscode
{
    //Provide the ABLockScreen with a code to verify against
    return 1234;
}

- (NSString *)padLockScreenTitleText
{
    //Provide the text for the lock screen title here
    return @"Enter passcode";
    
}

- (NSString *)padLockScreenSubtitleText
{
    //Provide the text for the lock screen subtitle here
    return @"Please enter passcode";
}

-(BOOL)hasAttemptLimit
{
    //If the lock screen only allows a limited number of attempts, return YES. Otherwise, return NO
    return YES;
}

- (int)attemptLimit
{
    //If the lock screen only allows a limited number of attempts, return the number of allowed attempts here You must return higher than 0 (Recomended more than 1).
    return 3;
}

#pragma mark PasswordDelegate -----------

-(void)deleteView
{
    [self dismissViewControllerAnimated:NO completion:^{}];
//    if(self.lockScreen)
//    {
//        [self.lockScreen.view removeFromSuperview];
//        self.lockScreen = nil;
//    }
//    if(self.localV)
//    {
//        [self.localV removeFromSuperview];
//        self.localV = nil;
//    }
}


@end
