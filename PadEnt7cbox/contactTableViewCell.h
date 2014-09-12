//
//  contactTableViewCell.h
//  AddressDemo
//
//  Created by hudie on 14-8-27.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookDept.h"
#import "AddressBookUser.h"

@interface contactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLbel;

-(void)setUpdateAddressBookDept:(AddressBookDept *)list;
-(void)setUpdateAddressBookUser:(AddressBookUser *)list;

-(void)clearView;

@end
