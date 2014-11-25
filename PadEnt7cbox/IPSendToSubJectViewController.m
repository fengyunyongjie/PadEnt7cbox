//
//  SendToSubJectViewController.m
//  icoffer
//
//  Created by Yangsl on 14-7-14.
//  Copyright (c) 2014年  All rights reserved.
//

#import "IPSendToSubJectViewController.h"
#import "YNFunctions.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "IPSujectUpload.h"
#import "YNFunctions.h"
#import "SCBSession.h"
#import "NSString+Format.h"
#import "Appdelegate.h"
#import "MyTabBarViewController.h"
#import "LookDownFile.h"
#import "IPSCBSubJectManager.h"
#import "MainViewController.h"
#import "YNNavigationController.h"
#import "IPSubJectFileListViewController.h"

@interface IPSendToSubJectViewController ()
@property (nonatomic, retain) UILabel          *tvPlaceholder;
@end

@class TextButton;
@implementation IPSendToSubJectViewController
@synthesize baseDiction,backButton,rightButton,touchButton,commentTextView,bottonControl,addButton,photoButton,myFileButton,linkButton,editView,selectedList,tableArray,selectedRow,hud,isSending;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableArray = [[NSMutableArray alloc] init];
    self.title = @"发送共享内容";
    self.view.backgroundColor = subject_detaiTableview_color;
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    
    self.tvPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 30)];
    self.tvPlaceholder.text = @"说点什么吧...";
    self.tvPlaceholder.textColor = [UIColor lightGrayColor];
    self.tvPlaceholder.font = [UIFont systemFontOfSize:12];
    self.tvPlaceholder.backgroundColor = [UIColor clearColor];

    //评论
    CGRect textRect = CGRectMake(10, 10, 300, 80);
    self.commentTextView = [[UITextView alloc] initWithFrame:textRect];
    self.commentTextView.layer.borderWidth = 1;
    self.commentTextView.layer.borderColor = [textBoder_color CGColor];
    self.commentTextView.delegate = self;
    [self.commentTextView addSubview:self.tvPlaceholder];
    [self.view addSubview:self.commentTextView];
    [self viewDidNewLoad:YES];
    
    NSMutableArray *rightItems=[NSMutableArray array];
    //发布按钮
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,50,20)];
    [rightButton setTitle:@"发布" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightItems addObject:rightItem];
    self.navigationItem.rightBarButtonItems = rightItems;
    [self performSelector:@selector(viewDidNewLoad:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
    
    //文件列表视图
    float tableviewY = self.commentTextView.frame.origin.y+self.commentTextView.frame.size.height+5;
    CGRect tableviewRect = CGRectMake(0, tableviewY, 320, height-tableviewY-120);
    self.tableView = [[UITableView alloc] initWithFrame:tableviewRect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    //添加触摸按钮
    self.touchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.touchButton addTarget:self action:@selector(touchBegainClick) forControlEvents:UIControlEventTouchDown];
    [self.touchButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.touchButton];
    [self.touchButton setHidden:YES];
    
    //底部视图
    CGRect bottonRect = CGRectMake(0, height-49-44-20, 320, 50);
    self.bottonControl = [[UIControl alloc] initWithFrame:bottonRect];
    [self.view addSubview:self.bottonControl];
    CGRect bottonImgRect = CGRectMake(0, 0, 320, 50);
    UIImageView *bottonImage = [[UIImageView alloc] initWithFrame:bottonImgRect];
    [bottonImage setImage:[UIImage imageNamed:@"oper_bk.png"]];
    [self.bottonControl addSubview:bottonImage];

    //添加按钮
    CGRect addRect = CGRectMake((320-30)/2, 10, 30, 30);
    self.addButton = [[UIButton alloc] initWithFrame:addRect];
    [self.addButton setImage:[UIImage imageNamed:@"add_pic.png"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottonControl addSubview:self.addButton];
    
    //相机
    float boderWidth=30,buttonWidth=34,buttonHeight=40;
    float x = (320-(34*3+30*2))/2;
    CGRect photoRect = CGRectMake(x, 50, buttonWidth, buttonHeight);
    self.photoButton = [[UIButton alloc] initWithFrame:photoRect];
    [photoButton addTarget:self action:@selector(clickPhotoButton) forControlEvents:UIControlEventTouchUpInside];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"bottom_cra.png"] forState:UIControlStateNormal];
    [self.bottonControl addSubview:self.photoButton];
    [self.photoButton setHidden:YES];
    
    //我的文件
    CGRect myFileRect = CGRectMake(x+buttonWidth+boderWidth, 50, buttonWidth, buttonHeight);
    self.myFileButton = [[UIButton alloc] initWithFrame:myFileRect];
    [self.myFileButton addTarget:self action:@selector(clickMyFileButton) forControlEvents:UIControlEventTouchUpInside];
    [self.myFileButton setBackgroundImage:[UIImage imageNamed:@"bottom_file.png"] forState:UIControlStateNormal];
    [self.bottonControl addSubview:self.myFileButton];
    [self.myFileButton setHidden:YES];
    
    //链接
    CGRect linkRect = CGRectMake(x+buttonWidth*2+boderWidth*2, 50, buttonWidth, buttonHeight);
    self.linkButton = [[UIButton alloc] initWithFrame:linkRect];
    [self.linkButton addTarget:self action:@selector(clickLinkButton) forControlEvents:UIControlEventTouchUpInside];
    [self.linkButton setBackgroundImage:[UIImage imageNamed:@"bottom_link.png"] forState:UIControlStateNormal];
    [self.bottonControl addSubview:self.linkButton];
    [self.linkButton setHidden:YES];
}

