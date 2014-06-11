//
//  SCBEmailManager.h
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kEMTypeOperate,
    kEMTypeList,            //收发邮件列表/ent/email/list
    kEMTypeDetail,          //收发邮件详情/ent/email/detail
    kEMTypeSendInterior,    //发送站内信/ent/email/send/interior
    kEMTypeSendExternal,    //发送站外信/ent/email/send/external
    kEMTypeDelete,          //站内外信删除/ent/email/del
    kEMTypeFileList,        //获取邮件内文件列表/ent/email/fids
    kEMTypeCheckDownload,   //站外信邮件下载校验/ent/email/checkDownload
    kEMTypeShowDetails,     //邮件详情显示/ent/email/details (不推荐使用)
    kEMTypeGetTemplate,     //站外信模板/ent/email/template
    kEMTypeReceiveList,     //收件列表
    kEMTypeSendList,        //发件列表
    kEMTypeSendFiles,       //发送文件
    kEMTypeViewReceive,     //收件预览
    kEMTypeViewSend,        //发件预览
    kEMTypeNotReadCount,    //未读数量
    kEMTypeGetEmailTitle,   //邮件主题模版
    kEMTypeCreateLink,      //文件外链
}kEMType;
@protocol SCBEmailManagerDelegate;
@interface SCBEmailManager : NSObject
@property (nonatomic,weak) id<SCBEmailManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kEMType em_type;

-(void)cancelAllTask;
-(void)listEmailWithType:(NSString *)type;  //type 0为收件箱，1为发件箱，2为所有
-(void)operateUpdateWithType:(NSString *)type;
-(void)detailEmailWithID:(NSString *)eid type:(NSString *)type; //type 同上
-(void)sendInteriorEmailToUser:(NSArray *)usrids Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids;
-(void)sendExternalEmailToUser:(NSString *)recevers Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids;
-(void)removeEmailWithID:(NSString *)eid type:(NSString *)type; //type 同上
-(void)removeEmailWithIDs:(NSArray *)eids type:(NSString *)type;
-(void)fileListWithID:(NSString *)eid;
-(void)getEmailTemplateWithName:(NSString *)filenames;
//收件箱列表
-(void)receiveListWithCursor:(int)cursor offset:(int)offset subject:(NSString*)subject;
//发件箱列表
-(void)sendListWithCursor:(int)cursor offset:(int)offset subject:(NSString *)subject;
//发送文件
-(void)sendFilesWithSubject:(NSString*)send_subject userids:(NSArray*)userids usernames:(NSArray*)usernames useremails:(NSArray *)useremails sendfiles:(NSArray*)sendfiles message:(NSString*)send_message;
//收件浏览
-(void)viewReceiveWithID:(NSString *)re_id;
//发件浏览
-(void)viewSendWithID:(NSString *)send_id;
//未读邮件数量
-(void)notReadCount;
//快速创建外链
-(void)createLinkWithFids:(NSArray *)fids;
//创建邮件外链
-(void)createLinkMailWithFids:(NSArray *)fids title:(NSString *)title content:(NSString *)content receivelist:(NSString *)receivelist;
//邮件外链主题模版
-(void)getEmailTitle;
//外链短信模版
-(void)getTemplateMsg;
//手动从中转站接收附件
-(void)getAttaFromTransitWithID:(NSString *)re_id re_sendid:(NSString *)re_sendid;
//删除收件
-(void)delReceiveWithID:(NSArray *)re_ids;
//删除发件
-(void)delSendWithID:(NSArray *)send_ids;
//批量已读接口
-(void)setReadWithIDs:(NSArray *)re_ids;
//新批量删除发件
-(void)delFilesSendByUserId;
//新收件箱内容全部标记成已读
-(void)updateReceiveIsReadByUserID;


@end
@protocol SCBEmailManagerDelegate
@optional
-(void)networkError;
-(void)listEmailSucceed:(NSDictionary *)datadic;
-(void)listEmailFail;
-(void)detailEmailSucceed:(NSDictionary *)datadic;
-(void)detailEmailFail;
-(void)sendEmailSucceed;
-(void)sendEmailFail;
-(void)removeEmailSucceed;
-(void)removeEmailFail;
-(void)fileListSucceed:(NSData *)data;
-(void)fileListFail;
-(void)operateSucceed:(NSDictionary *)datadic;
-(void)getEmailTemplateSucceed:(NSDictionary *)datadic;
-(void)getEmailTemplateFail;
-(void)receiveListSucceed:(NSDictionary *)datadic;
-(void)sendListSucceed:(NSDictionary *)datadic;
-(void)sendFilesSucceed:(NSDictionary *)datadic;
-(void)viewReceiveSucceed:(NSDictionary *)datadic;
-(void)viewSendSucceed:(NSDictionary *)datadic;
-(void)notReadCountSucceed:(NSDictionary *)datadic;
-(void)getEmailTitleSucceed:(NSDictionary *)datadic;
-(void)createLinkSucceed:(NSDictionary *)datadic;
-(void)getTemplateMsgSucceed:(NSDictionary *)datadic;
-(void)getAttaSucceed:(NSDictionary *)datadic;
-(void)delReceiveSucceed:(NSDictionary *)datadic;
-(void)delSendSucceed:(NSDictionary *)datadic;
-(void)setReadSucceed:(NSDictionary *)datadic;
@end