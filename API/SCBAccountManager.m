//
//  SCBAccountManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import "SCBAccountManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "MF_Base64Additions.h"
#import "YNFunctions.h"

#import "AppDelegate.h"
#import "APService.h"
static SCBAccountManager *_sharedAccountManager;
@implementation SCBAccountManager
+(SCBAccountManager *)sharedManager
{
    if (_sharedAccountManager==nil) {
        _sharedAccountManager=[[self alloc] init];
    }
    return _sharedAccountManager;
}
-(void)getUserInfo
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetInfo;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_INFO_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)checkNewVersion:(NSString *)version
{
    self.activeData=[NSMutableData data];
    self.type=kUserCheckVersion;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,VERSION_CHECK_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"version=%@&type=%@",version,@"1"];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)currentProfile
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetProfile;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_PROFILE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)getVcard
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetVcard;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_GETVCARD_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)getUserList
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetList;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)currentUserSpace
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetSpace;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_SPACE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"type=1"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
    self.activeData=[NSMutableData data];
    self.type=kUserLogin;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_LOGIN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *mi_ma =[user_pwd base64String];
    [body appendFormat:@"usr_account=%@&usr_pwd=%@",user_name,mi_ma];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)UserLogout
{
    
}
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
    self.activeData=[NSMutableData data];
    self.type=kUserRegist;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_REGISTER_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *mi_ma =[user_pwd base64String];
    [body appendFormat:@"usr_name=%@&usr_pwd=%@&check_code=%@",user_name,mi_ma,@"23452"];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
#pragma mark NSURLConnectionDelegate Method
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

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
    [self.activeData appendData:data];
    NSLog(@"connection:didReceiveData:");
    //    assert(theConnection == self.connection);
    
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    NSLog(@"connection:didFailWithError");
#pragma unused(theConnection)
#pragma unused(error)
    //    assert(theConnection == self.connection);
    //
    //    [self stopSendWithStatus:@"Connection failed"];
    if (self.delegate) {
        [self.delegate networkError];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    NSLog(@"connectionDidFinishLoading");
//    NSLog(@"%@",[[NSString alloc] initWithData:self.activeData encoding:NSUTF8StringEncoding]);
    NSError *jsonParsingError=nil;
    if (self.activeData==nil) {
        NSLog(@"!!!数据错误!!");
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    switch (self.type) {
        case kUserCheckVersion:
            NSLog(@"检测版本成功：\n%@",dic);
            if (dic==nil||[dic objectForKey:@"code"]==nil) {
                [self.delegate checkVersionFail];
            }else
            {
                [self.delegate checkVersionSucceed:dic];
            }
            break;
        case kUserGetInfo:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"获取用户信息成功:\n%@",dic);
                [self.delegate getUserInfoSucceed:dic];
            }else
            {
                [self.delegate getUserInfoFail];
            }
            break;
        case kUserGetVcard:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"Vcard获取成功:\n%@",dic);
                [self.delegate getVcardSucceed:dic];
            }else
            {
                [self.delegate getVcardFail];
            }
            break;
        case kUserGetList:
             if ([[dic objectForKey:@"code"] intValue]==0) {
                 NSLog(@"用户列表获取成功:\n%@",dic);
                 [self.delegate getUserListSucceed:dic];
             }else
             {
                 [self.delegate getUserListFail];
             }
            break;
        case kUserLogin:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"登录成功:\n%@",dic);
//                [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"usr_id"]];
//                [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"usr_token"]];
//                [[SCBSession sharedSession] setHomeID:(NSString *)[dic objectForKey:@"home_id"]];
                [[SCBSession sharedSession] setSpaceID:(NSString *)[dic objectForKey:@"per_space"]];
                [[SCBSession sharedSession] setUserTag:(NSString *)[dic objectForKey:@"usr_tag"]];
                [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"ent_uid"]];
                [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"ent_utoken"]];
                [[SCBSession sharedSession] setEnt_utype:(NSString *)[dic objectForKey:@"ent_utype"]];
                [[SCBSession sharedSession] setEntjpush:(NSString *)[dic objectForKey:@"entjpush"]];
                
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"ent_uid"] forKey:@"usr_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"ent_utoken"]  forKey:@"usr_token"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"home_id"]  forKey:@"home_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"per_space"]  forKey:@"space_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_tag"]  forKey:@"usr_tag"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"ent_utype"]  forKey:@"ent_utype"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"entjpush"]  forKey:@"entjpush"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"%@",[[SCBSession sharedSession] userId]);
                NSLog(@"%@",[[SCBSession sharedSession] userToken]);
                [self.delegate loginSucceed:self];
            }else
            {
                [self.delegate loginUnsucceed:dic];
            }

            break;
        case kUserRegist:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"注册成功:\n%@",dic);
                [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"usr_id"]];
                [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"usr_token"]];
                [[SCBSession sharedSession] setHomeID:(NSString *)[dic objectForKey:@"home_id"]];
                [[SCBSession sharedSession] setSpaceID:(NSString *)[dic objectForKey:@"space_id"]];
                [[SCBSession sharedSession] setUserTag:(NSString *)[dic objectForKey:@"usr_tag"]];
                
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_id"] forKey:@"usr_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_token"]  forKey:@"usr_token"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"home_id"]  forKey:@"home_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"space_id"]  forKey:@"space_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_tag"]  forKey:@"usr_tag"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.delegate registSucceed];
            }else
            {
                NSLog(@"注册失败！！！");
                [self.delegate registUnsucceed:self];
            }
            break;
        case kUserGetSpace:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"data=%@",dic);
                //NSLog(@"空间（已用大小/总大小） ： %@/%@",[dic objectForKey:@"space_used"],[dic objectForKey:@"space_total"]);
                //[self.delegate spaceSucceedUsed:[dic objectForKey:@"space_used"] total:[dic objectForKey:@"space_total"]];
                [self.delegate spaceSucceedUsed:[dic objectForKey:@"space_inuse"] total:[dic objectForKey:@"space_size"]];
            }else
            {
                
            }
            break;
        case kUserGetProfile:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"用户信获取成功 ： \n昵称：%@\n性别：%@\n生日：%@\n个人简介：%@",[dic objectForKey:@"nickname"],[dic objectForKey:@"gender"],[dic objectForKey:@"birthday"],[dic objectForKey:@"intro"]);
                [self.delegate nicknameSucessed:[dic objectForKey:@"nickname"]];
            }else
            {
                
            }
            break;
        default:
            break;
    }
    
    if ([[dic objectForKey:@"code"] intValue]==10) {
        //    DBSqlite3 *sql = [[DBSqlite3 alloc] init];
        //    [sql cleanSql];
//        UserInfo *info = [[UserInfo alloc] init];
//        info.user_name = [NSString formatNSStringForOjbect:[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"]];
//        info.is_oneWiFi = [YNFunctions isOnlyWifi];
//        [info insertUserinfo];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
//        [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [APService setTags:nil alias:nil];
//        
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate.uploadmanage stopAllUpload];
//        [appDelegate.downmange stopAllDown];
//        appDelegate.uploadmanage.isJoin = NO;
//        appDelegate.downmange.isStart = NO;
//        
//        [[LTHPasscodeViewController sharedUser] hiddenPassword];
//        [appDelegate finishLogout];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//                                                            message:@"无访问权限"
//                                                           delegate:nil
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:@"确定", nil];
//        [alertView show];

    }
    
    
    NSLog(@"网络操作失败：");
    NSLog(@"%@",dic);
    self.activeData=nil;
}
@end
