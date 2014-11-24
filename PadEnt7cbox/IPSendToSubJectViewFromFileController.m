//
//  SendToSubJectViewController.m
//  icoffer
//
//  Created by hudie on 14-7-8.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPSendToSubJectViewFromFileController.h"
#import <QuartzCore/QuartzCore.h>
#import "YNFunctions.h"
#import "MBProgressHUD.h"
#import "UIBarButtonItem+Yn.h"
#import "EmotionView.h"
#import "IPSubjectListForChooseViewController.h"
#import "DownList.h"

@interface IPSendToSubJectViewFromFileController ()
@property (nonatomic, strong) MBProgressHUD      *hud;
@property (nonatomic, retain) EmotionView        *emotionView;
@property (nonatomic, retain) NSMutableArray     *selectedArray;
@property (nonatomic, retain) UILabel            *tvPlaceholder;
@property (nonatomic, retain) NSMutableArray     *subjectArr;

@end

@implementation IPSendToSubJectViewFromFileController

- (BOOL)shouldAutorotate{
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //隐藏face button
    self.faceBtn.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //UItextView加边框和placeholder
    self.tvPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
    self.tvPlaceholder.text = @"说点什么吧...";
    self.tvPlaceholder.textColor = [UIColor lightGrayColor];
    self.tvPlaceholder.font = [UIFont systemFontOfSize:12];
    self.tvPlaceholder.backgroundColor = [UIColor clearColor];
    [self.infoTV addSubview:self.tvPlaceholder];
    self.infoTV.scrollEnabled = NO;
    self.infoTV.layer.borderWidth = 1.0;
    self.infoTV.layer.borderColor = [UIColor colorWithRed:205.0/255.0 green:204.0/255.0 blue:208.0/255.0 alpha:1].CGColor;
    
    self.faceBtn.selected = NO;
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(goToChooseSubject)]];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    self.navigationItem.title = @"发布到专题";
    self.emotionView = [[EmotionView alloc] initWithFrame:CGRectMake(0, 0, 320, 216-44)];
    
    self.res_name.text = [self.dataDic objectForKey:@"fname"];
    [self setThumbImage];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    self.subjectArr = [NSMutableArray array];
    [self updateSubjectList];
}

//返回
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//face view
- (IBAction)addFace:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        [self.infoTV setInputView:nil];
        [self.infoTV reloadInputViews];
        [self.infoTV becomeFirstResponder];
        self.faceBtn.selected = NO;
        [self.faceBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotion.png"] forState:UIControlStateNormal];

    } else {
        self.emotionView.tvDelegate = self.infoTV;
        [self.infoTV setInputView:self.emotionView];
        [self.infoTV reloadInputViews];
        [self.infoTV becomeFirstResponder];
        self.faceBtn.selected = YES;
        [self.faceBtn setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboard.png"] forState:UIControlStateNormal];

    }
}

- (void)goToChooseSubject {
    if (self.subjectArr.count > 0) {
        IPSubjectListForChooseViewController *s = [[IPSubjectListForChooseViewController alloc] init];
        s.parentSelectedIds = self.parentSelectedIds;
        s.fisdir = self.fisdir;
        s.commentString = self.infoTV.text;
        [self.navigationController pushViewController:s animated:YES];
    } else {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        self.hud.labelText=@"请新建一个专题";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
   
}



#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //return后键盘消失
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
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
    textView.text = nil;
    self.tvPlaceholder.hidden = YES;
    return YES;
}

#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}

//设置资源文件图标
- (void)setThumbImage {
    
    NSString *fname = [self.dataDic objectForKey:@"fname"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    
    if (self.fisdir.intValue == 0) {//文件夹
        self.res_image.image = [UIImage imageNamed:@"file_folder.png"];
    } else { //文件
        
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            NSString *fthumb=[self.dataDic objectForKey:@"fthumb"];
            NSString *localThumbPath=[YNFunctions getIconCachePath];
            fthumb =[YNFunctions picFileNameFromURL:fthumb];
            localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                
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
                [icon drawInRect:imageRect];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.res_image.image = image;
            }else{
                self.res_image.image = [UIImage imageNamed:@"file_pic.png"];
                NSLog(@"将要下载的文件：%@",localThumbPath);
                NSIndexPath *path = [[NSIndexPath alloc] init];
                [self startIconDownload:self.dataDic forIndexPath:path];
            }
            
        }else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_excel.png"];
        }else if ([fmime isEqualToString:@"mp3"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_moving.png"];
        }else if ([fmime isEqualToString:@"pdf"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_pdf.png"];
        }else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_ppt.png"];
        }else if([fmime isEqualToString:@"txt"])
        {
            self.res_image.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
           self.res_image.image = [UIImage imageNamed:@"file_other.png"];
        }
    }
    
}

//icon下载
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imageDownloadsInProgress) {
        self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    }
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}


//获取专题列表
- (void)updateSubjectList {
    
    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    [sm getSubjectList];
}

//SCBSubjectManager delegate
//获取专题列表成功
- (void)checkSubjectListSuccess:(NSDictionary *)dic {
    
    if (dic) {
        NSMutableArray *a = [dic objectForKey:@"data"];
        NSDictionary *d2 = [a objectAtIndex:1];
        NSDictionary *d1 = [a objectAtIndex:0];
        NSMutableArray *joinArray = [d2 objectForKey:@"subjectList"];
        NSMutableArray *materArray = [d1 objectForKey:@"subjectList"];
        [self.subjectArr addObject:joinArray];
        [self.subjectArr addObject:materArray];
    }
}

//获取专题列表失败
- (void)checkSubjectListUnsuccess:(NSString *)error_info {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}


@end
