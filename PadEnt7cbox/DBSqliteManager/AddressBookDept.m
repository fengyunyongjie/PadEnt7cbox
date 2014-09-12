//
//  AddressBookDept.m
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "AddressBookDept.h"
#import "NSString+Format.h"
#import "YNFunctions.h"
#import "AddressBookUser.h"
#import "ChineseString.h"

@implementation AddressBookDept
@synthesize user_id,dept_id,dept_pid,dept_pid_path,dept_name,dept_number,ent_id,userArray,deptArray,checked;

//解析user数据
-(NSMutableArray *)getDeptArray:(NSArray *)array
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    for(int i=0;i<array.count;i++)
    {
        NSDictionary *dictioinary = [array objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = [[dictioinary objectForKey:@"dept_id"] intValue];
        list.dept_name = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"dept_name"]];
        list.dept_pid = [[dictioinary objectForKey:@"dept_pid"] intValue];
        list.dept_pid_path = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"dept_pids"]];
        list.ent_id = [[dictioinary objectForKey:@"ent_id"] intValue];
        BOOL bl = [list selectAddressBookDeptListIsHave];
        if(!bl)
        {
            [tableArray addObject:list];
        }
    }
    
//    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
//    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
//    for(int i=0;i<array.count;i++)
//    {
//        NSDictionary *dictioinary = [array objectAtIndex:i];
//        NSString *deptName = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"dept_name"]];
//        [stringArray addObject:deptName];
//        [tableArray addObject:deptName];
//    }
//    NSMutableArray *stringA = [ChineseString SortArray:stringArray];
//    for(int i=0;i<array.count;i++)
//    {
//        NSDictionary *dictioinary = [array objectAtIndex:i];
//        AddressBookDept *list = [[AddressBookDept alloc] init];
//        list.dept_id = [[dictioinary objectForKey:@"dept_id"] intValue];
//        list.dept_name = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"dept_name"]];
//        list.dept_pid = [[dictioinary objectForKey:@"dept_pid"] intValue];
//        list.dept_pid_path = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"dept_pids"]];
//        list.ent_id = [[dictioinary objectForKey:@"ent_id"] intValue];
//        
//        for(int j=0;j<stringA.count;j++)
//        {
//            NSString *stringDeptName = [stringA objectAtIndex:j];
//            if([list.dept_name isEqualToString:stringDeptName])
//            {
//                BOOL bl = [list selectAddressBookDeptListIsHave];
//                if(!bl)
//                {
//                    [tableArray replaceObjectAtIndex:j withObject:list];
//                }
//            }
//        }
//    }
    return tableArray;
}

//添加数据
-(BOOL)insertAllAddressBookDeptList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookDept *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:InsertAddressBookDeptList,list.dept_id,list.dept_pid,list.dept_pid_path,list.dept_name,list.dept_number,list.ent_id];
            NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
            const char *insert_stmt = (char *) [s UTF8String];
            int success  = sqlite3_exec(contactDB, insert_stmt , 0, 0, 0 );
            if (success != SQLITE_OK) {
                bl = FALSE;
            }
        }
        int success = sqlite3_exec(contactDB,"COMMIT",0,0,0); //COMMIT
        
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
    }
    sqlite3_close(contactDB);
    return bl;
}
//删除数据
-(BOOL)deleteAddressBookDeptList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookDept *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:DeleteAddressBookDeptList,list.dept_id];
            NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
            const char *insert_stmt = (char *) [s UTF8String];
            int success  = sqlite3_exec(contactDB, insert_stmt , 0, 0, 0 );
            if (success != SQLITE_OK) {
                bl = FALSE;
            }
        }
        int success = sqlite3_exec(contactDB,"COMMIT",0,0,nil); //COMMIT
        
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
    }
    sqlite3_close(contactDB);
    return bl;
}
//删除所有数据
-(BOOL)deleteAllAddressBookDeptList
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        NSString *format = [NSString stringWithFormat:DeleteAllAddressBookDeptList];
        NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
        const char *insert_stmt = (char *) [s UTF8String];
        int success  = sqlite3_exec(contactDB, insert_stmt , 0, 0, 0 );
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        success = sqlite3_exec(contactDB,"COMMIT",0,0,nil); //COMMIT
        
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
    }
    sqlite3_close(contactDB);
    return bl;
}
//修改数据
-(BOOL)updateAddressBookDeptList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateAddressBookDeptList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [dept_pid_path UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [dept_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, dept_number);
        sqlite3_bind_int(statement, 4, ent_id);
        sqlite3_bind_int(statement, 5, dept_id);
        sqlite3_bind_int(statement, 6, dept_pid);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询数据是否存在
-(BOOL)selectAddressBookDeptListIsHave
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookDeptListIsHave UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        sqlite3_bind_int(statement, 2, dept_pid);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            bl = YES;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询数据
-(NSMutableArray *)selectAddressBookDeptListForDeptPid
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookDeptList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookDept *List = [[AddressBookDept alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.dept_id = sqlite3_column_int(statement, 1);
            List.dept_pid = sqlite3_column_int(statement, 2);
            List.dept_pid_path = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            List.dept_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            List.dept_number = sqlite3_column_int(statement, 5);
            List.ent_id = sqlite3_column_int(statement, 6);
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部门下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookDept *list = (AddressBookDept *)[tableArray objectAtIndex:i];
        AddressBookUser *userList = [[AddressBookUser alloc] init];
        userList.dept_id = list.dept_id;
        list.dept_number = [userList selectAddressBookUserListForCount];
    }
    return tableArray;
}
//查询所有数据
-(NSMutableArray *)selectAllAddressBookDeptList
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    
    AddressBookUser *userList = [[AddressBookUser alloc] init];
    userList.dept_id = self.dept_id;
    [tableArray addObjectsFromArray:[userList selectAddressBookUserListForDept]];
    
    NSMutableArray *dept_Array = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookDeptList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookDept *List = [[AddressBookDept alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.dept_id = sqlite3_column_int(statement, 1);
            List.dept_pid = sqlite3_column_int(statement, 2);
            List.dept_pid_path = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            List.dept_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            List.dept_number = sqlite3_column_int(statement, 5);
            List.ent_id = sqlite3_column_int(statement, 6);
            [dept_Array addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部门下成员总数
    for(int i=0;i<dept_Array.count;i++)
    {
        AddressBookDept *list = [dept_Array objectAtIndex:i];
        AddressBookUser *userList = [[AddressBookUser alloc] init];
        userList.dept_id = list.dept_id;
        list.dept_number = [userList selectAddressBookUserListForCount];
    }
    [tableArray addObjectsFromArray:dept_Array];
    return tableArray;
}

-(NSMutableArray *)selectAllAddressBookDeptListForDeptId
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookDeptListForDeptId UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookDept *List = [[AddressBookDept alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.dept_id = sqlite3_column_int(statement, 1);
            List.dept_pid = sqlite3_column_int(statement, 2);
            List.dept_pid_path = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            List.dept_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            List.dept_number = sqlite3_column_int(statement, 5);
            List.ent_id = sqlite3_column_int(statement, 6);
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}

//查询根目录数据
-(NSMutableArray *)selectBaseAddressBookDeptList
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllAddressBookDeptList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookDept *List = [[AddressBookDept alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.dept_id = sqlite3_column_int(statement, 1);
            List.dept_pid = sqlite3_column_int(statement, 2);
            List.dept_pid_path = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            List.dept_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            List.dept_number = sqlite3_column_int(statement, 5);
            List.ent_id = sqlite3_column_int(statement, 6);
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}

@end
