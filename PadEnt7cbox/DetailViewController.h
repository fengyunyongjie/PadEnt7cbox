//
//  DetailViewController.h
//  mdtest
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCBFileManager.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,SCBFileManagerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) NSMutableArray *splitView_array;
@property (nonatomic,assign) BOOL isFileManager;
@property (nonatomic,strong) UIBarButtonItem *downItem;
@property (nonatomic,strong) UIBarButtonItem *deleteItem;
@property (nonatomic,strong) UIBarButtonItem *fullItem;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) SCBFileManager *fm;

-(void)removeAllView;
-(void)showPhotoView:(NSString *)title withIsHave:(BOOL)isHaveDelete withIsHaveDown:(BOOL)isHaveDownload;
-(void)showOtherView:(NSString *)title withIsHave:(BOOL)isHaveDelete withIsHaveDown:(BOOL)isHaveDownload;
@end
