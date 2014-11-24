//
//  SubjectListForChooseViewController.m
//  icoffer
//
//  Created by hudie on 14-7-18.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "IPSubjectListForChooseViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"


@implementation IPSubjectItem

+ (IPSubjectItem *)IPSubjectItem {
    return [[self alloc] init];
}

@end


@interface IPSubjectListForChooseViewController ()
@property (nonatomic, retain) NSMutableArray     *materArray;
@property (nonatomic, retain) NSMutableArray     *joinArray;
@property (nonatomic, retain) NSMutableArray     *selectedArray;
@property (nonatomic, retain) NSMutableArray     *sectionArray;
@property (nonatomic, strong) MBProgressHUD      *hud;

@property (assign) NSInteger clickTimes;
@property (assign) NSInteger selectedNum;
@property (assign) NSInteger sendNum;
@property (assign) BOOL isPlus;

@end

@implementation IPSubjectListForChooseViewController

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
    self.sectionArray = [NSMutableArray array];
    self.materArray = [NSMutableArray array];
    self.joinArray = [NSMutableArray array];
    self.selectedArray = [NSMutableArray array];
    self.navigationItem.title = @"发布到专题";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publish)]];

    self.tableView.editing = YES;
    
    [self updateSubjectList];
}

- (void)viewDidLayoutSubviews {
     self.tableView.frame=CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height-30);
}

//publish
- (void)publish {
    if(self.selectedNum==0) {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        self.hud.labelText=@"请选择要发布到的专题";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
        
    } else {
        IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
        sm.delegate = self;
        NSString *fid = [self.parentSelectedIds objectAtIndex:0];
        NSMutableArray *a = [NSMutableArray array];
        for(int j=0;j<self.selectedArray.count;j++) {
            IPSubjectItem *item = [self.selectedArray objectAtIndex:j];
            [a addObject:item.sub_id];
            
        }

        if (self.fisdir.intValue == 0) {
            NSArray *b = [NSArray arrayWithObject:fid];
            [sm publishResourceWithSubjectId:a res_file:nil res_folder:b res_url:nil res_descs:nil comment:self.commentString];
        } else {
            NSArray *b = [NSArray arrayWithObject:fid];
            [sm publishResourceWithSubjectId:a res_file:b res_folder:nil res_url:nil res_descs:nil comment:self.commentString];
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = 0;
    switch (section) {
        case 0:
            rows = self.materArray.count;
            break;
        case 1:
            rows = self.joinArray.count;
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}

//自定义section的head view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    CGRect frameRect = CGRectMake(10, 0, 250, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:frameRect];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:16];

    if (self.sectionArray.count != 0) {
        NSString *group =[[self.sectionArray objectAtIndex:section] objectForKey:@"text"];
        label.text = [NSString stringWithFormat:@"%@",group];

    } else {
        label.text = @"";
    }
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 29, 320, 1)];
    imageV.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [label addSubview:imageV];
    UIImageView *imageV2 = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 320, 1)];
    imageV2.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [label addSubview:imageV2];
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1]];
    [sectionView addSubview:label];
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, 11, 250, 30)];
        [cell.contentView addSubview:label];
        label.tag = 1;
        label.font = [UIFont systemFontOfSize:16];
    }
    UILabel *l = (UILabel *)[cell viewWithTag:1];
    switch (indexPath.section) {
        case 0: {
            NSDictionary *d = [self.materArray objectAtIndex:indexPath.row];
            if (d){
                l.text = [d objectForKey:@"text"];
            } else {
                l.text = @"";
            }
        }
            break;
        case 1: {
            NSDictionary *d = [self.joinArray objectAtIndex:indexPath.row];
            if (d){
                l.text = [d objectForKey:@"text"];
            } else {
                l.text = @"";
            }
        }
            break;
        default:
            l.text = @"";
            break;
    }
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITableView dataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *d = [NSDictionary dictionary];
    if (indexPath.section == 0) {
        d = [self.materArray objectAtIndex:indexPath.row];
    } else{
        d = [self.joinArray objectAtIndex:indexPath.row];
    }
    IPSubjectItem* subItem = [[IPSubjectItem alloc] init];
    subItem.sub_id = [d objectForKey:@"id"];
    subItem.checked = YES;
    self.isPlus = YES;
    [self.selectedArray addObject:subItem];
    self.selectedNum++;
    return;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *d = [NSDictionary dictionary];
    if (indexPath.section == 0) {
        d = [self.materArray objectAtIndex:indexPath.row];
    } else{
        d = [self.joinArray objectAtIndex:indexPath.row];
    }
    IPSubjectItem* subItem = [[IPSubjectItem alloc] init];
    subItem.sub_id = [d objectForKey:@"id"];
    for (int i = 0; i < self.selectedArray.count;i++) {
        IPSubjectItem *item = [self.selectedArray objectAtIndex:i];
        if ([subItem.sub_id isEqualToString:item.sub_id]) {
            [self.selectedArray removeObject:item];
        }
    }
    self.isPlus = NO;
    self.selectedNum--;
    return;
}


//获取专题列表
- (void)updateSubjectList {
    
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"SubjectGroupList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.sectionArray=(NSMutableArray *)[self.dataDic objectForKey:@"data"];
        }
    }
    
    IPSCBSubJectManager *sm = [[IPSCBSubJectManager alloc] init];
    sm.delegate = self;
    [sm getSubjectList];
}

//SCBSubjectManager delegate
//获取专题列表成功
- (void)checkSubjectListSuccess:(NSDictionary *)dic {
    
    if (dic) {
        self.dataDic = dic;
        self.sectionArray = [dic objectForKey:@"data"];
        self.materArray = [NSMutableArray array];
        self.joinArray = [NSMutableArray array];
        
        NSDictionary *d = [self.sectionArray objectAtIndex:0];
        self.materArray = [d objectForKey:@"subjectList"];
        NSDictionary *d2 = [self.sectionArray objectAtIndex:1];
        self.joinArray = [d2 objectForKey:@"subjectList"];
        [self.listArray addObject:self.materArray];
        [self.listArray addObject:self.joinArray];
        
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"SubjectGroupList"]];
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
        
    } else {
        [self updateSubjectList];
    }
    [self.tableView reloadData];
}

//获取专题列表失败
- (void)checkSubjectListUnsuccess:(NSString *)error_info {
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

//发布成功
- (void)publishSuccess {
    self.sendNum++;
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    [self.parentViewController.view.superview addSubview:self.hud];
    self.hud.labelText=@"发布成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//发布失败
- (void)publishunsuccess:(NSString *)error_info {
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发布失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    
}

-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}


@end
