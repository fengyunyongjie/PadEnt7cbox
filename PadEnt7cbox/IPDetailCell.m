//
//  DetailCell.m
//  icoffer
//
//  Created by hudie on 14-7-10.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPDetailCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation IPDetailCell

- (void)awakeFromNib
{
    // Initialization code
    UIColor *c = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.contentLabel.layer.borderColor = c.CGColor;
    self.contentLabel.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCell:(NSDictionary *)diction {
    
}

@end
