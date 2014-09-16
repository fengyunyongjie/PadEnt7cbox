//
//  AddressBookUser.m
//  icoffer
//
//  Created by Yangsl on 14-8-26.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import "AddressBookUser.h"
#import "NSString+Format.h"
#import "YNFunctions.h"
#import "ChineseString.h"

@implementation AddressBookUser
@synthesize user_id,user_account,user_pwd,user_totalSize,user_userSize,user_createTime,user_state,user_passwordCheck,ent_id,dept_id,user_trueName,user_birthdayDate,user_sex,user_phone,user_picPath,user_post,checked,dept,call_phone_account;

//解析user数据
-(NSMutableArray *)getUserArray:(NSArray *)array
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    NSMutableArray *oldArray=[[NSMutableArray alloc] init];
    NSMutableArray *byoldArray=[[NSMutableArray alloc] init];
    for(int i=0;i<array.count;i++)
    {
        NSDictionary *dictioinary = [array objectAtIndex:i];
        NSString *userTrueName = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_turename"]];
        [stringArray addObject:userTrueName];
        [tableArray addObject:userTrueName];
    }
    
    NSMutableArray *stringA = [ChineseString SortArray:stringArray];
    for (int i=0; i<array.count; i++) {
        NSDictionary *dictioinary = [array objectAtIndex:i];
        AddressBookUser *list = [[AddressBookUser alloc] init];
        list.dept_id = [[dictioinary objectForKey:@"dept_id"] intValue];
        list.ent_id = [[dictioinary objectForKey:@"ent_id"] intValue];
        list.user_passwordCheck = [[dictioinary objectForKey:@"salt"] intValue];
        list.user_account = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_account"]];
        list.ent_id = [[dictioinary objectForKey:@"usr_id"] intValue];
        list.user_account = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_account"]];
        list.user_phone = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_phone"]];
        list.user_picPath = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_picpath"]];
        list.user_post = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_post"]];
        list.user_pwd = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_pwd"]];
        list.user_createTime = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_regtime"]];
        list.user_sex = [[dictioinary objectForKey:@"usr_sex"] intValue];
        list.user_state = [[dictioinary objectForKey:@"usr_state"] intValue];
        list.user_totalSize = [[dictioinary objectForKey:@"usr_totalsize"] intValue];
        list.user_trueName = [NSString formatNSStringForOjbect:[dictioinary objectForKey:@"usr_turename"]];
        list.user_userSize = [[dictioinary objectForKey:@"usr_usedsize"] intValue];
        [oldArray addObject:list];
//        for(int j=0;j<stringA.count;j++)
//        {
//            NSString *stringTrueName = [stringA objectAtIndex:j];
//            if([list.user_trueName isEqualToString:stringTrueName])
//            {
//                BOOL bl = [list selectAddressBookUserListIsHave];
//                if(!bl)
//                {
//                    [tableArray replaceObjectAtIndex:j withObject:list];
//                }
//            }
//        }
    }
    //排序oldArray;
    for (int i=0; i<stringA.count; i++) {
        NSString *stringTrueName = [stringA objectAtIndex:i];
        for (int j=0; j<oldArray.count; j++) {
            AddressBookUser *list=[oldArray objectAtIndex:j];
            if([list.user_trueName isEqualToString:stringTrueName])
            {
                [byoldArray addObject:list];
                [oldArray removeObject:list];
                break;
            }
        }
    }

    
    return byoldArray;
}

