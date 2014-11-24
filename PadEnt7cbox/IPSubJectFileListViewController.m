//
//  SubJectFileListViewController.m
//  icoffer
//
//  Created by hudie on 14-7-18.
//  Copyright (c) 2014年. All rights reserved.
//

#import "IPSubJectFileListViewController.h"
#import "YNFunctions.h"
#import "DownList.h"
#import "PhotoLookViewController.h"
#import "QLBrowserViewController.h"
#import "OtherBrowserViewController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "MainViewController.h"
#import "YNNavigationController.h"
#import "UIBarButtonItem+Yn.h"
#import "MBProgressHUD.h"


@interface IPSubJectFileListViewController () {
    UIToolbar   *moreEditBar;
    NSIndexPath *selectedIndexPath;
    UIControl   *singleBg;
}
@property (nonatomic, retain) MBProgressHUD *hud;


@end

@implementation IPSubJectFileListViewController
@synthesize type;

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
    [self updateFileList];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    if (self.type==SJSelectTypeChangeFileOrFolder) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dissmissSelf:)]];
    }
}

-(void)dissmissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)updateFileList {
    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    [sm getResouceFileWithSubjectId:self.subId f_id:self.fId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
        if (self.listArray.count>0) {
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        }else
        {
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        return self.listArray.count;
    }
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(80, 5, 200, 21)];
        UILabel *detailTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 21)];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:detailTextLabel];
        imageView.tag=1;
        textLabel.tag=2;
        detailTextLabel.tag=3;
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [detailTextLabel setTextColor:[UIColor grayColor]];
       
    }
    
    //修改accessoryType
    UIButton *accessory=[[UIButton alloc] init];
    [accessory setFrame:CGRectMake(5, 5, 40, 40)];
    [accessory setTag:indexPath.row];
    [accessory setImage:[UIImage imageNamed:@"sel_nor.png"] forState:UIControlStateNormal];
    [accessory setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateHighlighted];
    [accessory setImage:[UIImage imageNamed:@"sel_se.png"] forState:UIControlStateSelected];
    [accessory  addTarget:self action:@selector(accessoryButtonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=accessory;
    
    
    UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailTextLabel=(UILabel *)[cell.contentView viewWithTag:3];
    
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        cell.imageView.transform=CGAffineTransformMakeScale(1.0f,1.0f);
        if (dic) {
            textLabel.text=[dic objectForKey:@"file_name"];
            NSString *fisdir=[dic objectForKey:@"type"];
            int isPublish = [[dic objectForKey:@"isPublisher"] intValue];

            if (fisdir.intValue == 1) {
                //detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"details"]];
                imageView.image=[UIImage imageNamed:@"file_folder.png"];
                detailTextLabel.hidden = YES;
                if (isPublish == 1) {
                    cell.accessoryView.hidden = YES;
                } else {
                    cell.accessoryView.hidden = NO;
                }
                textLabel.frame = CGRectMake(80, 18, 200, 21);

            }else
            {
                cell.accessoryView.hidden = NO;
                detailTextLabel.hidden = NO;
                textLabel.frame = CGRectMake(80, 5, 200, 21);

                imageView.image=[UIImage imageNamed:@"file_other.png"];
                NSString *filesize=[dic objectForKey:@"file_size"];
                if (filesize.intValue==0) {
                    detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"details"]];
                }else
                {
                    detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"details"]];
                }
                
                NSString *fmime=[dic objectForKey:@"file_mime"];
               fmime = [fmime lowercaseString];


                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"])
                {
                    NSString *fthumb=[dic objectForKey:@"file_thumb"];
                    NSString *localThumbPath=[YNFunctions getIconCachePath];
                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                    NSLog(@"是否存在文件：%@",localThumbPath);
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                        NSLog(@"存在文件：%@",localThumbPath);
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
                        imageView.image = image;
                    }else{
                        imageView.image = [UIImage imageNamed:@"file_pic.png"];
                        NSLog(@"将要下载的文件：%@",localThumbPath);
                        [self startIconDownload:dic forIndexPath:indexPath];
                        
                    }
                }else if ([fmime isEqualToString:@"doc"]||
                          [fmime isEqualToString:@"docx"]||
                          [fmime isEqualToString:@"rtf"])
                {
                    imageView.image = [UIImage imageNamed:@"file_word.png"];
                }
                else if ([fmime isEqualToString:@"xls"]||
                         [fmime isEqualToString:@"xlsx"])
                {
                    imageView.image = [UIImage imageNamed:@"file_excel.png"];
                }else if ([fmime isEqualToString:@"mp3"])
                {
                    imageView.image = [UIImage imageNamed:@"file_music.png"];
                }else if ([fmime isEqualToString:@"mov"]||
                          [fmime isEqualToString:@"mp4"]||
                          [fmime isEqualToString:@"avi"]||
                          [fmime isEqualToString:@"rmvb"])
                {
                    imageView.image = [UIImage imageNamed:@"file_moving.png"];
                }else if ([fmime isEqualToString:@"pdf"])
                {
                    imageView.image = [UIImage imageNamed:@"file_pdf.png"];
                }else if ([fmime isEqualToString:@"ppt"]||
                          [fmime isEqualToString:@"pptx"])
                {
                    imageView.image = [UIImage imageNamed:@"file_ppt.png"];
                }else if([fmime isEqualToString:@"txt"])
                {
                    imageView.image = [UIImage imageNamed:@"file_txt.png"];
                }
                else
                {
                    imageView.image = [UIImage imageNamed:@"file_other.png"];
                }
                
            }
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (self.listArray)
   {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic)
        {
            NSString *fisdir=[dic objectForKey:@"type"];
            NSString *fname = [dic objectForKey:@"file_name"];
            NSString *fmime=[dic objectForKey:@"file_mime"];
            if (![fmime isEqual:[NSNull null]]) {
                fmime = [fmime lowercaseString];
            }
            if (fisdir.intValue == 1)
            {
                IPSubJectFileListViewController *flVC=[[IPSubJectFileListViewController alloc] init];
                    flVC.title=[dic objectForKey:@"file_name"];
                flVC.subId = self.subId;
                flVC.fId = [dic objectForKey:@"file_id"];
                    [self.navigationController pushViewController:flVC animated:YES];
            }
            else if ([fmime isEqualToString:@"png"]||
                     [fmime isEqualToString:@"jpg"]||
                     [fmime isEqualToString:@"jpeg"]||
                     [fmime isEqualToString:@"bmp"]||
                     [fmime isEqualToString:@"gif"])
            {
                int row = 0;
                if(indexPath.row<[self.listArray count])
                {
                    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                    for(int i=0;i<[self.listArray count];i++) {
                        NSDictionary *diction = [self.listArray objectAtIndex:i];
                        NSString *fname_ = [diction objectForKey:@"file_name"];
                                                  
                        if(([fmime isEqualToString:@"png"]||
                                                                            [fmime isEqualToString:@"jpg"]||
                                                                            [fmime isEqualToString:@"jpeg"]||
                                                                            [fmime isEqualToString:@"bmp"]||
                                                                            [fmime isEqualToString:@"gif"]))
                        {
                            DownList *list = [[DownList alloc] init];
                            list.d_file_id = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_id"]];
                            list.d_thumbUrl = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_thumb"]];
                            if([list.d_thumbUrl length]==0)
                            {
                                list.d_thumbUrl = @"0";
                            }
                            list.d_name = [NSString formatNSStringForOjbect:[diction objectForKey:@"file_name"]];
                            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
                            list.d_downSize = [[diction objectForKey:@"file_size"] integerValue];
                            [tableArray addObject:list];
                            if(row==0 && [fname isEqualToString:fname_])
                            {
                                row = [tableArray count]-1;
                            }
                        }
                    }
                    if([tableArray count]>0)
                    {
                        PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                        [look setCurrPage:row];
                        [look setTableArray:tableArray];
                        //look.isHaveDelete = YES;
//                        look.isHaveDownload=YES;
                       
                        [self presentViewController:look animated:YES completion:^{
                            [[UIApplication sharedApplication] setStatusBarHidden:YES];
                        }];
                    }
                }
            }
            else
            {
                NSString *file_id=[dic objectForKey:@"file_id"];
                NSString *f_name=[dic objectForKey:@"file_name"];
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSArray *array=[f_name componentsSeparatedByString:@"/"];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
                [NSString CreatePath:createPath];
                NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                    browser.dataSource=browser;
                    browser.delegate=browser;
                    browser.title=f_name;
                    browser.filePath=savedPath;
                    browser.fileName=f_name;
                    browser.currentPreviewItemIndex=0;
                    [self presentViewController:browser animated:YES completion:nil];
                }else
                {
                    OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                    otherBrowser.dataDic=dic;
                    NSString *f_name=[dic objectForKey:@"file_name"];
                    otherBrowser.title=f_name;
                    [self presentViewController:otherBrowser animated:YES completion:nil];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)accessoryButtonPressedAction: (id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:button.tag inSection:0];
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath=indexPath;
    if (!singleBg) {
        
        singleBg=[[UIControl alloc] initWithFrame:CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height)];
        [singleBg addTarget:self action:@selector(hideSingleBar) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:singleBg];
    }
    [singleBg setHidden:NO];
    singleBg.frame=CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.contentSize.height);
    
    int CellHeight=60;
    if (!moreEditBar) {
        [moreEditBar setBarTintColor:[UIColor blueColor]];
        moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, CellHeight)];
        [moreEditBar setBackgroundImage:[UIImage imageNamed:@"bk_select.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [moreEditBar setBarStyle:UIBarStyleBlackOpaque];
        
        
        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_selectTop.png"]];
        [jiantou setFrame:CGRectMake(280, -6, 10, 6)];
        [jiantou setTag:2012];
        [moreEditBar addSubview:jiantou];
    }
    [self.tableView addSubview:moreEditBar];
    [self.tableView bringSubviewToFront:moreEditBar];
    [moreEditBar setHidden:NO];
    CGRect r=moreEditBar.frame;
    
    r.origin.y=(indexPath.row+1) * CellHeight;
    if (r.origin.y+r.size.height>self.tableView.frame.size.height &&r.origin.y+r.size.height > self.tableView.contentSize.height) {
        r.origin.y=(indexPath.row+1)*CellHeight-(r.size.height *2);
        UIImageView *imageView=(UIImageView *)[moreEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, -1.0);
        imageView.frame=CGRectMake(280, CellHeight, 10, 6);
    }else
    {
        UIImageView *imageView=(UIImageView *)[moreEditBar viewWithTag:2012];
        imageView.transform=CGAffineTransformMakeScale(1.0, 1.0);
        imageView.frame=CGRectMake(280, -6, 10, 6);
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
        NSLog(@"Rect:%@\n SuperView:%@",NSStringFromCGRect(rectInSuperview),NSStringFromCGRect([tableView.superview frame]));
        if (rectInSuperview.origin.y+(rectInSuperview.size.height*2)>([tableView superview].frame.size.height+[tableView superview].frame.origin.y)-49-64) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        
    }

    moreEditBar.frame=r;
    //下载 转存 预览
    UIButton *btn_download ,*btn_resave,*btn_look;
    UIBarButtonItem *item_download,*item_resave, *item_look, *item_flexible;
    int btnWidth=40;
    //下载
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
    [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
    [btn_download addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    //转存
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 39)];
    [btn_resave setImage:[UIImage imageNamed:@"sub_bt_copy_nor.png"] forState:UIControlStateNormal];
    [btn_resave setImage:[UIImage imageNamed:@"sub_bt_copy_sel.png"] forState:UIControlStateHighlighted];
    [btn_resave addTarget:self action:@selector(resaveAction) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    //预览
    btn_look =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 39)];
    [btn_look setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
    [btn_look setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
    [btn_look addTarget:self action:@selector(lookAction) forControlEvents:UIControlEventTouchUpInside];
    item_look=[[UIBarButtonItem alloc] initWithCustomView:btn_look];
    
    item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
//    int fileType = [[dic objectForKey:@"type"] intValue];
//    
//    //文件夹
//    if (fileType == 1) {
//        
//        [moreEditBar setItems:@[item_download,item_flexible,item_resave]];
//        
//    } else {//文件
//        [moreEditBar setItems:@[item_download,item_flexible,item_look,item_flexible,item_resave]];
//    }
    
    NSDictionary *d = [self.listArray objectAtIndex:indexPath.row];
    int isPublish = [[d objectForKey:@"isPublisher"] intValue];
    NSString *fisdir=[d objectForKey:@"type"];
    if (fisdir.intValue == 1) {
        if (isPublish != 1) {
            [moreEditBar setItems:@[item_resave]];
        }
    } else {
        if (isPublish == 1) {
            [moreEditBar setItems:@[item_download]];
        } else {
            [moreEditBar setItems:@[item_download,item_flexible,item_resave]];
        }
    }
}


- (void)loadImagesForOnscreenRows
{
    if ([self.listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
            if (dic==nil) {
                break;
            }
            NSString *fmime=[dic objectForKey:@"file_mime"];
            if ([fmime isEqual:[NSNull null]]) {
                return;
            }else {
                fmime = [fmime lowercaseString];
            }
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"]){
                
                NSString *compressaddr=[dic objectForKey:@"file_thumb"];
                assert(compressaddr!=nil);
                compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
                NSString *path=[YNFunctions getIconCachePath];
                path=[path stringByAppendingPathComponent:compressaddr];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    NSLog(@"将要下载的文件：%@",path);
                    [self startIconDownload:dic forIndexPath:indexPath];
                }
            }
        }
    }
}
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imageDownloadsInProgress) {
        self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    }
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"取消全选"]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}


