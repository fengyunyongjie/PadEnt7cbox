//
//  SubUserListViewController.h
//  icoffer
//
//  Created by hudie on 14-7-7.
//  Copyright (c) 2014年. All rights reserved.
//  成员列表

#import <UIKit/UIKit.h>
#import "IPSCBSubJectManager.h"
@protocol SubUserListDelegate <NSObject>

-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names;

@end

@interface IPSubjectUserListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SCBSubJectDelegate>
@property (strong,nonatomic) NSDictionary           *dataDic;
@property (strong,nonatomic) NSMutableArray         *listArray;
@property (strong,nonatomic) UITableView            *tableView;
@property (weak, nonatomic) id<SubUserListDelegate> listViewDelegate;
@property (strong,nonatomic) NSMutableArray         *selectedItems;
@property (strong,nonatomic) UIToolbar              *toolbar;

@end

@interface IPUserItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
@property (nonatomic, retain)   NSString *user_name;
@property (nonatomic, assign)   int user_id;
+ (IPUserItem*) IPUserItem;
@end