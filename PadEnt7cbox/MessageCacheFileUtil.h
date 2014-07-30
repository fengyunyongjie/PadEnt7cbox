//
//  MessageCacheFileUtil.h
//  tigerTalker
//
//  Created by hudie on 14-6-26.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageCacheFileUtil : NSObject

+ (MessageCacheFileUtil *)sharedInstance;

- (NSString *)userDocPathAndIsMp3:(BOOL)isMp3;
- (void)deleteWithContentPath:(NSString *)thePath;

@end
