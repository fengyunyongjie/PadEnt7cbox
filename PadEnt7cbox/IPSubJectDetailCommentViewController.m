//
//  SubJectDetailCommentViewController.m
//  icoffer
//
//  Created by hudie on 14-7-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPSubJectDetailCommentViewController.h"
#import "EmotionView.h"
#import "IPCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "DownList.h"

#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "MessageCacheFileUtil.h"
#import "CafRecordWriter.h"
#import "Mp3RecordWriter.h"
#import "MLAudioMeterObserver.h"
#import "MLAudioRecorder.h"
#import "LCVoiceHud.h"

#import "AppDelegate.h"
#import "SCBSession.h"

@interface IPSubJectDetailCommentViewController () {
    EmotionView    *emotionView;
    NSMutableArray *listArray;
    
    NSString       *audioTemporarySavePath;
    NSString       *mp3TemporarySavePath;
    AVAudioPlayer  *audioPlayer;
    
    LCVoiceHud     *voiceHud;
    NSTimer        *timer;
    float volume;
    float recordTime;
    NSString       *audioId;

}

@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) CafRecordWriter *cafWriter;
@property (nonatomic, strong) Mp3RecordWriter *mp3Writer;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation IPSubJectDetailCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(audioPlayer.isPlaying)
    {
        [audioPlayer stop];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    emotionView = [[EmotionView alloc] initWithFrame:CGRectMake(0, 0, 320, 172+44)];
    self.longTapBtn.hidden = YES;
    self.faceBtn.selected = NO;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.tableview addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    //隐藏表情按钮
    self.faceBtn.hidden = YES;
    //设置文件图标
    [self setThumbImage];
    self.tableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableview.bounds.size.width, 0.01f)];
    self.title = @"资源评论";
    [self setAudio];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    self.tableview.frame=CGRectMake(0, 78, self.view.frame.size.width, self.view.frame.size.height-112);
}


//设置资源文件图标
- (void)setThumbImage {
    
    NSString *fname = [self.parentDic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    int file_type = [[self.parentDic objectForKey:@"type"] intValue];
    
    if (file_type == 1) {//文件夹
        self.res_img.image = [UIImage imageNamed:@"file_folder.png"];
        self.res_name.text = [self.parentDic objectForKey:@"file_name"];

    } else if (file_type == 3) {//链接
        self.res_img.image = [UIImage imageNamed:@"sub_link.png"];
        self.res_name.text = [self.parentDic objectForKey:@"details"];

        
    } else { //文件
        self.res_name.text = [self.parentDic objectForKey:@"file_name"];

        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"])
        {
            NSString *fthumb=[self.parentDic objectForKey:@"file_thumb"];
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
                 self.res_img.image = image;
            }else{
                 self.res_img.image = [UIImage imageNamed:@"file_pic.png"];
                NSLog(@"将要下载的文件：%@",localThumbPath);
               [self startIconDownload:self.parentDic forIndexPath:self.parent_indexpath];
            }
            
        }else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            self.res_img.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
             self.res_img.image = [UIImage imageNamed:@"file_excel.png"];
        }else if ([fmime isEqualToString:@"mp3"])
        {
             self.res_img.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            self.res_img.image = [UIImage imageNamed:@"file_moving.png"];
        }else if ([fmime isEqualToString:@"pdf"])
        {
             self.res_img.image = [UIImage imageNamed:@"file_pdf.png"];
        }else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
             self.res_img.image = [UIImage imageNamed:@"file_ppt.png"];
        }else if([fmime isEqualToString:@"txt"])
        {
             self.res_img.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
             self.res_img.image = [UIImage imageNamed:@"file_other.png"];
        }
    }

}


