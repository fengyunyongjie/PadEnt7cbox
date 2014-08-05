//
//  SubjectDetailTabBarController.h
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-4.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectDetailTabBarController : UITabBarController
@property (nonatomic,strong) NSString *subjectId;
@property (nonatomic,strong) NSString *subjectTitle;
@property (nonatomic,assign) BOOL isPublish;
@end
