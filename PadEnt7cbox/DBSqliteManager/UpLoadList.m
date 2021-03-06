//
//  UpLoadList.m
//  NetDisk
//
//  Created by Yangsl on 13-9-25.
//
//

#import "UpLoadList.h"
#import "NSString+Format.h"

@implementation UpLoadList
@synthesize t_id,t_name,t_lenght,t_date,t_state,t_fileUrl,t_url_pid,t_url_name,t_file_type,user_id,file_id,upload_size,is_autoUpload,is_share,spaceId,sudu,is_Onece,is_Fail,sname,md5String;

//批量处理添加
-(BOOL)insertsUploadList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            UpLoadList *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:InsertUploadLists,list.t_name,list.t_lenght,list.t_date,list.t_state,list.t_fileUrl,list.t_url_pid,list.t_url_name,list.t_file_type,list.user_id,list.file_id,list.upload_size,list.is_autoUpload,list.is_share,list.spaceId,list.is_Onece,list.sname,list.md5String];
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

//批量处理删除
-(BOOL)deletesUploadList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            UpLoadList *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:DeleteUploadLists,list.t_id,list.user_id];
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

-(BOOL)insertUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertUploadList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [t_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, t_lenght);
        sqlite3_bind_text(statement, 3, [t_date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, t_state);
        sqlite3_bind_text(statement, 5, [t_fileUrl UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [t_url_pid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [t_url_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 8, t_file_type);
        sqlite3_bind_text(statement, 9, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 10, [file_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 11, upload_size);
        sqlite3_bind_int(statement, 12, is_autoUpload);
        sqlite3_bind_int(statement, 13, is_share);
        sqlite3_bind_text(statement, 14, [spaceId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 15, is_Onece);
        sqlite3_bind_text(statement, 16, [sname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 17, [md5String UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR || success != 101) {
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self insertUploadList];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

-(BOOL)deleteUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteUploadList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, t_id);
        sqlite3_bind_text(statement, 2, [user_id UTF8String], -1, SQLITE_TRANSIENT);
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self deleteUploadList];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

-(BOOL)deleteAutoUploadListAllAndNotUpload
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteAutoUploadListAllAndNotUpload UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self deleteAutoUploadListAllAndNotUpload];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

-(BOOL)deleteMoveUploadListAllAndNotUpload
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteMoveUploadListAllAndNotUpload UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [user_id UTF8String], -1, SQLITE_TRANSIENT);
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self deleteMoveUploadListAllAndNotUpload];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

-(BOOL)deleteUploadListAllAndUploaded
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteUploadListAndUpload UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [user_id UTF8String], -1, SQLITE_TRANSIENT);
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self deleteUploadListAllAndUploaded];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

-(BOOL)updateUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateUploadListForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [file_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, upload_size);
        sqlite3_bind_text(statement, 3, [t_date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, t_state);
        sqlite3_bind_text(statement, 5, [sname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [md5String UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [t_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        
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
    if(!bl)
    {
        if(count<2)
        {
            [NSThread sleepForTimeInterval:0.5];
            [self insertUploadList];
            count++;
        }
        else
        {
            count = 0;
        }
    }
    return bl;
}

//查询文件是否存在
-(BOOL)selectUploadListIsHave
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectUploadListIsHaveName UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [t_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, is_autoUpload);
        if (sqlite3_step(statement)==SQLITE_ROW) {
            bl = TRUE;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询所有自动上传没有完成的记录
-(NSMutableArray *)selectAutoUploadListAllAndNotUpload
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAutoUploadListAllAndNotUpload UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, t_id);
        sqlite3_bind_text(statement, 2, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UpLoadList *uploadList = [[UpLoadList alloc] init];
            uploadList.t_id = sqlite3_column_int(statement, 0);
            uploadList.t_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            uploadList.t_lenght = sqlite3_column_int(statement, 2);
            uploadList.t_date = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            uploadList.t_state = sqlite3_column_int(statement, 4);
            uploadList.t_fileUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            uploadList.t_url_pid = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            uploadList.t_url_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            uploadList.t_file_type = sqlite3_column_int(statement, 8);
            uploadList.user_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 9)];
            uploadList.file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            uploadList.upload_size = sqlite3_column_int(statement, 11);
            uploadList.is_autoUpload = sqlite3_column_int(statement, 12);
            uploadList.is_share = sqlite3_column_int(statement, 13);
            uploadList.spaceId = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            uploadList.is_Onece = sqlite3_column_int(statement, 15);
            uploadList.sname = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            uploadList.md5String = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 17)];
            [tableArray addObject:uploadList];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    NSLog(@"自动上传的个数:%i",[tableArray count]);
    return tableArray;
}

//查询所有手动上传没有完成的记录
-(NSMutableArray *)selectMoveUploadListAllAndNotUpload
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectMoveUploadListAllAndNotUpload UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, t_id);
        sqlite3_bind_text(statement, 2, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UpLoadList *uploadList = [[UpLoadList alloc] init];
            uploadList.t_id = sqlite3_column_int(statement, 0);
            uploadList.t_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            uploadList.t_lenght = sqlite3_column_int(statement, 2);
            uploadList.t_date = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            uploadList.t_state = sqlite3_column_int(statement, 4);
            uploadList.t_fileUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            uploadList.t_url_pid = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            uploadList.t_url_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            uploadList.t_file_type = sqlite3_column_int(statement, 8);
            uploadList.user_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 9)];
            uploadList.file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            uploadList.upload_size = sqlite3_column_int(statement, 11);
            uploadList.is_autoUpload = sqlite3_column_int(statement, 12);
            uploadList.is_share = sqlite3_column_int(statement, 13);
            uploadList.spaceId = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            uploadList.is_Onece = sqlite3_column_int(statement, 15);
            uploadList.sname = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            uploadList.md5String = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 17)];
            [tableArray addObject:uploadList];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    NSLog(@"手动上传的个数:%i",[tableArray count]);
    return tableArray;
}

