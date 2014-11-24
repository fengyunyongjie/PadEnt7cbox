//
//  SendToSubJectViewController.h
//  icoffer
//
//  Created by Yangsl on 14-7-14.
//  Copyright (c) 2014年  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpLoadList.h"
#import "MBProgressHUD.h"

#define textBoder_color [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0]

typedef enum{
    SendToAlertTagNewLink,
    SendToAlertTagDelete,
}SendToAlertTag;

@interface IPSendToSubJectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextViewDelegate,UITextFieldDelegate>

@property(nonatomic, strong) NSDictionary *baseDiction;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *tableArray;
@property(nonatomic, strong) UIButton *touchButton;
@property(nonatomic, strong) UITextView *commentTextView;
@property(nonatomic, strong) UIControl *bottonControl;
@property(nonatomic, strong) UIButton *addButton;
@property(nonatomic, strong) UIButton *photoButton;
@property(nonatomic, strong) UIButton *myFileButton;
@property(nonatomic, strong) UIButton *linkButton;
@property(nonatomic, strong) UIButton *editView;
@property(nonatomic, strong) UpLoadList *selectedList;
@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, strong) MBProgressHUD *hud;
@property(nonatomic, assign) BOOL isSending;
@end


@interface TextButton : UIButton

@property(nonatomic, strong) UIImageView *topImage;
@property(nonatomic, strong) UILabel *bottonLabel;

@end


@interface SendToTableViewCell : UITableViewCell

@property(strong, nonatomic) UIImageView *logoIimageV;
@property(strong, nonatomic) UIButton *accessoryButton;
@property(strong, nonatomic) UpLoadList *list;
@property(strong, nonatomic) NSIndexPath *selectedIndexpath;

-(void)updateCeleView:(UpLoadList *)loadList indexPath:(NSIndexPath *)indexPath;

@end