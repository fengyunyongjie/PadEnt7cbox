//
//  Configuratioin.m
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-16.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "Configuratioin.h"

@implementation Configuratioin

- (id)initWithPlistIsDefault:(BOOL)bl;
{
    self = [super init];
    if (self)
    {
        NSString *plistName;
        if(bl)
        {
            plistName = @"PadEnt7cbox-config";
        }
        else
        {
            plistName = @"PadEnt7cbox-LanguageExtract";
        }
        NSString * langPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        NSDictionary *_dictionary = [NSDictionary dictionaryWithContentsOfFile:langPath];
        
        dictionary = [[NSDictionary alloc] initWithDictionary:_dictionary];
    }
    return self;
}

- (NSString*)GetWithKey:(NSString*)key
{
    NSString *string = [dictionary objectForKey:key];
    if (!string)
    {
        string = NSLocalizedString(key, nil);
    }
    NSString *value_string = [[NSString alloc] initWithFormat:@"%@",string];
    return value_string;
}

@end
