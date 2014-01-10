//
//  CustomJinDu.m
//  NetDisk
//
//  Created by Yangsl on 13-7-30.
//
//

#import "CustomJinDu.h"

#import <QuartzCore/QuartzCore.h>
#define BX 0

@implementation CustomJinDu
@synthesize backColor,currColor,currFloat,customSize,backLabel,currLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect backLabelRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        backLabel = [[UILabel alloc] initWithFrame:backLabelRect];
        [backLabel setTextColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
        [backLabel setFont:[UIFont systemFontOfSize:12]];
        backLabel.layer.masksToBounds = YES;
        backLabel.layer.cornerRadius = 2;
        
        CGRect currLabelRect = CGRectMake(BX, BX, 0, frame.size.height);
        [self addSubview:backLabel];
        
        currLabel = [[UIImageView alloc] initWithFrame:currLabelRect];
        currLabel.layer.masksToBounds = YES;
        currLabel.layer.cornerRadius = 2;
        [self addSubview:currLabel];
        [self setCurrColor:[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:230.0/255.0 alpha:1]];
    }
    return self;
}


-(void)setBackColor:(UIColor *)backColor_
{
    [backLabel setBackgroundColor:backColor_];
}

-(void)setCurrColor:(UIColor *)currColor_
{
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, 320, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [currColor_ CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [currLabel setImage:imge];
}

-(void)setCurrFloat:(float)currFloat_
{
    CGRect backLabelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [backLabel setFrame:backLabelRect];
    [backLabel setHidden:NO];
    [backLabel setText:nil];
    backLabel.layer.backgroundColor = [[UIColor grayColor] CGColor];
    [currLabel setHidden:NO];
    float width = currFloat_*self.frame.size.width;
    CGRect currLabelRect = CGRectMake(BX, BX, width, self.frame.size.height);
    [currLabel setFrame:currLabelRect];
}

-(void)showText:(NSString *)text
{
    [currLabel setHidden:YES];
    [backLabel setFont:[UIFont systemFontOfSize:12]];
    [backLabel setText:text];
    backLabel.layer.backgroundColor = [[UIColor clearColor] CGColor];
    CGRect backLabelRect = CGRectMake(0, -5, self.frame.size.width, 20);
    [backLabel setFrame:backLabelRect];
    [backLabel.layer setBorderWidth:0];
}

-(void)showDate:(NSString *)date
{
    [currLabel setHidden:YES];
    [backLabel setFont:[UIFont systemFontOfSize:11]];
    [backLabel setText:date];
    backLabel.layer.backgroundColor = [[UIColor clearColor] CGColor];
    CGRect backLabelRect = CGRectMake(0, -5, self.frame.size.width, 20);
    [backLabel setFrame:backLabelRect];
    [backLabel.layer setBorderWidth:0];
}

@end
