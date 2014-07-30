//
//  ResourceCommentViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-28.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "ResourceCommentViewController.h"
#import "SCBSubjectManager.h"
#import "ResourceCommentCell.h"
#import "MBProgressHUD.h"
#import "NSString+Format.h"
#import "YNFunctions.h"
#import "EmotionView.h"
#import <QuartzCore/QuartzCore.h>

#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "MessageCacheFileUtil.h"
#import "CafRecordWriter.h"
#import "Mp3RecordWriter.h"
#import "MLAudioMeterObserver.h"
#import "MLAudioRecorder.h"
#import "LCVoiceHud.h"

@interface ResourceCommentViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>{
    EmotionView    *emotionView;
//    NSMutableArray *listArray;
    
    NSString       *audioTemporarySavePath;
    NSString       *mp3TemporarySavePath;
    AVAudioPlayer  *audioPlayer;
    
    LCVoiceHud     *voiceHud;
    NSTimer        *timer;
    float volume;
    float recordTime;
    NSString       *audioId;
}
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *resourceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIButton *voiceInputButton;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) MBProgressHUD *hud;

@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSMutableString *waitSendArray;

@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) CafRecordWriter *cafWriter;
@property (nonatomic, strong) Mp3RecordWriter *mp3Writer;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@end

@implementation ResourceCommentViewController

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.commentTextField.layer.borderWidth=0.5f;
    self.commentTextField.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.commentTextField.layer.cornerRadius=3;
    
    self.voiceInputButton.layer.borderWidth=0.5f;
    self.voiceInputButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.voiceInputButton.layer.cornerRadius=3;
    
    NSDictionary *dic=self.resourceDic;
    NSString *fname = [dic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    self.resourceNameLabel.text=fname;
    self.linkLabel.hidden=YES;
    
    int file_type = [[dic objectForKey:@"type"] intValue];
    if(file_type == 1) {
        self.iconImageView.image = [UIImage imageNamed:@"file_folder.png"];
    }else if (file_type == 3) {//链接
        
        self.iconImageView.image = [UIImage imageNamed:@"sub_link.png"];
        self.linkLabel.text=[dic objectForKey:@"file_name"];
        self.resourceNameLabel.text=[dic objectForKey:@"details"];
        self.linkLabel.hidden=NO;
    }else { //文件
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"]){
            NSString *fthumb=[dic objectForKey:@"file_thumb"];
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
                self.iconImageView.image = image;
            }else{
                self.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
                NSLog(@"将要下载的文件：%@",localThumbPath);
                //                [self startIconDownload:dic forIndexPath:indexPath];
            }
            
        }else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
        }else if ([fmime isEqualToString:@"mp3"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
        }else if ([fmime isEqualToString:@"pdf"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
        }else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
        }else if([fmime isEqualToString:@"txt"])
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
            self.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
        }
    }
    [self updateList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 操作方法
- (void)updateList {
    SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
    sm.delegate = self;
    [sm getCommentListWithResourceId:self.resourceID];
}

-(void) resetTimer
{
    if (timer) {
        [timer invalidate];
    }
}

- (void)updateMeters {
    
    recordTime += WAVE_UPDATE_FREQUENCY;
    
    if (voiceHud)
    {
        [voiceHud setProgress:volume];
    }
}

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

- (IBAction)startVioceInput:(id)sender {
    //录音设置
    [self setAudio];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //self.longTapBtn.titleLabel.text = @"松开结束";
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;
    [self performSelector:@selector(endVoiceInput:) withObject:self afterDelay:60];
    
    recordTime = 0;
    [self resetTimer];
	timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [self showVoiceHudOrHide:YES];
}
- (IBAction)endVoiceInput:(id)sender {
    [self showVoiceHudOrHide:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self resetTimer];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [self.recorder stopRecording];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:mp3TemporarySavePath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //时长
    
//    SujectUpload *newUpload = [[SujectUpload alloc] init];
//    UpLoadList *list = [[UpLoadList alloc] init];
//    list.t_date = @"";
//    list.t_lenght = (NSInteger)[YNFunctions fileSizeAtPath:mp3TemporarySavePath];
//    list.t_name = [[mp3TemporarySavePath pathComponents] lastObject];
//    list.t_state = 0;
//    list.t_fileUrl = mp3TemporarySavePath;
//    list.t_url_pid = @"";
//    list.t_url_name = @"DeviceName";
//    list.t_file_type = 5;
//    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
//    list.file_id = @"";
//    list.upload_size = 0;
//    list.is_autoUpload = NO;
//    list.is_share = NO;
//    list.spaceId = [[SCBSession sharedSession] spaceID];
//    newUpload.list = list;
//    [newUpload setDelegate:self];
//    newUpload.uploadType = SJUploadTypeCommentAudio;
//    if(newUpload.list.t_state == 0)
//    {
//        newUpload.list.t_state = 0;
//        [newUpload isNetWork];
//    }
//    
//    if (self.hud) {
//        [self.hud removeFromSuperview];
//    }
//    self.hud=nil;
//    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//    [self.view.superview addSubview:self.hud];
//    [self.hud show:NO];
//    self.hud.labelText=@"正在发表...";
//    self.hud.mode=MBProgressHUDModeIndeterminate;
//    [self.hud show:YES];
}
- (IBAction)sendAction:(id)sender {
    if (!self.commentTextField.text||[self.commentTextField.text isEqualToString:@""]) {
        [self showMessage:@"请输入回复内容"];
        return;
    }
    SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
    sm.delegate = self;
    [sm sendCommentWithResourceId:self.resourceID subjectId:self.subjectID content:self.commentTextField.text type:@"0" seconds:nil];
    self.commentTextField.text=@"";
}
- (IBAction)switchInputType:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        self.voiceInputButton.hidden=NO;
        self.commentTextField.hidden=YES;
        self.sendButton.hidden=YES;
    }else
    {
        self.voiceInputButton.hidden=YES;
        self.commentTextField.hidden=NO;
        self.sendButton.hidden=NO;
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    ResourceCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"ResourceCommentCell"  owner:self options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
    NSString *nameStr = [dic objectForKey:@"usr_turename"];
    NSString *comment = [dic objectForKey:@"content"];
    NSString *publishTime = [dic objectForKey:@"publishTime"];
    NSString *type = [dic objectForKey:@"comment_type"];
    
    cell.personLabel.text=nameStr;
    cell.timeLabel.text=[NSString getTimeFormat:publishTime];
    cell.commentLabel.text=comment;
    if (type.intValue == 0) {
        
    }else{
        
    }
    CGRect cellFrame = [cell frame];
    CGRect r=cell.commentLabel.frame;
    CGSize size=[cell.commentLabel sizeThatFits:CGSizeMake(r.size.width, 1000)];
    if (size.height>24) {
        cellFrame.size.height=44+44+10+(size.height-24);
    }else{
        cellFrame.size.height=44+44+10;
    }
    [cell setFrame:cellFrame];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
#pragma mark - SCBSubjectManager delegate
-(void)networkError
{
    [self showMessage:@"链接失败，请检查网络"];
}

-(void)didGetCommentList:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"list"];
    [self.tableView reloadData];
}

