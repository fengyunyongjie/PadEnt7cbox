//
//  ShareToSubjectViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-28.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "ShareToSubjectViewController.h"
#import "YNFunctions.h"
#import "SubjectListForChooseViewController.h"

@interface ShareToSubjectViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *resourceNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@end

@implementation ShareToSubjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int scale=[UIScreen mainScreen].scale;
    float lineWidth=1.0f/scale;
    
    self.commentTextView.layer.borderWidth=lineWidth;;
    self.commentTextView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    UIBarButtonItem *cancelItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    UIBarButtonItem *nextItem=[[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
    self.navigationItem.leftBarButtonItem=cancelItem;
    self.navigationItem.rightBarButtonItem=nextItem;
    
    NSDictionary *dic =self.dataDic;
    NSString *fname = [dic objectForKey:@"fname"];
    NSString *fisdir=[dic objectForKey:@"fisdir"];
    NSString *fmime=[[fname pathExtension] lowercaseString];
    
    self.resourceNameLabel.text=fname;
    
    if ([fisdir isEqualToString:@"0"]) {
        self.iconImageView.image=[UIImage imageNamed:@"file_folder.png"];
    }else
    if ([fmime isEqualToString:@"png"]||
        [fmime isEqualToString:@"jpg"]||
        [fmime isEqualToString:@"jpeg"]||
        [fmime isEqualToString:@"bmp"]||
        [fmime isEqualToString:@"gif"]){
        NSString *fthumb=[dic objectForKey:@"file_thumb"];
        NSString *localThumbPath=[YNFunctions getIconCachePath];
        fthumb =[YNFunctions picFileNameFromURL:fthumb];
        localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
            
            UIImage *icon=[UIImage imageWithContentsOfFile:localThumbPath];
            CGSize itemSize = CGSizeMake(100, 100);
            UIGraphicsBeginImageContext(itemSize);
            CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
            if (icon.size.width>icon.size.height) {
                theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                theR.origin.x=-(theR.size.width/2)-itemSize.width;
            }else
            {
                theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                theR.origin.y=-(theR.size.height/2)-itemSize.height;
            }
            CGRect imageRect = CGRectMake(0, 0, 100, 100);
            [icon drawInRect:imageRect];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.iconImageView.image = image;
        }else{
            self.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
            NSLog(@"将要下载的文件：%@",localThumbPath);
            //                [self startIconDownload:dic forIndexPath:indexPath];
        }
        
    }else if ([fmime isEqualToString:@"doc"]||
              [fmime isEqualToString:@"docx"]||
              [fmime isEqualToString:@"rtf"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
    }
    else if ([fmime isEqualToString:@"xls"]||
             [fmime isEqualToString:@"xlsx"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
    }else if ([fmime isEqualToString:@"mp3"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
    }else if ([fmime isEqualToString:@"mov"]||
              [fmime isEqualToString:@"mp4"]||
              [fmime isEqualToString:@"avi"]||
              [fmime isEqualToString:@"rmvb"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
    }else if ([fmime isEqualToString:@"pdf"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
    }else if ([fmime isEqualToString:@"ppt"]||
              [fmime isEqualToString:@"pptx"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
    }else if([fmime isEqualToString:@"txt"])
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
    }
    else
    {
        self.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 操作方法
-(void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextAction:(id)sender
{
    SubjectListForChooseViewController *s = [[SubjectListForChooseViewController alloc] init];
    s.parentSelectedIds = self.parentSelectedIds;
    s.fisdir = self.fisdir;
    s.commentString = self.commentTextView.text;
    [self.navigationController pushViewController:s animated:YES];
}

@end
