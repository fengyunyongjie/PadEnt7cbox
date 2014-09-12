//
//  AddressBookUser.h
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"
#import "AddressBookDept.h"

#define InsertAddressBookUserList @"INSERT INTO AddressBookUserList(user_account,user_pwd,user_totalSize,user_userSize,user_createTime,user_state,user_passwordCheck,ent_id,dept_id,user_trueName,user_birthdayDate,user_sex,user_phone,user_picPath,user_post) VALUES ('%@','%@',%i,%i,'%@',%i,%i,%i,%i,'%@','%@',%i,'%@','%@','%@')"
#define DeleteAddressBookUserList @"DELETE FROM AddressBookUserList WHERE user_id=%i and user_account='%@'"
#define DeleteAllAddressBookUserList @"DELETE FROM AddressBookUserList WHERE user_account='%@'"
#define UpdateAddressBookUserList @"UPDATE AddressBookUserList SET user_pwd=?,user_totalSize=?,user_userSize=?,user_createTime=?,user_state=?,user_passwordCheck=?,ent_id=?,dept_id=?,user_trueName=?,user_birthdayDate=?,user_sex=?,user_phone=?,user_picPath=?,user_post=? WHERE user_id=? and user_account=?"
#define SelectAddressBookUserList @"SELECT * FROM AddressBookUserList WHERE user_account=?"
#define SelectAddressBookUserListForDeptId @"SELECT * FROM AddressBookUserList WHERE dept_id=?"
#define SelectAddressBookUserListForCount @"SELECT Count(*) FROM AddressBookUserList WHERE dept_id=?"
#define SelectAllAddressBookUserList @"SELECT * FROM AddressBookUserList"
#define SelectAddressBookUserListForString @"SELECT * FROM AddressBookUserList WHERE user_trueName like "
#define SelectAddressBookUserListForStringAndId @"SELECT * FROM AddressBookUserList WHERE dept_id=%i and user_trueName like "

//最近呼出
#define InsertRecentPhoneList @"INSERT INTO RecentPhoneList(user_account,user_pwd,user_totalSize,user_userSize,user_createTime,user_state,user_passwordCheck,ent_id,dept_id,user_trueName,user_birthdayDate,user_sex,user_phone,user_picPath,user_post,call_phone_account) VALUES ('%@','%@',%i,%i,'%@',%i,%i,%i,%i,'%@','%@',%i,'%@','%@','%@','%@')"
#define DeleteRecentPhoneList @"DELETE FROM RecentPhoneList WHERE user_id=%i and call_phone_account='%@'"
#define DeleteAllRecentPhoneList @"DELETE FROM RecentPhoneList WHERE call_phone_account='%@' and user_id<%i"
#define UpdateRecentPhoneList @"UPDATE RecentPhoneList SET user_pwd=?,user_totalSize=?,user_userSize=?,user_createTime=?,user_state=?,user_passwordCheck=?,ent_id=?,dept_id=?,user_trueName=?,user_birthdayDate=?,user_sex=?,user_phone=?,user_picPath=?,user_post=? WHERE user_id=? and user_account=?,call_phone_account=?"
#define SelectRecentPhoneList @"SELECT * FROM RecentPhoneList WHERE call_phone_account=?"
#define SelectRecentPhoneListForDeptId @"SELECT * FROM RecentPhoneList WHERE dept_id=? and call_phone_account=?"
#define SelectAllRecentPhoneList @"SELECT * FROM RecentPhoneList WHERE call_phone_account='%@' order by user_id desc limit 0,20"

@interface AddressBookUser : DBSqlite3

@property(nonatomic, assign) NSInteger user_id;
@property(nonatomic, strong) NSString *user_account;
@property(nonatomic, strong) NSString *user_pwd;
@property(nonatomic, assign) NSInteger user_totalSize;
@property(nonatomic, assign) NSInteger user_userSize;
@property(nonatomic, strong) NSString *user_createTime;
@property(nonatomic, assign) NSInteger user_state;
@property(nonatomic, assign) NSInteger user_passwordCheck;
@property(nonatomic, assign) NSInteger ent_id;
@property(nonatomic, assign) NSInteger dept_id;
@property(nonatomic, strong) NSString *user_trueName;
@property(nonatomic, strong) NSString *user_birthdayDate;
@property(nonatomic, assign) NSInteger user_sex;
@property(nonatomic, strong) NSString *user_phone;
@property(nonatomic, strong) NSString *user_picPath;
@property(nonatomic, strong) NSString *user_post;
@property(nonatomic, assign) BOOL checked;
@property(nonatomic, strong) AddressBookDept *dept;
@property(nonatomic, strong) NSString *call_phone_account;


//解析user数据
-(NSMutableArray *)getUserArray:(NSArray *)array;
//添加数据
-(BOOL)insertAllAddressBookUserList:(NSMutableArray *)tableArray;
//删除数据
-(BOOL)deleteAddressBookUserList:(NSMutableArray *)tableArray;
//删除所有数据
-(BOOL)deleteAllAddressBookUserList;
//修改数据
-(BOOL)updateAddressBookUserList;
//查询数据是否存在
-(BOOL)selectAddressBookUserListIsHave;
//查询数据
-(NSMutableArray *)selectAddressBookUserListForDept;
//查询所有数据
-(NSMutableArray *)selectAllAddressBookUserList;
-(NSInteger)selectAddressBookUserListForCount;
-(NSMutableArray *)selectAddressBookUserListForString:(NSString *)select_name;
//根据名称和id查询数据
-(NSMutableArray *)selectAddressBookUserListForString:(NSString *)select_name forWithDeptId:(NSInteger)select_deptid;

//添加数据
-(BOOL)insertAllRecentPhoneList:(NSMutableArray *)tableArray;
//删除数据
-(BOOL)deleteRecentPhoneList:(NSMutableArray *)tableArray;
//删除所有数据
-(BOOL)deleteAllRecentPhoneList;
//修改数据
-(BOOL)updateRecentPhoneList;
//查询数据是否存在
-(BOOL)selectRecentPhoneListIsHave;
//查询数据
-(NSMutableArray *)selectARecentPhoneListForDept;
//查询所有数据
-(NSMutableArray *)selectAllRecentPhoneList;

@end