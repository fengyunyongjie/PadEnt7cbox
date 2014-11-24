//
//  CommentCell.m
//  icoffer
//
//  Created by hudie on 14-7-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPCommentCell.h"

#define Time1Min 60
#define Time1Hour 60*60
#define Time1Day 60*60*24
#define Time2Day 60*60*24*2

@implementation IPCommentCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSString *)getTimeFormat:(NSString *)browseTime
{
    NSString *formatString = nil;
    //时间显示方式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    double sDouble = [[dateFormatter dateFromString:browseTime] timeIntervalSince1970];
    //今天的时间
    NSDate *todayDate = [NSDate date];
    NSString *eString  = [dateFormatter stringFromDate:todayDate];
    double eDouble = [[dateFormatter dateFromString:eString] timeIntervalSince1970];
    
    //对比时间
    double mDouble = eDouble-sDouble;
    if(mDouble<Time1Min)
    {
        //1分钟内
        formatString = [NSString stringWithFormat:@"%i秒前",(int)mDouble];
    }
    else if(mDouble<Time1Hour)
    {
        //1小时内
        formatString = [NSString stringWithFormat:@"%i分钟前",(int)(mDouble/60)];
    }
    else if(mDouble<Time1Day)
    {
        //1天内
        formatString = [NSString stringWithFormat:@"%i小时前",(int)(mDouble/60/60)];
    }
    else if(mDouble<Time2Day)
    {
        //2天内
        formatString = [NSString stringWithFormat:@"1天前"];
    }
    else
    {
        formatString = browseTime;
    }
    return formatString;
}



@end
