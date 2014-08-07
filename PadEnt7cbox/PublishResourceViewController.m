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
#import "SelectFileListViewController.h"
#import "SCBSession.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "SCBSubjectManager.h"
#import "SujectUpload.h"
#import "UpLoadList.h"
#import "NSString+Format.h"
#import "AppDelegate.h"
#import "MySplitViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SubjectActivityViewController.h"
#import "SubjectResourceViewController.h"


@interface PublishResourceViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate,ChangeFileOrFolderDelegate,UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIPopoverController *filePopoverController;
@property (weak, nonatomic) UILabel *placeholderLabel;
@property (strong,nonatomic) NSIndexPath *selectIndexPath;

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

//检查链接格式是否合法
- (BOOL)isURLValid:(NSString *)urlString {
    NSError *error = nil;
    NSMutableArray *matchsarr = [[NSMutableArray alloc]init];
    NSString *expression =  @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: expression options:NSRegularExpressionCaseInsensitive error:&error];
    [regex enumerateMatchesInString:urlString options:0 range:NSMakeRange(0, [urlString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange newrange = [result range];
        
        NSString *match = [urlString substringWithRange:newrange];
        
        NSURL *url = [NSURL URLWithString:match];
        [matchsarr addObject:url];
    }
     ];
    if (matchsarr.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

-(IBAction)publish:(id)sender
{
    BOOL canPublish=YES;
    NSMutableArray *fileIDArray=[NSMutableArray array];
    NSMutableArray *finderIDArray=[NSMutableArray array];
    NSMutableArray *urlArray=[NSMutableArray array];
    NSMutableArray *urlDesArray=[NSMutableArray array];
    for (NSDictionary *dic in self.listArray) {
        if ([[dic objectForKey:@"type"] isEqualToString:@"photo"]) {
            NSString *fid=[dic objectForKey:@"fid"];
            if (!fid) {
                canPublish=NO;
                NSString *photoName=[dic objectForKey:@"name"];
                [self showMessage:[NSString stringWithFormat:@"照片：‘%@’未上传完成",photoName]];
                return;
            }else
            {
                [fileIDArray addObject:fid];
            }
        }else if([[dic objectForKey:@"type"] isEqualToString:@"url"]){
            [urlArray addObject:[dic objectForKey:@"url"]];
            [urlDesArray addObject:[dic objectForKey:@"name"]];
        }else if([[dic objectForKey:@"type"] isEqualToString:@"file"]){
            NSDictionary *fileDic=[dic objectForKey:@"fileDic"];
            NSString *fisdir=[fileDic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                [finderIDArray addObject:[fileDic objectForKey:@"fid"]];
            }else
            {
                [fileIDArray addObject:[fileDic objectForKey:@"fid"]];
            }
        }
    }
    if (!canPublish) {
        [self showMessage:@"有照片未上传完成，不能发布"];
        return;
    }
    PublishResourceCell *cell=(PublishResourceCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *comment =cell.commentTextView.text;
    if (!comment) {
        comment=@"";
    }
    NSString *spaceStr = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (fileIDArray.count==0&&spaceStr.length==0&&finderIDArray.count==0&&urlArray.count==0) {
        [self showMessage:@"请选择资源或说点什么"];
        return;
    }
    SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
    sm.delegate = self;
    [sm publishResourceWithSubjectId:@[self.subjectID] res_file:fileIDArray res_folder:finderIDArray res_url:urlArray res_descs:urlDesArray comment:comment];
}

- (IBAction)openMenu:(id)sender {
    self.menuView.hidden=NO;
}

- (IBAction)openCameraView:(id)sender {
    if (self.listArray.count>=10) {
        [self showMessage:@"最多可添加10个文件"];
        return;
    }
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
        imagePicker.automaticallyAdjustsScrollViewInsets = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)openFileView:(UIButton *)sender {
    if (self.listArray.count>=10) {
        [self showMessage:@"最多可添加10个文件"];
        return;
    }
    self.menuView.hidden=YES;
    //选择 icoffer的我的文件目录
    NSLog(@"选择 icoffer的我的文件目录");
    SelectFileListViewController *flvc=[[SelectFileListViewController alloc] init];
    flvc.spid=[[SCBSession sharedSession] spaceID];
    flvc.f_id=@"0";
    flvc.title=@"请选择文件夹";
    flvc.type=kSelectTypePublishSubject;
    flvc.rootName=@"我的文件";
    flvc.roletype=@"2"; //2为我的文件夹 1为企业文件夹
    flvc.isHasSelectFile=YES;
    flvc.isFirstView = YES;
    flvc.publishDelegate=self;

    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
    self.filePopoverController=[[UIPopoverController alloc] initWithContentViewController:nav];
    [self.filePopoverController presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)openLinkView:(id)sender {
    if (self.listArray.count>=10) {
        [self showMessage:@"最多可添加10个文件"];
        return;
    }
    self.menuView.hidden=YES;
    //创建超链接
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建链接" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"请输入网址"];
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:1] setDelegate:self];
    [[alert textFieldAtIndex:1] setText:@"http://"];
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
            cell.commentTextView.delegate=self;
            self.placeholderLabel=cell.placeholderLabel;
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
                
                NSString *fthumb=[dic objectForKey:@"fthumb"];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                UIImage *image=[UIImage imageWithContentsOfFile:localThumbPath];
                if (image) {
                    cell.iconImageView.image=image;
                }
            }else if([type isEqualToString:@"file"])
            {
                NSDictionary *fileDic=[dic objectForKey:@"fileDic"];
                NSString *fname=[fileDic objectForKey:@"fname"];
                NSString *fmime=[[fname pathExtension] lowercaseString];
                NSString *fisdir=[fileDic objectForKey:@"fisdir"];
                cell.resourceNameLabel.text=fname;
                if ([fisdir isEqualToString:@"0"]) {
                    cell.iconImageView.image=[UIImage imageNamed:@"file_folder.png"];
                }else if ([fmime isEqualToString:@"png"]||
                          [fmime isEqualToString:@"jpg"]||
                          [fmime isEqualToString:@"jpeg"]||
                          [fmime isEqualToString:@"bmp"]||
                          [fmime isEqualToString:@"gif"]){
                    NSString *fthumb=[fileDic objectForKey:@"fthumb"];
                    NSString *localThumbPath=[YNFunctions getIconCachePath];
                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                    NSLog(@"是否存在文件：%@",localThumbPath);
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                        NSLog(@"存在文件：%@",localThumbPath);
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
                        //                        CGSize size=icon.size;
                        //                        if (size.width>size.height) {
                        //                            imageRect.size.height=size.height*(30.0f/imageRect.size.width);
                        //                            imageRect.origin.y+=(30-imageRect.size.height)/2;
                        //                        }else{
                        //                            imageRect.size.width=size.width*(30.0f/imageRect.size.height);
                        //                            imageRect.origin.x+=(30-imageRect.size.width)/2;
                        //                        }
                        [icon drawInRect:imageRect];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        cell.iconImageView.image = image;
                    }else{
                        cell.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
                        NSLog(@"将要下载的文件：%@",localThumbPath);
//                        [self startIconDownload:fileDic forIndexPath:indexPath];
                    }
                }else if ([fmime isEqualToString:@"doc"]||
                          [fmime isEqualToString:@"docx"]||
                          [fmime isEqualToString:@"rtf"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
                }
                else if ([fmime isEqualToString:@"xls"]||
                         [fmime isEqualToString:@"xlsx"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
                }else if ([fmime isEqualToString:@"mp3"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
                }else if ([fmime isEqualToString:@"mov"]||
                          [fmime isEqualToString:@"mp4"]||
                          [fmime isEqualToString:@"avi"]||
                          [fmime isEqualToString:@"rmvb"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
                }else if ([fmime isEqualToString:@"pdf"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
                }else if ([fmime isEqualToString:@"ppt"]||
                          [fmime isEqualToString:@"pptx"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
                }else if([fmime isEqualToString:@"txt"])
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
                }else
                {
                    cell.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
                }

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
        return 50;
    }
}
- (void)deleteAction:(UIButton *)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        self.selectIndexPath=indexPath;
        UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
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
        
        UIGraphicsBeginImageContext(CGSizeMake(100, 100));
        [image drawInRect:CGRectMake(0, 0, 100, 100)];
        UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
         NSString *iconFileName= [NSString stringWithFormat:@"%@.png",[[NSUUID UUID] UUIDString]];
        NSString *iconFilePath=[YNFunctions getIconCachePath];
        iconFilePath=[iconFilePath stringByAppendingPathComponent:iconFileName];
        [UIImagePNGRepresentation(iconImage) writeToFile:iconFilePath atomically:YES];
        
        BOOL result=[UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
        if (result) {
            NSLog(@"文件保存成功");
            NSLog(@"文件保存成功");
            SujectUpload *newUpload = [[SujectUpload alloc] init];
            UpLoadList *list = [[UpLoadList alloc] init];
            list.t_date = @"";
            list.t_lenght = (NSInteger)[YNFunctions fileSizeAtPath:filePath];
            list.t_name = [[filePath pathComponents] lastObject];
            list.t_state = 0;
            list.t_fileUrl = filePath;
            list.t_url_pid = @"";
            list.t_url_name = @"DeviceName";
            list.t_file_type = 5;
            list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
            list.file_id = @"";
            list.upload_size = 0;
            list.is_autoUpload = NO;
            list.is_share = NO;
            list.spaceId = [[SCBSession sharedSession] spaceID];
            newUpload.list = list;
            [newUpload setDelegate:self];
            if(newUpload.list.t_state == 0)
            {
                newUpload.list.t_state = 0;
                [newUpload isNetWork];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listArray addObject:@{@"type":@"photo",@"name":fileName,@"fthumb":iconFileName,@"list":list}];
                [self.tableView reloadData];
            });

        }
    });
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
            if ([self isURLValid:urlTextField.text]) {
                //创建连接
                [self.listArray addObject:@{@"type":@"url",@"name":nameTextField.text,@"url":urlTextField.text}];
                [self.tableView reloadData];
            }else
            {
                [self showMessage:@"链接格式非法"];
            }
        }
        else
        {
            [self showMessage:@"名称或网址不能为空！"];
        }
    }
}

