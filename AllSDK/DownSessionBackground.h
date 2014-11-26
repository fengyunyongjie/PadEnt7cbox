//
//  DownSessionBackground.h
//  Background
//
//  Created by Yangsl on 14-10-10.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownSessionBackgroundDelegate <NSObject>

- (void)requestDownloadFinishDictionary:(NSDictionary *)dictionary;

@end

@interface DownSessionBackground : NSObject<NSURLSessionDownloadDelegate>

@property(nonatomic, assign) BOOL isBackGround;
@property(nonatomic, strong, readonly) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, weak) id<DownSessionBackgroundDelegate> sessionDelegate;
@property(nonatomic, assign) double startTime;
@property (nonatomic, retain) NSString *file_path;

-(id)init;

-(void)startDownBackground:(NSMutableURLRequest *)request;
-(void)stopDownBackground;

@end
