//
//  SubjectDetailDynamicTableViewCell.m
//  icoffer
//
//  Created by Yangsl on 14-7-9.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "IPSubjectDetailDynamicTableViewCell.h"
#import "IPUnderLineLabel.h"
#import "NSString+Format.h"
#import "LookDownFile.h"
#import "YNFunctions.h"

@implementation IPSubjectDetailDynamicTableViewCell
@synthesize dictionCell,cellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)clearView
{
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    };
}

- (void)clickedDetail
{
    NSLog(@"进入详细页面:%@",dictionCell);
    [cellDelegate selectedCell:dictionCell];
}

- (void)updateCell:(NSDictionary *)diction indexPath:(NSIndexPath *)indexPath
{
    dictionCell = [NSDictionary dictionaryWithDictionary:diction];
    NSDictionary *content = [NSString stringWithDictionS:[diction objectForKey:@"content"]];
    NSInteger type = [[diction objectForKey:@"type"] integerValue];
    if(type == 0)
    {
        //仅发言
        [self addType0View:content indexPath:indexPath];
    }
    else if(type == 1 || type == 2 || type == 3 || type == 4 || type == 5)
    {
        //发言+资源
        [self addType2_5View:content indexPath:indexPath];
    }
    else if(type == 6)
    {
        //加入专题
        [self addType6View:content indexPath:indexPath];
    }
    else if(type == 6 || type == 7 || type == 7 || type == 9 || type == 10 || type == 11 || type == 12 || type == 13)
    {
        //信息一行搞定
        [self addType6_13View:content indexPath:indexPath];
    }
}

-(void)addType0View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为0的视图
    if(indexPath.row==0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getTextWidth:eveName andFont:[UIFont systemFontOfSize:16]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:@"说:"];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
        
    }
    else
    {
        NSString *eveContent = [content objectForKey:@"eveContent"];
        CGRect speakRect = CGRectMake(25, 5, 275, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [speakLabel setText:[NSString stringWithFormat:@"%@",eveContent]];
        [self addSubview:speakLabel];
    }
}