#pragma mark - SCBSubjectManagerDelegate
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}
-(void)didPublishResource:(NSDictionary *)datadic
{
    int code=[[datadic objectForKey:@"code"] intValue];
    if (code==0) {
        [self showMessage:@"发布成功"];
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIViewController *controller=delegate.splitVC.viewControllers.lastObject;
            if ([controller isKindOfClass:[SubjectDetailTabBarController class]]) {
                UINavigationController * nav=(UINavigationController *)[(SubjectDetailTabBarController *)controller selectedViewController];
                if ([nav respondsToSelector:@selector(viewControllers)]) {
                    UIViewController *viewController=nav.viewControllers.firstObject;
                    if ([viewController respondsToSelector:@selector(updateList)]) {
                        [(SubjectResourceViewController *)viewController updateList];
                    }
                }
                
            }
        }];
    }else
    {
        [self showMessage:[NSString stringWithFormat:@"操作失败"]];
    }
}
#pragma mark - ChangeFileOrFolderDelegate
-(void)addFile:(NSDictionary *)dic
{
    [self.filePopoverController dismissPopoverAnimated:YES];
    BOOL isExist=NO;
    for (NSDictionary *d in self.listArray) {
        if ([[d objectForKey:@"type"] isEqualToString:@"file"]) {
            NSString *fid=[[d objectForKey:@"fileDic"] objectForKey:@"fid"];
            if ([fid longLongValue]==[[dic objectForKey:@"fid"] longLongValue]) {
                isExist=YES;
                break;
            }
        }
    }
    if (isExist) {
        [self showMessage:@"文件已经存在"];
        return;
    }
    [self.listArray addObject:@{@"type":@"file",@"fileDic":dic}];
    [self.tableView reloadData];
}