//设置录音
- (void)setAudio {
    
    CafRecordWriter *writer = [[CafRecordWriter alloc] init];
    writer.filePath = [[[MessageCacheFileUtil sharedInstance] userDocPathAndIsMp3:NO] stringByAppendingString:@"/record.caf"];
    self.cafWriter = writer;
    
    Mp3RecordWriter *mp3Writer = [[Mp3RecordWriter alloc] init];
    NSDateFormatter *dateFormate=[[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyMMddHHmmss"];
    NSString *fileName=[NSString stringWithFormat:@"%@.mp3",[dateFormate stringFromDate:[NSDate date]]];

    mp3Writer.filePath = [[[MessageCacheFileUtil sharedInstance] userDocPathAndIsMp3:YES] stringByAppendingString:fileName];
    self.mp3Writer = mp3Writer;
    
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc] init];
    meterObserver.actionBlock =  ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
        NSLog(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
        volume = [MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates];
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    self.meterObserver = meterObserver;
    
    MLAudioRecorder *recorder = [[MLAudioRecorder alloc] init];
    __weak __typeof(self)weakSelf = self;
    recorder.receiveStoppedBlock = ^{
        weakSelf.meterObserver.audioQueue = nil;
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        weakSelf.meterObserver.audioQueue = nil;
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    
    //caf
    recorder.oFileWriteDelegate = writer;
    audioTemporarySavePath = writer.filePath;
    //mp3
    recorder.fileWriterDelegate = mp3Writer;
    mp3TemporarySavePath = mp3Writer.filePath;
    
    self.recorder = recorder;

}

#pragma mark - Helper Function

-(void) showVoiceHudOrHide:(BOOL)yesOrNo{
    
    if (voiceHud) {
        [voiceHud hide];
    }
    
    if (yesOrNo) {
        
        voiceHud = [[LCVoiceHud alloc] init];
        [voiceHud show];
        
    }else{
        
    }
}

-(void) resetTimer
{
    if (timer) {
        [timer invalidate];
    }
}

#pragma mark - Timer Update

- (void)updateMeters {
    
    recordTime += WAVE_UPDATE_FREQUENCY;
    
    if (voiceHud)
    {
        [voiceHud setProgress:volume];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SCBSubjectManager delegate
- (void)updateList {
    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    NSString *res_id = [self.parentDic objectForKey:@"resource_id"];
    [sm getCommentListWithResourceId:res_id];
}

//获取评论成功
- (void)getCommentListSuccess:(NSDictionary *)dic {
    listArray = [dic objectForKey:@"list"];
    [self.tableview reloadData];
}

//获取评论失败
- (void)getCommentListunsccess:(NSString *)error_info {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"获取评论失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}


//发送评论
- (IBAction)sendMessage:(id)sender {

    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    NSString *res_id = [self.parentDic objectForKey:@"resource_id"];
    if (sender == nil) {
        int len = audioPlayer.duration;
        if(len<1)len=1;
        [sm sendCommentWithResourceId:res_id subjectId:self.subjectId content:audioId type:@"1" seconds:[NSString stringWithFormat:@"%i",len]];

    } else {
        NSString *spaceStr = [self.messageTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![self.messageTF.text isEqualToString:@""] && spaceStr.length>0) {
            [sm sendCommentWithResourceId:res_id subjectId:self.subjectId content:self.messageTF.text type:@"0" seconds:nil];
        } else {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view.superview addSubview:self.hud];
            self.hud.labelText=@"请输入回复内容";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
        }
    }
}


//发送评论成功
- (void)sendCommentSuccess {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    [self.parentViewController.view.superview addSubview:self.hud];
    self.hud.labelText=@"评论成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self.navigationController popViewControllerAnimated:YES];
}

//发送评论失败
- (void)sendCommentunsuccess:(NSString *)error_info {
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"评论失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

//添加表情
- (IBAction)addFace:(id)sender {
    if (self.faceBtn.selected) {
        [_messageTF setInputView:nil];
        [_messageTF reloadInputViews];
        self.faceBtn.selected = NO;
        [_messageTF becomeFirstResponder];
        
    } else {
        emotionView.delegate = _messageTF;
        [_messageTF setInputView:emotionView];
        [_messageTF reloadInputViews];
        [_messageTF becomeFirstResponder];
        self.faceBtn.selected = YES;
    }
}

//录音和键盘之间切换
- (IBAction)voiceAction:(id)sender {
    [_messageTF resignFirstResponder];
    UIButton *b = (UIButton *)sender;
    if (b.tag == 0) {
        self.longTapBtn.hidden = NO;
        self.messageTF.hidden = YES;
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"sub_jianpan_up"] forState:UIControlStateNormal];
        self.voiceBtn.tag = 1;
    } else {
        self.longTapBtn.hidden = YES;
        self.messageTF.hidden = NO;
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"sub_voice_up"] forState:UIControlStateNormal];
        self.voiceBtn.tag = 0;
    }
  
}

//开始录音
- (IBAction)startRecord:(id)sender {
    //录音设置
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //self.longTapBtn.titleLabel.text = @"松开结束";
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;
    [self performSelector:@selector(stopRecord:) withObject:self afterDelay:60];
    
    recordTime = 0;
    [self resetTimer];
	timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [self showVoiceHudOrHide:YES];
}

//停止录音
- (IBAction)stopRecord:(id)sender {
    [self showVoiceHudOrHide:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self resetTimer];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.hud=[[MBProgressHUD alloc] initWithView:app.window];
    [app.window addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在发表中，请稍等";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
    
    //延迟1秒
    [self performSelector:@selector(sleep1) withObject:nil afterDelay:0.5];
}

- (void)sleep1
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [self.recorder stopRecording];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:mp3TemporarySavePath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //时长
    
    IPSujectUpload *newUpload = [[IPSujectUpload alloc] init];
    UpLoadList *list = [[UpLoadList alloc] init];
    list.t_date = @"";
    list.t_lenght = (NSInteger)[YNFunctions fileSizeAtPath:mp3TemporarySavePath];
    list.t_name = [[mp3TemporarySavePath pathComponents] lastObject];
    list.t_state = 0;
    list.t_fileUrl = mp3TemporarySavePath;
    list.t_url_pid = @"";
    list.t_url_name = @"DeviceName";
    list.t_file_type = 5;
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    list.file_id = @"";
    list.upload_size = 0;
    list.is_autoUpload = NO;
    list.is_share = NO;
    NSLog(@"[[SCBSession sharedSession] spaceID]:%@",[[SCBSession sharedSession] spaceID]);
    list.spaceId = [[SCBSession sharedSession] spaceID];
    newUpload.list = list;
    [newUpload setDelegate:self];
    newUpload.uploadType = SJUploadTypeCommentAudio;
    if(newUpload.list.t_state == 0)
    {
        newUpload.list.t_state = 0;
        [newUpload isNetWork];
    }
}

- (void)playAudio:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [listArray objectAtIndex:btn.tag];
    NSString *file_id = [dic objectForKey:@"content"];
    [self getFileWithFileId:file_id];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [listArray objectAtIndex:indexPath.section];
    NSString *type = [dic objectForKey:@"comment_type"];
    IPCommentCell *cell = nil;
    if (type.intValue == 0) {
        static NSString *CellIdentifier = @"IPCommentCell";
       cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *_nib=[[NSBundle mainBundle] loadNibNamed:@"IPCommentCell"
                                                        owner:self
                                                      options:nil];
            cell = [_nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        NSString *nameStr = [dic objectForKey:@"usr_turename"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:nameStr andFont:[UIFont systemFontOfSize:16]], 30);
        cell.nameLabel.frame = nameRect;
        UIColor *c = [UIColor colorWithRed:54.0/255.0 green:116.0/255.0 blue:176.0/255.0 alpha:1.0];
        cell.nameLabel.textColor = c;
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
        float speakX = cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 30, 30);
        UILabel *l = [[UILabel alloc] initWithFrame:speakRect];
        l.text = @" 说:";
        l.font = [UIFont systemFontOfSize:14];
        l.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:l];
        cell.commentLabel.text = [dic objectForKey:@"content"];
        NSString *publishTime = [dic objectForKey:@"publishTime"];
        cell.dateLabel.text = [NSString getTimeFormat:publishTime];

    } else {
        static NSString *CellIdentifier = @"IPCommentCell2";
        cell = [self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *_nib=[[NSBundle mainBundle] loadNibNamed:@"IPCommentCell"
                                                        owner:self
                                                      options:nil];
            cell = [_nib objectAtIndex:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *nameStr = [dic objectForKey:@"usr_turename"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:nameStr andFont:[UIFont systemFontOfSize:16]], 30);
        cell.nameLabel.frame = nameRect;
        UIColor *c = [UIColor colorWithRed:54.0/255.0 green:116.0/255.0 blue:176.0/255.0 alpha:1.0];
        cell.nameLabel.textColor = c;
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
        float speakX = cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 30, 30);
        UILabel *l = [[UILabel alloc] initWithFrame:speakRect];
        l.text = @" 说:";
        l.font = [UIFont systemFontOfSize:14];
        l.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:l];
        cell.commentLabel.text = [dic objectForKey:@"content"];
        NSString *publishTime = [dic objectForKey:@"publishTime"];
        cell.dateLabel.text = [NSString getTimeFormat:publishTime];
        int timeLength = [[dic objectForKey:@"seconds"] intValue];
        cell.timeLen.text = [NSString stringWithFormat:@"%d''",timeLength];
        cell.playBtn.tag = indexPath.section;
        [cell.playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0;
}

