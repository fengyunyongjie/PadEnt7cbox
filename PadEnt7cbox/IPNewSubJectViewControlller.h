//
//  NewSubJectViewControlller.h
//  icoffer
//
//  Created by hudie on 14-7-7.
//  Copyright (c) 2014年. All rights reserved.
//  新建专题

#import <UIKit/UIKit.h>
#import "IPSubjectUserListViewController.h"
#import "IPSCBSubJectManager.h"

@protocol NewSubJectDelegate <NSObject>

- (void)NewSubjectByName:(NSString *)subName subId:(NSString *)sub_id;

@end

@interface IPNewSubJectViewControlller : UIViewController<UITextFieldDelegate,SubUserListDelegate,SCBSubJectDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *subjectName;
@property (weak, nonatomic) IBOutlet UIButton    *addMemberBtn;
@property (weak, nonatomic) IBOutlet UIButton    *addContentBtn;
@property (weak, nonatomic) IBOutlet UILabel     *memberLabel;
@property (weak, nonatomic) IBOutlet UITextView  *infoTV;
@property (weak, nonatomic) IBOutlet UILabel     *desPlaceHolder;
@property (assign) id <NewSubJectDelegate> subDelegate;
@property (nonatomic, assign) BOOL isSending;

- (IBAction)addContact:(id)sender;
- (IBAction)selectAddMember:(id)sender;
- (IBAction)selectAddContent:(id)sender;

@end
