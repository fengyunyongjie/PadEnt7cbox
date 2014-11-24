//
//  SubjectDetailDynamicTableViewCell.h
//  icoffer
//
//  Created by Yangsl on 14-7-9.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubjectDetailDynamicTableViewCellDelegate <NSObject>

-(void)selectedCell:(NSDictionary *)dictioinary;

@end

@interface IPSubjectDetailDynamicTableViewCell : UITableViewCell

@property(nonatomic, strong) NSDictionary *dictionCell;
@property(nonatomic, weak) id<SubjectDetailDynamicTableViewCellDelegate> cellDelegate;

-(void)updateCell:(NSDictionary *)diction indexPath:(NSIndexPath *)indexPath;

+(float)getTableViewHeights:(NSDictionary *)diction;
+(NSInteger)getCurrTableViewCell:(NSDictionary *)diction;

@end