#pragma mark - //上传成功
-(void)upFinish:(NSDictionary *)dicationary fileinfo:(UpLoadList *)list;
{
    if (self.hud) {
        self.hud.labelText=@"文件上传完成";
        self.hud.mode=MBProgressHUDModeIndeterminate;
        self.hud.margin=10.f;
        [UIView animateWithDuration:1.0 animations:^{
            [self.hud removeFromSuperview];
        }];
    }
    NSString *file_id = [NSString formatNSStringForOjbect:[dicationary objectForKey:@"fid"]];
    
    NSDictionary *theDic;
    for (NSDictionary *dic in self.listArray) {
        if ([[dic objectForKey:@"type"] isEqualToString:@"photo"]) {
            if ([dic objectForKey:@"list"]==list) {
                theDic=dic;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessage:[NSString stringWithFormat:@"照片：'%@' 上传完成",[dic objectForKey:@"name"]]];
                });
                break;
            }
        }
    }
    if (theDic) {
        NSMutableDictionary *newDic=[NSMutableDictionary dictionaryWithDictionary:theDic];
        [newDic setObject:file_id forKey:@"fid"];
        int index=[self.listArray indexOfObject:theDic];
        [self.listArray replaceObjectAtIndex:index withObject:newDic];
    }
}
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)sudu
{
    
}
//文件重名
-(void)upReName
{
    
}
//上传失败
-(void)upError
{
//    if (self.hud) {
//        self.hud.labelText=@"文件上传失败";
//        self.hud.mode=MBProgressHUDModeIndeterminate;
//        [UIView animateWithDuration:1.0 animations:^{
//            [self.hud removeFromSuperview];
//        }];
//    }
}
//服务器异常
-(void)webServiceFail
{
    
}
//上传无权限
-(void)upNotUpload
{
    
}
//用户存储空间不足
-(void)upUserSpaceLass
{
    
}
//等待WiFi
-(void)upWaitWiFi
{
    
}
//网络失败
-(void)upNetworkStop
{
    
}
//文件名过长
-(void)upNotNameTooTheigth
{
}
//上传文件大小大于1g
-(void)upNotSizeTooBig
{
    
}
//文件名存在特殊字符
-(void)upNotHaveXNSString
{
    
}
#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeholderLabel.hidden = YES;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length > 0) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //textview.text less than 60
//    if (textView == commentTextView) {
        NSMutableString *textString = [textView.text mutableCopy];
        [textString replaceCharactersInRange:range withString:text];
        return [textString length] <= 60;
//    }
    
//    return YES;
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [self.touchButton setHidden:NO];
//    return YES;
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    //url name must less than 60
    if (textField.tag==110) {
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 60;
        
    } else if (textField.tag == 111) {
        //url must less than 255
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 255;
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        if (self.selectIndexPath) {
            [self.listArray removeObjectAtIndex:self.selectIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}
@end
