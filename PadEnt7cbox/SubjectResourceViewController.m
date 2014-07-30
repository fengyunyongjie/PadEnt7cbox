//
//  SubjectResourceViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SubjectResourceViewController.h"
#import "SubjectDetailTabBarController.h"
#import "SCBSubjectManager.h"
#import "NSString+Format.h"
#import "SubjectResourceCell.h"
#import "YNFunctions.h"
#import "ResourceCommentViewController.h"
#import "ResourceFinderViewController.h"
#import "DownList.h"
#import "PhotoLookViewController.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"

@interface SubjectResourceViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic,strong) NSArray *listArray;
@property (nonatomic,strong) SCBSubjectManager *sm_list;
@end

@implementation SubjectResourceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=[(SubjectDetailTabBarController *)self.tabBarController subjectTitle];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
}

-(void)viewDidLayoutSubviews
{
    self.tableView.frame=self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 操作方法
- (void)updateList
{
    self.sm_list=[SCBSubjectManager new];
    self.sm_list.delegate=self;
    [self.sm_list getResourceListWithSubjectId:[(SubjectDetailTabBarController *)self.tabBarController subjectId] resourceUserIds:@"" resourceType:@"" resourceTitil:@""];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SubjectResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SubjectResourceCell"  owner:self options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
    int commentCount=[[dic objectForKey:@"commentCount"] intValue];
    cell.resourceNameLabel.text=[dic objectForKey:@"file_name"];
    [cell.commentCountButton setTitle:[NSString stringWithFormat:@"%d",commentCount] forState:UIControlStateNormal];
    cell.personLabel.text=[dic objectForKey:@"username"];
    NSString *publishTime = [dic objectForKey:@"publishTime"];
    cell.detailLabel.text=[dic objectForKey:@"details"];
    cell.timeLabel.text=[NSString getTimeFormat:publishTime];
    
    NSString *fname = [dic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    
    int file_type = [[dic objectForKey:@"type"] intValue];
    if(file_type == 1) {
        cell.iconImageView.image = [UIImage imageNamed:@"file_folder.png"];
        cell.downloadButton.hidden=YES;
    }else if (file_type == 3) {//链接
        
        cell.iconImageView.image = [UIImage imageNamed:@"sub_link.png"];
        cell.resaveButton.hidden=YES;
        cell.downloadButton.hidden=YES;
    }else { //文件
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
                cell.iconImageView.image = image;
            }else{
                cell.iconImageView.image = [UIImage imageNamed:@"file_pic.png"];
                NSLog(@"将要下载的文件：%@",localThumbPath);
//                [self startIconDownload:dic forIndexPath:indexPath];
            }
            
        }else if ([fmime isEqualToString:@"doc"]||
                  [fmime isEqualToString:@"docx"]||
                  [fmime isEqualToString:@"rtf"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_word.png"];
        }
        else if ([fmime isEqualToString:@"xls"]||
                 [fmime isEqualToString:@"xlsx"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_excel.png"];
        }else if ([fmime isEqualToString:@"mp3"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_music.png"];
        }else if ([fmime isEqualToString:@"mov"]||
                  [fmime isEqualToString:@"mp4"]||
                  [fmime isEqualToString:@"avi"]||
                  [fmime isEqualToString:@"rmvb"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_moving.png"];
        }else if ([fmime isEqualToString:@"pdf"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_pdf.png"];
        }else if ([fmime isEqualToString:@"ppt"]||
                  [fmime isEqualToString:@"pptx"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_ppt.png"];
        }else if([fmime isEqualToString:@"txt"])
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_txt.png"];
        }
        else
        {
            cell.iconImageView.image = [UIImage imageNamed:@"file_other.png"];
        }
    }
    [cell.downloadButton addTarget:self action:@selector(downloadAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.resaveButton addTarget:self action:@selector(resaveAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(reviewAction:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
    NSString *fname = [dic objectForKey:@"file_name"];
    NSString *fmime = [[fname pathExtension] lowercaseString];
    
    int file_type = [[dic objectForKey:@"type"] intValue];
    if(file_type == 1) {
        //打开目录
        ResourceFinderViewController *finderViewController=[ResourceFinderViewController new];
        finderViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
        finderViewController.fID=[dic objectForKey:@"file_id"];
        finderViewController.title=[dic objectForKey:@"file_name"];
        [self.navigationController pushViewController:finderViewController animated:YES];
    }else if (file_type == 3) {//链接
        //打开链接
        NSString *urlString = [dic objectForKey:@"details"];
        if (![urlString hasPrefix:@"http://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }else {
        //打开文件
        if ([fmime isEqualToString:@"png"]||
            [fmime isEqualToString:@"jpg"]||
            [fmime isEqualToString:@"jpeg"]||
            [fmime isEqualToString:@"bmp"]||
            [fmime isEqualToString:@"gif"]){
            //打开图片
            DownList *list = [[DownList alloc] init];
            list.d_file_id = [dic objectForKey:@"file_id"];
            list.d_thumbUrl = [dic objectForKey:@"file_thumb"];
            if([list.d_thumbUrl length]==0)
            {
                list.d_thumbUrl = @"0";
            }
            list.d_name = [dic objectForKey:@"file_name"];
            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
            list.d_downSize = [[dic objectForKey:@"file_size"] intValue];
            
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            [tableArray addObject:list];
            if([tableArray count]>0)
            {
                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                [look setTableArray:tableArray];
                [self presentViewController:look animated:YES completion:nil];
            }
        }else
        {
            //打开其它文件
            NSString *fname=[dic objectForKey:@"file_name"];
            NSString *fid=[dic objectForKey:@"file_id"];
            NSString *documentDir = [YNFunctions getFMCachePath];
            NSArray *array=[fname componentsSeparatedByString:@"/"];
            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
            [NSString CreatePath:createPath];
            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                browser.dataSource=browser;
                browser.delegate=browser;
                browser.currentPreviewItemIndex=0;
                browser.title=fname;
                browser.filePath=savedPath;
                browser.fileName=fname;
                [self presentViewController:browser animated:YES completion:nil];
            } else {
                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                NSArray *values = [NSArray arrayWithObjects:fname,fid,[dic objectForKey:@"file_size"], nil];
                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                otherBrowser.dataDic=d;
                otherBrowser.title=fname;
                otherBrowser.dpDelegate=self;
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:otherBrowser];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)downloadAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
    }
}

- (void)resaveAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
    }
}

- (void)reviewAction:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    
    UITouch *touch =[touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        
        ResourceCommentViewController *resourceCommentViewController=[ResourceCommentViewController new];
        resourceCommentViewController.resourceID=[dic objectForKey:@"resource_id"];
        resourceCommentViewController.resourceDic=dic;
        resourceCommentViewController.subjectID=[(SubjectDetailTabBarController *)self.tabBarController subjectId];
        resourceCommentViewController.modalPresentationStyle=UIModalPresentationPageSheet;
        [self presentViewController:resourceCommentViewController animated:YES completion:nil];
    }
}

#pragma mark - SCBSubjectManagerDelegate
-(void)didGetResourceList:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    self.listArray=[datadic objectForKey:@"list"];
    [self.tableView reloadData];
}

#pragma mark -DownloadProgressDelegate
-(void)downloadFinished:(NSDictionary *)dataDic
{
    NSString *name = [dataDic objectForKey:@"fname"];
    NSString *fid = [dataDic objectForKey:@"fid"];
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[name componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
    [NSString CreatePath:createPath];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    
    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
    browser.dataSource=browser;
    browser.delegate=browser;
    browser.currentPreviewItemIndex=0;
    browser.title=name;
    browser.filePath=savedPath;
    browser.fileName=name;
    [self presentViewController:browser animated:NO completion:nil];
}
@end
