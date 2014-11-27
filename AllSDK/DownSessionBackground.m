//
//  DownSessionBackground.m
//  Background
//
//  Created by Yangsl on 14-10-10.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "DownSessionBackground.h"

@implementation DownSessionBackground
@synthesize isBackGround,urlSession,downloadTask,startTime,sessionDelegate;

-(id)init
{
    static DownSessionBackground *background;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        background = [super init];
    });
    return background;
}

-(NSURLSession *)urlSession
{
    static NSURLSession *backgroundSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.zhou-he.PadEnt7cbox.BackgroundSession"];
        backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return backgroundSession;
}

-(void)startDownBackground:(NSMutableURLRequest *)request
{
    self.downloadTask = [self.urlSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

-(void)stopDownBackground
{
    [self.downloadTask cancel];
}

#pragma mark NSURLSessionDelegate------

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSString *percentStr = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:currentProgress] numberStyle:NSNumberFormatterPercentStyle];
    NSLog(@"当前下载%@",percentStr);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载成功");
    NSLog(@"下载的文件路径：%@",location);
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentDir = [self getFMCachePath];
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSArray *array=[destinationFilename componentsSeparatedByString:@"/"];
    NSString *createPath = [NSString stringWithFormat:@"%@",documentDir];
    [self CreatePath:createPath];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
    NSURL *destinationURL = [NSURL fileURLWithPath:self.file_path];
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    BOOL success = [fileManager copyItemAtURL:location
                                        toURL:destinationURL
                                        error:&error];
    if(success)
    {
        NSLog(@"下载成功：%@",savedPath);
    }
    else
    {
        NSLog(@"下载失败");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sessionDelegate requestDownloadFinishDictionary:nil];
    });
}

-(NSString *)getFMCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/FMCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:attributes
                                                        error:nil];
    }
    return theFMCachePath;
}

-(void)CreatePath:(NSString *)urlPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:urlPath])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:urlPath
                                  withIntermediateDirectories:YES
                                                   attributes:attributes
                                                        error:nil];
    }
}

@end
