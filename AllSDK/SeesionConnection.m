//
//  SeesionConnection.m
//  Edunbao
//
//  Created by Yangsl on 14/11/3.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "SeesionConnection.h"

@implementation SeesionConnection
@synthesize urlSession,sesssionDataTask,sessioinDelegate;

-(NSURLSession *)urlSession
{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfiguration: @"com.zhou-he.PadEnt7cbox.BackgroundSessionConnection"];
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [NSData dataWithContentsOfURL:location];
    if(data==nil)
    {
        [self.sessioinDelegate requestSeesionConnectionDictionary:nil];
        NSError *error;
        [fileManager removeItemAtURL:location error:&error];
        NSLog(@"error:%@",error);
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"dict:%@",dict);
    [self.sessioinDelegate requestSeesionConnectionDictionary:dict];
    NSError *error;
    [fileManager removeItemAtURL:location error:&error];
    NSLog(@"error:%@",error);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [self.sessioinDelegate requestSeesionConnectionDictionary:nil];
}

@end
