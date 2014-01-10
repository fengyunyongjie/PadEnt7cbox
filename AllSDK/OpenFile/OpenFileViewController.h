//
//  OpenFileViewController.h
//  PadEnt7cbox
//
//  Created by Yangsl on 14-1-8.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwonFile.h"

@interface OpenFileViewController : UIViewController<DownloaderDelegate>

@property (strong,nonatomic) UIImageView *fileImageView;
@property (strong,nonatomic) UILabel *fileNameLabel;
@property (strong,nonatomic) UIImageView *progess_imageView;
@property (strong,nonatomic) UIImageView *progess2_imageView;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) DwonFile *downImage;

@end
