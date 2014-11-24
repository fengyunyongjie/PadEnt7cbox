//
//  SubJectNewDetailViewController.h
//  icoffer
//
//  Created by Yangsl on 14-7-11.
//  Copyright (c) 2014年 All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SCBFileManager.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
    SJNDTypeSelectedCell, //点击行
    SJNDTypeSelectedDown, //点击下载
    SJNDTypeSelectedCopy, //点击转存
    SJNDTypeSelectedComment, //点击评论
}SJNDType;

@interface IPSubJectNewDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SCBFileManagerDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSDictionary *dictionary;
@property(nonatomic, strong) NSMutableArray *tableArray;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UIControl *touchControl;
@property(nonatomic, strong) UIToolbar *editToolbar;
@property(nonatomic, strong) UIButton *selectedButton;
@property(nonatomic, strong) MBProgressHUD *hud;
@property(nonatomic, assign) SJNDType dType;
@property(nonatomic, strong) NSIndexPath *selectedIndexPath;
@property(nonatomic, assign) BOOL isPublish;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@protocol UpdateViewButtonDelegate <NSObject>

-(void)updateViewOneComment;
-(void)updateViewOneDown;
-(void)updateViewOneCopy;
-(void)updateViewCopyComment;
-(void)updateViewCopyAndDown;
-(void)updateViewCommentAndDown;
-(void)updateViewOneAll;

@end

@interface MainDetailViewCell : UITableViewCell

@property(nonatomic, strong) NSDictionary *dictionary;
@property(nonatomic, strong) UIButton *accessoryButton;
@property(nonatomic, weak) id<UpdateViewButtonDelegate> updateViewDelegate;
@property(nonatomic, assign) BOOL isPublish;

- (void)updateCell:(NSDictionary *)diction indexPath:(NSIndexPath *)indexPath;

@end

