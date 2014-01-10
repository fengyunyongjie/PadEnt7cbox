//
//  DetailViewController.m
//  mdtest
//
//  Created by fengyongning on 13-12-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DetailViewController.h"
#import "PartitionViewController.h"
#import "OtherBrowserViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize titleLabel,splitView_array,isFileManager,file_id;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(void)removeAllView
{
    for(UIViewController *viewCon in self.childViewControllers)
    {
        if([viewCon isKindOfClass:[OtherBrowserViewController class]])
        {
            OtherBrowserViewController *otherBrowser = (OtherBrowserViewController *)viewCon;
            [otherBrowser back:nil];
        }
        [viewCon.view removeFromSuperview];
        [viewCon removeFromParentViewController];
    }
    [self hiddenPhototView];
}

-(void)showPhotoView:(NSString *)title withIsHave:(BOOL)isHaveDelete
{
    if(titleLabel == nil)
    {
        CGRect title_rect = CGRectMake(0, 10, 200, 20);
        UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            title_rect.origin.x = (1024-320-200)/2;
        }
        else
        {
            title_rect.origin.x = (768-320-200)/2;
        }
        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar addSubview:titleLabel];
        
        CGRect down_rect = CGRectMake(0, 0, 20, 20);
        UIButton *down_button = [[UIButton alloc] initWithFrame:down_rect];
        [down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_nor@2x.png"] forState:UIControlStateNormal];
        UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:down_button];
        UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
        [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
        splitView_array = [NSMutableArray arrayWithObjects:deleteItem,downItem,nil];
    }
    if(!isHaveDelete)
    {
        [splitView_array removeObjectAtIndex:0];
    }
    [titleLabel setText:title];
    self.navigationItem.rightBarButtonItems = splitView_array;
}

-(void)hiddenPhototView
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [titleLabel setText:@""];
    self.navigationItem.rightBarButtonItems = nil;
}

-(void)showOtherView:(NSString *)title
{
    if(titleLabel == nil)
    {
        CGRect title_rect = CGRectMake(0, 10, 200, 20);
        UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            title_rect.origin.x = (1024-320-200)/2;
        }
        else
        {
            title_rect.origin.x = (768-320-200)/2;
        }
        titleLabel = [[UILabel alloc] initWithFrame:title_rect];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar addSubview:titleLabel];
        
        CGRect down_rect = CGRectMake(0, 0, 20, 20);
        UIButton *down_button = [[UIButton alloc] initWithFrame:down_rect];
        [down_button setBackgroundImage:[UIImage imageNamed:@"bt_download_nor@2x.png"] forState:UIControlStateNormal];
        UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithCustomView:down_button];
        UIButton *delete_button = [[UIButton alloc] initWithFrame:down_rect];
        [delete_button setBackgroundImage:[UIImage imageNamed:@"bt_del_nor@2x.png"] forState:UIControlStateNormal];
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:delete_button];
        splitView_array = [NSMutableArray arrayWithObjects:deleteItem,downItem,nil];
    }
    [titleLabel setText:title];
    self.navigationItem.rightBarButtonItems = splitView_array;
}

-(void)clipClicked
{
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            PartitionViewController *parttion = (PartitionViewController *)viewCon;
            [parttion clipClicked:nil];
            break;
        }
    }
}

-(void)deleteClicked
{
    for (UIViewController *viewCon in self.childViewControllers) {
        if([viewCon isKindOfClass:[PartitionViewController class]])
        {
            PartitionViewController *parttion = (PartitionViewController *)viewCon;
            [parttion deleteClicked:nil];
            break;
        }
    }
}

@end
