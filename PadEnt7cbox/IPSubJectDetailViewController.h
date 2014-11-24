//
//  SubJectDetailViewController.h
//  icoffer
//
//  Created by Yangsl on 14-7-8.
//  Copyright (c) 2014年  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
#import "SCBFileManager.h"
#import "IconDownloader.h"
#import "EGORefreshTableHeaderView.h"

typedef enum {
    SJMTypeDynamic, //动态
    SJMTypeResources,  //资源
    SJMTypeSubjectInfo, //专题信息
}SJMType;

@interface IPSubJectDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SCBSubJectDelegate,SCBFileManagerDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
    BOOL segementBl;
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
}
@property(nonatomic, strong) NSDictionary *baseDiction;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UITableView *tableView;
//数据源
@property(nonatomic, strong) NSMutableArray *dynamicArray;
@property(nonatomic, strong) NSMutableArray *resourcesArray;
@property(nonatomic, strong) NSMutableArray *subjectInfoArray;
//动态，资源，专题信息
@property(nonatomic, strong) UISegmentedControl *segMentControl;
@property(nonatomic, assign) SJMType sjmType;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;


@end