//
//  CreateSubjectViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-18.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "CreateSubjectViewController.h"
#import "SubUserListViewController.h"
#import "SCBSubjectManager.h"
#import "MBProgressHUD.h"

@interface CreateSubjectViewController ()<SubUserListDelegate,SCBSubjectManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *subjectNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *numbersTextField;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@property (weak, nonatomic) IBOutlet UIButton *isAddUserButton;
@property (weak, nonatomic) IBOutlet UIButton *isShareButton;
@property (strong,nonatomic) UIPopoverController *usersPopoverController;
@property (strong,nonatomic) NSArray *selectedIds;
@property (strong,nonatomic) MBProgressHUD *hud;
@end

@implementation CreateSubjectViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 操作方法
-(IBAction)cancel:(id)sender
{
//    [self.view setHidden:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)publish:(id)sender
{
    [self.subjectNameTextField resignFirstResponder];
    [self.contentTextField resignFirstResponder];
    BOOL isValid = [self checkTextisValid];
    if (isValid) {
        SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
        sm.delegate = self;
        [sm createSubjectWithName:self.subjectNameTextField.text info:self.contentTextField.text isPublish:self.isShareButton.isSelected isAddUser:self.isAddUserButton.isSelected members:self.selectedIds];
    }
}
//检查输入是否合法
- (BOOL)checkTextisValid {
    
    BOOL isValid = YES;
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view.window];
    self.hud.mode=MBProgressHUDModeText;
    [self.view.window addSubview:self.hud];
    
    NSString *subject = self.subjectNameTextField.text;
    NSString *memberStr = self.numbersTextField.text;
    if ([subject isEqualToString:@""]) {
        self.hud.labelText = @"请输入专题名称";
        isValid = NO;
        [self.hud show:NO];
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    } else if ([memberStr isEqualToString:@""]) {
        self.hud.labelText = @"请选择成员";
        isValid = NO;
        [self.hud show:NO];
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
    return isValid;
}
- (IBAction)isAddUser:(UIButton *)sender {
    [sender setSelected: !sender.isSelected];
}

- (IBAction)isShare:(UIButton *)sender {
    [sender setSelected: !sender.isSelected];
}

- (IBAction)openMembers:(UIButton *)sender {
    
    SubUserListViewController *userView = [[SubUserListViewController alloc] init];
    userView.listViewDelegate=self;
    userView.selectedItems=[NSMutableArray arrayWithArray:self.selectedIds];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:userView];
    self.usersPopoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
    [self.usersPopoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
-(void)showMessage:(NSString *)message
{
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=message;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1];
}
#pragma mark - SubUserListDelegate
//返回id
-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names
{
    self.selectedIds = [NSArray arrayWithArray:ids];
    NSMutableString *tableString = [[NSMutableString alloc] init];
    for(int i=0;i<names.count;i++)
    {
        [tableString appendString:[names objectAtIndex:i]];
        if(i+1 < names.count)
        {
            [tableString appendString:@","];
        }
    }
    self.numbersTextField.text = tableString;
    [self.usersPopoverController dismissPopoverAnimated:YES];
}
#pragma mark - SCBSubjectManagerDelegate
//创建主题成功
-(void)didCreateSubject:(NSDictionary *)datadic
{
    if ([[datadic objectForKey:@"code"] intValue]==0) {
        [self showMessage:@"创建成功"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self showMessage:@"创建失败"];
    }
    
    
}
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    //subject name must less than 30
    if (textField==self.subjectNameTextField) {
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 30;
        
    }else if(textField==self.contentTextField)
    {
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 60;
    }
    return YES;
}
@end
