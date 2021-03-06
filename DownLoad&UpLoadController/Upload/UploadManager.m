//
//  UploadManager.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UploadManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UpLoadList.h"
#import "NSString+Format.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "UpDownloadViewController.h"
#import "MyTabBarViewController.h"
#import "YNFunctions.h"
#import "MySplitViewController.h"
#import "LoginViewController.h"

@implementation UploadManager
@synthesize uploadArray,isStopCurrUpload,isStart,isOpenedUpload,isAutoStart,isJoin,neeUpload;

-(id)init
{
    self = [super init];
    [self selectUploadList];
    neeUpload = [[UploadFile alloc] init];
    return self;
}

//查询出所有数据
-(void)selectUploadList
{
    UpLoadList *list = [[UpLoadList alloc] init];
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    uploadArray = [[NSMutableArray alloc] initWithArray:[list selectMoveUploadListAllAndNotUpload]];
}

-(void)updateLoad
{
    UpLoadList *list = [[UpLoadList alloc] init];
    if([uploadArray count] == 0)
    {
        list.t_id = 0;
    }
    else
    {
        UpLoadList *ls = [uploadArray lastObject];
        if(ls!=nil)
        {
            list.t_id =  ls.t_id;
        }
    }
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    [uploadArray addObjectsFromArray:[list selectMoveUploadListAllAndNotUpload]];
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MyTabBarViewController *tabbar;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        tabbar = [appleDate.splitVC.viewControllers firstObject];
    }else{
        tabbar = appleDate.myTabBarVC;
    }
    UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
    UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[UpDownloadViewController class]])
    {
        if([uploadView.upLoading_array count] == 0)
        {
            [uploadView setUpLoading_array:uploadArray];
        }
    }
    if(!isJoin)
    {
        isStopCurrUpload = YES;
        isStart = FALSE;
        for (int i=0; i<[uploadArray count]; i++) {
            UpLoadList *list = [uploadArray objectAtIndex:i];
            if(list.t_state == 5 || list.t_state == 6)
            {
                list.is_Onece = NO;
            }
            else
            {
                list.t_state = 2;
            }
        }
    }
}

-(void)uploadFilePath:(NSString *)filePath toFileID:(NSString *)f_id withSpaceID:(NSString *)s_id
{
    isJoin=YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            MyTabBarViewController *tabbar;
            if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
                tabbar = [appleDate.splitVC.viewControllers firstObject];
            }else{
                tabbar = appleDate.myTabBarVC;
            }
            UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
            UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
            if([uploadView isKindOfClass:[UpDownloadViewController class]])
            {
                [uploadView showLoadData];
            }
        });
        
        UpLoadList *inserList = [[UpLoadList alloc] init];
        NSMutableArray *tableArray = [[NSMutableArray alloc] init];
        
        UpLoadList *list = [[UpLoadList alloc] init];
        list.t_date = @"";
        list.t_lenght =[YNFunctions fileSizeAtPath:filePath];
        list.t_name = [[filePath pathComponents] lastObject];
        list.t_state = 0;
        list.t_fileUrl = filePath;
        list.t_url_pid = [NSString formatNSStringForOjbect:f_id];
        list.t_url_name = @"DeviceName";
        list.t_file_type = 5;
        list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        list.file_id = @"";
        list.upload_size = 0;
        list.is_autoUpload = NO;
        
        list.is_share = NO;
        NSLog(@"s_id:%@",s_id);
        list.spaceId = [NSString formatNSStringForOjbect:s_id];
        //                [list insertUploadList];
        [tableArray addObject:list];
        [inserList insertsUploadList:tableArray];
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;

        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
       tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新加载
                if (uploadView.hud) {
                    if(uploadView.hud.mode == MBProgressHUDModeIndeterminate)
                    {
                        [uploadView.hud removeFromSuperview];
                        uploadView.hud=nil;
                    }
                }
            });
        }
        [self updateUploadList];
    });
}
-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id
{
    isJoin = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if([array_ count]>0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                MyTabBarViewController *tabbar;
                if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
                    tabbar = [appleDate.splitVC.viewControllers firstObject];
                }else{
                    tabbar = appleDate.myTabBarVC;
                }
                UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
                UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
                if([uploadView isKindOfClass:[UpDownloadViewController class]])
                {
                    [uploadView showLoadData];
                }
            });
            
            UpLoadList *inserList = [[UpLoadList alloc] init];
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            for(int i=0;i<[array_ count];i++)
            {
                ALAsset *asset = [array_ objectAtIndex:i];
                UpLoadList *list = [[UpLoadList alloc] init];
                list.t_date = @"";
                list.t_lenght = asset.defaultRepresentation.size;
                list.t_name = [NSString formatNSStringForOjbect:asset.defaultRepresentation.filename];
                list.t_state = 0;
                list.t_fileUrl = [NSString formatNSStringForOjbect:asset.defaultRepresentation.url];
                list.t_url_pid = [NSString formatNSStringForOjbect:f_id];
                list.t_url_name = [NSString formatNSStringForOjbect:device_name];
                list.t_file_type = 0;
                list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
                list.file_id = @"";
                list.upload_size = 0;
                list.is_autoUpload = NO;
                
                list.is_share = NO;
                NSLog(@"s_id:%@",s_id);
                list.spaceId = [NSString formatNSStringForOjbect:s_id];
//                [list insertUploadList];
                [tableArray addObject:list];
            }
            [inserList insertsUploadList:tableArray];
        }
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新加载
                if (uploadView.hud) {
                    if(uploadView.hud.mode == MBProgressHUDModeIndeterminate)
                    {
                        [uploadView.hud removeFromSuperview];
                        uploadView.hud=nil;
                    }
                }
            });
        }
        [self updateUploadList];
    });
}

