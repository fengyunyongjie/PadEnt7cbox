//
//  SharedEmailViewController.h
//  ndspro
//
//  Created by fengyongning on 13-11-22.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"
#import "UserListViewController.h"
#import "SCBEmailManager.h"
#import "MainViewController.h"
#import "YNNavigationController.h"

typedef enum {
    kTypeShareIn,        //站内发送
    kTypeShareEx,        //站外发送
}ShareEmailType;

@interface FileView:UIControl
@property(assign,nonatomic) int index;
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)NSDictionary *dicData;
@property(strong,nonatomic)NSString *imagePath;
@property(strong,nonatomic)UIButton *addFileButton;
-(void)setDic:(NSDictionary *)dic;
@end;


@interface SharedEmailViewController : UIViewController<TITokenFieldDelegate, UITextViewDelegate,UserListViewDelegate>
@property (strong,nonatomic) NSMutableArray *fids;
@property (strong,nonatomic) NSMutableArray *fileArray;
@property (assign,nonatomic) ShareEmailType tyle;
@property (strong,nonatomic) SCBEmailManager *em;
@property (strong,nonatomic) NSArray *usrids;
@property (strong,nonatomic) NSArray *usernameList;
@property (strong,nonatomic) NSString *names;
@property (strong,nonatomic) NSArray *emails;

@end
