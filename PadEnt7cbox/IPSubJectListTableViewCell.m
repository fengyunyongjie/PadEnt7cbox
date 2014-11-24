//
//  SubJectListTableViewCell.m
//  icoffer
//
//  Created by Yangsl on 14-7-7.
//  Copyright (c) 2014年  All rights reserved.
//

#import "IPSubJectListTableViewCell.h"
#import "SCBSession.h"

@implementation IPSubJectListTableViewCell
@synthesize titleImage,titleLabel,redView,timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float height = self.frame.size.height;
        float width = self.frame.size.width;
        CGRect imageRect = CGRectMake(10, (height-20)/2, height-20, height-20);
        titleImage = [[UIImageView alloc] initWithFrame:imageRect];
        [self addSubview:titleImage];
        
        CGRect titleRect = CGRectMake(height-6, (height-(height-10))/2+3, 180, height-10);
        titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [titleLabel setText:@"时光，静静地，好像从未迈出脚步。故事，无声地，似乎从不曾被讲述。"];
        [self addSubview:titleLabel];
        
        float redHeight = 22*20/40;
        CGRect redRect = CGRectMake(titleRect.origin.x+titleRect.size.width-10, (height-redHeight)/2, 20, redHeight);
        redView = [[RedView alloc] initWithFrame:redRect];
        [self addSubview:redView];
        
        CGRect timeRect = CGRectMake(width-100-10, (height-35)/2+2, 100, 35);
        timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:15]];
        [self addSubview:timeLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

-(void)updateCell:(NSDictionary *)diction
{
    //显示cell内容
    NSString *name = [diction objectForKey:@"name"];
    if(name)
    {
        [self.titleLabel setText:name];
    }
    
    NSInteger subj_comment_sum = [[diction objectForKey:@"subj_comment_sum"] integerValue];
    [self.redView updateNumber:subj_comment_sum];
    NSString *happenTime = [diction objectForKey:@"happenTime"];
    if(happenTime)
    {
        [self.timeLabel setText:[NSString getTimeFormat:happenTime]];
    }
    NSString *closeTime = [diction objectForKey:@"closeTime"];
    if([closeTime length]>0)
    {
        [self.titleLabel setText:[NSString stringWithFormat:@"(已关闭)%@",self.titleLabel.text]];
        [self.titleLabel setTextColor:[UIColor grayColor]];
        [titleImage setImage:[UIImage imageNamed:@"closed.png"]];
    }
    else
    {
        [self.titleLabel setTextColor:[UIColor blackColor]];
        int isMaster = [[diction objectForKey:@"isMaster"] intValue];
        if(isMaster == 1)
        {
            [titleImage setImage:[UIImage imageNamed:@"mycreate.png"]];
        }
        else
        {
            [titleImage setImage:[UIImage imageNamed:@"myparticipant.png"]];
        }
    }
    
    CGRect titleRect = self.titleLabel.frame;
    titleRect.size.width = [NSString getTitleWidth:self.titleLabel.text andFont:self.titleLabel.font];
    [self.titleLabel setFrame:titleRect];
    
    CGRect redRect = self.redView.frame;
    redRect.origin.x = titleRect.origin.x+titleRect.size.width+5;
    [self.redView setFrame:redRect];
}

@end


@implementation RedView
@synthesize bgImage,label;

-(id)initWithFrame:(CGRect)frame
{
    float width = frame.size.width;
    float height = frame.size.height;
    self = [super initWithFrame:frame];
    CGRect imageRect = CGRectMake(0, 0, width, height);
    bgImage = [[UIImageView alloc] initWithFrame:imageRect];
    [bgImage setImage:[UIImage imageNamed:@"paopao.png"]];
    CGRect labelRect = CGRectMake(0, 0, width, height);
    label = [[UILabel alloc] initWithFrame:labelRect];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:9]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setLineBreakMode:NSLineBreakByTruncatingTail];
    [bgImage addSubview:label];
    [self addSubview:bgImage];
    return self;
}

-(void)updateNumber:(NSInteger)number
{
    //修改显示的动态个数
    if(number>0)
    {
        if(number>99)
        {
            [label setText:[NSString stringWithFormat:@"99+"]];
        }
        else
        {
            [label setText:[NSString stringWithFormat:@"%i",number]];
        }
        [bgImage setHidden:NO];
    }
    else
    {
        [label setText:@""];
        [bgImage setHidden:YES];
    }
}

@end