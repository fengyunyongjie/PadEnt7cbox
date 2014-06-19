//
//  SelectFileListViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-8.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//
// 移动选择、转存选择、提交选择、上传选择
#import <UIKit/UIKit.h>
#import "FileListViewController.h"
//@class FileListViewController;
typedef enum {
    kSelectTypeDefault,
    kSelectTypeMove,
    kSelectTypeCopy,
    kSelectTypeResave,
    kSelectTypeCommit,
    kSelectTypeUpload,
    kSelectTypeShare,
    kSelectTypeFloderChange,
} SelectType;

@protocol SelectFileFileEmailViewDelegate <NSObject>

-(void)addSharedFileView:(NSDictionary *)dictionary;
-(void)changeFloderView:(NSDictionary *)dictionary;

@end

@protocol SelectFileListDelegate;
@interface SelectFileListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSArray *targetsArray;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSArray *finderArray;
@property (strong,nonatomic) NSString *f_id;
@property (strong,nonatomic) NSString *fcmd;
@property (strong,nonatomic) NSString *spid;
@property (strong,nonatomic) NSString *roletype;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) UIToolbar *toolbar;
@property (strong,nonatomic) NSString *rootName;
@property (weak,nonatomic) id<SelectFileListDelegate> delegate;
@property (assign,nonatomic) SelectType type;
@property (assign,nonatomic) BOOL isHasSelectFile;
@property (nonatomic,assign) BOOL isLoading;
@property (weak,nonatomic) id<SelectFileFileEmailViewDelegate> selectFileEmialViewDelegate;
@property (nonatomic,assign) BOOL isFirstView;

@end

@protocol SelectFileListDelegate
@optional
-(void)moveFileToID:(NSString *)f_id spid:(NSString *)spid;
-(void)copyFileToID:(NSString *)f_id spid:(NSString *)spid;
-(void)commitFileToID:(NSString *)f_id sID:(NSString *)s_pid;
-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid;
-(void)uploadFileder:(NSString *)deviceName;
-(void)uploadSpid:(NSString *)s_pid_;
-(void)uploadFiledId:(NSString *)f_id_;
-(void)showMessage:(NSString *)message;
-(void)operateUpdate;
-(void)editFinished;
@end