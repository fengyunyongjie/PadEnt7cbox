//
//  UserListViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-10.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendEmailViewController.h"

@protocol UserListViewDelegate <NSObject>

-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names emails:(NSArray *)emails;

@end

@interface UserListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) UITableView *tableView;
@property (weak,nonatomic) SendEmailViewController *delegate;
@property (weak,nonatomic) id<UserListViewDelegate> listViewDelegate;
@property (strong,nonatomic) NSArray *userItems;
@property (strong,nonatomic) NSMutableArray *selectedItems;
@property (strong,nonatomic) UIToolbar *toolbar;

@end


@interface FileItem : NSObject
{
}
@property (nonatomic, assign)	BOOL checked;
+ (FileItem*) fileItem;
@end