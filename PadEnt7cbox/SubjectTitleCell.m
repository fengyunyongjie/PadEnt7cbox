//
//  SubjectTitleCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-23.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectTitleCell.h"

@implementation SubjectTitleCell

- (void)awakeFromNib
{
    // Initialization code
    self.numLabel.layer.cornerRadius=10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
