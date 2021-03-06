//
//  SubjectActivityCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-21.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectActivityCell.h"

@implementation SubjectActivityCell

- (void)awakeFromNib
{
    // Initialization code
    int scale=[UIScreen mainScreen].scale;
    float lineWidth=1.0f/scale;
    
    self.boardView.layer.borderWidth=lineWidth;;
    self.boardView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.boardView1.layer.borderWidth=lineWidth;;
    self.boardView1.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.boardView1.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }else
    {
        self.boardView1.backgroundColor=[UIColor whiteColor];
    }
    [self.resourceImageView setHighlighted:selected];
}

@end
