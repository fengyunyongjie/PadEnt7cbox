//
//  SCBoxConfig.h
//  NetDisk
//
//  Created by fengyongning on 13-4-18.
//
//

#ifndef NetDisk_SCBoxConfig_h
#define NetDisk_SCBoxConfig_h

#define CLIENT_TAG @"3"
#define CONNECT_TIMEOUT 30
#define RESPONSE_TIMEOUT 10
#define CONNECT_MAX 60*3
//商业版URL
//#define HOST_URL @"http://192.168.1.9/"
//#define HOST_URL @"http://b.7cbox.cn/"
//#define HOST_URL @"http://192.168.1.51:8080/"
#define HOST_URL @"http://192.168.1.25:8080/"
//#define HOST_URL @"http://192.168.1.41:8080/"
//#define HOST_URL @"http://192.168.1.62:8080/"
//#define HOST_URL @"http://xianzhouhe.eicp.net:81/"
#define SERVER_URL [NSString stringWithFormat:@"%@%@",HOST_URL,@"biz/ent"]


#pragma mark - 1.子帐号
//子账号登录/ent/user/login
#define USER_LOGIN_URI @"/user/login"
//子账号退出/ent/user/logout
#define USER_LOGOUT_URI @"/user/logout"
//子账号空间权限列表/ent/author/menus
#define AUTHOR_MENUS_URI @"/author/menus"

#pragma mark - 1.用户管理
//用户注册
//#define USER_REGISTER_URI @"/usr/register"
#define USER_REGISTER_URI @"/account/register"
//用户登录
//#define USER_LOGIN_URI @"/usr/login"
//#define USER_LOGIN_URI @"/account/login/"
//用户注销
//#define USER_LOGOUT_URI @"/usr/logout"
//获取用户当前存储空间信息；
//#define USER_SPACE_URI @"/usr/space"
#define USER_SPACE_URI @"/account/spaceinfo"
//子账号列表/ent/user/list
#define USER_LIST_URI @"/user/lists"
//获取个人信息/usr/profile
#define USER_PROFILE_URI @"/usr/profile"
//子账号详情/ent/user/info
#define USER_INFO_URI @"/user/Info"
//获取vcard流/ent/user/getvcard
#define USER_GETVCARD_URI @"/user/getvcard"

#pragma mark - 2.好友管理
//获取群组列表/friendships/groups
#define FRIENDSHIPS_GROUPS @"/friendships/groups"
//获取所有群组及好友列表/friendships/groups/deep
#define FRIENDSHIPS_GROUPS_DEEP @"/friendships/groups/deep"
//创建群组/friendships/group/create
#define FRIENDSHOPS_GROUP_CREATE @"/friendships/group/create"
//修改群组/friendships/group/update
#define FRIENDSHIPS_GROUP_UPDATE @"/friendships/group/update"
//删除群组/friendships/group/del
#define FRIENDSHIP_GROUP_DEL @"/friendships/group/del"
//获取好友列表/friendships/friends
#define FRIENDSHIPS_FRIENDS @"/friendships/friends"
//添加好友/friendships/friend/create
#define FRIENDSHIPS_FRIEND_CREATE @"/friendships/friend/create"
//移动好友/friendships/friend/move
#define FRIENDSHIPS_FRIEND_MOVE @"/friendships/friend/move"
//修改好友备注/friendships/friend/remark/update
#define FRIENDSHIPS_FRIEND_REMARK_UPDATE @"/friendships/friend/remark/update"
//删除好友/friendships/friend/del
#define FRIENDSHIPS_FRIEND_DEL @"/friendships/friend/del"

#pragma mark - 3.短消息管理
//获取短消息列表/msgs
//发送短消息/msg/send
//删除短消息/msg/del
//删除所有短消息/msg/delall
//获取消息列表
#define MSGS @"/msgs"
//发送短消息
#define MSG_SEND @"/msg/send"
//删除短消息
#define MSG_DEL @"/msg/del"
//删除所有短消息
#define MSG_DELALL @"/msg/delall"

