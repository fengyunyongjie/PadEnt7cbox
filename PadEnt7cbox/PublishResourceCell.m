//
//  PublishResourceCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-28.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "PublishResourceCell.h"

@implementation PublishResourceCell

- (void)awakeFromNib
{
    // Initialization code
    int scale=[UIScreen mainScreen].scale;
    float lineWidth=1.0f/scale;
    self.boardView.layer.borderWidth=lineWidth;
    self.boardView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.commentTextView.layer.borderWidth=lineWidth;
    self.commentTextView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
