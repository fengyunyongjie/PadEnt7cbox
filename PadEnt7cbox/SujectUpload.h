//
//  SujectUpload.h
//  icoffer
//
//  Created by Yangsl on 14-7-16.
//  Copyright (c) 2014年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpLoadList.h"
#import "SCBUploader.h"

typedef enum {
    SJUploadTypePhoto,  //拍照上传
    SJUploadTypeCommentAudio, //音频评论上传
}SJUploadType;

@protocol SubjectUploadDelegate <NSObject>

//上传成功
-(void)upFinish:(NSDictionary *)dicationary fileinfo:(UpLoadList *)list;
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)sudu;
//文件重名
-(void)upReName;
//上传失败
-(void)upError;
//服务器异常
-(void)webServiceFail;
//上传无权限
-(void)upNotUpload;
//用户存储空间不足
-(void)upUserSpaceLass;
//等待WiFi
-(void)upWaitWiFi;
//网络失败
-(void)upNetworkStop;
//文件名过长
-(void)upNotNameTooTheigth;
//上传文件大小大于1g
-(void)upNotSizeTooBig;
//文件名存在特殊字符
-(void)upNotHaveXNSString;
//文件不存在
-(void)upNotFile;
@end

@interface SujectUpload : NSObject<UpLoadDelegate>

@property(nonatomic, strong) SCBUploader *uploderDemo;
@property(nonatomic, strong) NSString *finishName;
@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) UpLoadList *list;
@property(nonatomic, strong) NSArray *urlNameArray;
@property(nonatomic, assign) NSInteger urlIndex;
@property(nonatomic, strong) __block NSData *file_data;
@property(nonatomic, strong) NSString *md5String;
@property(nonatomic, assign) NSInteger total;
@property(nonatomic, assign) SJUploadType uploadType;
@property(nonatomic, strong) id<SubjectUploadDelegate> delegate;
@property(nonatomic, assign) BOOL isStop;
@property(nonatomic,strong) __block NSData *total_data;

-(void)isNetWork;

@end