-(void)viewDidLayoutSubviews
{
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        CGRect r=self.view.frame;
        r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
        self.view.frame=r;
    }
}

-(void)viewDidNewLoad:(BOOL)isHideTabBar
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appleDate.myTabBarVC setHidesTabBarWithAnimate:isHideTabBar];
}

-(void)addClicked
{
    NSLog(@"打开选择菜单");
    [self.touchButton setHidden:NO];
    [self.addButton setHidden:YES];
    [self.photoButton setHidden:NO];
    [self.myFileButton setHidden:NO];
    [self.linkButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect photoRect = self.photoButton.frame;
        photoRect.origin.y = 5;
        [self.photoButton setFrame:photoRect];
        CGRect myFileRect = self.myFileButton.frame;
        myFileRect.origin.y = 5;
        [self.myFileButton setFrame:myFileRect];
        CGRect linkRect = self.linkButton.frame;
        linkRect.origin.y = 5;
        [self.linkButton setFrame:linkRect];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self viewDidNewLoad:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self viewDidNewLoad:NO];
}

-(void)backClicked
{
    //返回上一级
    NSLog(@"返回上一级");
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)clickRightButton
{
    if(isSending)
    {
        return;
    }
    //发布资源
    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    NSMutableArray *subjectArray = [[NSMutableArray alloc] initWithObjects:[self.baseDiction objectForKey:@"subject_id"], nil];
    NSMutableArray *fielArray = [[NSMutableArray alloc] init];
    NSMutableArray *folderArray = [[NSMutableArray alloc] init];
    NSMutableArray *urlArray = [[NSMutableArray alloc] init];
    NSMutableArray *urlNameArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.tableArray.count; i++) {
        UpLoadList *upList = [self.tableArray objectAtIndex:i];
        if(upList.t_file_type==11)
        {
            BOOL isValid = [self isURLValid:upList.t_fileUrl];
            if (!isValid) {
                if (self.hud) {
                    [self.hud removeFromSuperview];
                }
                self.hud=nil;
                self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:self.hud];
                [self.hud show:NO];
                self.hud.labelText=@"链接格式非法";
                self.hud.mode=MBProgressHUDModeText;
                self.hud.margin=10.f;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:1.0f];
                return;
            }
            [urlArray addObject:upList.t_fileUrl];
            [urlNameArray addObject:upList.t_url_name];
        }
        else if(upList.t_file_type==12)
        {
            [folderArray addObject:upList.file_id];
        }
        else
        {
            [fielArray addObject:upList.file_id];
        }
    }
    NSString *spaceStr = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (fielArray.count>0 || folderArray.count>0 || urlArray.count >0) {
        isSending = YES;
        [sm publishResourceWithSubjectId:subjectArray res_file:fielArray res_folder:folderArray res_url:urlArray res_descs:urlNameArray comment:self.commentTextView.text];
    } else if (![self.commentTextView.text isEqualToString:@""] && spaceStr.length > 0) {
        isSending = YES;
        [sm publishResourceWithSubjectId:subjectArray res_file:fielArray res_folder:folderArray res_url:urlArray res_descs:urlNameArray comment:self.commentTextView.text];
    }
    else {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"请选择资源或说点什么";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
    
}

- (void)publishResourceWithSubjectId:(NSArray *)sub_ids res_file:(NSArray *)fileIds res_folder:(NSArray *)folderIds res_url:(NSArray *)urlStrings res_descs:(NSArray *)urlDesces comment:(NSString *)sub_comment{}

