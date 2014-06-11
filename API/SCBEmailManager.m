//
//  SCBEmailManager.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SCBEmailManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
@implementation SCBEmailManager
-(void)cancelAllTask
{
    self.delegate=nil;
}
-(void)listEmailWithType:(NSString *)type  //type 0为收件箱，1为发件箱，2为所有
{
    self.em_type=kEMTypeList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
//    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&cursor=%d&offset=%d",type,0,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)operateUpdateWithType:(NSString *)type  //type 0为收件箱，1为发件箱，2为所有
{
    self.em_type=kEMTypeOperate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&cursor=%d&offset=%d",type,0,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)detailEmailWithID:(NSString *)eid type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDetail;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DETAIL_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&eid=%@",type,eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)sendInteriorEmailToUser:(NSArray *)usrids Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids
{
    self.em_type=kEMTypeSendInterior;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_SENDIN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&fids[]="];
    NSString *usrids_str=[usrids componentsJoinedByString:@"&usrids[]="];
    [body appendFormat:@"fids[]=%@&usrids[]=%@&content=%@&title=%@",fids_str,usrids_str,content,title];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)sendExternalEmailToUser:(NSString *)recevers Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids
{
    self.em_type=kEMTypeSendExternal;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_SENDOUT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fids[]=%@&recevers=%@&content=%@&title=%@",fids_str,recevers,content,title];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)removeEmailWithID:(NSString *)eid type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DEL_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&eid=%@",type,eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)removeEmailWithIDs:(NSArray *)eids type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DELALL_URL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *e_ids=[eids componentsJoinedByString:@"&eids[]="];
    [body appendFormat:@"type=%@&eids[]=%@",type,e_ids];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)getEmailTemplateWithName:(NSString *)filenames
{
    self.em_type=kEMTypeGetTemplate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_TEMPLATE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"filenames=%@",filenames];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)fileListWithID:(NSString *)eid
{
    self.em_type=kEMTypeFileList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_FILELIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"eid=%@",eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//收件箱列表
-(void)receiveListWithCursor:(int)cursor offset:(int)offset subject:(NSString*)subject
{
    self.em_type=kEMTypeReceiveList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,RECEIVE_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"cursor=%d&offset=%d&subject=%@",cursor,offset,subject];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//发件箱列表
-(void)sendListWithCursor:(int)cursor offset:(int)offset subject:(NSString *)subject
{
    self.em_type=kEMTypeSendList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SEND_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"cursor=%d&offset=%d&subject=%@",cursor,offset,subject];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//发送文件
-(void)sendFilesWithSubject:(NSString*)send_subject userids:(NSArray*)userids usernames:(NSArray*)usernames useremails:(NSArray *)useremails sendfiles:(NSArray*)sendfiles message:(NSString*)send_message
{
    self.em_type=kEMTypeSendFiles;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SEND_FILES_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
//    NSString *u_ids=[userids componentsJoinedByString:@"&userids[]="];
//    NSString *u_names=[usernames componentsJoinedByString:@"&usernames[]="];
    NSString *files=[sendfiles componentsJoinedByString:@"&sendfiles[]="];
    NSMutableString *u_emails = [[NSMutableString alloc] init];
    for(int i=0;i<useremails.count;i++)
    {
        NSString *email_string = [useremails objectAtIndex:i];
        [u_emails appendString:email_string];
        if(i+1<useremails.count)
        {
            [u_emails appendString:@";"];
        }
    }
    
    [body appendFormat:@"send_subject=%@&useremails=%@&sendfiles[]=%@&send_message=%@",send_subject,u_emails,files,send_message];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//收件浏览
-(void)viewReceiveWithID:(NSString *)re_id
{
    self.em_type=kEMTypeViewReceive;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,VIEW_RECEIVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"re_id=%@",re_id];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//发件浏览
-(void)viewSendWithID:(NSString *)send_id
{
    self.em_type=kEMTypeViewSend;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,VIEW_SEND_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"send_id=%@",send_id];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//未读邮件数量
-(void)notReadCount
{
    self.em_type=kEMTypeNotReadCount;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,NOTREADCOUNT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
//    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//快速创建外链
-(void)createLinkWithFids:(NSArray *)fids
{
    self.em_type=kEMTypeCreateLink;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,CREATE_LINK_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&f_ids[]="];
    [body appendFormat:@"f_ids[]=%@&authorize=0&ecode=&endtime=&type=1&title=%@&content=%@&copylist=&receivelist=%@&randomNum=",fids_str,@"",@"",@""];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usrid"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//创建邮件外链
-(void)createLinkMailWithFids:(NSArray *)fids title:(NSString *)title content:(NSString *)content receivelist:(NSString *)receivelist
{
    self.em_type=kEMTypeCreateLink;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,CREATE_LINK_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&f_ids[]="];
    [body appendFormat:@"f_ids[]=%@&authorize=0&ecode=&endtime=&type=0&title=%@&content=%@&copylist=&receivelist=%@&randomNum=",fids_str,title,content,receivelist];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usrid"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//邮件外链主题模版
-(void)getEmailTitle
{
    self.em_type=kEMTypeNotReadCount;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_TITLE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usrid"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    //    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//删除收件
-(void)delReceiveWithID:(NSArray *)re_ids
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,DEL_RECEIVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *eids=[re_ids componentsJoinedByString:@"&re_ids[]="];
    [body appendFormat:@"re_ids[]=%@",eids];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//删除发件
-(void)delSendWithID:(NSArray *)send_ids
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,DEL_SEND_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *eids=[send_ids componentsJoinedByString:@"&send_ids[]="];
    [body appendFormat:@"send_ids[]=%@",eids];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
//批量已读接口
-(void)setReadWithIDs:(NSArray *)re_ids
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SET_READ_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *eids=[re_ids componentsJoinedByString:@"&re_ids[]="];
    [body appendFormat:@"re_ids[]=%@",eids];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
//    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}

//新批量删除发件
-(void)delFilesSendByUserId
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,DELFILES_SEND_USERID]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}

//新收件箱内容全部标记成已读
-(void)updateReceiveIsReadByUserID
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,UPDATERECEIVE_ISREAD_USERID]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
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
    if (self.em_type==kEMTypeFileList) {
        @try {
            if ([[dic objectForKey:@"code"] intValue]!=0) {
                NSLog(@"获取空间列表返回错误");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"有异常～,说明成功？？");
            if (self.delegate) {
                [self.delegate fileListSucceed:self.activeData];
            }
        }
        @finally {
            NSLog(@"%@",dic);
            NSLog(@"@finally");
        }
    }else if ([[dic objectForKey:@"code"] intValue]==0) {
        NSLog(@"操作成功 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            switch (self.em_type) {
                case kEMTypeList:
                    [self.delegate listEmailSucceed:dic];
                    break;
                case kEMTypeDetail:
                    [self.delegate detailEmailSucceed:dic];
                    break;
                case kEMTypeSendExternal:
                    [self.delegate sendEmailSucceed];
                    break;
                case kEMTypeSendInterior:
                    [self.delegate sendEmailSucceed];
                    break;
                case kEMTypeDelete:
                    [self.delegate removeEmailSucceed];
                    break;
                case kEMTypeOperate:
                    [self.delegate operateSucceed:dic];
                    break;
                case kEMTypeGetTemplate:
                    [self.delegate getEmailTemplateSucceed:dic];
                    break;
                case kEMTypeReceiveList:
                    [self.delegate receiveListSucceed:dic];
                    break;
                case kEMTypeSendList:
                    [self.delegate sendListSucceed:dic];
                    break;
                case kEMTypeSendFiles:
                    [self.delegate sendFilesSucceed:dic];
                    break;
                case kEMTypeViewReceive:
                    [self.delegate viewReceiveSucceed:dic];
                    break;
                case kEMTypeViewSend:
                    [self.delegate viewSendSucceed:dic];
                    break;
                case kEMTypeNotReadCount:
                    [self.delegate notReadCountSucceed:dic];
                    break;
                case kEMTypeCreateLink:
                    [self.delegate createLinkSucceed:dic];
                    break;
                case kEMTypeGetEmailTitle:
                    [self.delegate getEmailTitleSucceed:dic];
                    break;
            }
        }
    }else
    {
        if (self.delegate) {
            switch (self.em_type) {
                case kEMTypeList:
//                        [self.delegate listEmailSucceed:dic];
                    break;
                case kEMTypeDetail:
//                        [self.delegate detailEmailSucceed:dic];
                    break;
                case kEMTypeSendExternal:
                    [self.delegate sendEmailFail];
                    break;
                case kEMTypeSendInterior:
                    [self.delegate sendEmailFail];
                    break;
                case kEMTypeDelete:
                    [self.delegate removeEmailFail];
                    break;
                case kEMTypeGetTemplate:
                    [self.delegate getEmailTemplateFail];
                    break;
                    
            }
        }
    }
    self.activeData=nil;
    self.delegate=nil;
    NSLog(@"connectionDidFinishLoading");
    //UIImage *image=[[UIImage alloc] initWithData:self.activeDownload];
}
@end
