//
//  SubjectResourceCell.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-21.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectResourceCell.h"

@implementation SubjectResourceCell

- (void)awakeFromNib
{
    // Initialization code
    self.boardView.layer.borderWidth=0.5f;
    self.boardView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.boardView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }else
    {
        self.boardView.backgroundColor=[UIColor whiteColor];
    }
    // Configure the view for the selected state
}

@end
