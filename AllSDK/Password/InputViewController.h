//
//  InputViewController.h
//  PadEnt7cbox
//  密码锁变更页面
//  Created by Yangsl on 13-12-19.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordButton.h"

typedef enum {
    PasswordEditTypeDefault, //默认是PasswordEditTypeStart
    PasswordEditTypeStart, //要求输入两次密码，第二次输入的时候判断是否和第一次相同，如果不相同，提示再尝试一次第二次输入，如果还是错误，重置密码输入（从头开始再来）
    PasswordEditTypeUpdate, //要求输入旧密码，有五次机会，到第四次的时候提醒用户，如果五次都输入错误，直接注销用户；旧密码输入正确，输入新密码的原理啊和上面一致
    PasswordEditTypeClose //要求输入你的密码，有五次机会，到第四次的时候提醒用户，如果五次都输入错误，直接注销用户
} PasswordEditType;


@interface InputViewController : UIViewController<UIAlertViewDelegate>

@property(nonatomic,assign) PasswordEditType passwordType;
@property(nonatomic,strong) UIView *password_view;
@property(nonatomic,strong) UIImageView *top_view;
@property(nonatomic,strong) UIButton *back_button;
@property(nonatomic,strong) UILabel *title_label;
@property(nonatomic,strong) UIButton *update_button;
@property(nonatomic,strong) UILabel *state_label;
@property(nonatomic,strong) UITextField *password_textfield1;
@property(nonatomic,strong) UITextField *password_textfield2;
@property(nonatomic,strong) UITextField *password_textfield3;
@property(nonatomic,strong) UITextField *password_textfield4;
@property(nonatomic,strong) UILabel *password_error;
@property(nonatomic,strong) PasswordButton *password_button1;
@property(nonatomic,strong) PasswordButton *password_button2;
@property(nonatomic,strong) PasswordButton *password_button3;
@property(nonatomic,strong) PasswordButton *password_button4;
@property(nonatomic,strong) PasswordButton *password_button5;
@property(nonatomic,strong) PasswordButton *password_button6;
@property(nonatomic,strong) PasswordButton *password_button7;
@property(nonatomic,strong) PasswordButton *password_button8;
@property(nonatomic,strong) PasswordButton *password_button9;
@property(nonatomic,strong) PasswordButton *password_button0;
@property(nonatomic,strong) PasswordButton *password_delete;
@property(nonatomic,strong) UIButton *password_return;
@property(nonatomic,strong) UIImageView *botton_view;

@property(nonatomic,strong) NSString *one_password;
@property(nonatomic,strong) NSString *second_password;
@property(nonatomic,strong) NSString *old_password;
@property(nonatomic,strong) NSString *news_password;
@property(nonatomic,strong) UIView *localView;

@end
