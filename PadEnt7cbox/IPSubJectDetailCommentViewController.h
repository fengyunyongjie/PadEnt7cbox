//
//  SubJectDetailCommentViewController.h
//  icoffer
//
//  Created by hudie on 14-7-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
#import "IconDownloader.h"
#import "DwonFile.h"
#import "SCBFileManager.h"
#import "IPSujectUpload.h"

@interface IPSubJectDetailCommentViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SCBSubJectDelegate,IconDownloaderDelegate,DownloaderDelegate,SCBFileManagerDelegate,SubjectUploadDelegate>

@property (nonatomic, retain) NSDictionary        *parentDic;
@property (nonatomic, retain) NSString            *subjectId;
@property (strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSIndexPath         *parent_indexpath;

@property (weak, nonatomic) IBOutlet UIImageView  *res_img;
@property (weak, nonatomic) IBOutlet UILabel      *res_name;
@property (weak, nonatomic) IBOutlet UITextField  *messageTF;
@property (weak, nonatomic) IBOutlet UIButton     *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton     *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton     *longTapBtn;
@property (weak, nonatomic) IBOutlet UIButton     *sendBtn;
@property (weak, nonatomic) IBOutlet UIView       *messageView;
@property (weak, nonatomic) IBOutlet UITableView  *tableview;

- (IBAction)sendMessage:(id)sender;
- (IBAction)addFace:(id)sender;
- (IBAction)voiceAction:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;


@end
