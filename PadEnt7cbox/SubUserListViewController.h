//
//  SubUserListViewController.h
//  icoffer
//
//  Created by hudie on 14-7-7.
//  Copyright (c) 2014年. All rights reserved.
//  成员列表

#import <UIKit/UIKit.h>
@protocol SubUserListDelegate <NSObject>

-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names;

@end

@interface SubUserListViewController : UIViewController
@property (strong,nonatomic) NSDictionary           *dataDic;
@property (strong,nonatomic) NSMutableArray         *listArray;
@property (strong,nonatomic) UITableView            *tableView;
@property (weak, nonatomic) id<SubUserListDelegate> listViewDelegate;
@property (strong,nonatomic) NSMutableArray         *selectedItems;
@property (strong,nonatomic) UIToolbar              *toolbar;

@end

@interface UserItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
@property (nonatomic, retain)   NSString *user_name;
@property (nonatomic, assign)   int user_id;
+ (UserItem*) UserItem;
@end