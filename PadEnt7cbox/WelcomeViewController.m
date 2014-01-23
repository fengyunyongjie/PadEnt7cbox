//
//  WelcomeViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "WelcomeViewController.h"
#import "PConfig.h"
__strong static WelcomeViewController *_welcommeVC;
@interface WelcomeViewController ()<UIScrollViewDelegate>
@end

@implementation WelcomeViewController
@synthesize scroll_view,pageCtrl,imageView1,imageView2,imageView3,hidden_button;
//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    [self updateLoadView];
}
-(void)updateViewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        imageWidth = 1024;
        imageHeigth = 768;
        CGRect hidden_rect = CGRectMake(imageWidth*2+(imageWidth-201)/2-10, imageHeigth-200, 201, 52);
        hidden_rect.origin.y = imageHeigth-120;
        [hidden_button setFrame:hidden_rect];
        [pageCtrl setFrame:CGRectMake((768-200)/2, imageHeigth-60, 200, 49)];
    }
    else
    {
        imageWidth = 768;
        imageHeigth = 1024;
        CGRect hidden_rect = CGRectMake(imageWidth*2+(imageWidth-201)/2+5, imageHeigth-200, 201, 52);
        hidden_rect.origin.y = imageHeigth-180;
        [hidden_button setFrame:hidden_rect];
        [pageCtrl setFrame:CGRectMake((1024-200)/2, imageHeigth-60, 200, 49)];
    }
    
    //加载图片
    for (int i=1; i<=3; i++) {
        NSString *fileName = nil;
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            fileName=[NSString stringWithFormat:@"guide%i.png",i];
        }
        else
        {
            fileName=[NSString stringWithFormat:@"guide%i-.png",i];
        }
        if(i==1)
        {
            [imageView1 setImage:[UIImage imageNamed:fileName]];
        }
        else if(i==2)
        {
            [imageView2 setImage:[UIImage imageNamed:fileName]];
        }
        else
        {
            [imageView3 setImage:[UIImage imageNamed:fileName]];
        }
    }
}

-(void)updateLoadView
{
    CGRect self_rect = CGRectMake(0, 0, imageWidth, imageHeigth);
    [self.view setFrame:self_rect];
    CGRect scroll_rect = CGRectMake(0, 0, imageWidth, imageHeigth);
    [scroll_view setFrame:scroll_rect];
    [scroll_view setContentSize:CGSizeMake(imageWidth*3, imageHeigth)];
    for (int i=0; i<3; i++)
    {
        imageView1.frame=CGRectMake(0, 0, imageWidth, imageHeigth);
        imageView2.frame=CGRectMake(imageWidth, 0, imageWidth, imageHeigth);
        imageView3.frame=CGRectMake(2*imageWidth, 0, imageWidth, imageHeigth);
    }
    
    [scroll_view setContentOffset:CGPointMake(imageWidth * pageCtrl.currentPage, 0) animated:YES];
}

+(WelcomeViewController *)sharedUser
{
    if (_welcommeVC) {
        return _welcommeVC;
    }else
    {
        _welcommeVC=[[WelcomeViewController alloc] init];
        return _welcommeVC;
    }
}
-(void)showWelCome
{
    [[UIApplication sharedApplication].keyWindow addSubview: self.view];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIInterfaceOrientation toInterfaceOrientation=[self interfaceOrientation];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    
    CGRect self_rect = CGRectMake(0, 0, imageWidth, imageHeigth);
    [self.view setFrame:self_rect];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect scroll_rect = CGRectMake(0, 0, imageWidth, imageHeigth);
    scroll_view=[[UIScrollView alloc] initWithFrame:scroll_rect];
    [scroll_view setContentSize:CGSizeMake(imageWidth*3, imageHeigth)];
    [scroll_view setPagingEnabled:YES];
    [scroll_view setDelegate:self];
    [scroll_view setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:scroll_view];
    
    //加载图片
    for (int i=1; i<=3; i++) {
        NSString *fileName = nil;
        
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            fileName=[NSString stringWithFormat:@"guide%i.png",i];
        }
        else
        {
            fileName=[NSString stringWithFormat:@"guide%i-.png",i];
        }
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
        imageView.frame=CGRectMake((i-1)*imageWidth, 0, imageWidth, imageHeigth);
        if(i==1)
        {
            imageView1 = imageView;
            [scroll_view addSubview:imageView1];
        }
        else if(i==2)
        {
            imageView2 = imageView;
            [scroll_view addSubview:imageView2];
        }
        else
        {
            imageView3 = imageView;
            [scroll_view addSubview:imageView3];
        }
    }
    
    UIPageControl *_pageCtrl=[[UIPageControl alloc] initWithFrame:CGRectMake((imageWidth-200)/2, imageHeigth-60, 200, 49)];
    [_pageCtrl setNumberOfPages:3];
    [_pageCtrl addTarget:self action:@selector(clicked_page:) forControlEvents:UIControlEventTouchUpInside];
    [_pageCtrl setPageIndicatorTintColor:[UIColor colorWithRed:142/255.0f green:142/255.0f blue:142/255.0f alpha:1]];
    [_pageCtrl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:31/255.0f green:58/255.0f blue:125/255.0f alpha:1]];
    pageCtrl = _pageCtrl;
    [self.view addSubview:pageCtrl];
    
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(imageWidth*2+(imageWidth-201)/2, imageHeigth-200, 201, 52)];
    [button setBackgroundImage:[UIImage imageNamed:@"guide_bt_nor.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"guide_bt_se.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(toHideView) forControlEvents:UIControlEventTouchUpInside];
    hidden_button = button;
    [scroll_view addSubview:hidden_button];
    [self updateViewToInterfaceOrientation:toInterfaceOrientation];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        [pageCtrl setFrame:CGRectMake((1024-200)/2, 768-60, 200, 49)];
    }else
    {
        [pageCtrl setFrame:CGRectMake((768-200)/2, 1024-60, 200, 49)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)clicked_page:(id)sender
{
    UIPageControl *page = sender;
    if([page isKindOfClass:[UIPageControl class]])
    {
        [scroll_view setContentOffset:CGPointMake(imageWidth * page.currentPage, 0) animated:YES];
    }
}
-(void)toHideView
{
    [[NSUserDefaults standardUserDefaults] setObject:VERSION forKey:VERSION];
//    [self.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/imageWidth;
    if(scrollView.contentOffset.x > imageWidth * 2 )
    {
        [self.pageCtrl setHidden:YES];
    }
    else
    {
        [self.pageCtrl setHidden:NO];
    }
    [self.pageCtrl setCurrentPage:page];
    NSLog(@"page1:%i",page);
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/imageWidth;
    if(scrollView.contentOffset.x > imageWidth * 2 )
    {
        [self.pageCtrl setHidden:YES];
    }
    else
    {
        [self.pageCtrl setHidden:NO];
    }
    [self.pageCtrl setCurrentPage:page];
    NSLog(@"page2:%i",page);
}

@end