#pragma mark - 文件收发管理（信件收发）
//发送站内信/ent/email/send/interior
#define EMAIL_SENDIN_URI @"/email/send/interior"
//发送站外信/ent/email/send/external
#define EMAIL_SENDOUT_URI @"/email/send/external"
//收发邮件列表/ent/email/list
#define EMAIL_LIST_URI @"/email/list"
//收发邮件详情/ent/email/detail
#define EMAIL_DETAIL_URI @"/email/detail"
//站内外信删除/ent/email/del
#define EMAIL_DEL_URI @"/email/del"
#define EMAIL_DELALL_URL @"/email/delall"
//获取邮件内文件列表/ent/email/fids
#define EMAIL_FILELIST_URI @"/email/fids"
//站外信模板/ent/email/template
#define EMAIL_TEMPLATE_URI @"/email/template"
//收件箱列表
#define RECEIVE_LIST_URI @"/sendReceive/filesReceive"
//发件箱列表
#define SEND_LIST_URI @"/sendReceive/filesSend"
//发送文件
#define SEND_FILES_URI @"/sendReceive/sendFiles"
//收件浏览
#define VIEW_RECEIVE_URI @"/sendReceive/viewReceive"
//发件浏览
#define VIEW_SEND_URI @"/sendReceive/viewSend"
//未读邮件数量
#define NOTREADCOUNT_URI @"/sendReceive/notReadCount"
//邮件外链 或 快速外链
#define CREATE_LINK_URI @"/email/createLinkMail"
//邮件主题模版
#define EMAIL_TITLE_URI @"/email/getEmailTitle"
//短信模版
#define TEMPLATE_MSG_URI @"/email/template/msg"
//手动从中转站接收附件
#define TRANSIT_URI @"/sendReceive/getAttaFromTransit"
//删除收件 @"/sendReceive/delFilesReceive"
//批量删除收件
#define DEL_RECEIVE_URI @"/sendReceive/delFilesReceiveBatch"
//删除发件 @"/sendReceive/delFilesSend"
//批量删除发件
#define DEL_SEND_URI @"/sendReceive/delFilesSendBatch"
//批量已读接口
#define SET_READ_URI @"/sendReceive/batchUpdateRead"
//批量删除发件箱
#define DELFILES_SEND_USERID @"/sendReceive/delFilesSendByUserId"
//批量标记成已读
#define UPDATERECEIVE_ISREAD_USERID @"/sendReceive/updateReceiveIsReadByUserId"

#pragma mark - 4.文件管理
//打开网盘  文件列表/ent/file/list
//#define FM_URI @"/fm"
#define FM_URI @"/file/list"
#define FM_NODELIST @"/file/nodeList"
//单个文件请求 /ent/file/info
#define FM_INFO @"/file/info"
//新建
#define FM_MKDIR_URI @"/file/mkdir"
//移除/fm/rm
#define FM_RM_URI @"/file/rm"
//重命名/fm/rename
#define FM_RENAME_URI @"/file/rename"
//移动文件＝＝剪切粘贴 /fm/cutpaste
#define FM_MOVE_URI @"/file/cut"
//文件提交/ent/file/commit
#define FM_COMMIT_URI @"/file/commit"
//文件转存/ent/file/resave
#define FM_RESAVE_URI @"/file/resave"
//新加的接口，文件转存/ent/file/eresave
#define FM_ERESAVE_URI @"/file/eresave"
//转存文件==复制粘贴 /fm/copypaste
#define FM_COPYPASTE @"/fm/copypaste"
//文件下载
#define FM_DOWNLOAD_URI @"/file/download"
#define FM_DOWNLOAD_NEW_URI @"/fm/download/new"
//搜索/fm/search
#define FM_SEARCH_URI @"/file/search"
//缩略图下载
#define FM_DOWNLOAD_THUMB_URI @"/fm/download/thumb"
//新缩略图下载
#define FM_DOWNLOAD_THUMB_URI_NEW @"/fm/download/thumb_new"
//预览图下载 图片预览/ent/file/preview/pic
#define FM_DOWNLOAD_Look @"/file/preview/pic"
//获取文件详细信息
#define FM_GETFILEINFO @"/fm/getFileInfo"
//搜索当前文件夹 fm/search/current
#define FM_SEARCH_CURRENT @"/fm/getFileInfo"
//根据类别查看文件夹/fm/category_dir
#define FM_CATEGORY_DIR_URI @"/fm/category_dir"
//查看类别文件/fm/category_file
#define FM_CATEGORY_FILE_URI @"/fm/category_file"
//查看移动文件目录
#define FM_CUTTO @"/fm/cutTo"
//家庭空间管理 /family/members
#define FM_FAMILY_MEMBERS @"/family/lists"

#pragma mark - 5.共享管理
//打开共享文件夹
#define SHARE_OPEN_URI @"/share/open"
//新建/share/mkdir
#define SHARE_MKDIR_URI @"/share/mkdir"
//重命名/share/rename
#define SHARE_RENAME_URI @"/share/rename"
//剪切粘贴/share/cutpaste
#define SHARE_MOVE_URI @"/share/cutpaste"
//删除/share/rm
#define SHARE_RM_URI @"/share/rm"
//搜索/share/search
#define SHARE_SEARCH_URI @"/share/search"
//取消共享/share/cancel
//获取共享成员列表/share/members
//踢除共享成员/share/member/rm
//退出共享/share/member/exit

