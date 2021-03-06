//
//  MainViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileListViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "QBImagePickerController.h"

typedef enum {
    kTypeDefault,
    kTypeCommit,
    kTypeResave,
    kTypeCopy,
    kTypeMove,
    kTypeUpload,
    kTypeShare,
} MainType;
typedef enum {
    kTypeRoot,
    kTypeEnt,
}DirType;

@protocol SharedEmailViewDelegate <NSObject>

-(void)addSharedFileView:(NSDictionary *)dictionary;

@end

@interface MainViewController : UIViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate,QBImagePickerControllerDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property(strong,nonatomic) NSArray *listArray;
@property(strong,nonatomic) UITableView *tableView;
@property(weak,nonatomic) id delegate;
@property(assign,nonatomic) MainType type;
@property(assign,nonatomic) DirType dirType;
@property (strong,nonatomic) NSArray *targetsArray;
@property (assign,nonatomic) BOOL isHasSelectFile;
@property(weak,nonatomic) id<SharedEmailViewDelegate> sharedEmialViewDelegate;

@end