-(void)addType1View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为1的视图
    if(indexPath.row==0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getNameWidth:eveName andFont:[UIFont systemFontOfSize:16]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        NSString *eveTitle = [content objectForKey:@"eveTitle"];
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:eveTitle];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
    }
    else if(indexPath.row==1)
    {
        NSInteger count = [IPSubjectDetailDynamicTableViewCell getCurrTableViewCell:dictionCell];
        if(count==2)
        {
            [self.imageView setImage:[UIImage imageNamed:@"link.png"]];
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic = [eveFileUrl firstObject];
            
            NSString *urlTitle = [dic objectForKey:@"urlTitle"];
            CGRect nameRect = CGRectMake(60, 5, [NSString getNameWidth:urlTitle andFont:[UIFont systemFontOfSize:16]], 30);
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
            [nameLabel setFont:[UIFont systemFontOfSize:16]];
            [nameLabel setText:urlTitle];
            [nameLabel setTextColor:[UIColor blackColor]];
            [self addSubview:nameLabel];
            
            NSString *url = [dic objectForKey:@"url"];
            float urlX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
            CGRect urlRect = CGRectMake(urlX, 5, 300-urlX, 30);
            UILabel *urlLabel = [[UILabel alloc] initWithFrame:urlRect];
            [urlLabel setFont:[UIFont systemFontOfSize:14]];
            [urlLabel setText:url];
            [urlLabel setTextColor:[UIColor blueColor]];
            [self addSubview:urlLabel];
            self.backgroundColor = subject_tableviewcell_color;
        }
        else
        {
            NSString *eveContent = [content objectForKey:@"eveContent"];
            CGRect speakRect = CGRectMake(5, 5, 295, 30);
            UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
            [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [speakLabel setText:[NSString stringWithFormat:@"  %@",eveContent]];
            [self addSubview:speakLabel];
        }
    }
    else
    {
        [self.imageView setImage:[UIImage imageNamed:@"link.png"]];
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        NSDictionary *dic = [eveFileUrl firstObject];
        
        NSString *urlTitle = [dic objectForKey:@"urlTitle"];
        CGRect nameRect = CGRectMake(60, 5, [NSString getNameWidth:urlTitle andFont:[UIFont systemFontOfSize:16]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:urlTitle];
        [nameLabel setTextColor:[UIColor blackColor]];
        [self addSubview:nameLabel];
        
        NSString *url = [dic objectForKey:@"url"];
        float urlX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect urlRect = CGRectMake(urlX, 5, 300-urlX, 30);
        UILabel *urlLabel = [[UILabel alloc] initWithFrame:urlRect];
        [urlLabel setFont:[UIFont systemFontOfSize:14]];
        [urlLabel setText:url];
        [urlLabel setTextColor:[UIColor blueColor]];
        [self addSubview:urlLabel];
        self.backgroundColor = subject_tableviewcell_color;
    }
}

-(void)addType2_5View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为2-5的视图
    if(indexPath.row == 0)
    {
        NSString *eveName = [content objectForKey:@"eveName"];
        CGRect nameRect = CGRectMake(15, 5, [NSString getNameWidth:eveName andFont:[UIFont systemFontOfSize:16]], 30);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        [nameLabel setText:eveName];
        [nameLabel setTextColor:subject_color];
        [self addSubview:nameLabel];
        
        NSString *eveTitle = [content objectForKey:@"eveTitle"];
        float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
        CGRect speakRect = CGRectMake(speakX, 5, 100, 30);
        UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
        [speakLabel setTextColor:[UIColor grayColor]];
        [speakLabel setFont:[UIFont systemFontOfSize:15]];
        [speakLabel setText:eveTitle];
        [self addSubview:speakLabel];
        
        NSString *eveTime = [content objectForKey:@"eveTime"];
        CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
        [timeLabel setText:[NSString getTimeFormat:eveTime]];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:timeLabel];
    }
    else if(indexPath.row==1)
    {
        NSInteger count = [IPSubjectDetailDynamicTableViewCell getCurrTableViewCell:dictionCell];
        if(count==2)
        {
            NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
            NSDictionary *dic = [eveFileUrl firstObject];
            NSString *f_name = [dic objectForKey:@"f_name"];
            if([dic objectForKey:@"f_isdir"])
            {
                if([[dic objectForKey:@"f_isdir"] intValue] == 0)
                {
                    //文件夹
                    self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
                }
                else
                {
                    //文件
                    NSString *fmime=[[f_name pathExtension] lowercaseString];
                    
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"])
                    {
                        //下载图片
                        [self downLoadFile:dic];
                    }
                    else
                    {
                        [self updaTextImage:fmime];
                    }
                }
                //信息名称
                CGRect nameRect = CGRectMake(60, 5, 240, 30);
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
                [nameLabel setFont:[UIFont systemFontOfSize:16]];
                [nameLabel setText:f_name];
                [nameLabel setTextColor:[UIColor blackColor]];
                [self addSubview:nameLabel];
                self.backgroundColor = subject_tableviewcell_color;
            }
            else
            {
                [self addType1View:content indexPath:indexPath];
            }
        }
        else
        {
            int eventType = [[content objectForKey:@"eveType"] intValue];
            if (eventType == 1) {
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 27, 25)];
                imageV.image = [UIImage imageNamed:@"sub_yuyin_ico.png"];
                [self addSubview:imageV];
            } else {
                NSString *eveContent = [content objectForKey:@"eveContent"];
                CGRect speakRect = CGRectMake(25, 5, 275, 30);
                UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
                [speakLabel setFont:[UIFont boldSystemFontOfSize:14]];
                [speakLabel setText:[NSString stringWithFormat:@"%@",eveContent]];
                [self addSubview:speakLabel];
            }
            
        }
    }
    else
    {
        NSArray *eveFileUrl = [content objectForKey:@"eveFileUrl"];
        NSDictionary *dic = [eveFileUrl firstObject];
        NSString *f_name = [dic objectForKey:@"f_name"];
        if([dic objectForKey:@"f_isdir"])
        {
            if([[dic objectForKey:@"f_isdir"] intValue] == 0)
            {
                //文件夹
                self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
            }
            else
            {
                //文件
                NSString *fmime=[[f_name pathExtension] lowercaseString];
                
                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"])
                {
                    //下载图片
                    [self downLoadFile:dic];
                }
                else
                {
                    [self updaTextImage:fmime];
                }
            }
            
            //信息名称
            CGRect nameRect = CGRectMake(60, 5, 240, 30);
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
            [nameLabel setFont:[UIFont systemFontOfSize:16]];
            [nameLabel setText:f_name];
            [nameLabel setTextColor:[UIColor blackColor]];
            [self addSubview:nameLabel];
            self.backgroundColor = subject_tableviewcell_color;
        }
        else
        {
            [self addType1View:content indexPath:indexPath];
        }
    }
}

