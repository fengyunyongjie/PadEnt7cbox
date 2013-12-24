//
//  PasswordManager.m
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-20.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "PasswordManager.h"

@implementation PasswordManager

-(void)insertPasswordList:(PasswordList *)list
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertPasswordList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [list.p_text UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, list.p_fail_count);
        sqlite3_bind_text(statement, 3, [list.p_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, list.is_open);
        success = sqlite3_step(statement);
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

-(void)insertPasswordLists:(NSArray *)lists
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<lists.count; i++) {
            PasswordList *list = [lists objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:InsertPasswordLists,list.p_text,list.p_fail_count,list.p_ure_id,list.is_open];
            NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
            const char *insert_stmt = (char *) [s UTF8String];
            int success  = sqlite3_exec(contactDB, insert_stmt , 0, 0, 0 );
            if (success != SQLITE_OK) {
                bl = FALSE;
            }
        }
        int success = sqlite3_exec(contactDB,"COMMIT",0,0,0); //COMMIT
        NSLog(@"success:%i",success);
    }
    sqlite3_close(contactDB);
}

-(void)deletePasswordList:(PasswordList *)list
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeletePasswordList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [list.p_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

-(void)deletePasswordLists:(NSArray *)lists
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<lists.count; i++) {
            PasswordList *list = [lists objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:DeletePasswordLists,list.p_ure_id];
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
}

-(NSMutableArray *)selectPasswordListIsHave:(PasswordList *)list
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectPasswordListIsHave UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [list.p_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, list.is_open);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            PasswordList *list = [[PasswordList alloc] init];
            list.p_id = sqlite3_column_int(statement, 0);
            list.p_text = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            list.p_fail_count = sqlite3_column_int(statement, 2);
            list.p_ure_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            list.is_open = sqlite3_column_int(statement, 4);
            [tableArray addObject:list];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    NSLog(@"自动上传的个数:%i",[tableArray count]);
    return tableArray;
}

-(void)updatePasswordList:(PasswordList *)list
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdatePasswordList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [list.p_text UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, list.p_fail_count);
        sqlite3_bind_int(statement, 3, list.is_open);
        sqlite3_bind_text(statement, 4, [list.p_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

-(NSMutableArray *)selectOnePasswordList:(PasswordList *)list
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOnePasswordList UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [list.p_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            PasswordList *list = [[PasswordList alloc] init];
            list.p_id = sqlite3_column_int(statement, 0);
            list.p_text = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            list.p_fail_count = sqlite3_column_int(statement, 2);
            list.p_ure_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            list.is_open = sqlite3_column_int(statement, 4);
            [tableArray addObject:list];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    NSLog(@"自动上传的个数:%i",[tableArray count]);
    return tableArray;
}

@end
