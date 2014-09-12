//
//  NSString+Format.m
//  NetDisk
//
//  Created by Yangsl on 13-9-22.
//
//

#import "NSString+Format.h"
#import "YNFunctions.h"

#define Time1Min 60
#define Time1Hour 60*60
#define Time1Day 60*60*24
#define Time2Day 60*60*24*2

@implementation NSString (Format)

+(NSString *)formatNSStringForChar:(const char *)temp
{
    NSString *string;
    if(temp!=NULL)
    {
        string = [NSString stringWithUTF8String:temp];
    }
    else
    {
        string = @"";
    }
    return string;
}

+(NSString *)formatNSStringForOjbect:(NSObject *)object
{
    if(object ==nil || [object isEqual:@"<null>"] || [object isEqual:@"<NULL>"])
    {
        object = @"";
    }
    NSString *string = [NSString stringWithFormat:@"%@",object];
    return string;
}

//这个路径下是否存在此图片
+ (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}
//获取图片路径
+ (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

//这个路径下是否存在此图片
+ (BOOL)image_exists_FM_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:image_path];
}

+ (NSString*)get_image_FM_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

+(void)CreatePath:(NSString *)urlPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:urlPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:urlPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

+(NSDictionary *)stringWithDictionS:(NSString *)string
{
    //把字符串转化成字典类型
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dic;
}

+(NSString *)getTimeFormat:(NSString *)browseTime
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
    
    //计算今天的时间
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:[dateFormatter dateFromString:browseTime]];
    
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:[dateFormatter dateFromString:eString]];
    BOOL isToday = NO;
    if(todayComponent.year == component.year)
    {
        if(todayComponent.month == component.month)
        {
            if(todayComponent.week == component.week)
            {
                //今天
                if(todayComponent.weekday == component.weekday)
                {
                    isToday = YES;
                }
            }
        }
    }
    
    if(mDouble<0)
    {
        mDouble = 0;
    }
    if(mDouble<Time1Min)
    {
        //1分钟内
        formatString = [NSString stringWithFormat:@"1分钟前"];
    }
    else if(mDouble<Time1Hour)
    {
        //1小时内
        formatString = [NSString stringWithFormat:@"%i分钟前",(int)(mDouble/60)];
    }
    else if(isToday)
    {
        NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
        [dateFormatterNew setDateFormat:@"HH"];
        NSDate *dateNew = [dateFormatter dateFromString:browseTime];
        NSString *hour = [dateFormatterNew stringFromDate:dateNew];
        [dateFormatterNew setDateFormat:@"mm"];
        NSString *minute = [dateFormatterNew stringFromDate:dateNew];;
        formatString = [NSString stringWithFormat:@"今天 %@:%@",hour,minute];
    }
    else
    {
        formatString = [NSString formatDateString:browseTime];
    }
    return formatString;
}

+(NSString *)getAddressBookTimeFormat:(NSString *)browseTime
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
    
    //计算今天的时间
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:[dateFormatter dateFromString:browseTime]];
    
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:[dateFormatter dateFromString:eString]];
    BOOL isToday = NO;
    BOOL isYesterday = NO;
    if(todayComponent.year == component.year)
    {
        if(todayComponent.month == component.month)
        {
            if(todayComponent.week == component.week)
            {
                //今天
                if(todayComponent.day == component.day)
                {
                    isToday = YES;
                }
                else if(todayComponent.day == component.day+1)
                {
                    isYesterday = YES;
                }
            }
        }
    }
    
    if(mDouble<0)
    {
        mDouble = 0;
    }
    if(isToday)
    {
        NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
        [dateFormatterNew setDateFormat:@"HH"];
        NSDate *dateNew = [dateFormatter dateFromString:browseTime];
        NSString *hour = [dateFormatterNew stringFromDate:dateNew];
        [dateFormatterNew setDateFormat:@"mm"];
        NSString *minute = [dateFormatterNew stringFromDate:dateNew];;
        formatString = [NSString stringWithFormat:@"今天 %@:%@",hour,minute];
    }
    else if (isYesterday)
    {
        NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
        [dateFormatterNew setDateFormat:@"HH"];
        NSDate *dateNew = [dateFormatter dateFromString:browseTime];
        NSString *hour = [dateFormatterNew stringFromDate:dateNew];
        [dateFormatterNew setDateFormat:@"mm"];
        NSString *minute = [dateFormatterNew stringFromDate:dateNew];;
        formatString = [NSString stringWithFormat:@"昨天 %@:%@",hour,minute];
    }
    else
    {
        formatString = [NSString formatAddressBookDateString:browseTime];
    }
    return formatString;
}

+(CGFloat)getTextWidth:(NSString *)text andFont:(UIFont *)font
{
    //计算宽度
    UILabel *title_label = [[UILabel alloc] init];
    [title_label setFont:font];
    title_label.numberOfLines=0;
    [title_label setText:text];
    CGSize size = [title_label sizeThatFits:CGSizeMake(0, 20)];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    [title_label.text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    if(size.width>180)
    {
        size.width = 180;
    }
    return size.width;
}

+(CGFloat)getTitleWidth:(NSString *)text andFont:(UIFont *)font
{
    //计算宽度
    UILabel *title_label = [[UILabel alloc] init];
    [title_label setFont:font];
    title_label.numberOfLines=0;
    [title_label setText:text];
    CGSize size = [title_label sizeThatFits:CGSizeMake(0, 20)];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    [title_label.text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    if(size.width>150)
    {
        size.width = 150;
    }
    return size.width;
}

+(CGFloat)getNameWidth:(NSString *)text andFont:(UIFont *)font
{
    //计算宽度
    UILabel *title_label = [[UILabel alloc] init];
    [title_label setFont:font];
    title_label.numberOfLines=0;
    [title_label setText:text];
    CGSize size = [title_label sizeThatFits:CGSizeMake(0, 20)];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    [title_label.text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    if(size.width>60)
    {
        size.width = 60;
    }
    return size.width;
}

+(CGFloat)getTextHeigth:(NSString *)text andFont:(UIFont *)font
{
    //计算高度
    UILabel *title_label = [[UILabel alloc] init];
    [title_label setFont:font];
    title_label.lineBreakMode=NSLineBreakByWordWrapping;
    title_label.numberOfLines=0;
    [title_label setText:text];
    CGSize size = [title_label sizeThatFits:CGSizeMake(290, 20)];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    [title_label.text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    //    if(size.height>font.lineHeight*4)
    //    {
    //        size.height = font.lineHeight*4;
    //    }
    return size.height;
}

+(NSString *)formatDateString:(NSString *)dateString
{
    NSString *formatString = nil;
    //时间显示方式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    formatString = [dateFormatter stringFromDate:date];
    return formatString;
}

+(NSString *)formatAddressBookDateString:(NSString *)dateString
{
    NSString *formatString = nil;
    //时间显示方式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    formatString = [dateFormatter stringFromDate:date];
    return formatString;
}

@end
