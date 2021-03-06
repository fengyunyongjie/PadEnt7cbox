//
//  EmailListViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "CustomSelectButton.h"

@interface EmailListViewController : UIViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *inArray;
@property (strong,nonatomic) NSArray *outArray;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) NSArray *rightItems;
@property (strong,nonatomic) UIControl *menuView;
@property (strong,nonatomic) CustomSelectButton *customSelectButton;
@property (nonatomic,assign) BOOL isShowEmail;

@end