//查询出所有数据
-(void)updateUploadList
{
    dispatch_async(dispatch_get_main_queue(), ^{
    UpLoadList *list = [[UpLoadList alloc] init];
    if([uploadArray count] == 0)
    {
        list.t_id = 0;
    }
    else
    {
        UpLoadList *ls = [uploadArray lastObject];
        if(ls!=nil)
        {
            list.t_id =  ls.t_id;
        }
    }
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    
    [uploadArray addObjectsFromArray:[list selectMoveUploadListAllAndNotUpload]];
    [self updateTable];
    [self start];
    });
}

-(void)start
{
    isJoin = YES;
    isAutoStart = YES;
    isOpenedUpload = YES;
    if(!isStart)
    {
        [self updateTableStateForWaiting];
        isStart = YES;
        [self startUpload];
    }
}

//开始上传
-(void)startUpload
{
    if([uploadArray count]>0 && isStart)
    {
        isStopCurrUpload = NO;
        neeUpload.list = [uploadArray objectAtIndex:0];
        [neeUpload setDelegate:self];
        if(neeUpload.list.t_state == 0 || !neeUpload.list.is_Onece)
        {
            neeUpload.list.t_state = 0;
            [neeUpload startUpload];
        }
        else if(neeUpload.list.is_Onece)
        {
            [self upNetworkStop];
        }
    }
    if([uploadArray count]==0)
    {
        isStart = FALSE;
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate getStopUpload];
    }
    if(!isStart)
    {
        [self upNetworkStop];
    }
}

-(BOOL)IsHaveAutoStart
{
    if(isAutoStart && [uploadArray count]>0)
    {
        return YES;
    }
    return NO;
}

#pragma mark NewUploadDelegate

//上传成功
-(void)upFinish:(NSDictionary *)dicationary
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 1;
        list.upload_size = list.t_lenght;
        list.file_id = [NSString formatNSStringForOjbect:[dicationary objectForKey:@"fid"]];
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        list.t_date = [dateFormatter stringFromDate:todayDate];
        [list updateUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)sudu
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        if(sudu<0)
        {
            sudu = 0-sudu;
        }
        list.sudu = (int)sudu;
        float f = (float)list.upload_size / (float)list.t_lenght;
        NSLog(@"上传进度:%f",f);
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            MyTabBarViewController *tabbar;
            if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
                tabbar = [appleDate.splitVC.viewControllers firstObject];
            }else{
                tabbar = appleDate.myTabBarVC;
            }
            UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
            UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
            if([uploadView isKindOfClass:[UpDownloadViewController class]])
            {
                //更新UI
                [uploadView updateJinduData];
            }
        });
    }
}

//用户存储空间不足
-(void)upUserSpaceLass
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showSpaceNot];
        }
    });
    [self stopAllUpload];
}

-(void)upNotUpload
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot:@"上传失败，目标目录不存在"];
        }
    });
    isStopCurrUpload = YES;
    if([uploadArray count]>0 && isOpenedUpload)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 7;
        list.is_Onece = YES;
        [list deleteUploadList];
        [list insertUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//文件名过长
-(void)upNotNameTooTheigth
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot:@"上传失败，文件名过长"];
        }
    });
    isStopCurrUpload = YES;
    if([uploadArray count]>0 && isOpenedUpload)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 8;
        list.is_Onece = YES;
        [list deleteUploadList];
        [list insertUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}
