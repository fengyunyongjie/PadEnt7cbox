//
//  InputViewController.m
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-19.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "InputViewController.h"
#import "AppDelegate.h"
#import "PasswordManager.h"
#import "PasswordList.h"
#import "SCBSession.h"
#import "APService.h"

#define degreesToRadinas(x) (M_PI * (x)/180.0)
#define TextFiledColor [UIColor colorWithRed:31.0/255.0 green:58.0/255.0 blue:125.0/255.0 alpha:1.0]
#define TextViewColor [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]
@interface InputViewController ()
@property(strong,nonatomic) UIAlertView *alertView;
@end

@implementation InputViewController
@synthesize passwordType,password_view,top_view,back_button,title_label,update_button,state_label,password_textfield1,password_textfield2,password_textfield3,password_textfield4,password_error,password_button1,password_button2,password_button3,password_button4,password_button5,password_button6,password_button7,password_button8,password_button9,password_button0,password_return,botton_view,one_password,second_password,old_password,news_password,localView,password_delete,bgView,passwordDelegate,isShowBackground;

-(void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)addBackGroundImage:(UIImage *)bg
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.localView = [[UIImageView alloc] initWithFrame:app.window.frame];
    [app.window setBackgroundColor:[UIColor blackColor]];
    [self.localView setImage:bg];
    [self.localView setAlpha:0.6];
    [self.view addSubview:self.localView];
}

