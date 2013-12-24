//
//  PasswordController.h
//  ndspro
//
//  Created by Yangsl on 13-10-16.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputViewController.h"

@interface PasswordController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,PasswordDelegate>

@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,strong) InputViewController *lockScreen;
@property(nonatomic,strong) UIView *localV;
@end
