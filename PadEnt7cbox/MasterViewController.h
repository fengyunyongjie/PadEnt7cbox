//
//  MasterViewController.h
//  mdtest
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
