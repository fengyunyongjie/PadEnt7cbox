//
//  DetailView.m
//  AddressDemo
//
//  Created by hudie on 14-8-27.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import "ContactDetailView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ContactDetailView
@synthesize bookUser;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


+ (ContactDetailView *)instanceDetailView {
    
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"ContactDetailView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.thumbImageV.layer.cornerRadius = 10;
    self.thumbImageV.layer.masksToBounds = YES;
    
    [self.actionTable setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    self.actionTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.actionTable.layer.borderWidth = 0.5;
    self.actionTable.scrollEnabled = NO;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"detailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.tag = 1;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(70, 5, 30, 30)];
        [cell.contentView addSubview:imageV];
        imageV.tag = 2;

    }
    
    NSArray *titleArray = [NSArray arrayWithObjects:@"拨打电话",@"发送短信",@"取消", nil];
    NSArray *imageArray = [NSArray arrayWithObjects:@"address_gray_tel.png", @"address_gray_message.png",nil];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text = [titleArray objectAtIndex:indexPath.row];

    if (indexPath.row != 2) {
        UIImageView *imageV = (UIImageView *)[cell viewWithTag:2];
        imageV.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
        if (indexPath.row == 0) {
            imageV.frame = CGRectMake(90, 12, 12, 17);
        } else {
            imageV.frame = CGRectMake(90, 13, 17, 14);
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            //tel
            [self.delegate joinPhone:bookUser];
            break;
        case 1:
            //message
            [self.delegate joinEmail:bookUser];
            break;
        case 2:
            //cancel
            [self.delegate dismissDetailView];
            break;
        default:
            break;
    }
}

@end