-(void)didSendComment:(NSDictionary *)datadic
{
    int code=[[datadic objectForKey:@"code"] intValue];
    if (code==0) {
        [self showMessage:@"发送成功"];
        [self updateList];
    }else
    {
        [self showMessage:@"发送失败"];
    }
}
#pragma mark - ---键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    int interaction=[[[aNotifacation userInfo] objectForKey:@"UIKeyboardFrameChangedByUserInteraction"] intValue];
    if ([[aNotifacation userInfo] objectForKey:@"UIKeyboardFrameChangedByUserInteraction"]&&interaction!=0) {
        return;
    }else if(![[aNotifacation userInfo] objectForKey:@"UIKeyboardFrameChangedByUserInteraction"])
    {
        return;
    }
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.x-beginRect.origin.x;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    
    [CATransaction begin];
    [UIView animateWithDuration:0.3f animations:^{
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            {
                CGFloat deltaY=endRect.origin.x-beginRect.origin.x;
                CGRect r=self.messageView.frame;
                r.origin.y=r.origin.y+deltaY;
                [self.messageView setFrame:r];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                CGFloat deltaY=endRect.origin.x-beginRect.origin.x;
                CGRect r=self.messageView.frame;
                r.origin.y=r.origin.y-deltaY;
                [self.messageView setFrame:r];
            }
                break;
            case UIInterfaceOrientationPortrait:
            {
                CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
                CGRect r=self.messageView.frame;
                r.origin.y=r.origin.y-deltaY;
                [self.messageView setFrame:r];
            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
                CGRect r=self.messageView.frame;
                r.origin.y=r.origin.y+deltaY;
                [self.messageView setFrame:r];
            }
                break;
        }
        [self.messageView updateConstraintsIfNeeded];
        //[self.tableview setContentInset:UIEdgeInsetsMake(self.tableview.contentInset.top-deltaY, 0, 0, 0)];
//        CGRect r=self.view.frame;
//        r.size.height=r.size.height+deltaY;
//        [self.view setFrame:r];
    } completion:^(BOOL finished) {
        
    }];
    [CATransaction commit];
    
}
#pragma mark - interfaceOrientation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view endEditing:YES];
}
@end
