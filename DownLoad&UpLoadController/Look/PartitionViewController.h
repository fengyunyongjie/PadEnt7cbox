//
//  PartitionViewController.h
//  PadEnt7cbox
//
//  Created by Yangsl on 13-12-26.
//  Copyright (c) 2013年 Yangshenglou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SCBLinkManager.h"
#import <MessageUI/MessageUI.h>
#import "LookDownFile.h"
#import "SCBFileManager.h"
#import "PhotoLookViewController.h"
#import "DwonFile.h"

@interface PartitionViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,SCBLinkManagerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,LookDownDelegate,SCBFileManagerDelegate,PhotoLookViewDelegate,DownloaderDelegate>{
    /*
     缩放代码
     */
    NSMutableArray *tableArray;
    NSInteger currPage;
    
    /*
     操作提示
     */
    MBProgressHUD *hud;
    int deletePage;
    
    /*
     记录滑动中加载了多少条数据
     */
    NSInteger startPage;
    NSInteger endPage;
    
    /*
     字典类型把已经加载完成的数据存储
     */
    NSMutableArray *activityDic;
    
    /*
     滑动不加载数据
     */
    BOOL isLoadImage;
    CGFloat currWidth;
    CGFloat currHeight;
    
    NSInteger endCurrPage;
    
    UIScrollView *imageScrollView;
    CGFloat enFloat;
    
    NSMutableArray *downArray;
    
    int sharedType; //1 短信分享，2 邮件分享，3 复制，4 微信，5 朋友圈
    
    SCBLinkManager *linkManager;
    NSString *selected_id;
    CGFloat ScollviewHeight; //当前屏幕的高度
    CGFloat ScollviewWidth; //当前屏幕的宽度
}

@property (atomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) NSMutableArray *tableArray;
@property (nonatomic, assign) NSInteger currPage;

@property(assign,nonatomic) CGFloat offset;
@property(assign,nonatomic) BOOL isDoubleClick;

/*
 添加头部和底部栏
 */
@property(retain,nonatomic) UIButton *topLeftButton;
@property(retain,nonatomic) UILabel *topTitleLabel;
@property(retain,nonatomic) UIToolbar *topToolBar;

@property(retain,nonatomic) UIButton *leftButton;
@property(retain,nonatomic) UIButton *rightButton;
@property(assign,nonatomic) BOOL isHaveDelete;
@property(assign,nonatomic) BOOL isHaveDownload;
@property(retain,nonatomic) UIToolbar *bottonToolBar;
@property(assign,nonatomic) BOOL isScape;
@property(assign,nonatomic) int page;
@property(assign,nonatomic) int endFloat;
@property(nonatomic,retain) SCBLinkManager *linkManager;
@property(nonatomic,retain) NSString *selected_id;
@property(nonatomic,retain) MBProgressHUD *hud;
@property(strong,nonatomic) SCBFileManager *fm;
@property(nonatomic,strong) UIControl *jindu_control;
@property(nonatomic,strong) UIView *jinDuView;
@property(strong,nonatomic) UIImageView *progess_imageView;
@property(strong,nonatomic) UIImageView *progess2_imageView;
@property(strong,nonatomic) DwonFile *downImageS;

-(CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center;

-(void)clipClicked:(id)sender;

-(void)deleteClicked:(id)sender;

-(void)showJinDu;

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

-(void)cancelDown;

@end
