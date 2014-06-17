//
//  EmailDetailViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FileVieww:UIControl
@property(assign,nonatomic) int index;
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)NSDictionary *dicData;
@property(strong,nonatomic)NSString *imagePath;

-(void)setDic:(NSDictionary *)dic;
@end;
@interface EmailDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSMutableArray *fileArray;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) NSString *eid;
@property (strong,nonatomic) NSString *etype;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@end
