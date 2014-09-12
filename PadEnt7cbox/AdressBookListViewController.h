//
//  AdressBookListViewController.h
//  icoffer
//
//  Created by Yangsl on 14-8-27.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSelectButton.h"
#import "CutomNothingView.h"
#import "SCBAddressBookManager.h"
#import "ContactDetailView.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface AdressBookListViewController : UIViewController<CustomSelectButtonDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,SCBAddressBookDelegate,UISearchBarDelegate,ContactDetailViewDelegate,MFMessageComposeViewControllerDelegate,UIScrollViewDelegate>

@property(nonatomic, strong) UITableView *table_view;
@property(nonatomic, strong) NSMutableArray *tableArray;
@property(nonatomic, strong) UIControl *control;
@property(strong, nonatomic) CustomSelectButton *customSelectButton;
@property(nonatomic, strong) CutomNothingView *nothingView;
@property(nonatomic, assign) NSInteger select_dept_id;
@property(nonatomic, assign) BOOL isShowRecent;
@property(nonatomic, assign) BOOL isSendMessage;
@property(strong, nonatomic) UIView *searchView;
@property(strong, nonatomic) UISearchBar *searchBar;
@property(nonatomic, assign) BOOL isNotFirstFloder;
@property(strong, nonatomic) MBProgressHUD *hud;
@property(nonatomic, strong) NSString *navigationTitle;
@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) BOOL isNotFirstSearch;
@property (nonatomic, retain) NSMutableArray *recentArray;

@end
