//
//  SessionBackground.m
//  Background
//
//  Created by Yangsl on 14-10-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "SessionBackground.h"
#import "MF_Base64Additions.h"

@implementation SessionBackground
@synthesize urlSession,sesssionDataTask,sessioinDelegate;

-(NSURLSession *)urlSession
{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfiguration: @"com.zhou-he.PadEnt7cbox.SessionBackground"];
        session = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:nil];
    });
    return session;
}

-(void)startBackground:(NSMutableURLRequest *)request
{
    self.sesssionDataTask = [self.urlSession downloadTaskWithRequest:request];
    [self.sesssionDataTask resume];
}


-(void)stopDownBackground
{
    [self.sesssionDataTask cancel];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"url:%@",location);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [NSData dataWithContentsOfURL:location];
    if(data==nil)
    {
        [self.sessioinDelegate requestCommitDictionary:nil];
        NSError *error;
        [fileManager removeItemAtURL:location error:&error];
        NSLog(@"error:%@",error);
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"dict:%@",dict);
    [self.sessioinDelegate requestCommitDictionary:dict];
    NSError *error;
    [fileManager removeItemAtURL:location error:&error];
    NSLog(@"error:%@",error);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [self.sessioinDelegate requestCommitDictionary:nil];
}

@end
