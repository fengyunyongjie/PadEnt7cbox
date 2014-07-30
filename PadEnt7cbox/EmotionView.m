//
//  EmotionView.m
//  tigerTalker
//
//  Created by hudie on 14-6-24.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import "EmotionView.h"
#import "FaceView.h"
@implementation EmotionView
@synthesize delegate,tvDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _faceView = [[FaceView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
        [self addSubview:_faceView];
        _faceView.hidden = NO;
        
    }
    return self;
}


-(void)setDelegate:(UITextField *)value{
    if(delegate != value){
        delegate = value;
        _faceView.delegate = delegate;
    }
}

- (void)setTvDelegate:(UITextView *)value {
    if (tvDelegate != value) {
        tvDelegate = value;
        _faceView.delegate = tvDelegate;
    }
}

@end
