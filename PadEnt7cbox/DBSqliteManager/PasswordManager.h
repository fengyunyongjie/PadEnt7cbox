//
//  PasswordManager.h
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-20.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import "DBSqlite3.h"
#import "PasswordList.h"

#define InsertPasswordList @"INSERT INTO PasswordList(p_text,p_fail_count,p_ure_id,IS_OPEN) VALUES (?,?,?,?)"
#define InsertPasswordLists @"INSERT INTO PasswordList(p_text,p_fail_count,p_ure_id,IS_OPEN) VALUES ('%@',%i,'%@',%i);"
#define DeletePasswordList @"DELETE FROM PasswordList WHERE p_ure_id=?"
#define DeletePasswordLists @"DELETE FROM PasswordList WHERE p_ure_id='%@';"
#define SelectPasswordListIsHave @"SELECT * FROM PasswordList WHERE p_ure_id=? and IS_OPEN=?"
#define UpdatePasswordList @"UPDATE PasswordList SET p_text=?,p_fail_count=?,IS_OPEN=? WHERE p_ure_id=?"
#define SelectOnePasswordList @"SELECT * FROM PasswordList WHERE p_ure_id=?"

@interface PasswordManager : DBSqlite3

-(void)insertPasswordList:(PasswordList *)list;
-(void)insertPasswordLists:(NSArray *)lists;
-(void)deletePasswordList:(PasswordList *)list;
-(void)deletePasswordLists:(NSArray *)lists;
-(NSMutableArray *)selectPasswordListIsHave:(PasswordList *)list;
-(void)updatePasswordList:(PasswordList *)list;
-(NSMutableArray *)selectOnePasswordList:(PasswordList *)list;

@end
