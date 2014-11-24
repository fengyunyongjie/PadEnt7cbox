//
//  SubJectListViewController.h
//  icoffer
//
//  Created by Yangsl on 14-7-7.
//  Copyright (c) 2014年 All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
#import "MBProgressHUD.h"

@interface IPSubJectListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SCBSubJectDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *tableArray;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) MBProgressHUD *hud;

@end
