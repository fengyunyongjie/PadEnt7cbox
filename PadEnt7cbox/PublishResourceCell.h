//
//  PublishResourceCell.h
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-28.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishResourceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *resourceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@end
