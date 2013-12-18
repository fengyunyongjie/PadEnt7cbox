//
//  SharedEmailViewController.h
//  ndspro
//
//  Created by fengyongning on 13-11-22.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenField.h"
@interface FileView:UIControl
@property(assign,nonatomic) int index;
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)NSDictionary *dicData;
@property(strong,nonatomic)NSString *imagePath;

-(void)setDic:(NSDictionary *)dic;
@end;


@interface SharedEmailViewController : UIViewController<TITokenFieldDelegate, UITextViewDelegate>
@property (strong,nonatomic) NSArray *fids;
@property (strong,nonatomic) NSArray *fileArray;
@end
