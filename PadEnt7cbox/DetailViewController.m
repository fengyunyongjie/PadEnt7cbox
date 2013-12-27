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

-(void)showPhotoView:(BOOL)isHaveDelete
{
    int width = 50;
    CGRect leftRect = CGRectMake(0, 5, width, 33);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:leftRect];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftButton.titleLabel setTextColor:[UIColor blackColor]];
    [leftButton setTitle:@"下载" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clipClicked) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    leftButton.showsTouchWhenHighlighted = YES;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if(isHaveDelete)
    {
        CGRect rightRect = CGRectMake(0, 5, width, 33);
        UIButton *rightButton = [[UIButton alloc] initWithFrame:rightRect];
        [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [rightButton.titleLabel setTextColor:[UIColor blackColor]];
        [rightButton setTitle:@"删除" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setBackgroundColor:[UIColor clearColor]];
        rightButton.showsTouchWhenHighlighted = YES;
        UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

-(void)hiddenPhototView
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = nil;
}

-(void)showOtherView:(NSString *)title
{
    self.navigationItem.title = title;
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
