//
//  SCBSubjectManager.h
//  PadEnt7cbox
//
//  Created by fengyongning on 14-7-10.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SCBSubjectManagerDelegate;
@interface SCBSubjectManager : NSObject
@property (nonatomic,weak) id<SCBSubjectManagerDelegate> delegate;

//请求专题列表
-(void)getSubjectList;
//发布资源选择专题列表
-(void)getSelectSubjectList;
//新建专题
-(void)createSubjectWithName:(NSString *)name info:(NSString *)info isPublish:(BOOL)isPublish isAddUser:(BOOL)isAddUser members:(NSArray *)members;
//获取专题动态
-(void)getActivityWithSubjectID:(NSString *)subject_id;
//获取专题信息
-(void)getSubjectInfoWithSubjectID:(NSString *)subject_id;
//获取资源列表
- (void)getResourceListWithSubjectId:(NSString *)sub_id resourceUserIds:(NSString *)res_userId resourceType:(NSString *)res_type resourceTitil:(NSString *)res_title;
//发布资源
- (void)publishResourceWithSubjectId:(NSArray *)sub_ids res_file:(NSArray *)fileIds res_folder:(NSArray *)folderIds res_url:(NSArray *)urlStrings res_descs:(NSArray *)urlDesces comment:(NSString *)sub_comment;
//获取部门成员
- (void)getMemberList;
//获取资源评论
- (void)getCommentListWithResourceId:(NSString *)res_id;
//发布评论
- (void)sendCommentWithResourceId:(NSString *)res_id subjectId:(NSString *)sub_id content:(NSString *)aContent type:(NSString *)comment_type seconds:(NSString *)audioLen;
//文件列表
- (void)getResourceFileWithSubjectId:(NSString *)sub_id f_id:(NSString *)fid;
//获取动态的总个数
- (void)getSubjectSum;
//判断资源是否存在
-(void)requestSubjectIsExistWithResouceId:(NSString *)resouceId;
@end

@protocol SCBSubjectManagerDelegate
@required
-(void)networkError;
@optional
-(void)didGetSubjectList:(NSDictionary *)datadic;
-(void)didGetSelectSubjectList:(NSDictionary *)datadic;
-(void)didCreateSubject:(NSDictionary *)datadic;
-(void)didGetActivity:(NSDictionary *)datadic;
-(void)didGetSubjectInfo:(NSDictionary *)datadic;
-(void)didGetResourceList:(NSDictionary *)datadic;
-(void)didPublishResource:(NSDictionary *)datadic;
-(void)didGetMemberList:(NSDictionary *)datadic;
-(void)didGetCommentList:(NSDictionary *)datadic;
-(void)didSendComment:(NSDictionary *)datadic;
-(void)didGetResourceFile:(NSDictionary *)datadic;
-(void)didGetSubjectSum:(NSDictionary *)datadic;
-(void)didSubjectIsExist:(NSDictionary *)datadic;
@end