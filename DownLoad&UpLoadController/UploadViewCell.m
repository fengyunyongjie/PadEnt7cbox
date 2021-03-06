//
//  UploadViewCell.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#define UpdateHeigth 10
#define UpdateWidth 15

#import "UploadViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "YNFunctions.h"
#import "NSString+Format.h"

@implementation UploadViewCell
@synthesize button_dele_button,imageView,contentView,label_name;
@synthesize delegate,jinDuView,size_label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect image_rect = CGRectMake(5+UpdateHeigth, UpdateHeigth, 40, 40);
        self.imageView = [[UIImageView alloc] initWithFrame:image_rect];
        [self addSubview:self.imageView];
        
        CGRect label_rect = CGRectMake(60+UpdateWidth, 5+UpdateHeigth/2, 150, 20);
        self.label_name = [[UILabel alloc] initWithFrame:label_rect];
        [self.label_name setTextColor:[UIColor blackColor]];
        [self.label_name setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.label_name];
        
        CGRect progress_rect = CGRectMake(60+UpdateWidth, 30+UpdateHeigth/2, 150, 3);
        self.jinDuView = [[CustomJinDu alloc] initWithFrame:progress_rect];
        [self addSubview:self.jinDuView];
        
        CGRect sizeRect = CGRectMake(220+UpdateWidth, 25+UpdateHeigth/2, 70, 15);
        self.size_label = [[UILabel alloc] initWithFrame:sizeRect];
        [self.size_label setTextColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
        [self.size_label setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.size_label];
        
        CGRect button_rect = CGRectMake(270, 0, 50+UpdateHeigth, 50+UpdateHeigth);
        self.button_dele_button = [[UIButton alloc] initWithFrame:button_rect];
        [self.button_dele_button setBackgroundImage:[UIImage imageNamed:@"Bt_Cancle.png"] forState:UIControlStateNormal];
        [self.button_dele_button addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.button_dele_button];
        
//        CGRect start_rect = CGRectMake(270, 15, 40, 30);
//        self.button_start_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [self.button_start_button setFrame:start_rect];
//        [self.button_start_button setBackgroundColor:[UIColor clearColor]];
//        [self.button_start_button setTitle:@"暂停" forState:UIControlStateNormal];
//        [self.button_start_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.button_start_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [self.button_start_button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchDown];
//        [self addSubview:self.button_start_button];
//        [self.button_start_button setHidden:YES];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        [self.jinDuView.backLabel setTextColor:[UIColor blackColor]];
        [self.size_label setTextColor:[UIColor blackColor]];
    }
    else
    {
        [self.jinDuView.backLabel setTextColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
        [self.size_label setTextColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
    }
}

-(void)setUploadDemo:(UpLoadList *)list
{
    upload_list = list;
    down_list = nil;
    [self.size_label setText:[YNFunctions convertSize1:[NSString stringWithFormat:@"%i",(int)list.t_lenght]]];
    if(list.t_state == 1)
    {
        [self.jinDuView showDate:list.t_date];
    }
    else if(list.t_state == 0 || list.t_file_type == 5)
    {
        if(list.t_lenght == 0)
        {
            [self.jinDuView setCurrFloat:0];
        }
        else
        {
            float f = (float)list.upload_size / (float)list.t_lenght;
            [self.jinDuView setCurrFloat:f];
        }
    }
    else if(list.t_state == 2)
    {
        [self.jinDuView showText:@"暂停"];
    }
    else if(list.t_state == 3)
    {
        [self.jinDuView showText:@"等待WiFi"];
    }
    else if(list.t_state == 5)
    {
        [self.jinDuView showText:@"上传失败"];
    }
    else if(list.t_state == 6)
    {
        [self.jinDuView showText:@"上传失败，文件超过1GB"];
    }
    else if(list.t_state == 7)
    {
        [self.jinDuView showText:@"上传失败，目标目录不存在"];
    }
    else if(list.t_state == 8)
    {
        [self.jinDuView showText:@"上传失败，文件名过长"];
    }
    else if(list.t_state == 9)
    {
        [self.jinDuView showText:@"上传失败，文件名存在特殊字符"];
    }
    if(![self.label_name.text isEqualToString:list.t_name])
    {
        if(list.t_file_type == 5)
        {
            UIImage *imageV = [UIImage imageWithContentsOfFile:list.t_fileUrl];
            [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            if(!imageV)
            {
                NSString *fmime = list.t_fileUrl;
                fmime = [[fmime componentsSeparatedByString:@"/"] lastObject];
                NSRange range = [fmime rangeOfString:@"."];
                if(range.length>0)
                {
                    fmime = [[fmime substringFromIndex:range.location+1] lowercaseString];
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        imageV = [UIImage imageNamed:@"file_pic.png"];
                    }
                    else if ([fmime isEqualToString:@"doc"]||
                             [fmime isEqualToString:@"docx"])
                    {
                        imageV = [UIImage imageNamed:@"file_doc.png"];
                    }else if ([fmime isEqualToString:@"mp3"])
                    {
                        imageV = [UIImage imageNamed:@"file_music.png"];
                    }else if ([fmime isEqualToString:@"mov"])
                    {
                        imageV = [UIImage imageNamed:@"file_moving.png"];
                    }else if ([fmime isEqualToString:@"ppt"])
                    {
                        imageV = [UIImage imageNamed:@"file_other.png"];
                    }else
                    {
                        imageV = [UIImage imageNamed:@"file_other.png"];
                    }
                }
                else
                {
                    imageV = [UIImage imageNamed:@"file_other.png"];
                }
            }
            [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
        }
        else
        {
            ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
            [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result){
                UIImage *imageV = [UIImage imageWithCGImage:[result thumbnail]];
                if(!imageV)
                {
                    NSString *fmime = list.t_fileUrl;
                    fmime = [[fmime componentsSeparatedByString:@"/"] lastObject];
                    NSRange range = [fmime rangeOfString:@"."];
                    if(range.length>0)
                    {
                        fmime = [[fmime substringFromIndex:range.location+1] lowercaseString];
                        if ([fmime isEqualToString:@"png"]||
                            [fmime isEqualToString:@"jpg"]||
                            [fmime isEqualToString:@"jpeg"]||
                            [fmime isEqualToString:@"bmp"]||
                            [fmime isEqualToString:@"gif"])
                        {
                            imageV = [UIImage imageNamed:@"file_pic.png"];
                        }
                        else if ([fmime isEqualToString:@"doc"]||
                                 [fmime isEqualToString:@"docx"])
                        {
                            imageV = [UIImage imageNamed:@"file_doc.png"];
                        }else if ([fmime isEqualToString:@"mp3"])
                        {
                            imageV = [UIImage imageNamed:@"file_music.png"];
                        }else if ([fmime isEqualToString:@"mov"])
                        {
                            imageV = [UIImage imageNamed:@"file_moving.png"];
                        }else if ([fmime isEqualToString:@"ppt"])
                        {
                            imageV = [UIImage imageNamed:@"file_other.png"];
                        }else
                        {
                            imageV = [UIImage imageNamed:@"file_other.png"];
                        }
                    }
                    else
                    {
                        imageV = [UIImage imageNamed:@"file_other.png"];
                    }
                }
                [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            } failureBlock:^(NSError *error){}];
        }
    }
    [self.label_name setText:list.t_name];
}

-(void)setDownDemo:(DownList *)list
{
    down_list = list;
    upload_list = nil;
    [self.size_label setText:[YNFunctions convertSize1:[NSString stringWithFormat:@"%i",(int)list.d_downSize]]];
//    [self.sudu_label setText:[NSString stringWithFormat:@"%@/s",[YNFunctions convertSize:[NSString stringWithFormat:@"%i",list.sudu]]]];
    if(list.d_state == 1 || list.d_state == 4)
    {
        [self.jinDuView showDate:list.d_datetime];
    }
    else if(list.d_state == 0)
    {
        float f = (float)list.curr_size / (float)list.d_downSize;
        [self.jinDuView setCurrFloat:f];
    }
    else if(list.d_state == 2)
    {
        [self.jinDuView showText:@"暂停"];
    }
    else if(list.d_state == 3)
    {
        [self.jinDuView showText:@"等待WiFi"];
    }
    else if(list.d_state == 5)
    {
        [self.jinDuView showText:@"下载失败"];
    }
    if(![self.label_name.text isEqualToString:list.d_name])
    {
        NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
        NSString *localThumbPath=[YNFunctions getIconCachePath];
        fthumb =[YNFunctions picFileNameFromURL:fthumb];
        localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
        UIImage *imageV = [UIImage imageWithContentsOfFile:localThumbPath];
        if(!imageV)
        {
            NSString *fmime=[[list.d_name pathExtension] lowercaseString];
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"])
            {
                imageV = [UIImage imageNamed:@"file_pic.png"];
            }
            else if ([fmime isEqualToString:@"doc"]||
                [fmime isEqualToString:@"docx"]||
                [fmime isEqualToString:@"rtf"])
            {
                imageV = [UIImage imageNamed:@"file_word.png"];
            }
            else if ([fmime isEqualToString:@"xls"]||
                     [fmime isEqualToString:@"xlsx"])
            {
                imageV = [UIImage imageNamed:@"file_excel.png"];
            }else if ([fmime isEqualToString:@"mp3"])
            {
                imageV = [UIImage imageNamed:@"file_music.png"];
            }else if ([fmime isEqualToString:@"mov"]||
                      [fmime isEqualToString:@"mp4"]||
                      [fmime isEqualToString:@"avi"]||
                      [fmime isEqualToString:@"rmvb"])
            {
                imageV= [UIImage imageNamed:@"file_moving.png"];
            }else if ([fmime isEqualToString:@"pdf"])
            {
                imageV = [UIImage imageNamed:@"file_pdf.png"];
            }else if ([fmime isEqualToString:@"ppt"]||
                      [fmime isEqualToString:@"pptx"])
            {
                imageV = [UIImage imageNamed:@"file_ppt.png"];
            }else if([fmime isEqualToString:@"txt"])
            {
                imageV = [UIImage imageNamed:@"file_txt.png"];
            }else
            {
                imageV = [UIImage imageNamed:@"file_other.png"];
            }
        }
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
        
    }
    [self.label_name setText:list.d_name];
}

-(void)updateList
{
    if(down_list)
    {
        NSString *fthumb=[NSString formatNSStringForOjbect:down_list.d_thumbUrl];
        NSString *localThumbPath=[YNFunctions getIconCachePath];
        fthumb =[YNFunctions picFileNameFromURL:fthumb];
        localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
        UIImage *imageV = [UIImage imageWithContentsOfFile:localThumbPath];
        if(!imageV)
        {
            NSString *fmime=[[down_list.d_name pathExtension] lowercaseString];
            if ([fmime isEqualToString:@"doc"]|| [fmime isEqualToString:@"docx"])
            {
                imageV = [UIImage imageNamed:@"file_doc.png"];
            }else if ([fmime isEqualToString:@"mp3"])
            {
                imageV = [UIImage imageNamed:@"file_music.png"];
            }else if ([fmime isEqualToString:@"mov"])
            {
                imageV = [UIImage imageNamed:@"file_moving.png"];
            }else if ([fmime isEqualToString:@"ppt"])
            {
                imageV = [UIImage imageNamed:@"file_other.png"];
            }
            else
            {
                imageV = [UIImage imageNamed:@"file_other.png"];
            }
        }
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
    }
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(NSString *)getThumbPath:(NSString *)name
{
    NSString *documentDir = [YNFunctions getIconCachePath];
    NSArray *array=[name componentsSeparatedByString:@"/"];
    return [NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
}

-(NSString *)getFilePath:(NSString *)name
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[name componentsSeparatedByString:@"/"];
    return [NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
}

-(void)showTopBar
{
    
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)deleteSelf
{
    if(upload_list)
    {
        [delegate deletCell:upload_list];
    }
    else if(down_list)
    {
        [delegate deletCell:down_list];
    }
    
}

-(void)showEdit:(BOOL)bl
{
    if(bl)
    {
        [UIView animateWithDuration:0.15 animations:^{
            float y = 40;
            CGRect image_rect = CGRectMake(5+y+UpdateHeigth, UpdateHeigth, 40, 40);
            [self.imageView setFrame:image_rect];
            
            CGRect label_rect = CGRectMake(60+y+UpdateWidth, 5+UpdateHeigth/2, 150, 20);
            [self.label_name setFrame:label_rect];
            
            CGRect progress_rect = CGRectMake(60+y+UpdateWidth, 30+UpdateHeigth/2, 150, 3);
            [self.jinDuView setFrame:progress_rect];
            
            CGRect sizeRect = CGRectMake(220+y+UpdateWidth, 25+UpdateHeigth/2, 70, 15);
            [self.size_label setFrame:sizeRect];
            
            CGRect button_rect = CGRectMake(270+y, 0, 50+UpdateHeigth, 50+UpdateHeigth);
            [self.button_dele_button setFrame:button_rect];
            [self.button_dele_button setHidden:YES];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.15 animations:^{
            CGRect image_rect = CGRectMake(5+UpdateHeigth, UpdateHeigth, 40, 40);
            [self.imageView setFrame:image_rect];
            
            CGRect label_rect = CGRectMake(60+UpdateWidth, 5+UpdateHeigth/2, 150, 20);
            [self.label_name setFrame:label_rect];
            
            CGRect progress_rect = CGRectMake(60+UpdateWidth, 30+UpdateHeigth/2, 150, 3);
            [self.jinDuView setFrame:progress_rect];
            
            CGRect sizeRect = CGRectMake(220+UpdateWidth, 25+UpdateHeigth/2, 70, 15);
            [self.size_label setFrame:sizeRect];
            
            CGRect button_rect = CGRectMake(270, 0, 50+UpdateHeigth, 50+UpdateHeigth);
            [self.button_dele_button setFrame:button_rect];
            [self.button_dele_button setHidden:NO];
        }];
    }
}

@end
