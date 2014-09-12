//
//  CutomNothingView.h
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutomNothingView : UIView

@property(strong,nonatomic) UILabel *notingLabel;
@property(strong,nonatomic) UIImageView *notingImageView;

- (id)initWithFrame:(CGRect)frame boderHeigth:(float)boderHeigth labelHeight:(float)labelHeight imageHeight:(float)imageHeight;

-(void)hiddenView;
-(void)notHiddenView;

@end
