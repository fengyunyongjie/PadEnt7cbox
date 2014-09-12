//
//  DetailView.h
//  AddressDemo
//
//  Created by hudie on 14-8-27.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookUser.h"

@protocol ContactDetailViewDelegate <NSObject>

- (void)joinPhone:(AddressBookUser *)bookUser;
- (void)joinEmail:(AddressBookUser *)bookUser;
- (void)dismissDetailView;

@end

@interface ContactDetailView : UIView <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UITableView *actionTable;
@property (nonatomic, weak) id<ContactDetailViewDelegate>delegate;
@property (nonatomic, strong) AddressBookUser *bookUser;


+ (ContactDetailView *)instanceDetailView;

@end