#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}

#pragma mark ----键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    
    [CATransaction begin];
    [UIView animateWithDuration:0.3f animations:^{
        [self.messageView setFrame:CGRectMake(self.messageView.frame.origin.x, self.messageView.frame.origin.y+deltaY, self.messageView.frame.size.width, self.messageView.frame.size.height)];
        //[self.tableview setContentInset:UIEdgeInsetsMake(self.tableview.contentInset.top-deltaY, 0, 0, 0)];
        
    } completion:^(BOOL finished) {
        
    }];
    [CATransaction commit];
    
}

#pragma mark-
#pragma mark- UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.faceBtn.selected = NO;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    //comment must less than 60
    if (textField==self.messageTF) {
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 60;
        
    }
    return YES;
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
}


- (void)getFileWithFileId:(NSString *)file_id {
    
    SCBFileManager *fm = [[SCBFileManager alloc] init];
    fm.delegate = self;
    [fm requestEntFileInfo:file_id];
}

#pragma mark - SCBFileManager delegate
- (void)getFileEntInfo:(NSDictionary *)dictionary {
    [self downLoad:dictionary];
}

- (void)downLoad:(NSDictionary *)dic {
    
    NSString *file_id = [dic objectForKey:@"fid"];
    NSString *f_name = [dic objectForKey:@"fname"];
    NSInteger size = [[dic objectForKey:@"fsize"] integerValue];
    DwonFile *down = [[DwonFile alloc] init];
    [down setFile_id:file_id];
    [down setFileName:f_name];
    [down setFileSize:size];
    [down setDelegate:self];
    [down startDownload];
}

- (void)downFinish:(NSString *)baseUrl {
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:baseUrl];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer play];
}

-(void)downError {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"该文件已被删除或取消共享";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

- (void)didFailWithError {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

#pragma mark-
//上传成功
-(void)upFinish:(NSDictionary *)dicationary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        audioId = [dicationary objectForKey:@"fid"];
        [self sendMessage:nil];
        [[MessageCacheFileUtil sharedInstance] deleteWithContentPath:mp3TemporarySavePath];
        [[MessageCacheFileUtil sharedInstance] deleteWithContentPath:audioTemporarySavePath];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        self.hud.labelText=@"评论失败";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    });

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


@end