- (void)getResourceFileSuccess:(NSDictionary *)dic {
    self.listArray = [dic objectForKey:@"list"];
    [self.tableView reloadData];
}

- (void)getResourceFileUnsuccess:(NSString *)error_info {
    
}

//预览
- (void)lookAction {
    NSDictionary *fiel_dic = [self.listArray objectAtIndex:selectedIndexPath.row];
    //picture
    if (fiel_dic) {
        NSString *fmine = [fiel_dic objectForKey:@"file_mime"];
        if ([fmine isEqual:[NSNull null]]) {
            return;
        } else {
            fmine = [fmine lowercaseString];
        }
        NSInteger fsize = [[fiel_dic objectForKey:@"file_size"] integerValue];
        NSString *name = [fiel_dic objectForKey:@"file_name"];
        NSString *thumb = [fiel_dic objectForKey:@"file_thumb"];
        NSString *fid = [fiel_dic objectForKey:@"file_id"];
        if([fmine isEqualToString:@"png"]||[fmine isEqualToString:@"jpg"]|| [fmine isEqualToString:@"jpeg"]|| [fmine isEqualToString:@"bmp"]||[fmine isEqualToString:@"gif"]) {
            DownList *list = [[DownList alloc] init];
            list.d_file_id = fid;
            list.d_thumbUrl = thumb;
            if([list.d_thumbUrl length]==0)
            {
                list.d_thumbUrl = @"0";
            }
            list.d_name = name;
            list.d_baseUrl = [NSString get_image_save_file_path:list.d_name];
            list.d_downSize = fsize;
            
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            [tableArray addObject:list];
            if([tableArray count]>0)
            {
                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
                [look setTableArray:tableArray];
                [self presentViewController:look animated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarHidden:YES];
                }];
            }
        } else {
            NSString *documentDir = [YNFunctions getFMCachePath];
            NSArray *array=[name componentsSeparatedByString:@"/"];
            NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,fid];
            [NSString CreatePath:createPath];
            NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                browser.dataSource=browser;
                browser.delegate=browser;
                browser.title=name;
                browser.filePath=savedPath;
                browser.fileName=name;
                browser.currentPreviewItemIndex=0;
                [self presentViewController:browser animated:YES completion:nil];
            } else {
                OtherBrowserViewController *otherBrowser=[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil];
                
                NSArray *values = [NSArray arrayWithObjects:name,fid,[fiel_dic objectForKey:@"file_name"], nil];
                NSArray *keys = [NSArray arrayWithObjects:@"fname",@"fid",@"fsize", nil];
                NSDictionary *d = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                otherBrowser.dataDic=d;
                otherBrowser.title=name;
                [self presentViewController:otherBrowser animated:YES completion:nil];
            }
        }
        
    }
}

