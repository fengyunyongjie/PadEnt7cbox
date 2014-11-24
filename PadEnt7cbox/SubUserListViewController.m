//
//  SubUserListViewController.m
//  icoffer
//
//  Created by hudie on 14-7-7.
//  Copyright (c) 2014年. All rights reserved.
//

#import "SubUserListViewController.h"
#import "YNFunctions.h"
#import "MBProgressHUD.h"
#import "UIBarButtonItem+Yn.h"
#import "SCBSubjectManager.h"

@implementation UserItem

+ (UserItem*) UserItem
{
	return [[self alloc] init];
}
@end

@interface SubUserListViewController ()<UITableViewDataSource,UITableViewDelegate,SCBSubjectManagerDelegate>
@property (strong, nonatomic) MBProgressHUD   *hud;
@property (nonatomic, retain) NSMutableArray  *sectionArray;
@property (assign) NSInteger clickTimes;
@property (assign) NSInteger selectedNum;
@property (assign) BOOL      isPlus;
@end

@implementation SubUserListViewController
@synthesize listViewDelegate,selectedItems,toolbar;

- (BOOL)shouldAutorotate{
    return NO;
}

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
    [self updateList];
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{} completion:^(BOOL bl){
        self.view.userInteractionEnabled = YES;
    }];
}

-(void)viewDidLayoutSubviews
{
    self.tableView.frame=self.view.bounds;
//    self.toolbar.frame=CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49);
    [self.toolbar setHidden:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [self.view addSubview:self.tableView];
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
    self.navigationItem.rightBarButtonItem=barItem;
    UIBarButtonItem *okBarItem=[[UIBarButtonItem alloc] initWithTitleStr:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okAction:)];
    self.navigationItem.leftBarButtonItem=okBarItem;
    
    self.clickTimes = 2;
    self.selectedNum = self.selectedItems.count;
        
    if([self.selectedItems count]==0)
    {
        self.navigationItem.title = @"选择成员(选中0人)";
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat:@"选择成员(选中%d人)",self.selectedNum];
    }
        
    if(self.selectedNum == self.selectedItems.count && self.selectedNum == self.listArray.count)
    {
        [barItem setTitle:@"取消全选"];
    }
    
    [self.tableView setEditing:YES];
    
    self.toolbar=[[UIToolbar alloc] init];
    [self.toolbar sizeToFit];
    [self.view addSubview:self.toolbar];
    
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *btn_download ,*btn_resave;
    UIBarButtonItem  *item_download, *item_resave;
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_resave setTitle:@"确 定" forState:UIControlStateNormal];
    [btn_resave addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_download setTitle:@"取 消" forState:UIControlStateNormal];
    [btn_download addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolbar setItems:@[fix,item_download,fix,item_resave,fix]];
}


//全选按钮操作
-(void)selectAll:(id)sender
{
    self.clickTimes ++;
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"全选"])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitleStr:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
        self.selectedNum = self.listArray.count;
        self.navigationItem.title = [NSString stringWithFormat:@"选择成员(选中%d人)",self.listArray.count];
        [self.selectedItems removeAllObjects];
        
        
        for (int i = 0; i < self.listArray.count; i++) {
            UserItem *item = [self.listArray objectAtIndex:i];
            item.checked = YES;
        }
        for(int i=0;i<self.sectionArray.count;i++)
        {
            NSMutableArray *memberArray = [[self.sectionArray objectAtIndex:i] objectForKey:@"memberlist"];
            for (int j = 0; j < memberArray.count; j++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    

    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
        self.navigationItem.title = @"选择成员(选中0人)";
        self.selectedNum = 0;
        [self.selectedItems removeAllObjects];
        for (int i = 0; i < self.listArray.count; i++) {
            UserItem *item = [self.listArray objectAtIndex:i];
            item.checked = NO;
        }
        for(int i=0;i<self.sectionArray.count;i++)
        {
            NSMutableArray *memberArray = [[self.sectionArray objectAtIndex:i] objectForKey:@"memberlist"];
            for (int j = 0; j < memberArray.count; j++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                
            }
        }
    }
}

#pragma mark - 获取成员列表
- (void)updateList
{
    self.listArray = [NSMutableArray array];
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"MemberList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.sectionArray=(NSMutableArray *)[self.dataDic objectForKey:@"data"];
            for (int i = 0; i < self.sectionArray.count; i++) {
                NSMutableArray *memberArray = [[self.sectionArray objectAtIndex:i] objectForKey:@"memberlist"];
                for (int j = 0; j < memberArray.count; j++) {
                    NSDictionary *d = [memberArray objectAtIndex:j];
                    UserItem *item = [[UserItem alloc] init];
                    item.user_id = [[d objectForKey:@"usrid"] intValue];
                    item.checked = NO;
                    item.user_name = [d objectForKey:@"usrturename"];
                    [self.listArray addObject:item];
                }
            }
        }
    }
    SCBSubjectManager *sm = [[SCBSubjectManager alloc] init];
    sm.delegate=self;
    [sm getMemberList];
}

