//
//  ResourceCell.h
//  icoffer
//
//  Created by hudie on 14-7-10.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPResourceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *res_image;
@property (weak, nonatomic) IBOutlet UILabel     *res_name;
@property (weak, nonatomic) IBOutlet UILabel     *res_desc;
@property (weak, nonatomic) IBOutlet UIButton    *moreBtn;
@property (weak, nonatomic) IBOutlet UILabel     *username;
@property (weak, nonatomic) IBOutlet UILabel     *dateLabel;
-(NSString *)getTimeFormat:(NSString *)browseTime;

@end
