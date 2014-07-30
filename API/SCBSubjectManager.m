//
//  SCBSubjectManager.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-10.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SCBSubjectManager.h"
#import "SCBSession.h"
#import "SCBoxConfig.h"
#import "YNFunctions.h"

typedef enum {
    kSMTypeGetSubjectList,          //专题列表
    kSMTypeGetSelectSubjectList,    //发布资源时请求专题列表
    kSMTypeCreateSubject,           //新建专题
    kSMTypeGetActivity,             //动态列表
    kSMTypeGetSubjectInfo,          //专题信息
    kSMTypeGetResourceList,         //资源列表
    kSMTypePublishResource,         //发布资源
    kSMTypeGetMemberList,           //成员列表
    kSMTypeGetCommentList,          //资源评论列表
    kSMTypeSendComment,             //发布资源评论
    kSMTypeGetResourceFile,         //打开资源文件目录
    kSMTypeGetSubjectSum,           //专题新动态总数
    kSMTypeSubjectIsExist,          //资源是否存在
}kSMType;

@interface SCBSubjectManager()<NSURLConnectionDelegate>
@property(nonatomic,assign) kSMType sm_type;
@property(nonatomic,retain) NSMutableData *activeData;
@property(nonatomic,strong) NSURLConnection *conn;
@end

@implementation SCBSubjectManager
-(void)getSubjectList
{
    self.sm_type=kSMTypeGetSubjectList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_LIST_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"user_id=%@",[[SCBSession sharedSession] userId]];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    self.conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)getSelectSubjectList
{
    self.sm_type=kSMTypeGetSelectSubjectList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_LIST_PUBLISH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"user_id=%@",[[SCBSession sharedSession] userId]];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    self.conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
