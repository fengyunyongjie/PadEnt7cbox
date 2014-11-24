//
//  SubJectListTableViewCell.h
//  icoffer
//
//  Created by Yangsl on 14-7-7.
//  Copyright (c) 2014年  All rights reserved.
//

#import <UIKit/UIKit.h>

@class RedView;
@interface IPSubJectListTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *titleImage;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) RedView *redView;
@property(nonatomic, strong) UILabel *timeLabel;

-(void)updateCell:(NSDictionary *)diction;

@end


@interface RedView : UIView

@property(nonatomic, strong) UIImageView *bgImage;
@property(nonatomic, strong) UILabel *label;

-(void)updateNumber:(NSInteger)number;

@end
