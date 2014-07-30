//
//  ResourceFileCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-30.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "ResourceFileCell.h"

@implementation ResourceFileCell

- (void)awakeFromNib
{
    // Initialization code
    self.boardView.layer.borderWidth=0.5f;
    self.boardView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.boardView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }else
    {
        self.boardView.backgroundColor=[UIColor whiteColor];
    }
}

@end
