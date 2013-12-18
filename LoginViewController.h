//
//  LoginViewController.h
//  PadEnt7cbox
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (strong,nonatomic)IBOutlet UITextField *userNameTextField;
@property (strong,nonatomic)IBOutlet UITextField *passwordTextField;
@property (strong,nonatomic)IBOutlet UIImageView *bgview;
- (IBAction)login:(id)sender;
- (IBAction)endEdit:(id)sender;
@end