//将UIView转成UIImage
-(UIImage *)getImageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContextWithOptions(theView.frame.size, YES, theView.layer.contentsScale);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    
    
    NSLog(@"rect:%@",NSStringFromCGRect(self.view.frame));
    self.view.autoresizesSubviews = YES;
    self.localView = [[UIImageView alloc] init];
    if(self.isShowBackground)
    {
        [self addBackGroundImage:[UIImage imageNamed:@"startpage-.png"]];
    }
    else
    {
        [self addBackGroundImage:[self getImageFromView:bgView]];
    }
    self.one_password = @"";
    self.second_password = @"";
    
    CGRect view_rect = CGRectMake(0, 0, 320, 480);
    self.password_view = [[UIView alloc] initWithFrame:view_rect];
    
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    [self.password_view setBackgroundColor:[UIColor whiteColor]];
    CGRect top_rect = CGRectMake(0, 0, 320, 44);
	self.top_view = [[UIImageView alloc] initWithFrame:top_rect];
    self.top_view.backgroundColor = TextFiledColor;
    [self.password_view addSubview:self.top_view];
    
    CGRect back_rect = CGRectMake(5, 0, 50, 44);
    self.back_button = [[UIButton alloc] initWithFrame:back_rect];
    [self.back_button setTitle:@"返回" forState:UIControlStateNormal];
    [self.back_button.titleLabel setTextColor:[UIColor whiteColor]];
    [self.back_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.back_button addTarget:self action:@selector(back_clicked) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.back_button];
    
    CGRect title_rect = CGRectMake((320-100)/2, 0, 100, 44);
    self.title_label = [[UILabel alloc] initWithFrame:title_rect];
    [self.title_label setTextAlignment:NSTextAlignmentCenter];
    [self.title_label setText:@"设置密码"];
    [self.title_label setTextColor:[UIColor whiteColor]];
    [self.title_label setFont:[UIFont systemFontOfSize:16]];
    [self.password_view addSubview:self.title_label];
    
    CGRect update_rect = CGRectMake(320-100-5, 0, 100, 44);
    self.update_button = [[UIButton alloc] initWithFrame:update_rect];
    [self.update_button setTitle:@"忘记密码" forState:UIControlStateNormal];
    [self.update_button.titleLabel setTextColor:[UIColor whiteColor]];
    [self.update_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.update_button addTarget:self action:@selector(closePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.update_button];
    
    CGRect state_rect = CGRectMake((320-125)/2, update_rect.origin.y+update_rect.size.height+20, 125, 44);
    self.state_label = [[UILabel alloc] initWithFrame:state_rect];
    [self.state_label setTextAlignment:NSTextAlignmentCenter];
    [self.state_label setText:@"请输入密码"];
    [self.state_label setTextColor:TextFiledColor];
    [self.state_label setFont:[UIFont systemFontOfSize:14]];
    [self.password_view addSubview:self.state_label];
    
    int width = (320-80-30)/4;
    CGRect textfield1_rect = CGRectMake(40, state_rect.origin.y+state_rect.size.height+10, width, 44);
    self.password_textfield1 = [[UITextField alloc] initWithFrame:textfield1_rect];
    [self.password_textfield1 setSecureTextEntry:YES];
    [self.password_textfield1 setTextAlignment:NSTextAlignmentCenter];
    [self.password_textfield1 setBackgroundColor:TextViewColor];
    [self.password_textfield1 setEnabled:NO];
    [self.password_view addSubview:self.password_textfield1];
    
    CGRect textfield2_rect = CGRectMake(40+width+10, state_rect.origin.y+state_rect.size.height+10, width, 44);
    self.password_textfield2 = [[UITextField alloc] initWithFrame:textfield2_rect];
    [self.password_textfield2 setSecureTextEntry:YES];
    [self.password_textfield2 setTextAlignment:NSTextAlignmentCenter];
    [self.password_textfield2 setBackgroundColor:TextViewColor];
    [self.password_textfield2 setEnabled:NO];
    [self.password_view addSubview:self.password_textfield2];
    
    CGRect textfield3_rect = CGRectMake(40+(width+10)*2, state_rect.origin.y+state_rect.size.height+10, width, 44);
    self.password_textfield3 = [[UITextField alloc] initWithFrame:textfield3_rect];
    [self.password_textfield3 setSecureTextEntry:YES];
    [self.password_textfield3 setTextAlignment:NSTextAlignmentCenter];
    [self.password_textfield3 setBackgroundColor:TextViewColor];
    [self.password_textfield3 setEnabled:NO];
    [self.password_view addSubview:self.password_textfield3];
    
    CGRect textfield4_rect = CGRectMake(40+(width+10)*3, state_rect.origin.y+state_rect.size.height+10, width, 44);
    self.password_textfield4 = [[UITextField alloc] initWithFrame:textfield4_rect];
    [self.password_textfield4 setSecureTextEntry:YES];
    [self.password_textfield4 setTextAlignment:NSTextAlignmentCenter];
    [self.password_textfield4 setBackgroundColor:TextViewColor];
    [self.password_textfield4 setEnabled:NO];
    [self.password_view addSubview:self.password_textfield4];
    CGRect error_rect = CGRectMake(0, textfield4_rect.origin.y+textfield4_rect.size.height+10, 320, 44);
    self.password_error = [[UILabel alloc] initWithFrame:error_rect];
    [self.password_error setTextAlignment:NSTextAlignmentCenter];
    [self.password_error setText:@"时刻保护您的隐私安全\n(使用场景：设备丢失或者外借时)"];
    [self.password_error setFont:[UIFont systemFontOfSize:14]];
    [self.password_view addSubview:self.password_error];
    
    CGRect botton_rect = CGRectMake(0, error_rect.origin.y+error_rect.size.height+20, 320, 480-(error_rect.origin.y+error_rect.size.height+20));
    self.botton_view = [[UIImageView alloc] initWithFrame:botton_rect];
    [self.botton_view setBackgroundColor:TextViewColor];
    [self.password_view addSubview:self.botton_view];
    
    int button_width = (320-2)/3;
    int button_height = 60;
    
    CGRect button1_rect = CGRectMake(0, error_rect.origin.y+error_rect.size.height+21, button_width, button_height);
    self.password_button1 = [[PasswordButton alloc] initWithFrame:button1_rect];
    [self.password_button1 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button1 setTitle:@"1" forState:UIControlStateNormal];
    [self.password_button1 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button1 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button1];
    
    CGRect button2_rect = CGRectMake(button_width+1, error_rect.origin.y+error_rect.size.height+21, button_width, button_height);
    self.password_button2 = [[PasswordButton alloc] initWithFrame:button2_rect];
    [self.password_button2 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button2 setTitle:@"2" forState:UIControlStateNormal];
    [self.password_button2 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button2 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button2];
    
    CGRect button3_rect = CGRectMake(button_width*2+2, error_rect.origin.y+error_rect.size.height+21, button_width, button_height);
    self.password_button3 = [[PasswordButton alloc] initWithFrame:button3_rect];
    [self.password_button3 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button3 setTitle:@"3" forState:UIControlStateNormal];
    [self.password_button3 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button3 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button3];
    
    CGRect button4_rect = CGRectMake(0, button3_rect.origin.y+button3_rect.size.height+1, button_width, button_height);
    self.password_button4 = [[PasswordButton alloc] initWithFrame:button4_rect];
    [self.password_button4 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button4 setTitle:@"4" forState:UIControlStateNormal];
    [self.password_button4 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button4 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button4];
    
    CGRect button5_rect = CGRectMake(button_width+1, button3_rect.origin.y+button3_rect.size.height+1, button_width, button_height);
    self.password_button5 = [[PasswordButton alloc] initWithFrame:button5_rect];
    [self.password_button5 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button5 setTitle:@"5" forState:UIControlStateNormal];
    [self.password_button5 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button5 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button5];
    
    CGRect button6_rect = CGRectMake(button_width*2+2, button3_rect.origin.y+button3_rect.size.height+1, button_width, button_height);
    self.password_button6 = [[PasswordButton alloc] initWithFrame:button6_rect];
    [self.password_button6 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button6 setTitle:@"6" forState:UIControlStateNormal];
    [self.password_button6 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button6 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button6];
    
    CGRect button7_rect = CGRectMake(0, button6_rect.origin.y+button6_rect.size.height+1, button_width, button_height);
    self.password_button7 = [[PasswordButton alloc] initWithFrame:button7_rect];
    [self.password_button7 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button7 setTitle:@"7" forState:UIControlStateNormal];
    [self.password_button7 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button7 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button7];
    
    CGRect button8_rect = CGRectMake(button_width+1, button6_rect.origin.y+button6_rect.size.height+1, button_width, button_height);
    self.password_button8 = [[PasswordButton alloc] initWithFrame:button8_rect];
    [self.password_button8 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button8 setTitle:@"8" forState:UIControlStateNormal];
    [self.password_button8 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button8 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button8];
    
    CGRect button9_rect = CGRectMake(button_width*2+2, button6_rect.origin.y+button6_rect.size.height+1, button_width, button_height);
    self.password_button9 = [[PasswordButton alloc] initWithFrame:button9_rect];
    [self.password_button9 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button9 setTitle:@"9" forState:UIControlStateNormal];
    [self.password_button9 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button9 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button9];
    
    CGRect button0_rect = CGRectMake(button_width+1, button9_rect.origin.y+button9_rect.size.height+1, button_width, button_height);
    self.password_button0 = [[PasswordButton alloc] initWithFrame:button0_rect];
    [self.password_button0 setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_button0 setTitle:@"0" forState:UIControlStateNormal];
    [self.password_button0 addTarget:self action:@selector(clickedTouch:) forControlEvents:UIControlEventTouchDown];
    [self.password_button0 addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_button0];
    
    CGRect delete_rect = CGRectMake(button_width*2+2, button9_rect.origin.y+button9_rect.size.height+1, button_width, button_height);
    self.password_delete = [[PasswordButton alloc] initWithFrame:delete_rect];
    [self.password_delete setTitleColor:TextFiledColor forState:UIControlStateNormal];
    [self.password_delete setTitle:@"删除" forState:UIControlStateNormal];
    [self.password_delete addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.password_view addSubview:self.password_delete];
    
    self.password_view.layer.masksToBounds = YES;
    self.password_view.layer.cornerRadius = 8;
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.password_view];
    
    
//    PasswordEditTypeDefault, //默认是PasswordEditTypeStart
//    PasswordEditTypeStart, //要求输入两次密码，第二次输入的时候判断是否和第一次相同，如果不相同，提示再尝试一次第二次输入，如果还是错误，重置密码输入（从头开始再来）
//    PasswordEditTypeUpdate, //要求输入旧密码，有五次机会，到第四次的时候提醒用户，如果五次都输入错误，直接注销用户；旧密码输入正确，输入新密码的原理啊和上面一致
    if(passwordType == PasswordEditTypeDefault)
    {
        [self.back_button setHidden:YES];
        [self showTypeDefault];
    }
    else if(passwordType == PasswordEditTypeStart)
    {
        [self showTypeStartFirst];
    }
    else if(passwordType == PasswordEditTypeUpdate)
    {
        [self showTypeUpdateStartFirst];
    }
    else if(passwordType == PasswordEditTypeClose)
    {
        [self showTypeClose];
    }
    
    [self.password_view bringSubviewToFront:self.view];
    [self.localView sendSubviewToBack:self.view];
}

