//
//  DwonFile.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DwonFile.h"
#import "YNFunctions.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "MF_Base64Additions.h"
#import "Reachability.h"
#import "NSString+Format.h"
#import "DownSessionBackground.h"
#import "AppDelegate.h"
@implementation DwonFile
@synthesize delegate,downsize,imageConnection,imageViewIndex,file_id,index,showType,indexPath,isStop,macTimeOut,fileSize,fileName,file_path;

- (void)startDownload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread detachNewThreadSelector:@selector(isNetWork) toTarget:self withObject:nil];
    });
}

-(void)isNetWork
{
    if([self isConnection] == ReachableViaWiFi)
    {
        
    }
    else if([self isConnection] == ReachableViaWWAN)
    {
        if([YNFunctions isOnlyWifi])
        {
            //等待WiFi
            [delegate upWaitWiFi];
            return;
        }
    }
    else
    {
        //网络连接断开
        [delegate upNetworkStop];
        return;
    }
    
    downsize = 0;
    endSudu = 0;
    NSString *documentDir = [YNFunctions getFMCachePath];
    NSArray *array=[fileName componentsSeparatedByString:@"/"];
    //NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,file_id];
    NSString *createPath = [NSString stringWithFormat:@"%@",documentDir];
    [NSString CreatePath:createPath];
    file_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    //查询本地是否已经有该图片
    BOOL bl = [NSString image_exists_FM_file_path:file_path];
    if(bl)
    {
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:file_path];
        bl = fileSize==[[handle availableData] length];
    }
    
    if(bl)
    {
        [delegate downFinish:file_path];
    }
    else
    {
//        file_path = [NSString stringWithFormat:@"%@.data",file_path];
//        assert(file_path!=nil);
//        self.fileStream=[NSOutputStream outputStreamToFileAtPath:file_path append:NO];
//        assert(self.fileStream!=nil);
//        [self.fileStream open];
        
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?ent_uid=%@&fids[]=%@",SERVER_URL,FM_DOWNLOAD_URI,[NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]],file_id]];
        NSLog(@"url:%@",s_url);
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        
        [request setHTTPMethod:@"GET"];

        dispatch_async(dispatch_get_main_queue(), ^{
            //后台
      
            DownSessionBackground *sessionBackground = [[DownSessionBackground alloc] init];
            sessionBackground.file_path = file_path;
            sessionBackground.sessionDelegate = self;
            [sessionBackground startDownBackground:request];
            //imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
          
        });
    }
}

//判断当前的网络是3g还是wifi
-(NetworkStatus) isConnection
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReach currentReachabilityStatus];
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
        NSLog(@"暂停下载");
        [delegate upError];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL bl = [fileManager removeItemAtPath:file_path error:nil];
        if(bl)
        {
            NSLog(@"删除临时文件成功");
        }
    }
    NSLog(@"下载的大小:%i",[data length]);
    downsize += [data length];
    
    if([delegate respondsToSelector:@selector(downCurrSize:)])
    {
        [delegate downCurrSize:downsize];
    }
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
            //下载文件失败
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
    if(delegate && [delegate respondsToSelector:@selector(upError)])
    {
        [delegate upError];
    }
}

- (void)requestDownloadFinishDictionary:(NSDictionary *)dictionary  {
    //下载完成
    if(file_path)
    {
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:file_path];
        BOOL bl = fileSize==[[handle availableData] length];
        if(bl)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *resource = [file_path substringToIndex:file_path.length-5];
            [fileManager moveItemAtPath:file_path
                                 toPath:resource
                                  error:nil];
            [delegate downFinish:resource];
        }
        else
        {
            [delegate didFailWithError];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //下载完成
    if(file_path)
    {
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:file_path];
        BOOL bl = fileSize==[[handle availableData] length];
        if(bl)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *resource = [file_path substringToIndex:file_path.length-5];
            [fileManager moveItemAtPath:file_path
                                 toPath:resource
                                  error:nil];
            [delegate downFinish:resource];
        }
        else
        {
            [delegate didFailWithError];
        }
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *ponse = (NSHTTPURLResponse *)response;
    if(ponse.statusCode == 404)
    {
        file_path = nil;
    }
    
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{

}

@end