-(void)fileMoThan10
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"最多可添加10个文件";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

-(void)clickPhotoButton
{
    if(self.tableArray.count==10)
    {
        [self fileMoThan10];
        return;
    }
    [self touchBegainClick];
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

-(void)clickMyFileButton
{
    if(self.tableArray.count==10)
    {
        [self fileMoThan10];
        return;
    }
    //选择 icoffer的我的文件目录
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

#pragma mark - ChangeFileOrFolderDelegate

-(void)updateFileId:(NSString *)changFileId name:(NSString *)fileName
{
    UpLoadList *list = [[UpLoadList alloc] init];
    list.file_id = [NSString stringWithFormat:@"%@",changFileId];
    list.t_name = [NSString stringWithFormat:@"%@",fileName];
    [self.tableArray addObject:list];
    [self.tableView reloadData];
}

-(void)updateFolderId:(NSString *)changFolderId name:(NSString *)fileName
{
    UpLoadList *list = [[UpLoadList alloc] init];
    list.file_id = [NSString stringWithFormat:@"%@",changFolderId];
    list.t_name = [NSString stringWithFormat:@"%@",fileName];
    list.t_file_type=12;
    [self.tableArray addObject:list];
    [self.tableView reloadData];
}

-(void)clickLinkButton
{
    if(self.tableArray.count==10)
    {
        [self fileMoThan10];
        return;
    }
    [self touchBegainClick];
    //创建超链接
    NSLog(@"创建超链接");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建链接" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [[alert textFieldAtIndex:1] setText:@"http://"];
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    UITextField *name = [alert textFieldAtIndex:0];
    name.tag = 110;
    name.delegate = self;
    UITextField *address = [alert textFieldAtIndex:1];
    address.tag = 111;
    address.delegate = self;
    [alert setTag:SendToAlertTagNewLink];
    [alert show];
}

-(void)touchBegainClick
{
    [self.commentTextView resignFirstResponder];
    //触摸按钮
    [UIView animateWithDuration:0.3 animations:^{
        CGRect photoRect = self.photoButton.frame;
        photoRect.origin.y = 50;
        [self.photoButton setFrame:photoRect];
        CGRect myFileRect = self.myFileButton.frame;
        myFileRect.origin.y = 50;
        [self.myFileButton setFrame:myFileRect];
        CGRect linkRect = self.linkButton.frame;
        linkRect.origin.y = 50;
        [self.linkButton setFrame:linkRect];
    } completion:^(BOOL bl){
        [self.addButton setHidden:NO];
        [self.photoButton setHidden:YES];
        [self.myFileButton setHidden:YES];
        [self.linkButton setHidden:YES];
    }];
    [self.touchButton setHidden:YES];
}

-(void)clickNewLinkButton
{
    //确定新建连接
    NSLog(@"确定新建连接");
}

-(void)clickcancelNewButton
{
    //取消新建连接
    NSLog(@"取消新建连接");
    [self touchBegainClick];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.text.length > 0) {
        self.tvPlaceholder.hidden = YES;
    } else {
        self.tvPlaceholder.hidden = NO;
        
    }
    [self.touchButton setHidden:NO];
    return YES;
}

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
    if (textView == commentTextView) {
        NSMutableString *textString = [textView.text mutableCopy];
        [textString replaceCharactersInRange:range withString:text];
        return [textString length] <= 60;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.touchButton setHidden:NO];
    return YES;
}

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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            NSString *filePath=[YNFunctions getTempCachePath];
            NSDateFormatter *dateFormate=[[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yy-MM-dd HH mm ss"];
            NSString *fileName=[NSString stringWithFormat:@"%@.jpg",[dateFormate stringFromDate:[NSDate date]]];
            filePath=[filePath stringByAppendingPathComponent:fileName];
            BOOL result=[UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
            if (result) {
                NSLog(@"文件保存成功");
                IPSujectUpload *newUpload = [[IPSujectUpload alloc] init];
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
                selectedList = list;
                [newUpload setDelegate:self];
                if(newUpload.list.t_state == 0)
                {
                    newUpload.list.t_state = 0;
                    [newUpload isNetWork];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    self.hud=[[MBProgressHUD alloc] initWithView:app.window];
                    [app.window addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件正在上传中......";
                    self.hud.mode=MBProgressHUDModeIndeterminate;
                    self.hud.margin=10.f;
                    [self.hud show:YES];
                });
            }else
            {
                NSLog(@"文件保存失败");
            }
        }
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//上传成功
-(void)upFinish:(NSDictionary *)dicationary
{
    if (self.hud) {
        self.hud.labelText=@"文件上传完成";
        self.hud.mode=MBProgressHUDModeIndeterminate;
        self.hud.margin=10.f;
        [UIView animateWithDuration:1.0 animations:^{
            [self.hud removeFromSuperview];
        }];
    }
    selectedList.file_id = [NSString formatNSStringForOjbect:[dicationary objectForKey:@"fid"]];
    [self.tableArray addObject:selectedList];
    [self.tableView reloadData];
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
    if (self.hud) {
        self.hud.labelText=@"文件上传失败";
        self.hud.mode=MBProgressHUDModeIndeterminate;
        [UIView animateWithDuration:1.0 animations:^{
            [self.hud removeFromSuperview];
        }];
    }
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

#pragma mark - Table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableArray.count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"SubJectListTableViewCell";
    SendToTableViewCell *cell = [[SendToTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellString];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if(indexPath.row < self.tableArray.count)
    {
        UpLoadList *list = [self.tableArray objectAtIndex:indexPath.row];
        [cell updateCeleView:list indexPath:indexPath];
    }
    if(cell.accessoryButton)
    {
        [cell.accessoryButton addTarget:self action:@selector(accessoryButtonDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)accessoryButtonDeleteAction:(id)sender
{
    UIButton *button = sender;
    selectedRow = button.tag;
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    [actionSheet setTag:SendToAlertTagDelete];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        if(selectedRow<self.tableArray.count)
        {
            [self.tableArray removeObjectAtIndex:selectedRow];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex)
    {
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        UITextField *urlTextField = [alertView textFieldAtIndex:1];
         NSString *spaceStr = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([nameTextField.text length]>0 && [urlTextField.text length]>0 && spaceStr.length > 0)
        {
            //创建连接
            UpLoadList *list = [[UpLoadList alloc] init];
            list.t_fileUrl = urlTextField.text;
            list.t_url_name = nameTextField.text;
            list.t_file_type = 11;
            list.spaceId = [[SCBSession sharedSession] spaceID];;
            [self.tableArray addObject:list];
            [self.tableView reloadData];
        }
        else
        {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"名称或网址不能为空！";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
        }
    }
}

#pragma mark - 

- (void)publishSuccess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    [self.parentViewController.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发布成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self backClicked];
    isSending = FALSE;
}

- (void)publishUnsuccess:(NSString *)error_info
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    [self.parentViewController.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发布失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    isSending = FALSE;
}

@end


@implementation TextButton
@synthesize topImage,bottonLabel;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    CGRect topRect = CGRectMake(20, 0, 20, 20);
    self.topImage = [[UIImageView alloc] initWithFrame:topRect];
    [self.topImage setImage:[UIImage imageNamed:@"file_doc.png"]];
    [self addSubview:self.topImage];
    
    CGRect bottonRect = CGRectMake(0, 22, 60, 20);
    self.bottonLabel = [[UILabel alloc] initWithFrame:bottonRect];
    [self.bottonLabel setFont:[UIFont systemFontOfSize:14]];
    [self.bottonLabel setTextColor:[UIColor blackColor]];
    [self.bottonLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.bottonLabel];
    
    return self;
}

@end

@implementation SendToTableViewCell
@synthesize list,accessoryButton,logoIimageV,selectedIndexpath;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        CGRect logoRect = CGRectMake(15, 5, 30, 30);
        self.logoIimageV = [[UIImageView alloc] initWithFrame:logoRect];
        [self addSubview:self.logoIimageV];
        self.backgroundColor = subject_tableviewcell_color;
    }
    return self;
}

-(void)updateCeleView:(UpLoadList *)loadList indexPath:(NSIndexPath *)indexPath
{
    selectedIndexpath = indexPath;
    list = loadList;
    if(list.t_file_type==11) //11 超链接文件
    {
        self.logoIimageV.image = [UIImage imageNamed:@"link.png"];
        //信息名称
        NSString *urlTitle = list.t_url_name;
        CGRect nameRect = CGRectMake(50, 5, [NSString getNameWidth:urlTitle andFont:[UIFont systemFontOfSize:16]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:urlTitle];
        [nameLabel setTextColor:[UIColor blackColor]];
        [self addSubview:nameLabel];
        
        NSString *url = list.t_fileUrl;
        float urlX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect urlRect = CGRectMake(urlX, 5, 270-urlX, 30);
        UILabel *urlLabel = [[UILabel alloc] initWithFrame:urlRect];
        [urlLabel setFont:[UIFont systemFontOfSize:14]];
        [urlLabel setText:url];
        [urlLabel setTextColor:[UIColor blueColor]];
        [self addSubview:urlLabel];
    }
    else if(list.t_file_type==12) //12 文件夹
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_folder.png"];
        //信息名称
        CGRect nameRect = CGRectMake(50, 5, 220, 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:list.t_name];
        [nameLabel setTextColor:[UIColor blackColor]];
        [self addSubview:nameLabel];
    }
    else //图片、文件
    {
        //信息名称
        CGRect nameRect = CGRectMake(50, 5, 220, 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:list.t_name];
        [nameLabel setTextColor:[UIColor blackColor]];
        [self addSubview:nameLabel];
        //文件
        NSString *fmime=[[list.t_name pathExtension] lowercaseString];
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            //下载图片
            [self downLoadFile];
        }
        else
        {
            [self updaTextImage:fmime];
        }
    }
    [self addAccButton:indexPath];
}

- (void)downLoadFile
{
    //下载图片
    NSString *f_id = [NSString stringWithFormat:@"%@",list.file_id];
    NSString *f_name = [NSString stringWithFormat:@"%@",list.t_name];
    
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
    [NSString CreatePath:createPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    BOOL bl;
    bl = [NSString image_exists_FM_file_path:path];
    if(bl)
    {
        if([UIImage imageWithContentsOfFile:path])
        {
            [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.logoIimageV];
        }
        else
        {
            self.logoIimageV.image = [UIImage imageNamed:@"file_pic.png"];
        }
        return;
    }
    else
    {
        documentDir = [YNFunctions getProviewCachePath];
        createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
        [NSString CreatePath:createPath];
        path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        //查询本地是否已经有该图片
        bl = [NSString image_exists_at_file_path:path];
        if(bl)
        {
            if([UIImage imageWithContentsOfFile:path])
            {
                [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.logoIimageV];
            }
            else
            {
                self.logoIimageV.image = [UIImage imageNamed:@"file_pic.png"];
            }
        }
        else
        {
            self.logoIimageV.image = [UIImage imageNamed:@"file_pic.png"];
            dispatch_async(dispatch_get_main_queue(), ^{
                LookDownFile *downImage = [[LookDownFile alloc] init];
//                [downImage setIsPic2:YES];
                [downImage setFile_id:f_id];
                [downImage setFileName:f_name];
                [downImage setImageViewIndex:selectedIndexpath.row];
                [downImage setIndexPath:nil];
                [downImage setDelegate:self];
                [downImage startDownload];
            });
        }
    }
}

-(void)formatPhoto:(UIImage *)image imageView:(UIImageView *)textImageView
{
    UIImage *imageS = nil;
    UIImage *imageV = image;
    float width=100;
    if(imageV.size.width>=imageV.size.height)
    {
        if(imageV.size.height<=width)
        {
            CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.height = width;
            newImageSize.width = width*imageV.size.width/imageV.size.height;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake((newImageSize.width-width)/2, 0, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else if(imageV.size.width<=imageV.size.height)
    {
        if(imageV.size.width<=width)
        {
            CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.width = width;
            newImageSize.height = width*imageV.size.height/imageV.size.width;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake(0, (newImageSize.height-width)/2, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else
    {
        imageS = image;
    }
    [textImageView performSelectorInBackground:@selector(setImage:) withObject:imageS];
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)updaTextImage:(NSString *)fmime
{
    if ([fmime isEqualToString:@"doc"]||
        [fmime isEqualToString:@"docx"]||
        [fmime isEqualToString:@"rtf"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_txt.png"];
    }
    else
    {
        self.logoIimageV.image = [UIImage imageNamed:@"file_other.png"];
    }
}

-(void)addAccButton:(NSIndexPath *)indexPath
{
    if(self.accessoryButton==nil)
    {
        //修改accessoryType
        self.accessoryButton=[[UIButton alloc] init];
        [self.accessoryButton setFrame:CGRectMake(5, 5, 30, 30)];
        [self.accessoryButton setTag:indexPath.row];
        [self.accessoryButton setImage:[UIImage imageNamed:@"del_ico_nor.png"] forState:UIControlStateNormal];
        [self.accessoryButton setImage:[UIImage imageNamed:@"del_ico_sel.png"] forState:UIControlStateHighlighted];
        [self.accessoryButton setImage:[UIImage imageNamed:@"del_ico_sel.png"] forState:UIControlStateSelected];
        self.accessoryView = self.accessoryButton;
    }
}

#pragma mark - LookFileDelegate

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.logoIimageV];
}

- (void)downFinish:(NSString *)baseUrl
{
    
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    
}

-(void)didFailWithError
{
    
}

@end
