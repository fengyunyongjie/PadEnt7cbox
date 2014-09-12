//
//  SCBAddressBookManager.h
//  icoffer
//
//  Created by Yangsl on 14-8-27.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCBAddressBookDelegate <NSObject>

//用户信息
-(void)requestSuccessAddressBookUser:(NSDictionary *)dictionary;
-(void)requestFailAddressBookUser:(NSDictionary *)dictionary;

@end

@interface SCBAddressBookManager : NSObject

@property(nonatomic, weak) id<SCBAddressBookDelegate> delegate;
@property(nonatomic, strong) NSMutableData *tableData;
@property(nonatomic, strong) NSURLConnection *connection;

//请求用户信息
-(void)requestAddressBookUser;
//请求部门信息
-(void)requestAddressBookDept;

@end
