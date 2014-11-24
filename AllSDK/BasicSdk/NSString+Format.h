//
//  NSString+Format.h
//  NetDisk
//
//  Created by Yangsl on 13-9-22.
//
//

#import <Foundation/Foundation.h>

#define subject_detaiTableview_color [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]
#define subject_color [UIColor colorWithRed:54.0/255.0 green:116.0/255.0 blue:176.0/255.0 alpha:1.0]
#define subject_tableviewcell_color [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]

@interface NSString (Format)

+(NSString *)formatNSStringForChar:(const char *)temp;
+(NSString *)formatNSStringForOjbect:(NSObject *)object;
//这个路径下是否存在此图片
+ (BOOL)image_exists_at_file_path:(NSString *)image_path;
//获取图片路径
+ (NSString*)get_image_save_file_path:(NSString*)image_path;
+ (BOOL)image_exists_FM_file_path:(NSString *)image_path;
+ (NSString*)get_image_FM_file_path:(NSString*)image_path;
+(void)CreatePath:(NSString *)urlPath;
+(NSDictionary *)stringWithDictionS:(NSString *)string;
+(NSString *)getTimeFormat:(NSString *)browseTime;
+(NSString *)formatDateString:(NSString *)dateString;
+(NSString *)formatAddressBookDateString:(NSString *)dateString;
+(NSString *)getAddressBookTimeFormat:(NSString *)browseTime;
+(CGFloat)getTextWidth:(NSString *)text andFont:(UIFont *)font;
+(CGFloat)getTitleWidth:(NSString *)text andFont:(UIFont *)font;
+(CGFloat)getNameWidth:(NSString *)text andFont:(UIFont *)font;
+(CGFloat)getTextHeigth:(NSString *)text andFont:(UIFont *)font;
@end
