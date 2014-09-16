//
//  NothingViewController.m
//  PadEnt7cbox
//
//  Created by fengyongning on 14-9-16.
//  Copyright (c) 2014年 Yangshenglou. All rights reserved.
//

#import "NothingViewController.h"
#import "CutomNothingView.h"

@interface NothingViewController ()
@property (strong,nonatomic) CutomNothingView *nothingView;
@end

@implementation NothingViewController

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
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNothingView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)createNothingView
{
    if (!self.nothingView) {
        float boderHeigth = 20;
        float labelHeight = 40;
        float imageHeight = 100;
        CGRect nothingRect = self.view.bounds;
        self.nothingView = [[CutomNothingView alloc] initWithFrame:nothingRect boderHeigth:boderHeigth labelHeight:labelHeight imageHeight:imageHeight];
        [self.view addSubview:self.nothingView];
        [self.view bringSubviewToFront:self.nothingView];
        [self.nothingView notHiddenView];
        [self.nothingView.notingLabel setText:@""];
    }
}
@end
