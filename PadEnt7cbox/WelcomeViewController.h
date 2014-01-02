//
//  WelcomeViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController
{
    CGFloat imageWidth;
    CGFloat imageHeigth;
}

@property(nonatomic,strong) UIScrollView *scroll_view;
@property(nonatomic,strong) UIPageControl *pageCtrl;
@property(nonatomic,strong) UIImageView *imageView1;
@property(nonatomic,strong) UIImageView *imageView2;
@property(nonatomic,strong) UIImageView *imageView3;
@property(nonatomic,strong) UIButton *hidden_button;

+(WelcomeViewController *)sharedUser;
-(void)showWelCome;
@end
