//
//  LoginViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SCBAccountManager.h"
#import "AppDelegate.h"
#import "APService.h"
#import "SCBSession.h"
#import "PConfig.h"
#import "YNFunctions.h"
#import "UserInfo.h"
#import "MySplitViewController.h"
#import "MyTabBarViewController.h"
#import "UpDownloadViewController.h"

BOOL isMustUpdate=NO;
enum{
    kAlertTypeNewVersion,
    kAlertTypeMustUpdate,
};

@interface LoginViewController ()<SCBAccountManagerDelegate>
@property(strong,nonatomic) SCBAccountManager *am;
@property(strong,nonatomic) MBProgressHUD *hud;
@property(strong,nonatomic) NSArray *priorConstraints;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userNameTextField.delegate=self;
    self.passwordTextField.delegate=self;
    [self.logoView setHidden:YES];
    [self.loginView setHidden:YES];
    // observe keyboard hide and show notifications to resize the text view appropriately
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientation];
    int W = 1024,H = 768;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect r1=self.logoView.frame;
        CGRect r2=self.loginView.frame;
        self.logoView.frame=CGRectMake((W-r2.size.width-r1.size.width)/3, (H-r1.size.height)/2, r1.size.width, r1.size.height);
        self.loginView.frame=CGRectMake((W-r2.size.width-r1.size.width)/3*2+r1.size.width, (H-r2.size.height)/2, r2.size.width, r2.size.height);
    }else
    {
        CGRect r1=self.logoView.frame;
        CGRect r2=self.loginView.frame;
        self.logoView.frame=CGRectMake((H-r1.size.width)/2, (W-r2.size.height-r1.size.height)/3, r1.size.width, r1.size.height);
        self.loginView.frame=CGRectMake((H-r2.size.width)/2, (W-r2.size.height-r1.size.height)/3*2+r1.size.height, r2.size.width, r2.size.height);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.logoView setHidden:NO];
    [self.loginView setHidden:NO];
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:0];
    [self checkUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)registAssert
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    
    BOOL rt = YES;
    NSString *loginName = self.userNameTextField.text;
    if (loginName==nil||[loginName isEqualToString:@""]) {
        self.hud.labelText=@"请输入合法的用户名";
        rt=NO;
    }
    else
    {
        NSRange rang  = [loginName rangeOfString:@"@"];
        if (rang.location==NSNotFound) {
            self.hud.labelText=@"请输入合法的用户名";
            //rt=NO;
        }
        else
        {
            NSString *password = self.passwordTextField.text;
            if ([password isEqualToString:@""]) {
                self.hud.labelText=@"密码不得为空";
                rt=NO;
            }
            else if ([password length]<6||[password length]>16) {
                self.hud.labelText=@"输入密码在6-16位";
                rt=NO;
            }
        }
    }
    [self.hud show:NO];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    return rt;
}

