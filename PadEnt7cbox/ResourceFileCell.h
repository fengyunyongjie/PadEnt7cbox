//
//  ResourceFileCell.h
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-30.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *resaveButton;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@end