//添加数据
-(BOOL)insertAllAddressBookUserList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookUser *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:InsertAddressBookUserList,list.user_account,list.user_pwd,list.user_totalSize,list.user_userSize,list.user_createTime,list.user_state,list.user_passwordCheck,list.ent_id,list.dept_id,list.user_trueName,list.user_birthdayDate,list.user_sex,list.user_phone,list.user_picPath,list.user_post];
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
-(BOOL)deleteAddressBookUserList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookUser *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:DeleteAddressBookUserList,list.user_id,list.user_account];
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
-(BOOL)deleteAllAddressBookUserList
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        NSString *format = [NSString stringWithFormat:DeleteAllAddressBookUserList,user_account];
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
-(BOOL)updateAddressBookUserList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateAddressBookUserList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [user_pwd UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, user_totalSize);
        sqlite3_bind_int(statement, 3, user_userSize);
        sqlite3_bind_text(statement, 4, [user_createTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 5, user_state);
        sqlite3_bind_int(statement, 6, user_passwordCheck);
        sqlite3_bind_int(statement, 7, ent_id);
        sqlite3_bind_int(statement, 8, dept_id);
        sqlite3_bind_text(statement, 9, [user_trueName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [user_birthdayDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 11, user_sex);
        sqlite3_bind_text(statement, 12, [user_phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 13, [user_picPath UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 14, [user_post UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 15, user_id);
        sqlite3_bind_text(statement, 16, [user_account UTF8String], -1, SQLITE_TRANSIENT);
        
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
-(BOOL)selectAddressBookUserListIsHave
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookUserList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [user_account UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            bl = YES;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询数据
-(NSMutableArray *)selectAddressBookUserListForDept
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookUserListForDeptId UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    return tableArray;
}

-(NSInteger)selectAddressBookUserListForCount
{
    sqlite3_stmt *statement;
    NSInteger total = 0;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAddressBookUserListForCount UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            total = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return total;
}
//查询所有数据
-(NSMutableArray *)selectAllAddressBookUserList
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllAddressBookUserList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    return tableArray;
}

//根据名称查询数据
-(NSMutableArray *)selectAddressBookUserListForString:(NSString *)select_name
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        NSMutableString *format = [[NSMutableString alloc] initWithString:SelectAddressBookUserListForString];
        [format appendString:@"'%"];
        [format appendString:select_name];
        [format appendString:@"%'"];
        NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
        const char *insert_stmt = (char *) [s UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    return tableArray;
}

//根据名称和id查询数据
-(NSMutableArray *)selectAddressBookUserListForString:(NSString *)select_name forWithDeptId:(NSInteger)select_deptid
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        NSMutableString *format = [[NSMutableString alloc] initWithFormat:SelectAddressBookUserListForStringAndId,select_deptid];
        [format appendString:@"'%"];
        [format appendString:select_name];
        [format appendString:@"%'"];
        NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
        const char *insert_stmt = (char *) [s UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    return tableArray;
}

//最近呼出

//添加数据
-(BOOL)insertAllRecentPhoneList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookUser *list = [tableArray objectAtIndex:i];
            //时间显示方式
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            list.user_createTime = [dateFormatter stringFromDate:[NSDate date]];
            NSString *format = [NSString stringWithFormat:InsertRecentPhoneList,list.user_account,list.user_pwd,list.user_totalSize,list.user_userSize,list.user_createTime,list.user_state,list.user_passwordCheck,list.ent_id,list.dept_id,list.user_trueName,list.user_birthdayDate,list.user_sex,list.user_phone,list.user_picPath,list.user_post,list.call_phone_account];
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
-(BOOL)deleteRecentPhoneList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AddressBookUser *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:DeleteRecentPhoneList,list.user_id,list.call_phone_account];
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
-(BOOL)deleteAllRecentPhoneList
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        NSString *format = [NSString stringWithFormat:DeleteAllRecentPhoneList,call_phone_account,user_id];
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
-(BOOL)updateRecentPhoneList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateRecentPhoneList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [user_pwd UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, user_totalSize);
        sqlite3_bind_int(statement, 3, user_userSize);
        sqlite3_bind_text(statement, 4, [user_createTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 5, user_state);
        sqlite3_bind_int(statement, 6, user_passwordCheck);
        sqlite3_bind_int(statement, 7, ent_id);
        sqlite3_bind_int(statement, 8, dept_id);
        sqlite3_bind_text(statement, 9, [user_trueName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [user_birthdayDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 11, user_sex);
        sqlite3_bind_text(statement, 12, [user_phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 13, [user_picPath UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 14, [user_post UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 15, user_id);
        sqlite3_bind_text(statement, 16, [user_account UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 17, [call_phone_account UTF8String], -1, SQLITE_TRANSIENT);
        
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
-(BOOL)selectRecentPhoneListIsHave
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectRecentPhoneList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [call_phone_account UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            bl = YES;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询数据
-(NSMutableArray *)selectRecentPhoneListForDept
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectRecentPhoneListForDeptId UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, dept_id);
        sqlite3_bind_text(statement, 2, [call_phone_account UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            List.call_phone_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    return tableArray;
}
//查询所有数据
-(NSMutableArray *)selectAllRecentPhoneList
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        NSString *format = [NSString stringWithFormat:SelectAllRecentPhoneList,call_phone_account];
        const char *insert_stmt = [format UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            AddressBookUser *List = [[AddressBookUser alloc] init];
            List.user_id = sqlite3_column_int(statement, 0);
            List.user_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            List.user_pwd = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 2)];
            List.user_totalSize = sqlite3_column_int(statement, 3);
            List.user_userSize = sqlite3_column_int(statement, 4);
            List.user_createTime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            List.user_state = sqlite3_column_int(statement, 6);
            List.user_passwordCheck = sqlite3_column_int(statement, 7);
            List.ent_id = sqlite3_column_int(statement, 8);
            List.dept_id = sqlite3_column_int(statement, 9);
            List.user_trueName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            List.user_birthdayDate = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 11)];
            List.user_sex = sqlite3_column_int(statement, 12);
            List.user_phone = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 13)];
            List.user_picPath = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            List.user_post = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 15)];
            List.call_phone_account = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            [tableArray addObject:List];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    //查询部分下成员总数
    for(int i=0;i<tableArray.count;i++)
    {
        AddressBookUser *userList = [tableArray objectAtIndex:i];
        AddressBookDept *list = [[AddressBookDept alloc] init];
        list.dept_id = userList.dept_id;
        userList.dept = [[list selectAllAddressBookDeptListForDeptId] firstObject];
    }
    if([tableArray count]>0)
    {
        AddressBookUser *list = (AddressBookUser *)[tableArray lastObject];
        BOOL bl = [list deleteAllRecentPhoneList];
        if(bl)
        {
            NSLog(@"删除20条以前的数据");
        }
    }
    return tableArray;
}

@end
