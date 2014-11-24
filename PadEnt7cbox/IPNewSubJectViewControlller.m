//
//  NewSubJectViewControlller.m
//  icoffer
//
//  Created by hudie on 14-7-7.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPNewSubJectViewControlller.h"
#import "UIBarButtonItem+Yn.h"
#import "MBProgressHUD.h"
#import "IPSubjectUserListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface IPNewSubJectViewControlller ()

@property (strong, nonatomic) UIBarButtonItem  *backBarButtonItem;
@property (strong, nonatomic) MBProgressHUD    *hud;
@property (nonatomic, retain) NSArray          *selectedIds;
@property (nonatomic, retain) UILabel          *tvPlaceholder;


@end

@implementation IPNewSubJectViewControlller
@synthesize isSending;

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

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)]];
    //导航栏右边按钮
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(publish)]];
   
    self.tvPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    self.tvPlaceholder.text = @"为您创建的共享进行简要的说明";
    self.tvPlaceholder.textColor = [UIColor colorWithRed:205.0/255.0 green:204.0/255.0 blue:208.0/255.0 alpha:1];
    self.tvPlaceholder.font = [UIFont systemFontOfSize:16];
    self.tvPlaceholder.backgroundColor = [UIColor clearColor];
    [self.infoTV addSubview:self.tvPlaceholder];
    self.infoTV.scrollEnabled = YES;

    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

//返回
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//新建主题
- (void)publish {
    if(isSending)
    {
       return;
    }
    //keyboard disappear
    [self.subjectName resignFirstResponder];
    [self.infoTV resignFirstResponder];
    
    BOOL isValid = [self checkTextisValid];
    if (isValid) {
        isSending = YES;
        IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
        sm.delegate = self;
        [sm createSubjectWithName:self.subjectName.text remark:self.infoTV.text publish:self.addMemberBtn.tag adduser:self.addContentBtn.tag members:self.selectedIds];
    }
}

//检查输入是否合法
- (BOOL)checkTextisValid {
    
    BOOL isValid = YES;
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    self.hud.mode=MBProgressHUDModeText;
    [self.view.superview addSubview:self.hud];
    
    NSString *subject = self.subjectName.text;
    NSString *memberStr = self.memberLabel.text;
    NSString *spaceStr = [subject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([subject isEqualToString:@""] || spaceStr.length == 0) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加成员
- (IBAction)addContact:(id)sender {
    
    IPSubjectUserListViewController *userView = [[IPSubjectUserListViewController alloc] init];
    userView.listViewDelegate = self;
    userView.selectedItems = [NSMutableArray arrayWithArray:self.selectedIds];
    [self.navigationController pushViewController:userView animated:YES];
}

//选择是否允许添加成员
- (IBAction)selectAddMember:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        [self.addMemberBtn setBackgroundImage:[UIImage imageNamed:@"sub_xuanzex02.png"] forState:UIControlStateNormal];
        button.tag = 1;
        
    }else {
        [self.addMemberBtn setBackgroundImage:[UIImage imageNamed:@"sub_xuanzex01.png"] forState:UIControlStateNormal];
        button.tag = 0;
    }
}

//选择是否允许添加内容
- (IBAction)selectAddContent:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        [self.addContentBtn setBackgroundImage:[UIImage imageNamed:@"sub_xuanzex02.png"] forState:UIControlStateNormal];
        button.tag = 1;
    }else {
        [self.addContentBtn setBackgroundImage:[UIImage imageNamed:@"sub_xuanzex01.png"] forState:UIControlStateNormal];
        button.tag = 0;
    }
}

//返回id
-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names
{
    if (ids.count == 0) {
        self.desPlaceHolder.hidden = NO;
    } else {
        self.desPlaceHolder.hidden = YES;
    }
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
    self.memberLabel.text = tableString;
    self.memberLabel.textColor = [UIColor colorWithRed:19.0/255 green:88.0/255.0 blue:176.0/255.0 alpha:1];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    //subject name must less than 30
    if (textField==self.subjectName) {
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 30;

    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
   
    [textField resignFirstResponder];
    return YES;
   
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //return后键盘消失
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (textView.text.length > 0) {
        self.tvPlaceholder.hidden = YES;
    } else {
        self.tvPlaceholder.hidden = NO;

    }
    //textview.text less than 60
    if (textView == self.infoTV) {
        NSMutableString *textString = [textView.text mutableCopy];
        [textString replaceCharactersInRange:range withString:text];
        return [textString length] <= 60;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.tvPlaceholder.hidden = YES;
    } else {
        self.tvPlaceholder.hidden = NO;
        
    }
    return YES;
}


#pragma mark - SCBSubjectManagerDelegate
//创建主题成功
-(void)createSubjectSuccess:(NSString *)subject_id {
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    self.hud.mode=MBProgressHUDModeText;
    [self.parentViewController.view.superview addSubview:self.hud];
    self.hud.labelText = @"新建成功";
    [self.hud show:NO];
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    isSending = FALSE;isSending = FALSE;
    //返回专题列表，返回专题名称和id
    //[self.subDelegate NewSubjectByName:self.subjectName.text subId:subject_id];
    [self dismissViewControllerAnimated:YES completion:nil];
   
}

//创建主题失败
-(void)createSubjectUnsuccess:(NSString *)error_info {
    
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
    isSending = FALSE;
}


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
    isSending = FALSE;
}

@end
