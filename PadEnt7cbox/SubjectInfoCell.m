//
//  SubjectInfoCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-25.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectInfoCell.h"

@implementation SubjectInfoCell

- (void)awakeFromNib
{
    // Initialization code
    self.boardView.layer.borderWidth=0.5f;
    self.boardView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.boardView1.layer.borderWidth=0.5f;
    self.boardView1.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end