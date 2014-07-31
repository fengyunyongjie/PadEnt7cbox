//
//  SujectUpload.m
//  icoffer
//
//  Created by Yangsl on 14-7-16.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "SujectUpload.h"
#import "Reachability.h"
#import "SCBoxConfig.h"
#import "YNFunctions.h"
#import "SCBSession.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>

#define SomeDataSize 1024*200

@implementation SujectUpload
@synthesize finishName,connection,list,urlNameArray,urlIndex,file_data,md5String,total,uploadType,delegate,isStop,uploderDemo;

-(id)init
{
    self = [super init];
    uploderDemo = [[SCBUploader alloc] init];
    [uploderDemo setUpLoadDelegate:self];
    return self;
}

//判断当前的网络是3g还是wifi
-(NetworkStatus) isConnection
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReach currentReachabilityStatus];
}

-(void)isNetWork
{
    if([self isConnection] == ReachableViaWiFi)
    {
        //WiFi 状态
        [self newRequestVerify];
    }
    else if([self isConnection] == ReachableViaWWAN)
    {
        if(![YNFunctions isOnlyWifi])
        {
            [self newRequestVerify];
        }
        else
        {
            [self updateAutoUploadState];
            //等待WiFi
            [delegate upWaitWiFi];
        }
    }
    else
    {
        [self updateAutoUploadState];
        //网络连接断开
        [delegate upNetworkStop];
    }
}

-(void)newRequestVerify
{
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_CLIENT_VERIFY]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *uploadStirng;
    if(uploadType==SJUploadTypePhoto)
    {
        uploadStirng = @"jpg";
    }
    else
    {
        uploadStirng = @"mp3";
    }
    [body appendFormat:@"f_pid=%@&filename=%@&fsize=%@&space_id=%@&FileType=%@",list.t_url_pid,list.t_name,[NSString stringWithFormat:@"%i",list.t_lenght],list.spaceId,uploadStirng];
    NSLog(@"body:%@",body);
    NSLog(@"1:开始专题校验");
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || isStop)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upError];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    if([[dictionary objectForKey:@"code"] intValue] == 0 )
    {
        NSLog(@"2:开始上传校验");
        if([dictionary objectForKey:@"msg"])
        {
            list.t_url_pid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"msg"]];
        }
        
        [self nomalRequestVerify];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 2 )
    {
        [self updateAutoUploadState];
        //上传文件大小大于1G
        [delegate upNotSizeTooBig];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 3 )
    {
        [self updateAutoUploadState];
        //空间不足
        [delegate upUserSpaceLass];
    }
    else
    {
        [self updateAutoUploadState];
        //失败
        [self updateNetWork];
    }
}

-(void)nomalRequestVerify
{
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_VERIFY]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%@&f_name=%@&f_size=%@&space_id=%@",list.t_url_pid,list.t_name,[NSString stringWithFormat:@"%i",list.t_lenght],list.spaceId];
    NSLog(@"body:%@",body);
    NSLog(@"userid:%@",[[SCBSession sharedSession] userId]);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || isStop)
    {
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upError];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    if([[dictionary objectForKey:@"code"] intValue] == 0 )
    {
        finishName = [dictionary objectForKey:@"s_name"];
        NSLog(@"3:开始上传：%@",list.t_fileUrl);
        [self uploadSomeFile];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 7 )
    {
        [self updateAutoUploadState];
        [delegate upNotUpload];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 3 )
    {
        [self updateAutoUploadState];
        //上传文件大小大于1G
        [delegate upNotSizeTooBig];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 5 )
    {
        [self updateAutoUploadState];
        //空间不足
        [delegate upUserSpaceLass];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 6 )
    {
        [self updateAutoUploadState];
        //文件名存在特殊字符
        [delegate upNotHaveXNSString];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 2 )
    {
        [self updateAutoUploadState];
        //文件名过长
        [delegate upNotNameTooTheigth];
    }
    else
    {
        [self updateAutoUploadState];
        //失败
        [self updateNetWork];
    }
}

