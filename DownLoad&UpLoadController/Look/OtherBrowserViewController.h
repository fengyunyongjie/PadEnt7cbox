//
//  OtherBrowserViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-27.
//
//

#import <UIKit/UIKit.h>
#import "QLBrowserViewController.h"
#import "DwonFile.h"

@protocol DownloadProgressDelegate <NSObject>
-(void)downloadFinished:(NSDictionary *)dataDic;
@end

@interface OtherBrowserViewController : UIViewController<UIDocumentInteractionControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,DownloaderDelegate>
{
    BOOL isBack;
}
@property (strong,nonatomic) id<DownloadProgressDelegate> dpDelegate;

@property (strong,nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (strong,nonatomic) IBOutlet UILabel *downloadLabel;
@property (strong,nonatomic) IBOutlet UIImageView *iconImageView;
@property (assign,nonatomic) BOOL isFinished;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSString *savePath;

@property (strong,nonatomic) UILabel *titleLabel;


-(IBAction)openWithOthersApp:(id)sender;
-(IBAction)shared:(id)sender;
-(IBAction)download:(id)sender;
-(void)back:(id)sender;
@end