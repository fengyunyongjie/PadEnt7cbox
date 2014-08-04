//
//  ResourceCommentViewController.h
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-28.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectResourceViewController.h"

@interface ResourceCommentViewController : UIViewController
@property (strong,nonatomic)NSString *resourceID;
@property (strong,nonatomic)NSString *subjectID;
@property (strong,nonatomic)NSDictionary *resourceDic;
@property (weak,nonatomic) SubjectResourceViewController *delegate;
@end