//分段上传
-(void)uploadSomeFile
{
    if(isStop)
    {
        [self updateAutoUploadState];
        [delegate upError];
        return;
    }
    if(list.t_file_type == 5)
    {
        total = list.t_lenght;
        file_data = [NSData dataWithContentsOfFile:list.t_fileUrl];
        if([file_data length]>0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                connection = [uploderDemo requestUploadFile:finishName startSkip:[NSString stringWithFormat:@"%i",list.upload_size] skip:[NSString stringWithFormat:@"%i",total] Image:file_data];
            });
        }
    }
    else
    {
        ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
        [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result)
         {
             NSError *error = nil;
             
             if(SomeDataSize<list.t_lenght-list.upload_size)
             {
                 total = SomeDataSize;
                 Byte *byte_data = malloc(total);
                 [result.defaultRepresentation getBytes:byte_data fromOffset:list.upload_size length:SomeDataSize error:&error];
                 file_data = [NSData dataWithBytesNoCopy:byte_data length:SomeDataSize];
                 //DDLogCError(@"文件大小：%i",[file_data length]);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     connection = [uploderDemo requestUploadFile:finishName startSkip:[NSString stringWithFormat:@"%i",list.upload_size] skip:[NSString stringWithFormat:@"%i",SomeDataSize] Image:file_data];
                 });
             }
             else
             {
                 total = list.t_lenght-list.upload_size;
                 Byte *byte_data = malloc(total);
                 [result.defaultRepresentation getBytes:byte_data fromOffset:list.upload_size length:list.t_lenght-list.upload_size error:&error];
                 file_data = [NSData dataWithBytesNoCopy:byte_data length:list.t_lenght-list.upload_size];
                 //DDLogCError(@"这次上传了多少:%i",total);
                 //DDLogCError(@"文件大小：%i",[file_data length]);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     connection = [uploderDemo requestUploadFile:finishName startSkip:[NSString stringWithFormat:@"%i",list.upload_size] skip:[NSString stringWithFormat:@"%i",list.t_lenght-list.upload_size] Image:file_data];
                 });
             }
         } failureBlock:^(NSError *error)
         {
             //DDLogCError(@"error:%@",error);
         }];
    }
}

-(void)updateAutoUploadState
{
    isStop = YES;
}

-(void)updateNetWork
{
    [self updateAutoUploadState];
    [delegate upError];
}

-(void)comeBackNewTheadMian:(NSDictionary *)dictionary
{
    if(isStop)
    {
        [self updateAutoUploadState];
        [delegate upError];
        return;
    }
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        NSLog(@"4:提交上传表单:%@",finishName);
        [self newRequestUploadCommit:list.t_url_pid f_name:list.t_name s_name:finishName skip:[NSString stringWithFormat:@"%i",list.t_lenght] space_id:list.spaceId];
    }
    else
    {
        [self updateAutoUploadState];
        NSLog(@"上传失败");
        [self updateNetWork];
    }
}

#pragma mark 新的上传 提交上传表单
-(void)newRequestUploadCommit:(NSString *)fPid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip space_id:(NSString *)spaceId
{
    if(isStop)
    {
        [self updateAutoUploadState];
        [delegate upError];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_COMMIT]];
    
    NSData *returnData;
    NSError *error;
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_MAX];
    NSLog(@"request1:%@",[[SCBSession sharedSession] userId]);
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendString:[NSString stringWithFormat:@"ent_uid=%@",[[SCBSession sharedSession] userId]]];
    NSString *uploadStirng;
    if(uploadType==SJUploadTypePhoto)
    {
        uploadStirng = @"jpg";
    }
    else
    {
        uploadStirng = @"mp3";
    }
    [body appendString:[NSString stringWithFormat:@"FileType=%@",uploadStirng]];
    [body appendString:[NSString stringWithFormat:@"&fpid=%@",fPid]];
    [body appendString:[NSString stringWithFormat:@"&fname=%@",f_name]];
    [body appendString:[NSString stringWithFormat:@"&sname=%@",s_name]];
    [body appendString:[NSString stringWithFormat:@"&spaceid=%@",list.spaceId]];
    [body appendString:[NSString stringWithFormat:@"&f_md5=%@",[self md5:file_data]]];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    returnData = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil error:&error];
    if(returnData == nil || isStop)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upError];
        }
        return;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    NSLog(@"5:完成");
    [self updateAutoUploadState];
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        [delegate upFinish:dictionary fileinfo:self.list];
    }
    else
    {
        [self updateNetWork];
    }
}

#pragma mark UpLoadDelegate

//上传效验
-(void)uploadVerify:(NSDictionary *)dictionary{}

//上传文件完成
-(void)uploadFinish:(NSDictionary *)dictionary
{
    if(isStop)
    {
        [self updateAutoUploadState];
        [delegate upError];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        list.upload_size = list.upload_size + total;
        [delegate upProess:list.upload_size fileTag:list.sudu];
        connection = nil;
        if(list.upload_size == list.t_lenght)
        {
            [NSThread detachNewThreadSelector:@selector(comeBackNewTheadMian:) toTarget:self withObject:dictionary];
        }
        else
        {
            [self uploadSomeFile];
        }
    });
}

//申请上传状态
-(void)requestUploadState:(NSDictionary *)dictionary{}

//查看上传记录
-(void)lookDescript:(NSDictionary *)dictionary{}

//上传文件流
-(void)uploadFiles:(int)proress sudu:(NSInteger)sudu
{
    if(isStop)
    {
        [self updateAutoUploadState];
        [connection cancel];
        connection = nil;
        [delegate upError];
        return;
    }
}

//上传提交
-(void)uploadCommit:(NSDictionary *)dictionary{}

#pragma mark 公用代理方法

//上传失败
-(void)didFailWithError
{
    [self updateAutoUploadState];
    [self updateNetWork];
}

-(NSString *)md5:(NSData *)concat {
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    NSData* filedata = concat;
    CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

@end