//接受好友的共享邀请share/invitation/add
#define SHARE_INVITATION_ADD @"/share/invitation/add"

//拒绝好友的共享邀请/share/invitation/remove
#define SHARE_INVITATION_REMOVE @"/share/invitation/remove"

#pragma mark - 6.意见管理
//意见反馈/advice
#define REPORT_ADVICE_URI @"/advice"

#pragma mark - 照片管理
// 获取时间轴 /fm/timeline
#define FM_TIMELINE @"/fm/timeline"
// 根据表达式获取图片信息 /fm/timeImage
#define FM_TIMEIMAGE @"/fm/timeImage"
//客户端版本校验/ent/version/check(检查更新)
#define VERSION_CHECK_URI @"/version/check"

#pragma mark - 获取用户的所有的拍摄信息
#define PHOTO_ALL  @"/photo/all"
//获取时间分组
#define PHOTO_TIMERLINE @"/photo/timeline"
//获取按年或月查询的概要照片
#define PHOTO_GENERAL @"/photo/general"
//获取按月或日查询的所有照片（分页）
#define PHOTO_DETAIL @"/photo/detail"
//移除
#define PHOTO_Delete @"/fm/rm"
//新建
#define FM_MKDIR_URL @"/fm/mkdir"
//上传校验
#define FM_UPLOAD_VERIFY @"/fm/upload/verify"
//上传
#define FM_UPLOAD @"/fm/upload"
//申请传输文件
#define FM_UPLOAD_STATE @"/fm/upload/state"
//新上传效验 /ent /file/upload/new/verify
#define FM_UPLOAD_NEW_VERIFY @"/file/upload/new/verify"
//新上传  /ent /file/upload/put
#define FM_UPLOAD_NEW @"/file/upload/put"
//新上传提交 /ent /file/upload/commit
#define FM_UPLOAD_NEW_COMMIT @"/file/upload/commit"
//专题上传 新上传效验 /ent /file/upload/new/verify
#define FM_UPLOAD_CLIENT_VERIFY @"/file/upload/clientVerifyIOS"
//专题上传 新上传提交 /file/upload/clientCommit
#define FM_UPLOAD_CLIENTCOMMIT @"/file/upload/clientCommitIOS"
//统一上传
#define FM_UPLOAD_New_CLIENTCOMMIT @"/file/upload/clientUpload"
#pragma mark - 7.分享链接
//发布公开外链
#define LINK_RELEASE_PUB_URI @"/link/release_pub"
//邮件分享私密外链
#define LINK_RELEASE_EMAIL_URI @"/link/release_email"

#pragma mark - 主题管理
//新建主题
#define SM_CREATE_SUBJECT_URI @"/subject/create_subject"
//发布主题评论
//#define SM_CREATE_SUBJECT_URI @""
//查看主题列表
#define SM_LIST_SUBJECT_URI @"/subject/list_subject"
//发布资源到主题的主题列表
#define SM_LIST_PUBLISH_URI @"/subject/listSubjectByUserIdToCli"
//获取主题相关事件动态数
#define SM_NUM_SUBJECT_URI @"/subject/sum_subject_event"
//查看主题/动态信息
#define SM_ACTIVITY_SUBJECT_URI @"/subjectevent/viewSubjectInfoBySubjectId"
//主题右侧栏信息
#define SM_INFORIGHT_SUBJECT_URI @"/subject/viewRightSubjectInfoBySubjectId"
//动态
#define SM_INFOLIST_SUBJECT_URI @"/subjectevent /viewSubjectInfoListByUserId"
//获取专题动态总个数
#define SM_SUM_SUBJECT_URI @"/subject/sum_subjects"
#pragma mark - 资源管理1
//发布资源
#define SM_RESOURCES_PUBLISH_URI @"/subject/resources_publish"
//资源列表
#define SM_RESOURCES_LIST_URI @"/subject/resources_list"
//发布资源评论
#define SM_PUBLISH_COMMENT_URI @"/subject/comment_publish"
//获取资源评论
#define SM_COMMENT_LIST_URI  @"/subject/comment_list"
//判断资源是否存在
#define SM_RESOURCES_EXIST_URI @"/subject/resources_exist"
//成员列表
#define SM_MEMBER_LIST_URI @"/dept/getComMember"
//查看成员信息 /viewSubjectMemberBySubjectId
#define SM_LOOK_MEMBER_URI @"/viewSubjectMemberBySubjectId"
//获取资源文件夹下的文件列表
#define SM_RESOURCE_FILE_LIST_URI  @"/file/listFilesByfid"

//通讯录信息列表
#define DEPT_FIND_ALLDEPTSYS @"/dept/findAllDeptSys"

#endif
