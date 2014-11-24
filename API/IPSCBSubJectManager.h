//
//  SCBSubJectManager.h
//  icoffer
//
//  Created by Yangsl on 14-7-8.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kLMTypeSubjectList, //专题列表
    kLMTypeSubjectNew,  //新建专题
    kLMTypeSubjectInfo, //主题动态
    kLMTypeSubjectRightInfo, //右侧栏信息
    kLMTypeSubjectMebmerInfo,   //成员信息
    kLMTypeSubjectResourcesPublish, //发布资源
    kLMTypeSubjectResourcesList, //资源列表
    kLMTypeSubjectResourcesDelete, //删除资源
    kLMTypeSubjectCommentPublist, //发布资源评论
    kLMTypeSubjectCommentDelete, //删除资源评论
    kLMTypeSubjectResourcesExist, //判断资源是否存在
    kLMTypeGetMemberList,  //获取成员列表
    kLMTypeGetSubjectListFromFile, //获取主题
    kLMTypePublishResourceFromFile, //从文件列表发布资源
    kLMTypeSubjectSum, //获取动态的总个数
    kLMTypeGetCommentList,  //获取资源评论
    kLMTypeSendComment,   //发布评论
    kLMTypeGetResourceFile, //资源文件列表
}kSMType;

@protocol SCBSubJectDelegate <NSObject>
@optional
//请求专题列表返回
-(void)requestSubJectListSuccess:(NSDictionary *)diction;
-(void)requestSubJectListFail:(NSDictionary *)diction;

//请求主题动态返回
-(void)requestSubjectEventOfInfoSuccess:(NSDictionary *)diction;
-(void)requestSubjectEventOfInfoFail:(NSDictionary *)diction;

//成员列表
- (void)getMemberListSuccess:(NSDictionary *)dic;
- (void)getMemberListunsuccess:(NSString *)error_info;

//新建专题
-(void)createSubjectSuccess:(NSString *)subject_id;
-(void)createSubjectUnsuccess:(NSString *)error_info;

//获取发布资源的专题列表
- (void)checkSubjectListSuccess:(NSDictionary *)dic;
- (void)checkSubjectListUnsuccess:(NSString *)error_info;

//从文件列表发布资源到专题
- (void)publishSuccess;
- (void)publishUnsuccess:(NSString *)error_info;

//右侧栏信息
- (void)getSubjectInfoSuccess:(NSDictionary *)dic;
- (void)getSubjectInfoUnsuccess:(NSString *)error_info;

//资源列表
- (void)getResourceListSuccess:(NSDictionary *)dic;
- (void)getResourceListunsccess:(NSString *)error_info;

//获取动态的总个数
- (void)getSubjectSumSuccess:(NSDictionary *)dic;
- (void)getSubjectSumunSuccess:(NSString *)error_info;

//发布评论
- (void)sendCommentSuccess;
- (void)sendCommentunsuccess:(NSString *)error_info;

//获取资源评论
- (void)getCommentListSuccess:(NSDictionary *)dic;
- (void)getCommentListunsccess:(NSString *)error_info;

//文件列表
- (void)getResourceFileSuccess:(NSDictionary *)dic;
- (void)getResourceFileUnsuccess:(NSString *)error_info;

//判断资源文件是否存在
- (void)getResourceExistSuccess:(NSDictionary *)dictionSize;
- (void)getResourceExistUnsuccess:(NSString *)error_info;

-(void)networkError;

@end

@interface IPSCBSubJectManager : NSObject

@property(nonatomic, weak) id<SCBSubJectDelegate> delegate;
@property(nonatomic, assign) kSMType mtype;
@property(nonatomic, strong) NSMutableData *tableData;
@property(nonatomic, strong) NSURLConnection *connection;

//请求专题列表
-(void)requestSubjectList:(NSString *)user_id;
//查看主题/主题动态信息
-(void)requestSubjectEventOfInfo:(NSString *)subject_id user_id:(NSString *)user_id;
//获取部门成员
- (void)getMemeberList;
//新建专题
- (void)createSubjectWithName:(NSString *)subName remark:(NSString *)subRemark publish:(int)isPublish adduser:(int)isAdduser members:(NSArray *)subMember;
//发布资源
- (void)publishResourceWithSubjectId:(NSArray *)sub_ids res_file:(NSArray *)fileIds res_folder:(NSArray *)folderIds res_url:(NSArray *)urlStrings res_descs:(NSArray *)urlDesces comment:(NSString *)sub_comment;
//获取专题列表
- (void)getSubjectList;

// 主题右侧信息
- (void)getSubjectInfoWithSubjectId:(NSString *)sub_id;

//获取资源列表
- (void)getResourceListWithSubjectId:(NSString *)sub_id resourceUserIds:(NSString *)res_userId resourceType:(NSString *)res_type resourceTitil:(NSString *)res_title;
//获取资源评论
- (void)getCommentListWithResourceId:(NSString *)res_id;
//发布评论
- (void)sendCommentWithResourceId:(NSString *)res_id subjectId:(NSString *)sub_id content:(NSString *)aContent type:(NSString *)comment_type seconds:(NSString *)audioLen;
//文件列表
- (void)getResouceFileWithSubjectId:(NSString *)sub_id f_id:(NSString *)fid;
//获取动态的总个数
- (void)getSubjectSum;
//判断资源是否存在
-(void)requestSubjectIsExistWithResouceId:(NSString *)resouceId;
@end
