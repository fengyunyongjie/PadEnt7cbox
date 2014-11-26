//
//  UploadSessionBackgound.h
//  icoffer
//
//  Created by Yangsl on 14-10-20.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadSessionBackgoundDelegate <NSObject>

-(void)requestUploadFinishDictionary:(NSDictionary *)dictionary;

@end

@interface UploadSessionBackgound : NSObject<NSURLSessionDataDelegate>

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionUploadTask *sesssionDataTask;
@property(nonatomic, weak) id<UploadSessionBackgoundDelegate> sessioinDelegate;
@property(nonatomic, assign) double startTime;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopUploadBackground;

@end
