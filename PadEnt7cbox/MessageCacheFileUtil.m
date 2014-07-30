//
//  MessageCacheFileUtil.m
//  tigerTalker
//
//  Created by hudie on 14-6-26.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import "MessageCacheFileUtil.h"
NSString *const originFile = @"origin";
NSString *const mp3File = @"mp3File_";

@implementation MessageCacheFileUtil

static MessageCacheFileUtil *sharedInstance;

+ (MessageCacheFileUtil *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[MessageCacheFileUtil alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    return [super init];
}

- (NSString *)userDocPathAndIsMp3:(BOOL)isMp3 {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *userFolderPathh;
    if (isMp3) {
        userFolderPathh = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",mp3File]];
    }else {
        userFolderPathh = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",originFile]];

    }
       NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFolderPathh]) {
        [fileManager createDirectoryAtPath:userFolderPathh withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userFolderPathh;
}

- (void)deleteWithContentPath:(NSString *)thePath {
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:thePath]) {
        [fileManager removeItemAtPath:thePath error:&error];
    }
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

@end
