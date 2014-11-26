//
//  UploadSessionBackgound.m
//  icoffer
//
//  Created by Yangsl on 14-10-20.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "UploadSessionBackgound.h"

@implementation UploadSessionBackgound
@synthesize urlSession,sesssionDataTask,sessioinDelegate,startTime;

-(NSURLSession *)urlSession
{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfiguration: @"com.zhou-he.PadEnt7cbox.UploadSessionBackgound"];
        session = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:nil];
    });
    return session;
}

-(void)startBackground:(NSMutableURLRequest *)request
{
    self.sesssionDataTask = [self.urlSession uploadTaskWithStreamedRequest:request];
    [self.sesssionDataTask resume];
    self.startTime = [[NSDate date] timeIntervalSince1970];
}


-(void)stopUploadBackground
{
    [self.sesssionDataTask cancel];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    if(data==nil)
    {
        [self.sessioinDelegate requestUploadFinishDictionary:nil];
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"dict:%@",dict);
    [self.sessioinDelegate requestUploadFinishDictionary:dict];
    double endTime = [[NSDate date] timeIntervalSince1970];
    endTime  = fabs(endTime-self.startTime);
    double length = [data length];
    NSString *sudu = [NSString getFormatSudu:endTime lenght:length];
    NSLog(@"上传速度为:%@",sudu);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [self.sessioinDelegate requestUploadFinishDictionary:nil];
}

@end
