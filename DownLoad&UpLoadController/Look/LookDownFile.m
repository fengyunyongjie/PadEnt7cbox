//
//  LookDownFile.m
//  ndspro
//
//  Created by Yangsl on 13-10-15.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "LookDownFile.h"
#import "SCBoxConfig.h"
#import "YNFunctions.h"
#import "SCBSession.h"
#import "Reachability.h"

@implementation LookDownFile
@synthesize delegate,downsize,imageConnection,imageViewIndex,file_id,indexPath,isStop,macTimeOut,fileSize,fileName,file_path;

- (void)startDownload
{
    if(imageConnection)
    {
        return;
    }
    if([self isConnection] == ReachableViaWiFi)
    {
        
    }
    else if([self isConnection] == ReachableViaWWAN)
    {
        //网络连接断开
        [delegate didFailWithError];
        return;
    }
    else
    {
        //网络连接断开
        [delegate didFailWithError];
        return;
    }
    
    downsize = 0;
    endSudu = 0;
    
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[fileName componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    [NSString CreatePath:createPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    BOOL bl;
    bl = [NSString image_exists_FM_file_path:path];
    if(bl)
    {
        [delegate appImageDidLoad:imageViewIndex urlImage:path index:indexPath]; //将视图tag和地址派发给实现类
        return;
    }
    else
    {
        documentDir = [YNFunctions getProviewCachePath];
        createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
        [NSString CreatePath:createPath];
        path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        //查询本地是否已经有该图片
        bl = [NSString image_exists_at_file_path:path] && [UIImage imageWithContentsOfFile:path];
    }
    
    if(bl)
    {
        [delegate appImageDidLoad:imageViewIndex urlImage:path index:indexPath]; //将视图tag和地址派发给实现类
    }
    else
    {
        documentDir = [YNFunctions getProviewCachePath];
        createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
        [NSString CreatePath:createPath];
        file_path = [NSString stringWithFormat:@"%@/%@.data",createPath,[array lastObject]];
        assert(path!=nil);
        self.fileStream=[NSOutputStream outputStreamToFileAtPath:file_path append:NO];
        assert(self.fileStream!=nil);
        [self.fileStream open];
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?pic=1&fid=%@",SERVER_URL,FM_DOWNLOAD_Look,file_id]];
        NSLog(@"url:%@",s_url);
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        [request setHTTPMethod:@"GET"];
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
        [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
        imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)cancelDownload
{
    isStop = YES;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(isStop)
    {
        [imageConnection cancel];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL bl = [fileManager removeItemAtPath:file_path error:nil];
        NSLog(@"取消下载,删除临时文件：%i",bl);
        return;
    }
    NSLog(@"下载的大小:%i",[data length]);
    downsize += [data length];
#pragma unused(connection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(connection == self.imageConnection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [connection cancel];
            [delegate didFailWithError];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
    if(endSecond==todayComponent.second)
    {
        return;
    }
    [delegate downFile:downsize totalSize:downsize-endSudu];
    endSudu = downsize;
    macTimeOut += 10;
    NSMutableURLRequest *request = (NSMutableURLRequest *)[connection currentRequest];
    [request setTimeoutInterval:macTimeOut];
    endSecond = todayComponent.second;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"eeor:%@",error);
    if(delegate && [delegate respondsToSelector:@selector(didFailWithError)])
    {
        [delegate didFailWithError];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //下载完成
    if(file_path)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *resource = [file_path substringToIndex:file_path.length-5];
        [fileManager moveItemAtPath:file_path
                             toPath:resource
                              error:nil];
        [delegate appImageDidLoad:imageViewIndex urlImage:resource index:indexPath];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"response:%@",response);
    NSHTTPURLResponse *ponse = (NSHTTPURLResponse *)response;
    if(ponse.statusCode == 404)
    {
        file_path = nil;
    }
}

//判断当前的网络是3g还是wifi
-(NetworkStatus) isConnection
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReach currentReachabilityStatus];
}

@end
