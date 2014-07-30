//
//  SubjectListForChooseViewController.h
//  icoffer
//
//  Created by hudie on 14-7-18.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//  选择主题

#import <UIKit/UIKit.h>
#import "SCBSubjectManager.h"

@interface SubjectListForChooseViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (strong,nonatomic) NSDictionary           *dataDic;
@property (strong,nonatomic) NSMutableArray         *listArray;
@property (strong, nonatomic) NSMutableArray      *selectedItems;
@property (nonatomic, retain) NSString            *commentString;
@property (nonatomic, retain) NSString            *fisdir;
@property (nonatomic, retain) NSArray            *parentSelectedIds;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@interface SubjectItem : NSObject {
    
}
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, retain) NSString * sub_id;
+ (SubjectItem *)SubjectItem;
@end