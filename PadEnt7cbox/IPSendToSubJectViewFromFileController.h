//
//  SendToSubJectViewController.h
//  icoffer
//
//  Created by hudie on 14-7-8.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
#import "IconDownloader.h"


@interface IPSendToSubJectViewFromFileController : UIViewController<UITextViewDelegate,IconDownloaderDelegate,SCBSubJectDelegate>
@property (weak, nonatomic) IBOutlet UITextView   *infoTV;
@property (weak, nonatomic) IBOutlet UIButton     *faceBtn;
@property (nonatomic, retain) NSMutableArray      *listArray;
@property (nonatomic, retain) NSDictionary        *dataDic;
@property (strong, nonatomic) NSMutableArray      *selectedItems;
@property (nonatomic, retain) NSArray             *parentSelectedIds;
@property (nonatomic, assign) NSString            *fisdir;
@property (weak, nonatomic) IBOutlet UIImageView  *res_image;
@property (weak, nonatomic) IBOutlet UILabel      *res_name;
@property (strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)addFace:(id)sender;

@end
