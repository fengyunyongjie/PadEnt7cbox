//
//  SeesionConnection.h
//  Edunbao
//
//  Created by Yangsl on 14/11/3.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SeesionConnectionDelegate <NSObject>

-(void)requestSeesionConnectionDictionary:(NSDictionary *)dictionary;

@end

@interface SeesionConnection : NSObject

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionDownloadTask *sesssionDataTask;
@property(nonatomic, weak) id<SeesionConnectionDelegate> sessioinDelegate;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopDownBackground;

@end