/*
 
 PasswordEditTypeStart, //要求输入两次密码，第二次输入的时候判断是否和第一次相同，如果不相同，提示再尝试一次第二次输入，如果还是错误，重置密码输入（从头开始再来）
 PasswordEditTypeUpdate, //要求输入旧密码，有五次机会，到第四次的时候提醒用户，如果五次都输入错误，直接注销用户；旧密码输入正确，输入新密码的原理啊和上面一致
 PasswordEditTypeClose //要求输入你的密码，有五次机会，到第四次的时候提醒用户，如果五次都输入错误，直接注销用户
 
 */

#pragma mark 修改提示信息 PasswordEditTypeStart --------------------

//第一次开启
-(void)showTypeStartFirst
{
    [self.update_button setHidden:YES];
    [self.state_label setText:@"请输入密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@"时刻保护您的隐私安全\n(使用场景：设备丢失或者外借时)"];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
    [self.title_label setText:@"设置密码"];
}

//第二次输入
-(void)showTypeStartSecond
{
    [self.state_label setText:@"请再次输入密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@""];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//第二次输入密码错误
-(void)showTypeStartSecondError
{
    [self.state_label setText:@"请输入密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@"密码不匹配，请再尝试一次"];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

#pragma mark 修改提示信息 PasswordEditTypeUpdate --------------------

//请输入旧密码
-(void)showTypeUpdateStartFirst
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请输入原密码"];
    
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
    [self.title_label setText:@"修改密码"];
}

-(PasswordList *)selectList
{
    PasswordManager *manager = [[PasswordManager alloc] init];
    PasswordList *list = [[PasswordList alloc] init];
    list.is_open = YES;
    list.p_ure_id = [[SCBSession sharedSession] userId];
    NSArray *array = [manager selectPasswordListIsHave:list];
    if([array count]>0)
    {
        return [array lastObject];
    }
    return nil;
}

//输入错误提示
-(void)showTypeUpdateFirstError
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请输入原密码"];
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//请输入新密码
-(void)showTypeUpdateNewPassword
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请输入新密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@""];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//请再次输入新密码
-(void)showTypeUpdateSecondNewPassword
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请再次输入新密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@""];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//新密码输入错误
-(void)showTypeUpdateFirstNewPasswordError
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请输入新密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@"密码不匹配，请再尝试一次"];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//请再次输入新密码
-(void)showTypeUpdateSecondNewPasswordError
{
    [self.update_button setHidden:NO];
    [self.state_label setText:@"请再次输入新密码"];
    [self.password_error setTextColor:[UIColor grayColor]];
    [self.password_error setText:@""];
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

//提示还有最后一次
-(void)showEnd
{
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你还可以尝试最后一次解锁，若依然错误，将会退回登录界面" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    self.alertView=alert;
}

#pragma mark 修改提示信息 PasswordEditTypeClose --------------------
//默认情况
-(void)showTypeClose
{
    [self.state_label setText:@"请输入你的密码"];
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
    [self.title_label setText:@"关闭密码"];
}

//输入错误提示
-(void)showTypeCloseError
{
    [self.state_label setText:@"请输入你的密码"];
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}


#pragma mark 默认提示信息 PasswordEditTypeDefault --------------------

-(void)showTypeDefault
{
    [self.state_label setText:@"请输入你的密码"];
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
    [self.title_label setText:@"输入密码"];
}

-(void)showTypeDefaultError
{
    [self.state_label setText:@"请输入你的密码"];
    PasswordList *list = [self selectList];
    if(list.p_fail_count == 5)
    {
        [self.password_error setTextColor:[UIColor grayColor]];
        [self.password_error setText:@""];
    }
    else
    {
        [self.password_error setTextColor:[UIColor redColor]];
        [self.password_error setText:[NSString stringWithFormat:@"还可以尝试%i次",list.p_fail_count]];
    }
    self.password_textfield1.text = @"";
    self.password_textfield2.text = @"";
    self.password_textfield3.text = @"";
    self.password_textfield4.text = @"";
}

-(void)back_clicked
{
    [passwordDelegate deleteView];
}

-(void)clickedTouch:(id)sender
{
    if([self.password_textfield4.text length] > 0)
    {
        return;
    }
    
    PasswordButton *button = sender;
    if([self.password_textfield1.text length] == 0)
    {
        [self.password_textfield1 setText:button.titleLabel.text];
    }
    else if([self.password_textfield2.text length] == 0)
    {
        [self.password_textfield2 setText:button.titleLabel.text];
    }
    else if([self.password_textfield3.text length] == 0)
    {
        [self.password_textfield3 setText:button.titleLabel.text];
    }
    else if([self.password_textfield4.text length] == 0)
    {
        [self.password_textfield4 setText:button.titleLabel.text];
    }
}

-(void)clicked:(id)sender
{
    if([self.password_textfield4.text length] > 0)
    {
        //开始验证
        if(passwordType == PasswordEditTypeDefault)
        {
            if([one_password length] == 0)
            {
                one_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                
                PasswordList *list = [self selectList];
                
                PasswordManager *manager = [[PasswordManager alloc] init];
                if(list)
                {
                    if([list.p_text isEqualToString:one_password])
                    {
                        list.p_fail_count = 5;
                        list.is_open = YES;
                        [manager updatePasswordList:list];
                        [self back_clicked];
                        return;
                    }
                }
                one_password = @"";
                
                list.p_fail_count--;
                [manager updatePasswordList:list];
                if(list.p_fail_count == 0)
                {
                    list.p_fail_count = 5;
                    list.is_open = NO;
                    [manager updatePasswordList:list];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"switch_upload"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [APService setTags:nil alias:nil];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate finishLogout];
                }
                else if(list.p_fail_count == 1)
                {
                    [self showEnd];
                    [self showTypeDefaultError];
                }
                else
                {
                    [self showTypeDefaultError];
                }
            }
        }
        else if(passwordType == PasswordEditTypeStart)
        {
            if([one_password length] == 0) //第一次
            {
                one_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                [self showTypeStartSecond];
            }
            else if([second_password length] == 0) //第二次
            {
                second_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                if(![one_password isEqualToString:second_password])
                {
                    one_password = @"";
                    second_password = @"";
                    [self showTypeStartSecondError];
                }
                else
                {
                    PasswordManager *passwordManager = [[PasswordManager alloc] init];
                    PasswordList *list = [[PasswordList alloc] init];
                    list.p_text = second_password;
                    list.p_fail_count = 5;
                    list.p_ure_id = [[SCBSession sharedSession] userId];
                    list.is_open = 1;
                    NSArray *array = [passwordManager selectPasswordListIsHave:list];
                    if([array count] == 0)
                    {
                        [passwordManager insertPasswordList:list];
                    }
                    else
                    {
                        [passwordManager updatePasswordList:list];
                    }
                    [self back_clicked];
                }
            }
        }
        else if (passwordType == PasswordEditTypeUpdate)
        {
            if([old_password length] == 0)
            {
                old_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                PasswordList *list = [self selectList];
                if(list)
                {
                    if([list.p_text isEqualToString:old_password])
                    {
                        [self showTypeUpdateNewPassword];
                        return;
                    }
                }
                old_password = @"";
                
                
                PasswordManager *manager = [[PasswordManager alloc] init];
                list.p_fail_count--;
                [manager updatePasswordList:list];
                if(list.p_fail_count == 0)
                {
                    list.p_fail_count = 5;
                    list.is_open = NO;
                    [manager updatePasswordList:list];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"switch_upload"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [APService setTags:nil alias:nil];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate finishLogout];
                }
                else if(list.p_fail_count == 1)
                {
                    [self showEnd];
                    [self showTypeUpdateFirstError];
                }
                else
                {
                    [self showTypeUpdateFirstError];
                }
                
            }
            else if([one_password length] == 0)
            {
                one_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                [self showTypeUpdateSecondNewPassword];
            }
            else if([second_password length] == 0)
            {
                second_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                if(![one_password isEqualToString:second_password])
                {
                    one_password = @"";
                    second_password = @"";
                    [self showTypeStartSecondError];
                }
                else
                {
                    PasswordManager *passwordManager = [[PasswordManager alloc] init];
                    PasswordList *list = [[PasswordList alloc] init];
                    list.p_text = second_password;
                    list.p_fail_count = 5;
                    list.p_ure_id = [[SCBSession sharedSession] userId];
                    list.is_open = 1;
                    NSArray *array = [passwordManager selectPasswordListIsHave:list];
                    if([array count] == 0)
                    {
                        [passwordManager insertPasswordList:list];
                    }
                    else
                    {
                        [passwordManager updatePasswordList:list];
                    }
                    [self back_clicked];
                }
            }
        }
        else if(passwordType == PasswordEditTypeClose)
        {
            if([one_password length] == 0)
            {
                one_password = [NSString stringWithFormat:@"%@%@%@%@",self.password_textfield1.text,self.password_textfield2.text,self.password_textfield3.text,self.password_textfield4.text];
                
                PasswordList *list = [self selectList];
                
                PasswordManager *manager = [[PasswordManager alloc] init];
                if(list)
                {
                    if([list.p_text isEqualToString:one_password])
                    {
                        list.p_fail_count = 5;
                        list.is_open = NO;
                        [manager updatePasswordList:list];
                        [self back_clicked];
                        return;
                    }
                }
                one_password = @"";
                
                list.p_fail_count--;
                [manager updatePasswordList:list];
                if(list.p_fail_count == 0)
                {
                    list.p_fail_count = 5;
                    list.is_open = NO;
                    [manager updatePasswordList:list];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"switch_upload"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [APService setTags:nil alias:nil];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate finishLogout];
                }
                else if(list.p_fail_count == 1)
                {
                    [self showEnd];
                    [self showTypeCloseError];
                }
                else
                {
                    [self showTypeCloseError];
                }
            }
        }
    }
}

