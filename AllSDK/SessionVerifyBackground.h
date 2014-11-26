//
//  SessionVerifyBackground.h
//  Edunbao
//
//  Created by Yangsl on 14/10/31.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionVerifyBackgroundDelegate <NSObject>

-(void)requestVerifyDictionary:(NSDictionary *)dictionary;

@end

@interface SessionVerifyBackground : NSObject

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionDownloadTask *sesssionDataTask;
@property(nonatomic, weak) id<SessionVerifyBackgroundDelegate> sessioinDelegate;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopDownBackground;

@end
