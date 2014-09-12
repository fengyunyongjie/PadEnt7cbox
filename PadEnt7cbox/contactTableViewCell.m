//
//  contactTableViewCell.m
//  AddressDemo
//
//  Created by hudie on 14-8-27.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import "contactTableViewCell.h"

@implementation contactTableViewCell
@synthesize thumbImageV,nameLabel,telLabel,jobLabel,dateLbel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpdateAddressBookDept:(AddressBookDept *)list
{
    nameLabel.text = [NSString stringWithFormat:@"%@(%i人)",list.dept_name,list.userArray.count];
}

-(void)setUpdateAddressBookUser:(AddressBookUser *)list
{
    nameLabel.text = list.user_trueName;
    telLabel.text = list.user_phone;
    jobLabel.text = list.user_post;
    dateLbel.text = [NSString getAddressBookTimeFormat:list.user_createTime];
    
}

-(void)clearView
{
    nameLabel.text = @"";
    telLabel.text = @"";
    jobLabel.text = @"";
    dateLbel.text = @"";
}

@end