//确定
-(void)okAction:(id)sender
{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (int i=0;i<self.listArray.count; i++) {
        UserItem *item=[self.listArray objectAtIndex:i];
        if ([item checked]) {
            NSString *idStr = [NSString stringWithFormat:@"%d",item.user_id];
            [ids addObject:idStr];
            [names addObject:item.user_name];
        }
    }
    //返回用户id和用户名
    [self.listViewDelegate didSelectUserIDS:ids Names:names];
    if ([[UIDevice currentDevice] userInterfaceIdiom]!=UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//取消
-(void)cancel:(id)sender
{
    [self.listViewDelegate didSelectUserIDS:nil Names:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)updateSelectAllButton
{
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
    self.navigationItem.rightBarButtonItem=barItem;
    self.clickTimes = 2;
    self.selectedNum = self.selectedItems.count;
        
    if([self.selectedItems count]==0)
    {
        self.navigationItem.title = @"选择成员(选中0人)";
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat:@"选择成员(选中%d人)",self.selectedNum];
    }
        
    if(self.selectedNum == self.selectedItems.count && self.selectedNum == self.listArray.count)
    {
        [barItem setTitle:@"取消全选"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *memberArray = [[self.sectionArray objectAtIndex:section]objectForKey:@"memberlist"];
    if (memberArray) {
        [self updateSelectAllButton];
        return memberArray.count;
    }
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    
//    return [self.sectionArray objectAtIndex:section];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

//自定义section的head view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    CGRect frameRect = CGRectMake(10, 0, 250, 40);
    UILabel *label = [[UILabel alloc] initWithFrame:frameRect];
    NSDictionary *dic = [self.sectionArray objectAtIndex:section];
    NSString *group = [dic objectForKey:@"deptName"];
    label.text = [NSString stringWithFormat:@"%@",group];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 320, 1)];
    imageV.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [label addSubview:imageV];
    UIImageView *imageV2 = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 38, 320, 1)];
    imageV2.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [label addSubview:imageV2];
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1]];
    [sectionView addSubview:label];
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    if (self.sectionArray) {
        NSArray *memberArray = [[self.sectionArray objectAtIndex:indexPath.section]objectForKey:@"memberlist"];
        NSDictionary *dic=[memberArray objectAtIndex:indexPath.row];
        if (dic)
        {
            cell.textLabel.text=[dic objectForKey:@"usrturename"];
            int fid1 = [[dic objectForKey:@"usrid"] intValue];
            for(int j=0;j<self.selectedItems.count;j++)
            {
                int fid2 = [[self.selectedItems objectAtIndex:j] intValue];
                if(fid1==fid2)
                {
                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
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
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *memberArray = [[self.sectionArray objectAtIndex:indexPath.section]objectForKey:@"memberlist"];
    NSDictionary *dic=[memberArray objectAtIndex:indexPath.row];
    for (int i = 0; i < self.listArray.count; i++) {
        UserItem *item = [self.listArray objectAtIndex:i];
        int user_id = [[dic objectForKey:@"usrid"] intValue];
        if (item.user_id == user_id) {
            item.checked = YES;
        }
    }
    self.isPlus = YES;
    [self updateNavigationTitle];
    return;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *memberArray = [[self.sectionArray objectAtIndex:indexPath.section]objectForKey:@"memberlist"];
    NSDictionary *dic=[memberArray objectAtIndex:indexPath.row];
    for (int i = 0; i < self.listArray.count; i++) {
        UserItem *item = [self.listArray objectAtIndex:i];
        int user_id = [[dic objectForKey:@"usrid"] intValue];
        if (item.user_id == user_id) {
            item.checked = NO;
        }
    }
    self.isPlus = NO;
    [self updateNavigationTitle];
    return;
}

#pragma mark -SCBSubjectManagerDelegate
//获取成员列表成功
-(void)didGetMemberList:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.sectionArray=(NSMutableArray *)[self.dataDic objectForKey:@"data"];
        NSMutableArray *a = [NSMutableArray array];
        if (self.sectionArray) {
            for (int i = 0; i < self.sectionArray.count; i++) {
                NSMutableArray *memberArray = [[self.sectionArray objectAtIndex:i] objectForKey:@"memberlist"];
                for (int j = 0; j < memberArray.count; j++) {
                    NSDictionary *d = [memberArray objectAtIndex:j];
                    int userId = [[d objectForKey:@"usrid"] intValue];
                    UserItem *item = [[UserItem alloc] init];
                    item.user_id = userId;
                    item.checked = NO;
                    item.user_name = [d objectForKey:@"usrturename"];
                    [a addObject:item];

                    if (self.selectedItems.count > 0) {
                        for (int k = 0; k < self.selectedItems.count; k++) {
                            int sel_userId = [[self.selectedItems objectAtIndex:k] intValue];
                            if (userId == sel_userId) {
                                item.checked = YES;
                            }
                        }
                    }
                }
            }
        
            self.listArray = a;
            [self.tableView reloadData];
        }
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"MemberList"]];
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateList];
    }
}
-(void)getMemberListunsuccess:(NSString *)error_info
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"获取成员列表失败";
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

- (void)updateNavigationTitle {
    
    if (self.isPlus) {
        self.selectedNum++;
    }else {
        self.selectedNum--;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"选择成员(选中%d人)",self.selectedNum];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
