//
//  UpDownloadViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-29.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomSelectButton.h"
#import "UploadViewCell.h"
#import "QBImagePickerController.h"
#import "MBProgressHUD.h"
#import "IconDownloader.h"

@interface UpDownloadViewController : UIViewController<CustomSelectButtonDelegate,UITableViewDelegate,UITableViewDataSource,UploadViewCellDelegate,QBImagePickerControllerDelegate,UIActionSheetDelegate,IconDownloaderDelegate>
{
    NSInteger selectTableviewSection;
    NSInteger selectTableViewRow;
}

@property(strong,nonatomic) UITableView *table_view;
@property(strong,nonatomic) NSMutableArray *upLoading_array;
@property(strong,nonatomic) NSMutableArray *upLoaded_array;
@property(strong,nonatomic) NSMutableArray *downLoading_array;
@property(strong,nonatomic) NSMutableArray *downLoaded_array;
@property(assign,nonatomic) BOOL isShowUpload;
@property(strong,nonatomic) NSObject *deleteObject;
@property(strong,nonatomic) CustomSelectButton *customSelectButton;
@property(strong,nonatomic) UIControl *menuView;
@property(strong,nonatomic) UIButton *editView;
@property(strong,nonatomic) UIBarButtonItem *rightItem;
@property(strong,nonatomic) MBProgressHUD *hud;
@property(strong,nonatomic) UIButton *btnStart;
@property(strong,nonatomic) NSMutableArray *selectAllIds;
@property(strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property(strong,nonatomic) UIButton *btn_del;
@property(strong,nonatomic) NSString *selectTableViewFid;
@property(assign,nonatomic) BOOL isMultEditing;

-(void)isSelectedLeft:(BOOL)bl;
-(void)updateCount:(NSString *)upload_count downCount:(NSString *)down_count;
-(void)showFloderNot:(NSString *)alertText;
-(void)showSpaceNot;
-(void)updateTableViewCount;
-(void)updateCurrTableViewCell;
-(void)start:(id)sender;
//显示数据正在加载中....
-(void)showLoadData;
-(void)updateSelected;
-(void)updateJinduData;

@end
