//
//  SessionUploadState.h
//  Edunbao
//
//  Created by Yangsl on 14/11/13.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionUploadStateDelegate <NSObject>

-(void)requestUplaodStateDictionary:(NSDictionary *)dictionary;

@end

@interface SessionUploadState : NSObject<NSURLSessionDataDelegate>

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionDownloadTask *sesssionDataTask;
@property(nonatomic, weak) id<SessionUploadStateDelegate> sessioinDelegate;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopDownBackground;

@end