-(void)hideSingleBar
{
    [singleBg setHidden:YES];
    [moreEditBar setHidden:YES];
    if (selectedIndexPath) {
        
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        UIButton *button=(UIButton *) cell.accessoryView;
        [button setSelected:NO];
    }
}

//下载
- (void)downloadAction {
    [self hideSingleBar];
    NSDictionary *fiel_dic = [self.listArray objectAtIndex:selectedIndexPath.row];
    NSString *fileId = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"file_id"]];
    NSString *thumb = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"file_thumb"]];
    if([thumb length]==0)
    {
        thumb = @"0";
    }
    NSString *name = [NSString formatNSStringForOjbect:[fiel_dic objectForKey:@"file_name"]];
    NSInteger fsize = [[fiel_dic objectForKey:@"file_size"] integerValue];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    DownList *list = [[DownList alloc] init];
    list.d_name = name;
    list.d_downSize = fsize;
    list.d_thumbUrl = thumb;
    list.d_file_id = fileId;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *todayDate = [NSDate date];
    list.d_datetime = [dateFormatter stringFromDate:todayDate];
    list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    [tableArray addObject:list];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = self;
    [delegate.downmange addDownLists:tableArray];
    
}

-(void)downFileSuccess:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载完成",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
    });
}

-(void)downFileunSuccess:(NSString *)name
{
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=[NSString stringWithFormat:@"%@ 下载失败",name];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.downmange.managerDelegate = nil;
}


