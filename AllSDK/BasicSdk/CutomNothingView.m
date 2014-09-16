//
//  CutomNothingView.m
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "CutomNothingView.h"

@implementation CutomNothingView
@synthesize notingLabel,notingImageView;

- (id)initWithFrame:(CGRect)frame boderHeigth:(float)boderHeigth labelHeight:(float)labelHeight imageHeight:(float)imageHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGRect imageViewRect = CGRectMake((frame.size.width-imageHeight)/2, (frame.size.height-imageHeight-labelHeight-boderHeigth)/2, imageHeight, imageHeight);
        self.notingImageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        [self.notingImageView setImage:[UIImage imageNamed:@"address_upload_bg.png"]];
        [self addSubview:self.notingImageView];
        
        CGRect notingRect = CGRectMake(0, imageViewRect.origin.y+imageHeight+boderHeigth, 320, labelHeight);
        self.notingLabel = [[UILabel alloc] initWithFrame:notingRect];
        [self.notingLabel setTextColor:[UIColor lightGrayColor]];
        [self.notingLabel setFont:[UIFont systemFontOfSize:18]];
        [self.notingLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.notingLabel];
        
        [self hiddenView];
    }
    return self;
}

-(void)hiddenView
{
    [self.notingImageView setHidden:YES];
    [self.notingLabel setHidden:YES];
    [self setHidden:YES];
}

-(void)notHiddenView
{
    [self.notingImageView setHidden:NO];
    [self.notingLabel setHidden:NO];
    [self setHidden:NO];
}

@end
