//
//  DetailViewController.h
//  mdtest
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) NSArray *splitView_array;

-(void)removeAllView;
-(void)showPhotoView:(BOOL)isHaveDelete;
-(void)showOtherView:(NSString *)title;

@end
