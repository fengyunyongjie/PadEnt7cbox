//
//  UserListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-10.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UserListViewController.h"
#import "YNFunctions.h"
#import "SCBAccountManager.h"
#import "MBProgressHUD.h"

@implementation FileItem

+ (FileItem*) fileItem
{
	return [[self alloc] init];
}
@end

@interface UserListViewController ()<SCBAccountManagerDelegate>
@property (strong,nonatomic) SCBAccountManager *am;
@property (strong,nonatomic) MBProgressHUD *hud;
@end

@implementation UserListViewController
@synthesize listViewDelegate,selectedItems,toolbar;
//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
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
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-[self.toolbar frame].size.height);
    }else
    {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-[self.toolbar frame].size.height);
    }
    
    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.toolbar.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-49, 320, 49);
    }else
    {
        self.toolbar.frame=CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
    self.navigationItem.rightBarButtonItem=barItem;
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

-(void)selectAll:(id)sender
{
    UIBarButtonItem *barItem = sender;
    if([barItem.title isEqualToString:@"全选"])
    {
        [barItem setTitle:@"取消全选"];
        for(int i=0;i<self.listArray.count;i++)
        {
            if(i<self.userItems.count)
            {
                FileItem* fileItem = [self.userItems objectAtIndex:i];
                [fileItem setChecked:YES];
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else
    {
        [barItem setTitle:@"全选"];
        
        for(int i=0;i<self.listArray.count;i++)
        {
            if(i<self.userItems.count)
            {
                FileItem* fileItem = [self.userItems objectAtIndex:i];
                [fileItem setChecked:NO];
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
            if (self.listArray) {
                NSMutableArray *a=[NSMutableArray array];
                for (int i=0; i<self.listArray.count; i++) {
                    FileItem *fileItem=[[FileItem alloc]init];
                    [a addObject:fileItem];
                    [fileItem setChecked:NO];
                }
                self.userItems=a;
                [self.tableView reloadData];
            }
        }
    }
    
//    [self.am cancelAllTask];
    self.am=nil;
    self.am=[[SCBAccountManager alloc] init];
    [self.am setDelegate:self];
    [self.am getUserList];
}
-(void)okAction:(id)sender
{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    NSMutableArray *names=[[NSMutableArray alloc] init];
    NSMutableArray *emails=[[NSMutableArray alloc] init];
    for (int i=0;i<self.userItems.count; i++) {
        FileItem *item=[self.userItems objectAtIndex:i];
        if ([item checked]) {
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *id=[dic objectForKey:@"usrid"];
            NSString *name=[dic objectForKey:@"usrturename"];
            NSString *email=[dic objectForKey:@"usraccount"];
            [ids addObject:id];
            [names addObject:name];
            [emails addObject:email];
        }
    }
    [self.listViewDelegate didSelectUserIDS:ids Names:names emails:emails];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
        return self.listArray.count;
    }
    return 0;
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
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
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
    //    self.selectedIndexPath=indexPath;
    //    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItem* fileItem = [self.userItems objectAtIndex:indexPath.row];
    fileItem.checked = YES;
    return;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItem* fileItem = [self.userItems objectAtIndex:indexPath.row];
    fileItem.checked = NO;
    return;
}

#pragma mark -SCBAccountManagerDelegate
-(void)getUserListSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
        if (self.listArray) {
            NSMutableArray *a=[NSMutableArray array];
            for (int i=0; i<self.listArray.count; i++) {
                FileItem *fileItem=[[FileItem alloc]init];
                [a addObject:fileItem];
                BOOL bl = NO;
                NSDictionary *diction1 = [self.listArray objectAtIndex:i];
                int fid1 = [[diction1 objectForKey:@"usrid"] intValue];
                for(int j=0;j<self.selectedItems.count;j++)
                {
                    int fid2 = [[self.selectedItems objectAtIndex:j] intValue];
                    if(fid1==fid2)
                    {
                        bl = YES;
                    }
                }
                [fileItem setChecked:bl];
            }
            self.userItems=a;
            [self.tableView reloadData];
        }
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
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
-(void)getUserListFail
{
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