//查询所有上传完成的历史记录
-(NSMutableArray *)selectUploadListAllAndUploaded
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectUploadListAllAndUploaded UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [user_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, t_id);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UpLoadList *uploadList = [[UpLoadList alloc] init];
            uploadList.t_id = sqlite3_column_int(statement, 0);
            uploadList.t_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            uploadList.t_lenght = sqlite3_column_int(statement, 2);
            uploadList.t_date = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            uploadList.t_state = sqlite3_column_int(statement, 4);
            uploadList.t_fileUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            uploadList.t_url_pid = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            uploadList.t_url_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            uploadList.t_file_type = sqlite3_column_int(statement, 8);
            uploadList.user_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 9)];
            uploadList.file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            uploadList.upload_size = sqlite3_column_int(statement, 11);
            uploadList.is_autoUpload = sqlite3_column_int(statement, 12);
            uploadList.is_share = sqlite3_column_int(statement, 13);
            uploadList.spaceId = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            uploadList.is_Onece = sqlite3_column_int(statement, 15);
            uploadList.sname = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            uploadList.md5String = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 17)];
            [tableArray addObject:uploadList];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    NSLog(@"完成上传的个数:%i",[tableArray count]);
    return tableArray;
}

-(void)updateList:(UpLoadList *)demo
{
    self.t_id = demo.t_id;
    self.t_date = demo.t_date;
    self.t_lenght = demo.t_lenght;
    self.t_name = demo.t_name;
    self.t_state = demo.t_state;
    self.t_fileUrl = demo.t_fileUrl;
    self.t_url_pid = demo.t_url_pid;
    self.t_url_name = demo.t_url_name;
    self.t_file_type = demo.t_file_type;
    self.user_id = demo.user_id;
    self.file_id = demo.file_id;
    self.upload_size = demo.upload_size;
    self.is_autoUpload = demo.is_autoUpload;
    
    self.is_share = demo.is_share;
    self.spaceId = demo.spaceId;
    self.is_Onece = demo.is_Onece;
    self.is_Fail = demo.is_Fail;
    self.sname = demo.sname;
    self.md5String = demo.md5String;
}

-(NSMutableArray *)SelectAllUploadList
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllUpload UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UpLoadList *uploadList = [[UpLoadList alloc] init];
            uploadList.t_id = sqlite3_column_int(statement, 0);
            uploadList.t_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            uploadList.t_lenght = sqlite3_column_int(statement, 2);
            uploadList.t_date = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            uploadList.t_state = sqlite3_column_int(statement, 4);
            uploadList.t_fileUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            uploadList.t_url_pid = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            uploadList.t_url_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            uploadList.t_file_type = sqlite3_column_int(statement, 8);
            uploadList.user_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 9)];
            uploadList.file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 10)];
            uploadList.upload_size = sqlite3_column_int(statement, 11);
            uploadList.is_autoUpload = sqlite3_column_int(statement, 12);
            uploadList.is_share = sqlite3_column_int(statement, 13);
            uploadList.spaceId = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 14)];
            uploadList.is_Onece = sqlite3_column_int(statement, 15);
            uploadList.sname = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 16)];
            uploadList.md5String = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 17)];
            [tableArray addObject:uploadList];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}


@end
