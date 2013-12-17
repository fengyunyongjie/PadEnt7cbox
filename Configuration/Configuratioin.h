//
//  Configuratioin.h
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-16.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuratioin : NSObject
{
    NSDictionary *dictionary;
}

- (id)initWithPlistIsDefault:(BOOL)bl;

- (NSString*)GetWithKey:(NSString*)key;

@end
