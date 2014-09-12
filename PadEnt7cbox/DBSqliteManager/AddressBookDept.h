//
//  AddressBookDept.h
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"

#define InsertAddressBookDeptList @"INSERT INTO AddressBookDeptList(dept_id,dept_pid,dept_pid_path,dept_name,dept_number,ent_id) VALUES (%i,%i,'%@','%@',%i,%i)"
#define DeleteAddressBookDeptList @"DELETE FROM AddressBookDeptList WHERE dept_id=%i"
#define DeleteAllAddressBookDeptList @"DELETE FROM AddressBookDeptList"
#define UpdateAddressBookDeptList @"UPDATE AddressBookDeptList SET dept_pid_path=?,dept_name=?,dept_number=?,ent_id=? WHERE dept_id=? and dept_pid=?"
#define SelectAddressBookDeptListIsHave @"SELECT * FROM AddressBookDeptList WHERE dept_id=? and  dept_pid=?"
#define SelectAddressBookDeptList @"SELECT * FROM AddressBookDeptList WHERE dept_pid=?"
#define SelectAddressBookDeptListForDeptId @"SELECT * FROM AddressBookDeptList WHERE dept_id=?"
#define SelectAllAddressBookDeptList @"SELECT * FROM AddressBookDeptList WHERE dept_pid=-1"

@interface AddressBookDept : DBSqlite3

@property(nonatomic, assign) NSInteger user_id;
@property(nonatomic, assign) NSInteger dept_id;
@property(nonatomic, assign) NSInteger dept_pid;
@property(nonatomic, strong) NSString *dept_pid_path;
@property(nonatomic, strong) NSString *dept_name;
@property(nonatomic, assign) NSInteger dept_number;
@property(nonatomic, assign) NSInteger ent_id;
@property(nonatomic, strong) NSMutableArray *userArray;
@property(nonatomic, strong) NSMutableArray *deptArray;
@property(nonatomic, assign) BOOL checked;

//解析user数据
-(NSMutableArray *)getDeptArray:(NSArray *)array;
//添加数据
-(BOOL)insertAllAddressBookDeptList:(NSMutableArray *)tableArray;
//删除数据
-(BOOL)deleteAddressBookDeptList;
//删除所有数据
-(BOOL)deleteAllAddressBookDeptList;
//修改数据
-(BOOL)updateAddressBookDeptList;
//查询数据是否存在
-(BOOL)selectAddressBookDeptListIsHave;
//查询数据
-(NSMutableArray *)selectAddressBookDeptListForDeptPid;
//查询所有数据
-(NSMutableArray *)selectAllAddressBookDeptList;
//查询所有数据
-(NSMutableArray *)selectAllAddressBookDeptListForDeptId;
//查询根目录数据
-(NSMutableArray *)selectBaseAddressBookDeptList;

@end