- (IBAction)login:(id)sender
{
    if (isMustUpdate) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"当前版本需要更新才可以使用，点确定更新"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag=kAlertTypeMustUpdate;
        [alertView show];
        return;
    }
    [self.userNameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
    if ([self registAssert]) {
        //把用户信息存储到数据库
        NSString *user_name = _userNameTextField.text;
        NSString *user_passwor = _passwordTextField.text;
        NSLog(@"user_name;%@,user_password:%@",user_name,user_passwor);
        [[SCBAccountManager sharedManager] setDelegate:self];
        [[SCBAccountManager sharedManager] UserLoginWithName:self.userNameTextField.text Password:self.passwordTextField.text];
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
        [appDelegate.window addSubview:self.hud];
        self.hud.labelText=@"正在登录...";
        self.hud.mode=MBProgressHUDModeIndeterminate;
        [self.hud show:YES];
    }
}
- (IBAction)endEdit:(id)sender
{
    [self.userNameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}
-(void)checkUpdate
{
    SCBAccountManager *am=[[SCBAccountManager alloc] init];
    am.delegate=self;
    [am checkNewVersion:BUILD_VERSION];
}
#pragma mark - SCBAccountManagerDelegate Methods
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
    //    [self doneLoadingTableViewData];
}
-(void)loginSucceed:(id)manager
{
    UserInfo *info = [[UserInfo alloc] init];
    info.user_name = _userNameTextField.text;
    NSArray *array = [info selectAllUserinfo];
    if([array count]>0)
    {
        UserInfo *lastInfo = [array lastObject];
        [YNFunctions setIsOnlyWifi:lastInfo.is_oneWiFi];
    }
    else
    {
        [YNFunctions setIsOnlyWifi:YES];
    }
    
    NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] entjpush]];
    [APService setTags:nil alias:alias];
    NSLog(@"设置别名成功：%@",alias);
    
    [[NSUserDefaults standardUserDefaults] setObject:_userNameTextField.text forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    }
    //    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"登录成功！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate finishLogin];
    
    MyTabBarViewController *tabbar = [app_delegate.splitVC.viewControllers firstObject];
    UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
    UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[UpDownloadViewController class]])
    {
        [app_delegate.uploadmanage.uploadArray removeAllObjects];
        [uploadView.upLoaded_array removeAllObjects];
        
        [app_delegate.downmange.downingArray removeAllObjects];
        [uploadView.downLoaded_array removeAllObjects];
    }
}
-(void)loginUnsucceed:(NSDictionary *)datadic
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:appDelegate.window];
    [appDelegate.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"用户名或密码错误";
    int code=[[datadic objectForKey:@"code"] intValue];
    if (code==2||code==4) {
        self.hud.labelText=@"该用户已被禁用";
    }else if (code==3)
    {
        self.hud.labelText=@"此帐号不存在";
    }
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)checkVersionSucceed:(NSDictionary *)datadic
{
    int code=-1;
    code=[[datadic objectForKey:@"code"] intValue];
    if (code==0) {
        int isupdate=-1;//是否强制更新，0不强制，1强制
        isupdate=[[datadic objectForKey:@"isupdate"] intValue];
        if ([BUILD_VERSION intValue]>=isupdate) {
            isMustUpdate=NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"有新版本，点确定更新"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag=kAlertTypeNewVersion;
            [alertView show];
        }else if([BUILD_VERSION intValue]<isupdate)
        {
            isMustUpdate=YES;
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                message:@"当前版本需要更新才可以使用，点确定更新"
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:@"确定", nil];
//            alertView.tag=kAlertTypeMustUpdate;
//            [alertView show];
            
        }
        NSLog(@"有新版本");
    }else if(code==1)
    {
        NSLog(@"失败，服务端异常");
        
    }else if(code==2)
    {
        NSLog(@"无新版本");
        //        [self.hud show:NO];
        //        if (self.hud) {
        //            [self.hud removeFromSuperview];
        //        }
        //        self.hud=nil;
        //        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        //        [self.view.superview addSubview:self.hud];
        //        [self.hud show:NO];
        //        self.hud.labelText=@"当前版本为最新版本";
        //        self.hud.mode=MBProgressHUDModeText;
        //        self.hud.margin=10.f;
        //        [self.hud show:YES];
        //        [self.hud hide:YES afterDelay:1.0f];
        
    }else
    {
        NSLog(@"失败，服务端发生未知错误");
    }
}
-(void)checkVersionFail
{
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField==self.userNameTextField) {
        //NSLog(@"UserName");
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 32;
        //        if (range.length>=32) {
        //            return NO;
        //        }
    }else if(textField==self.passwordTextField)
    {
        //NSLog(@"passwd");
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 16;
        //        if (range.length>=16) {
        //            return NO;
        //        }
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    BOOL retValue = NO;
    // see if we're on the username or password fields
    if (textField == self.userNameTextField)//当是 “帐号”输入框时
    {
        //        if ([textField.text length]  == 11)//输入的号码完整时
        //        {
        [self.passwordTextField becomeFirstResponder];// “会员密码”输入框 作为 键盘的第一 响应者，光标 进入此输入框中
        retValue = NO;
        //        }
    }
    else
    {
        //        [self.userPass resignFirstResponder];//如果 现在 是 第二个输入框，那么 键盘 隐藏
        [textField resignFirstResponder];
    }
    return retValue;
    //返回值为NO，即 忽略 按下此键；若返回为YES则 认为 用户按下了此键，并去调用TextFieldDoneEditint方法，在此方法中，你可以继续 写下 你想做的事
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
            }else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
            }
            break;
        default:
            break;
    }
    
}

#pragma mark - WillAnimateRotation
// makes "subview" match the width and height of "superview" by adding the proper auto layout constraints
//
- (NSArray *)constrainSubview1:(UIView *)subview1 subview2:(UIView *)subview2 toMatchWithSuperview:(UIView *)superview orientation:(int)orientation
{
    subview1.translatesAutoresizingMaskIntoConstraints = NO;
    subview2.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview1,subview2);
    NSString *vfl=@"V:|-100-[subview1]-100-[subview2]-100-|";
    if (orientation==0) {
        vfl=@"V:|-100-[subview1]-100-[subview2]-100-|";
    }else
    {
        vfl=@"H:|-100-[subview1]-100-[subview2]-100-|";
    }
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:vfl
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:vfl
                    options:0
                    metrics:nil
                    views:viewsDictionary]];
    [superview addConstraints:constraints];
    
    return constraints;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    int W=1024;
    int H=768;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect r1=self.logoView.frame;
        CGRect r2=self.loginView.frame;
        self.logoView.frame=CGRectMake((W-r2.size.width-r1.size.width)/3, (H-r1.size.height)/2, r1.size.width, r1.size.height);
        self.loginView.frame=CGRectMake((W-r2.size.width-r1.size.width)/3*2+r1.size.width, (H-r2.size.height)/2, r2.size.width, r2.size.height);
    }else
    {   
        CGRect r1=self.logoView.frame;
        CGRect r2=self.loginView.frame;
        self.logoView.frame=CGRectMake((H-r1.size.width)/2, (W-r2.size.height-r1.size.height)/3, r1.size.width, r1.size.height);
        self.loginView.frame=CGRectMake((H-r2.size.width)/2, (W-r2.size.height-r1.size.height)/3*2+r1.size.height, r2.size.width, r2.size.height);
    }
}
#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    [UIView beginAnimations:@"MoveUp" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect r=self.view.frame;
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight:
            r.origin.x=100;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            r.origin.x=-100;
            break;
        case UIInterfaceOrientationPortrait:
            r.origin.y=-100;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            r.origin.y=100;
            break;
        default:
            break;
    }
    [self.view setFrame:r];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:@"MoveDown" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect r=self.view.frame;
    r.origin.y=0;
    r.origin.x=0;
    [self.view setFrame:r];
    [UIView commitAnimations];
}
@end
