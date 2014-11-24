//
//  SCBSubJectManager.m
//  icoffer
//
//  Created by Yangsl on 14-7-8.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "IPSCBSubJectManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "YNFunctions.h"

@implementation IPSCBSubJectManager
@synthesize delegate,mtype,tableData,connection;

-(void)requestSubjectList:(NSString *)user_id
{
    //请求专题列表
    self.mtype=kLMTypeSubjectList;
    self.tableData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_LIST_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"user_id=%@",[[SCBSession sharedSession] userId]];
    NSLog(@"body: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)requestSubjectEventOfInfo:(NSString *)subject_id user_id:(NSString *)user_id
{
    //主题动态信息
    self.mtype=kLMTypeSubjectInfo;
    self.tableData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_ACTIVITY_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"user_id=%@",user_id];
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
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

//获取成员列表
- (void)getMemeberList {
    self.tableData=[NSMutableData data];
    self.mtype = kLMTypeGetMemberList;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_MEMBER_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

//新建专题
- (void)createSubjectWithName:(NSString *)subName remark:(NSString *)subRemark publish:(int)isPublish adduser:(int)isAdduser members:(NSArray *)subMember{
    
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSubjectNew;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_CREATE_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"subj_name=%@",subName];
    [body appendFormat:@"&subj_comment=%@",subRemark];
    [body appendFormat:@"&subj_is_publish=%d",isPublish];
    [body appendFormat:@"&subj_is_adduser=%d",isAdduser];
    
    NSString *memberStr=[subMember componentsJoinedByString:@"&membersid[]="];
    [body appendFormat:@"&membersid[]=%@",memberStr];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


//get subject group list
- (void)getSubjectList {
    
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeGetSubjectListFromFile;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_LIST_PUBLISH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *userid = [[SCBSession sharedSession] userId];
    [body appendFormat:@"user_id=%@",userid];
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

//发布资源
- (void)publishResourceWithSubjectId:(NSArray *)sub_ids res_file:(NSArray *)fileIds res_folder:(NSArray *)folderIds res_url:(NSArray *)urlStrings res_descs:(NSArray *)urlDesces comment:(NSString *)sub_comment{
    
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypePublishResourceFromFile;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}


//获取专题右侧栏信息
- (void)getSubjectInfoWithSubjectId:(NSString *)sub_id {
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSubjectRightInfo;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_INFORIGHT_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *userid = [[SCBSession sharedSession] userId];
    [body appendFormat:@"user_id=%@",userid];
    [body appendFormat:@"&subject_id=%@",sub_id];
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)getResourceListWithSubjectId:(NSString *)sub_id resourceUserIds:(NSString *)res_userId resourceType:(NSString *)res_type resourceTitil:(NSString *)res_title {
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSubjectResourcesList;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

//获取动态的总个数
- (void)getSubjectSum
{
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSubjectSum;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SM_SUM_SUBJECT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPMethod:@"POST"];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

//发布评论
- (void)sendCommentWithResourceId:(NSString *)res_id subjectId:(NSString *)sub_id content:(NSString *)aContent type:(NSString *)comment_type seconds:(NSString *)audioLen {
    
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSendComment;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

//获取评论
- (void)getCommentListWithResourceId:(NSString *)res_id {
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeGetCommentList;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)getResouceFileWithSubjectId:(NSString *)sub_id f_id:(NSString *)fid {
    
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeGetResourceFile;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)requestSubjectIsExistWithResouceId:(NSString *)resouceId
{
    self.tableData = [NSMutableData data];
    self.mtype = kLMTypeSubjectResourcesExist;
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
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //网络链接失败
    switch (mtype) {
        case kLMTypeSubjectList:
            [self.delegate requestSubJectListFail:nil];
            break;
        case kLMTypeSubjectInfo:
            [self.delegate requestSubjectEventOfInfoFail:nil];
            [self.delegate networkError];
            break;
        case kLMTypeGetMemberList:
            [self.delegate getMemberListunsuccess:@"网络有问题"];
            break;
        case kLMTypeSubjectNew:
            [self.delegate createSubjectUnsuccess:@"网络有问题"];
            break;
        case kLMTypeGetSubjectListFromFile:
            [self.delegate checkSubjectListUnsuccess:@"网络有问题"];
            break;
        case kLMTypePublishResourceFromFile:
            [self.delegate publishUnsuccess:@"网络有问题"];
            break;
        case kLMTypeSubjectRightInfo:
            [self.delegate networkError];
            [self.delegate getSubjectInfoUnsuccess:@"网络有问题"];
            break;
        case kLMTypeSubjectResourcesList:
            [self.delegate getResourceListunsccess:@"网络有问题"];
            [self.delegate networkError];
            break;
        case kLMTypeSubjectSum:
            [self.delegate getSubjectSumunSuccess:@"网络有问题"];
            break;
        case kLMTypeSendComment:
            [self.delegate sendCommentunsuccess:@"网络有问题"];
            break;
        case kLMTypeGetCommentList:
            [self.delegate getCommentListunsccess:@"网络有问题"];
            break;
        case kLMTypeGetResourceFile:
            [self.delegate getResourceFileUnsuccess:@"网络有问题"];
            break;
        case kLMTypeSubjectResourcesExist:
            [self.delegate getResourceExistUnsuccess:@"网络有问题"];
            break;
        default:
            break;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //接受数据流
    [self.tableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //网络请求成功
    NSError *jsonParsingError=nil;
    if (self.tableData==nil) {
        NSLog(@"!!!数据错误!!");
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.tableData options:0 error:&jsonParsingError];
//    if([dic objectForKey:@"code"])
    {
        switch (mtype) {
            case kLMTypeSubjectList:
                [self.delegate requestSubJectListSuccess:dic];
                break;
            case kLMTypeSubjectInfo:
                [self.delegate requestSubjectEventOfInfoSuccess:dic];
                break;
            case kLMTypeGetMemberList:
                [self.delegate getMemberListSuccess:dic];
                break;
            case kLMTypeSubjectNew:
                [self.delegate createSubjectSuccess:[dic objectForKey:@"sub_id"]];
                break;
            case kLMTypeGetSubjectListFromFile:
                [self.delegate checkSubjectListSuccess:dic];
                break;
            case kLMTypePublishResourceFromFile:
                [self.delegate publishSuccess];
                break;
            case kLMTypeSubjectRightInfo:
                [self.delegate getSubjectInfoSuccess:dic];
                break;
            case kLMTypeSubjectResourcesList:
                [self.delegate getResourceListSuccess:dic];
                break;
            case kLMTypeSubjectSum:
                [self.delegate getSubjectSumSuccess:dic];
                break;
            case kLMTypeSendComment:
                [self.delegate sendCommentSuccess];
                break;
            case kLMTypeGetCommentList:
                [self.delegate getCommentListSuccess:dic];
                break;
            case kLMTypeGetResourceFile:
                [self.delegate getResourceFileSuccess:dic];
                break;
            case kLMTypeSubjectResourcesExist:
                [self.delegate getResourceExistSuccess:dic];
                break;
            default:
                break;
        }
    }
}

@end
