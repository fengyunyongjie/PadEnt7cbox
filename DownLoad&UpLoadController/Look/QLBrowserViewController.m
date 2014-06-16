//
//  QLBrowserViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-6-24.
//
//

#import "QLBrowserViewController.h"

@interface QLBrowserViewController ()

@end

@implementation QLBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - QLPreviewControllerDataSource
// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}
// returns the item that the preview controller should preview
- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index
{
    NSURL *fileURL = nil;
    NSString *fmime=[[self.fileName pathExtension] lowercaseString];
    if ([fmime isEqualToString:@"txt"]) {
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacChineseSimp);
        NSString *text=[NSString stringWithContentsOfFile:self.filePath encoding:encode error:nil];
        bool result=[text writeToFile:[self.filePath stringByAppendingString:@".txt"] atomically:YES encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16) error:nil];
        if (result) {
            fileURL=[NSURL fileURLWithPath:[self.filePath stringByAppendingString:@".txt"]];
        }else
        {
            fileURL=[NSURL fileURLWithPath:self.filePath];
        }
    }else
    {
        fileURL=[NSURL fileURLWithPath:self.filePath];
    }
    return fileURL;
}
#pragma mark - QLPreviewControllerDelegate
@end
