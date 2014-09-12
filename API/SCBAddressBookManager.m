//
//  SCBAddressBookManager.m
//  icoffer
//
//  Created by Yangsl on 14-8-27.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "SCBAddressBookManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"

@implementation SCBAddressBookManager
@synthesize delegate,tableData,connection;

//请求用户信息
-(void)requestAddressBookUser
{
    self.tableData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,DEPT_FIND_ALLDEPTSYS]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [request setHTTPMethod:@"POST"];
    connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //网络链接失败
    [self.delegate requestFailAddressBookUser:nil];
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
    [self.delegate requestSuccessAddressBookUser:dic];
}

@end
