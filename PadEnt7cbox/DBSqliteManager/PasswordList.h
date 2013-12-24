//
//  PasswordList.h
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-20.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

@interface PasswordList : NSObject

@property(nonatomic,assign) NSInteger p_id;
@property(nonatomic,strong) NSString *p_text;
@property(nonatomic,assign) NSInteger p_fail_count;
@property(nonatomic,strong) NSString *p_ure_id;
@property(nonatomic,assign) NSInteger is_open;

@end
