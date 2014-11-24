//
//  SubJectFileListViewController.h
//  icoffer
//
//  Created by hudie on 14-7-18.
//  Copyright (c) 2014年. All rights reserved.
//  资源列表文件夹

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
#import "IconDownloader.h"
#import "SCBFileManager.h"

typedef enum {
    SJSelectTypeDefault, //默认
    SJSelectTypeChangeFileOrFolder,  //文件、文件夹
}SJSelectType;

@interface IPSubJectFileListViewController : UIViewController<SCBSubJectDelegate,IconDownloaderDelegate,SCBFileManagerDelegate,SCBSubJectDelegate>
@property (nonatomic, retain) NSString           *subId;
@property (nonatomic, retain) NSString           *fId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray     *listArray;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) SJSelectType type;

@end