-(void)addType6View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为6的视图
    NSString *eveName = [dictionCell objectForKey:@"usr_turename"];
    CGRect nameRect = CGRectMake(15, 5, [NSString getNameWidth:eveName andFont:[UIFont systemFontOfSize:16]], 30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
    [nameLabel setFont:[UIFont systemFontOfSize:16]];
    [nameLabel setText:eveName];
    [nameLabel setTextColor:subject_color];
    [self addSubview:nameLabel];
    
    NSString *eveTitle = [content objectForKey:@"eveTitle"];
    float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
    CGRect speakRect = CGRectMake(speakX, 5, [NSString getTextWidth:eveTitle andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
    [speakLabel setTextColor:[UIColor grayColor]];
    [speakLabel setFont:[UIFont systemFontOfSize:15]];
    [speakLabel setText:eveTitle];
    [self addSubview:speakLabel];
    
//    //邀请成员
//    NSArray *object = [[content objectForKey:@"object"] componentsSeparatedByString:@" "];
//    NSString *toName = [object firstObject];
//    float toNameX = speakLabel.frame.origin.x+speakLabel.frame.size.width+5;
//    CGRect toNameRect = CGRectMake(toNameX, 5, [NSString getNameWidth:toName andFont:[UIFont systemFontOfSize:15]], 30);
//    UILabel *toNameLabel = [[UILabel alloc] initWithFrame:toNameRect];
//    [toNameLabel setTextColor:subject_color];
//    [toNameLabel setFont:[UIFont systemFontOfSize:15]];
//    [toNameLabel setText:toName];
//    [self addSubview:toNameLabel];
    
    //人数
    NSInteger number = [[content objectForKey:@"number"] integerValue];
    NSString *numberSting = [NSString stringWithFormat:@"%i人",number];
    float numberX = speakLabel.frame.origin.x+speakLabel.frame.size.width;
    CGRect numberRect = CGRectMake(numberX, 5, [NSString getTextWidth:numberSting andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:numberRect];
    [numberLabel setTextColor:subject_color];
    [numberLabel setFont:[UIFont systemFontOfSize:15]];
    [numberLabel setText:numberSting];
    [self addSubview:numberLabel];
    
    //操作行为
    NSString *action = [content objectForKey:@"action"];
    float actionX = numberRect.origin.x+numberRect.size.width+5;
    CGRect actionRect = CGRectMake(actionX, 5, [NSString getTextWidth:action andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *actionLabel = [[UILabel alloc] initWithFrame:actionRect];
    [actionLabel setTextColor:[UIColor grayColor]];
    [actionLabel setFont:[UIFont systemFontOfSize:15]];
    [actionLabel setText:action];
    [self addSubview:actionLabel];
    
//    NSString *subjectName = [content objectForKey:@"subjectName"];
//    float subjectX = actionRect.origin.x+actionRect.size.width+5;
//    CGRect subjectRect = CGRectMake(subjectX, 5, 100, 30);
//    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:subjectRect];
//    [subjectLabel setTextColor:[UIColor grayColor]];
//    [subjectLabel setFont:[UIFont systemFontOfSize:15]];
//    [subjectLabel setText:subjectName];
//    [self addSubview:subjectLabel];
    
    NSString *eveTime = [content objectForKey:@"eveTime"];
    CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
    [timeLabel setText:[NSString getTimeFormat:eveTime]];
    [timeLabel setTextColor:[UIColor grayColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:timeLabel];
}

-(void)addType6_13View:(NSDictionary *)content indexPath:(NSIndexPath *)indexPath
{
    //添加类型为6-13的视图
    NSString *eveName = [content objectForKey:@"eveName"];
    CGRect nameRect = CGRectMake(15, 5, [NSString getNameWidth:eveName andFont:[UIFont systemFontOfSize:16]], 30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
    [nameLabel setFont:[UIFont systemFontOfSize:16]];
    [nameLabel setText:eveName];
    [nameLabel setTextColor:subject_color];
    [self addSubview:nameLabel];
    
    NSString *eveTitle = [content objectForKey:@"eveTitle"];
    if([eveTitle isEqualToString:@"将专题权限设置为"])
    {
        NSLog(@"content:%@",content);
    }
    //投机取巧，根据关键字查看是否有权限修改的描述
    BOOL bl = NO;
    NSString *subjectAuth = [content objectForKey:@"subjectAuth"];
    if(![subjectAuth isEqual:[NSNull null]])
    {
        NSString *selectString1 = @"不允许";
        NSString *selectString2 = @"共享";
        NSString *selectString3 = @"邀请新成员";
        NSString *selectString4 = @"允许";
        if([subjectAuth rangeOfString:selectString1].length>0)
        {
            if([subjectAuth rangeOfString:selectString2].length>0)
            {
                eveTitle = @"设置专题不允许共享内容";
            }
            else if([subjectAuth rangeOfString:selectString3].length>0)
            {
                eveTitle = @"设置专题不允许邀请新成员";
                bl = YES;
            }
        }
        else if([subjectAuth rangeOfString:selectString4].length>0)
        {
            if([subjectAuth rangeOfString:selectString2].length>0)
            {
                eveTitle = @"设置专题允许共享内容";
            }
            else if([subjectAuth rangeOfString:selectString3].length>0)
            {
                eveTitle = @"设置专题允许邀请新成员";
            }
        }
    }
    float speakX = nameLabel.frame.origin.x+nameLabel.frame.size.width+5;
    CGRect speakRect = CGRectMake(speakX, 5, [NSString getTextWidth:eveTitle andFont:[UIFont systemFontOfSize:15]], 30);
    UILabel *speakLabel = [[UILabel alloc] initWithFrame:speakRect];
    [speakLabel setTextColor:[UIColor grayColor]];
    [speakLabel setFont:[UIFont systemFontOfSize:15]];
    [speakLabel setText:eveTitle];
    [self addSubview:speakLabel];
    
//    NSString *subjectName = [content objectForKey:@"subjectName"];
//    float subjectX = speakRect.origin.x+speakRect.size.width+5;
//    CGRect subjectRect = CGRectMake(subjectX, 5, 100, 30);
//    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:subjectRect];
//    [subjectLabel setTextColor:[UIColor grayColor]];
//    [subjectLabel setFont:[UIFont systemFontOfSize:15]];
//    [subjectLabel setText:subjectName];
//    [self addSubview:subjectLabel];
    
    NSString *eveTime = [content objectForKey:@"eveTime"];
    CGRect timeRect = CGRectMake(320-135, 5, 120, 30);
    if(bl)
    {
        timeRect.origin.x += 5;
    }
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
    [timeLabel setText:[NSString getTimeFormat:eveTime]];
    [timeLabel setTextColor:[UIColor grayColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:timeLabel];
}

+(float)getTableViewHeights:(NSDictionary *)diction
{
    float height = 40;
    return height;
}

+(NSInteger)getCurrTableViewCell:(NSDictionary *)diction
{
    NSInteger count = 0;
    NSInteger type = [[diction objectForKey:@"type"] integerValue];
    NSDictionary *content = [NSString stringWithDictionS:[diction objectForKey:@"content"]];
    BOOL evenContentBl = NO;
    NSString *eveContent = [content objectForKey:@"eveContent"];
    if([eveContent length]>0 && ![eveContent isEqualToString:@"(null)"] && ![eveContent isEqual:[NSNull null]])
    {
        evenContentBl = YES;
    }
    if(type==0)
    {
        count = 2;
    }
    else if(type==1 || type==2 || type==3 || type==4 || type==5)
    {
        count = 2;
        if(evenContentBl)
        {
            count = 3;
        }
    }
    else if(type==6 || type==7 || type==8 || type==9 || type==10 || type==11 || type==12 || type==13)
    {
        count = 1;
    }
    return count;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(UIImage *)getImageForEM:(NSString *)emName
{
    NSRange range = [emName rangeOfString:@"_"];
    if(range.length>0)
    {
        emName = [emName substringFromIndex:range.location];
        emName = [emName substringToIndex:emName.length-1];
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"%i.gif",(int)emName]];
}

-(void)updaTextImage:(NSString *)fmime
{
    if ([fmime isEqualToString:@"doc"]||
        [fmime isEqualToString:@"docx"]||
        [fmime isEqualToString:@"rtf"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_txt.png"];
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"file_other.png"];
    }
}

- (void)downLoadFile:(NSDictionary *)diction
{
    //下载图片
    NSString *f_id = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_id"]];
    NSString *f_name = [NSString stringWithFormat:@"%@",[diction objectForKey:@"f_name"]];
    
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[f_name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
    [NSString CreatePath:createPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    BOOL bl;
    bl = [NSString image_exists_FM_file_path:path];
    if(bl)
    {
        if([UIImage imageWithContentsOfFile:path])
        {
            [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.imageView];
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
        }
        return;
    }
    else
    {
        documentDir = [YNFunctions getProviewCachePath];
        createPath = [NSString stringWithFormat:@"%@/%@",documentDir,f_id];
        [NSString CreatePath:createPath];
        path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        //查询本地是否已经有该图片
        bl = [NSString image_exists_at_file_path:path];
        if(bl)
        {
            if([UIImage imageWithContentsOfFile:path])
            {
                [self formatPhoto:[UIImage imageWithContentsOfFile:path] imageView:self.imageView];
            }
            else
            {
                self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
            }
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
            LookDownFile *downImage = [[LookDownFile alloc] init];
            [downImage setFile_id:f_id];
            [downImage setFileName:f_name];
            [downImage setImageViewIndex:self.imageView.tag];
            [downImage setIndexPath:nil];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
}

-(void)formatPhoto:(UIImage *)image imageView:(UIImageView *)textImageView
{
    UIImage *imageS = nil;
    UIImage *imageV = image;
    float width=100;
    if(imageV.size.width>=imageV.size.height)
    {
        if(imageV.size.height<=width)
        {
            CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.height = width;
            newImageSize.width = width*imageV.size.width/imageV.size.height;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake((newImageSize.width-width)/2, 0, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else if(imageV.size.width<=imageV.size.height)
    {
        if(imageV.size.width<=width)
        {
            CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
            imageS = [self imageFromImage:imageV inRect:imageRect];
        }
        else
        {
            CGSize newImageSize;
            newImageSize.width = width;
            newImageSize.height = width*imageV.size.height/imageV.size.width;
            imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake(0, (newImageSize.height-width)/2, width, width);
            imageS = [self imageFromImage:imageS inRect:imageRect];
        }
    }
    else
    {
        imageS = image;
    }
    [textImageView performSelectorInBackground:@selector(setImage:) withObject:imageS];
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - LookFileDelegate

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    self.imageView.image = [UIImage imageWithContentsOfFile:path];
}

- (void)downFinish:(NSString *)baseUrl
{
    
}

-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    
}

-(void)didFailWithError
{
    
}


@end