//文件大小超过1GB
-(void)upNotSizeTooBig
{
    NSLog(@"文件大小超过1GB..................................");
    isStopCurrUpload = YES;
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 6;
        list.is_Onece = YES;
        BOOL bl = [list deleteUploadList];
        if(bl)
        {
            [list insertUploadList];
        }
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot:@"上传失败，文件大小超过1GB"];
        }
    });
    [self startUpload];
}

//文件名存在特殊字符
-(void)upNotHaveXNSString
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot:@"上传失败，文件名存在特殊字符"];
        }
    });
    isStopCurrUpload = YES;
    if([uploadArray count]>0 && isOpenedUpload)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 9;
        list.is_Onece = YES;
        [list deleteUploadList];
        [list insertUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//服务器异常
-(void)webServiceFail
{
    isStopCurrUpload = YES;
    if([uploadArray count]>0 && isOpenedUpload)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 5;
        list.is_Onece = YES;
        [list deleteUploadList];
        [list insertUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//上传失败
-(void)upError
{
    isStopCurrUpload = YES;
    [self startUpload];
}

//等待WiFi
-(void)upWaitWiFi
{
    isStopCurrUpload = YES;
    isStart = FALSE;
    [self updateTableStateForWaitWiFi];
}

//文件重名
-(void)upReName
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 1;
        list.upload_size = list.t_lenght;
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        list.t_date = [dateFormatter stringFromDate:todayDate];
        [list updateUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//网络失败
-(void)upNetworkStop
{
    isStopCurrUpload = YES;
    isStart = FALSE;
    [self updateTableStateForStop];
}

//更新ui
-(void)updateTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MyTabBarViewController *tabbar;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
            tabbar = [appleDate.splitVC.viewControllers firstObject];
        }else{
            tabbar = appleDate.myTabBarVC;
        }
        UINavigationController *NavigationController = [[tabbar viewControllers] objectAtIndex:3];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            //更新UI
            [uploadView isSelectedLeft:uploadView.isShowUpload];
        }
        UIApplication *app = [UIApplication sharedApplication];
        app.applicationIconBadgeNumber = [self.uploadArray count]+[appleDate.downmange.downingArray count];
        if([appleDate.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            app.applicationIconBadgeNumber = 0;
        }
       [tabbar addUploadNumber:app.applicationIconBadgeNumber];

    });
}

//修改Ui状态为等待WiFi
-(void)updateTableStateForWaitWiFi
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        if(list.t_state == 5 || list.t_state == 6)
        {
            
        }
        else
        {
            list.t_state = 3;
        }
        list.upload_size = 0;
    }
    [self updateTable];
}

//修改Ui状态为等待
-(void)updateTableStateForWaiting
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        if(list.t_state == 5 || list.t_state == 6)
        {
            list.is_Onece = NO;
        }
        else
        {
            list.t_state = 0;
        }
        list.upload_size = 0;
    }
    [self updateTable];
}

//修改Ui状态为暂停
-(void)updateTableStateForStop
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        if(list.t_state == 5 || list.t_state == 6 || list.t_state == 7 || list.t_state == 8 || list.t_state == 9)
        {
            
        }
        else
        {
            list.t_state = 2;
        }
        list.upload_size = 0;
    }
    [self updateTable];
}

//暂时所有上传
-(void)stopAllUpload
{
    isAutoStart = NO;
    isOpenedUpload = FALSE;
    isStopCurrUpload = YES;
    isStart = NO;
    [self updateTableStateForStop];
}

//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex
{
    if(selectIndex<[uploadArray count])
    {
        if(selectIndex==0 && isStart)
        {
            isStopCurrUpload = YES;
        }
        if(selectIndex<[uploadArray count])
        {
            [uploadArray removeObjectAtIndex:selectIndex];
        }
    }
}

//批量删除
-(void)deletes:(NSMutableArray *)array
{
    UpLoadList *list = [[UpLoadList alloc] init];
    [list deletesUploadList:array];
}

//删除所有上传
-(void)deleteAllUpload
{
    isStopCurrUpload = YES;
    isStart = NO;
    UpLoadList *list = [[UpLoadList alloc] init];
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    BOOL bl = [list deleteMoveUploadListAllAndNotUpload];
    if(bl)
    {
        if(uploadArray)
        {
            [uploadArray removeAllObjects];
            [self updateTable];
        }
    }
}

-(void)upNotFile
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot:@"上传失败，此文件已经不存在"];
        }
    });
    isStopCurrUpload = YES;
    if([uploadArray count]>0 && isOpenedUpload)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 7;
        list.is_Onece = YES;
        [list deleteUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

@end
