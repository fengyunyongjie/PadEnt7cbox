//
//  PasswordButton.m
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-20.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "PasswordButton.h"

@implementation PasswordButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor whiteColor];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
