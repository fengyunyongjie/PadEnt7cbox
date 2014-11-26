//
//  SessionBackground.h
//  Background
//
//  Created by Yangsl on 14-10-9.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionBackgroundDelegate <NSObject>

-(void)requestCommitDictionary:(NSDictionary *)dictionary;

@end

@interface SessionBackground : NSObject<NSURLSessionTaskDelegate>

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionDownloadTask *sesssionDataTask;
@property(nonatomic, weak) id<SessionBackgroundDelegate> sessioinDelegate;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopDownBackground;

@end