//转存
- (void)resaveAction {
    
    NSLog(@"转存");
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择转存的位置";
    flvc.delegate=self;
    flvc.type=kTypeCopy;
    NSDictionary *d = [self.listArray objectAtIndex:selectedIndexPath.row];
    flvc.targetsArray=[NSArray arrayWithObject:[d objectForKey:@"file_id"]];
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flvc];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:nav animated:YES completion:nil];
}

//转存delegate
-(void)resaveFileToID:(NSString *)f_id spid:(NSString *)spid
{
    NSDictionary *fiel_dic = [self.listArray objectAtIndex:selectedIndexPath.row];
    SCBFileManager *fm_move = [[SCBFileManager alloc] init];
    fm_move.delegate=self;
    
    NSString *fid=[fiel_dic objectForKey:@"file_id"];
    NSString *pid = self.fId;
    [fm_move resaveFileIDs:@[fid] toPID:f_id  sID:spid];
    
}

//转存成功
-(void)moveSucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
//转存失败
-(void)moveUnsucess
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

-(void)Unsucess:(NSString *)strError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    if (strError==nil||[strError isEqualToString:@""]) {
        self.hud.labelText=@"操作失败";
    }else
    {
        self.hud.labelText=strError;
    }
    
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:2.0f];
}


@end
