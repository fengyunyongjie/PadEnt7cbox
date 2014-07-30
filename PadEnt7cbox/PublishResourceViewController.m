//
//  PublishResourceViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-18.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "PublishResourceViewController.h"
#import "PublishResourceCell.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "FileListViewController.h"
#import "SCBSession.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"


@interface PublishResourceViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) MBProgressHUD *hud;

@end

@implementation PublishResourceViewController

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
    self.listArray=[NSMutableArray array];
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
    
}

- (IBAction)openMenu:(id)sender {
    self.menuView.hidden=NO;
}

- (IBAction)openCameraView:(id)sender {
    self.menuView.hidden=YES;
    //拍照上传
    NSLog(@"拍照上传");
    //判断是否可以打开相机，模拟器此功能无法使用
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        //无权限
        NSString *titleString = @"因iOS系统限制，开启相机服务才能拍照，传输过程严格加密，不会作其他用途。\n\n\t步骤：设置>隐私>相机>icoffer";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:titleString delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        
        //imagePicker.mediaTypes=[NSArray arrayWithObject:@"public.photo"];
        imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        
        imagePicker.allowsEditing=NO;
        imagePicker.showsCameraControls=YES;
        imagePicker.cameraViewTransform=CGAffineTransformIdentity;
        
        // not all devices have two cameras or a flash so just check here
        if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] ) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            if ( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront] ) {
            }
        } else {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        if ( [UIImagePickerController isFlashAvailableForCameraDevice:imagePicker.cameraDevice] ) {
            imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }
        imagePicker.delegate = self;
        imagePicker.wantsFullScreenLayout = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)openFileView:(id)sender {
    self.menuView.hidden=YES;
    
//    //选择 icoffer的我的文件目录
//    NSLog(@"选择 icoffer的我的文件目录");
//    FileListViewController *flvc=[[FileListViewController alloc] init];
//    flvc.spid=[[SCBSession sharedSession] spaceID];
//    flvc.f_id=@"0";
//    flvc.title=@"我的文件";
//    flvc.roletype=@"2";
//    flvc.flType=kMyndsTypeChangeFileOrFolder;
//    flvc.fileOrFolderDelegate=self;
//    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
//    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
//    [nav.navigationBar setTintColor:[UIColor whiteColor]];
//    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)openLinkView:(id)sender {
    self.menuView.hidden=YES;
    //创建超链接
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建链接" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"请输入网址"];
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [alert show];
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
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self.listArray count];
            break;
    }
    return 0;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        static NSString *cellIdentifier = @"Cell";
        PublishResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"PublishResourceCell"  owner:self options:nil] firstObject];
            cell.backgroundColor=[UIColor clearColor];
        }
        return cell;
    }else
    {
        static NSString *cellIdentifier = @"Cell";
        PublishResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"PublishResourceCell"  owner:self options:nil] lastObject];
            cell.backgroundColor=[UIColor clearColor];
            NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
//            cell.personLabel.text=[dic objectForKey:@"usr_turename"];
//            if ([[dic objectForKey:@"isMaster"] intValue]==0) {
//                cell.headLabel.text=@"成员：";
//                cell.personLabel.textColor=[UIColor lightGrayColor];
//            }
            NSString *type=[dic objectForKey:@"type"];
            if ([type isEqualToString:@"url"]) {
                cell.iconImageView.image=[UIImage imageNamed:@"sub_link.png"];
                cell.resourceNameLabel.text=[dic objectForKey:@"name"];
                cell.linkLabel.text=[dic objectForKey:@"url"];
            }else if ([type isEqualToString:@"photo"]) {
                cell.iconImageView.image=[UIImage imageNamed:@"file_pic.png"];
                cell.resourceNameLabel.text=[dic objectForKey:@"name"];
            }
            [cell.delButton addTarget:self action:@selector(deleteAction:event:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        return 100;
    }else
    {
        return 44;
    }
}
- (void)deleteAction:(UIButton *)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        [self.listArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *filePath=[YNFunctions getTempCachePath];
    NSDateFormatter *dateFormate=[[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yy-MM-dd HH mm ss"];
    NSString *fileName=[NSString stringWithFormat:@"%@.jpg",[dateFormate stringFromDate:[NSDate date]]];
    filePath=[filePath stringByAppendingPathComponent:fileName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        BOOL result=[UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
        if (result) {
            NSLog(@"文件保存成功");
        }
    });
    [self.listArray addObject:@{@"type":@"photo",@"name":fileName}];
    [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex)
    {
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        UITextField *urlTextField = [alertView textFieldAtIndex:1];
        if([nameTextField.text length]>0 && [urlTextField.text length]>0)
        {
            //创建连接
            [self.listArray addObject:@{@"type":@"url",@"name":nameTextField.text,@"url":urlTextField.text}];
            [self.tableView reloadData];
        }
        else
        {
            [self showMessage:@"名称或网址不能为空！"];
        }
    }
}
#pragma mark - SCBSubjectManagerDelegate
//-(void)didGetSubjectInfo:(NSDictionary *)datadic
//{
//    self.dataDic=datadic;
//    self.listArray=[datadic objectForKey:@"joinMember"];
//    [self.tableView reloadData];
//}
@end