-(void)closePassword
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"继续操作将退出当前账号，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    [alert show];
    self.alertView=alert;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        PasswordList *list = [[PasswordList alloc] init];
        list.p_ure_id = [[SCBSession sharedSession] userId];
        PasswordManager *manager = [[PasswordManager alloc] init];
        [manager deletePasswordList:list];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
        [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"switch_upload"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [APService setTags:nil alias:nil];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate finishLogout];
    }
    self.alertView=nil;
}

-(void)deleteClicked
{
    if([self.password_textfield4.text length] > 0)
    {
        self.password_textfield4.text = @"";
    }
    else if([self.password_textfield3.text length] > 0)
    {
        self.password_textfield3.text = @"";
    }
    else if([self.password_textfield2.text length] > 0)
    {
        self.password_textfield2.text = @"";
    }
    else if([self.password_textfield1.text length] > 0)
    {
        self.password_textfield1.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return NO;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
}

-(void)updateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect password_rect = self.password_view.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        password_rect.origin.x = self.view.frame.size.height/2-320/2;
        password_rect.origin.y = self.view.frame.size.width/2-480/2;
    }
    else
    {
        password_rect.origin.x = self.view.frame.size.width/2-320/2;
        password_rect.origin.y = self.view.frame.size.height/2-480/2;
    }
    [self.password_view setFrame:password_rect];
    
    CGRect localRect = self.localView.frame;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        if(isShowBackground)
        {
            [self.localView setImage:[UIImage imageNamed:@"startpage.png"]];
        }
        else
        {
            self.localView.transform =  CGAffineTransformMakeRotation(degreesToRadinas(90));
        }
        
        localRect.origin.x = 0;
        localRect.origin.y = 0;
        localRect.size.width = self.view.frame.size.height;
        localRect.size.height = self.view.frame.size.width;
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if(isShowBackground)
        {
            [self.localView setImage:[UIImage imageNamed:@"startpage.png"]];
        }
        else
        {
            self.localView.transform =  CGAffineTransformMakeRotation(degreesToRadinas(-90));
        }
        localRect.origin.x = 0;
        localRect.origin.y = 0;
        localRect.size.width = self.view.frame.size.height;
        localRect.size.height = self.view.frame.size.width;
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if(isShowBackground)
        {
            [self.localView setImage:[UIImage imageNamed:@"startpage-.png"]];
        }
        else
        {
            self.localView.transform =  CGAffineTransformMakeRotation(degreesToRadinas(180));
        }
        localRect.origin.x = 0;
        localRect.origin.y = 0;
        localRect.size.width = self.view.frame.size.width;
        localRect.size.height = self.view.frame.size.height;
    }
    else
    {
        if(isShowBackground)
        {
            [self.localView setImage:[UIImage imageNamed:@"startpage-.png"]];
        }
        else
        {
            self.localView.transform =  CGAffineTransformMakeRotation(degreesToRadinas(0));
        }
        localRect.origin.x = 0;
        localRect.origin.y = 0;
        localRect.size.width = self.view.frame.size.width;
        localRect.size.height = self.view.frame.size.height;
    }
    [self.localView setFrame:localRect];
}

-(void)controllerClose
{
    PasswordList *list = [self selectList];
    PasswordManager *manager = [[PasswordManager alloc] init];
    list.p_fail_count = 5;
    list.is_open = NO;
    [manager updatePasswordList:list];
}

@end
