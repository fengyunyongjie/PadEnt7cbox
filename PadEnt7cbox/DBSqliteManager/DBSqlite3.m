//
//  DBSqlite3.m
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import "DBSqlite3.h"
#import "YNFunctions.h"
#import "LTHPasscodeViewController.h"
#import "UpLoadList.h"


@implementation DBSqlite3
@synthesize databasePath;

-(void)updateVersion
{
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"hongPanShangYe.sqlite"];
    //判断更新数据库文件
    if(![self isHaveTable:@"UploadList"])
    {
        [[LTHPasscodeViewController sharedUser] hiddenPassword];
    }

    //新版本更新数据库
    if(![self isHaveTableAndColoumName:@"UploadList" coloumName:@"sname"])
    {
        UpLoadList *list = [[UpLoadList alloc] init];
        NSMutableArray *insertsUploadList = [list SelectAllUploadList];
        //删除数据表
        [self deleteUploadList:DropTableUploadlist];
        if (sqlite3_open([self.databasePath fileSystemRepresentation], &contactDB)==SQLITE_OK)
        {
            char *errMsg;
            //新代码
            if (sqlite3_exec(contactDB, (const char *)[CreateUploadList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            }
            sqlite3_close(contactDB);
        }
        //添加数据
        [list insertsUploadList:insertsUploadList];
    }
}

-(void)cleanSql
{
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"hongPanShangYe.sqlite"];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    BOOL bl = [filemgr removeItemAtPath:self.databasePath error:nil];
    NSLog(@"--------------------------------------------------\n删除所有数据库文件:%i\n--------------------------------------------------",bl);
}

-(id)init
{
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"hongPanShangYe.sqlite"];
    if (sqlite3_open([self.databasePath fileSystemRepresentation], &contactDB)==SQLITE_OK)
    {
        char *errMsg;
        //        if (sqlite3_exec(contactDB, [CreateTaskTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        //            NSLog(@"errMsg:%s",errMsg);
        //        }
        //        if (sqlite3_exec(contactDB, (const char *)[CreatePhotoFileTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        //            NSLog(@"errMsg:%s",errMsg);
        //        }
        if (sqlite3_exec(contactDB, (const char *)[CreateUserinfoTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        //        //新代码
        if (sqlite3_exec(contactDB, (const char *)[CreateUploadList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        //        if (sqlite3_exec(contactDB, (const char *)[CreateAutoUploadList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        //            NSLog(@"errMsg:%s",errMsg);
        //        }
        //商业版新代码
        if (sqlite3_exec(contactDB, (const char *)[CreateDownList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        if (sqlite3_exec(contactDB, (const char *)[CreatePasswordList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        //通讯录
        if (sqlite3_exec(contactDB, (const char *)[CreateAddressBookUserList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        }
        if (sqlite3_exec(contactDB, (const char *)[CreateAddressBookDeptList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        }
        if (sqlite3_exec(contactDB, (const char *)[CreateRecentPhoneList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
        }

        sqlite3_close(contactDB);
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
    
    
    return self;
}

-(BOOL)isHaveTable:(NSString *)name
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    __block BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectTableIsHave UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            int i = sqlite3_column_int(statement, 0);
            if(i>=1)
            {
                bl = TRUE;
                break;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(BOOL)deleteUploadList:(NSString *)sqlDelete
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [sqlDelete UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
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
    return bl;
}

-(BOOL)deleteAddressBookList
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        NSMutableString *format = [[NSMutableString alloc] initWithFormat:DeleteUserListSql];
        [format appendString:DeleteDeptListSql];
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

-(BOOL)isHaveTableAndColoumName:(NSString *)tableName coloumName:(NSString *)coloumName
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    __block BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectIsHaveTableAndColoumName UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            NSString *name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            if([name isEqualToString:coloumName])
            {
                bl = TRUE;
                break;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

@end