-(void)createSubjectWithName:(NSString *)name info:(NSString *)info isPublish:(BOOL)isPublish isAddUser:(BOOL)isAddUser members:(NSArray *)members
{
    self.sm_type=kSMTypeCreateSubject;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_CREATE_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"subj_name=%@",name];
    [body appendFormat:@"&subj_remarks=%@",info];
    [body appendFormat:@"&subj_is_publish=%@",isPublish?@"1":@"0"];
    [body appendFormat:@"&subj_is_adduser=%@",isAddUser?@"1":@"0"];
    for (NSString *userid in members) {
        [body appendFormat:@"&members[]=%@",userid];
    }
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    self.conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
-(void)getActivityWithSubjectID:(NSString *)subject_id
{
    self.sm_type=kSMTypeGetActivity;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_ACTIVITY_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"subject_id=%@&last_time=&user_id=%@&cursor=0&offset=0",subject_id,[[SCBSession sharedSession] userId]];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    self.conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)getSubjectInfoWithSubjectID:(NSString *)subject_id
{
    self.sm_type=kSMTypeGetSubjectInfo;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_INFORIGHT_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"user_id=%@",[[SCBSession sharedSession] userId]];
    [body appendFormat:@"&subject_id=%@",subject_id];
    [body appendString:@"&cursor=0&offset=0"];
    NSLog(@"body: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
//获取资源列表
- (void)getResourceListWithSubjectId:(NSString *)sub_id resourceUserIds:(NSString *)res_userId resourceType:(NSString *)res_type resourceTitil:(NSString *)res_title
{
    self.sm_type=kSMTypeGetResourceList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_RESOURCES_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSString *desc=[YNFunctions getDesc];
    NSString *order=@"asc";
    if ([desc isEqualToString:@"time"]) {
        order=@"desc";
    }
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"subject_id=%@&cursor=%d&offset=%d",sub_id,0,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
//发布资源
- (void)publishResourceWithSubjectId:(NSArray *)sub_ids res_file:(NSArray *)fileIds res_folder:(NSArray *)folderIds res_url:(NSArray *)urlStrings res_descs:(NSArray *)urlDesces comment:(NSString *)sub_comment
{
    self.sm_type=kSMTypePublishResource;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_RESOURCES_PUBLISH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *userid = [[SCBSession sharedSession] userId];
    [body appendFormat:@"user_id=%@",userid];
    NSString *fileIdStr = [fileIds componentsJoinedByString:@"&file_ids[]="];
    [body appendFormat:@"&file_ids[]=%@",fileIdStr];
    NSString *folderStr = [folderIds componentsJoinedByString:@"&folder_ids[]="];
    [body appendFormat:@"&folder_ids[]=%@",folderStr];
    NSString *urlStr = [urlStrings componentsJoinedByString:@"&url_res[]="];
    [body appendFormat:@"&url_res[]=%@",urlStr];
    NSString *urlDesStr = [urlDesces componentsJoinedByString:@"&url_descs[]="];
    [body appendFormat:@"&url_descs[]=%@",urlDesStr];
    NSString *idStr=[sub_ids componentsJoinedByString:@"&subject_ids[]="];
    [body appendFormat:@"&subject_ids[]=%@",idStr];
    [body appendFormat:@"&comment=%@",sub_comment];
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//获取部门成员
- (void)getMemberList
{
    self.sm_type=kSMTypeGetMemberList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_MEMBER_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//获取资源评论
- (void)getCommentListWithResourceId:(NSString *)res_id
{
    self.sm_type=kSMTypeGetCommentList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_COMMENT_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"resource_id=%@",res_id];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//发布评论
- (void)sendCommentWithResourceId:(NSString *)res_id subjectId:(NSString *)sub_id content:(NSString *)aContent type:(NSString *)comment_type seconds:(NSString *)audioLen
{
    self.sm_type=kSMTypeSendComment;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_PUBLISH_COMMENT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"resource_id=%@",res_id];
    [body appendFormat:@"&subject_id=%@",sub_id];
    [body appendFormat:@"&content=%@",aContent];
    [body appendFormat:@"&comment_type=%@",comment_type];
    if ([comment_type isEqualToString:@"1"]) {
        [body appendFormat:@"&seconds=%@",audioLen];
    }
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//文件列表
- (void)getResourceFileWithSubjectId:(NSString *)sub_id f_id:(NSString *)fid
{
    self.sm_type=kSMTypeGetResourceFile;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_RESOURCE_FILE_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"subject_id=%@",sub_id];
    [body appendFormat:@"&fid=%@",fid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//获取动态的总个数
- (void)getSubjectSum
{
    self.sm_type=kSMTypeGetSubjectSum;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_SUM_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPMethod:@"POST"];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
//判断资源是否存在
-(void)requestSubjectIsExistWithResouceId:(NSString *)resouceId
{
    self.sm_type=kSMTypeSubjectIsExist;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_RESOURCES_EXIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"resource_id=%@",resouceId];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    self.conn =[[NSURLConnection alloc] initWithRequest:request delegate:self];

}
#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{
    NSLog(@"connection:didReceiveResponse:");
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
    //    assert(theConnection == self.connection);
    //
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error %zd",(ssize_t)httpResponse.statusCode);
    } else {
        NSLog(@"Response OK.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeData appendData:data];
    NSLog(@"connection:didReceiveData:%@",data);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    // Release the connection now that it's finished
    NSLog(@"connection:didFailWithError");
    if (self.delegate) {
        [self.delegate networkError];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Release the connection now that it's finished
    // call our delegate and tell it that our icon is ready for display
    //[delegate fileDidDownload:self.index];
    if(!self.activeData)
    {
        NSLog(@"请求得到的数据为空");
        return;
    }
    NSLog(@"%@",[[NSString alloc] initWithData:self.activeData encoding:NSUTF8StringEncoding]);
    NSError *jsonParsingError=nil;
    
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    if (self.delegate) {
        switch (self.sm_type) {
            case kSMTypeGetSubjectList:
                [self.delegate didGetSubjectList:dic];
                break;
            case kSMTypeCreateSubject:
                [self.delegate didCreateSubject:dic];
                break;
            case kSMTypeGetActivity:
                [self.delegate didGetActivity:dic];
                break;
            case kSMTypeGetSubjectInfo:
                [self.delegate didGetSubjectInfo:dic];
                break;
            case kSMTypeGetCommentList:
                [self.delegate didGetCommentList:dic];
                break;
            case kSMTypeGetMemberList:
                [self.delegate didGetMemberList:dic];
                break;
            case kSMTypeGetResourceFile:
                [self.delegate didGetResourceFile:dic];
                break;
            case kSMTypeGetResourceList:
                [self.delegate didGetResourceList:dic];
                break;
            case kSMTypeGetSelectSubjectList:
                [self.delegate didGetSelectSubjectList:dic];
                break;
            case kSMTypeGetSubjectSum:
                [self.delegate didGetSubjectSum:dic];
                break;
            case kSMTypePublishResource:
                [self.delegate didPublishResource:dic];
                break;
            case kSMTypeSendComment:
                [self.delegate didSendComment:dic];
                break;
            case kSMTypeSubjectIsExist:
                [self.delegate didSubjectIsExist:dic];
                break;
        }
    }
    
    self.activeData=nil;
    self.delegate=nil;
    NSLog(@"connectionDidFinishLoading");
}
@end
