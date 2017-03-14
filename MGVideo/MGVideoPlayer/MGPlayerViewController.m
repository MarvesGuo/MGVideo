//
//  MGPlayerViewController.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "MGPlayerViewController.h"
#import "MGPlayerView.h"
#import "VideoView.h"

@interface MGPlayerViewController ()

@property (nonatomic,strong) MGPlayerView *_playerView;

@end

@implementation MGPlayerViewController


#pragma mark - life cycle

- (void)dealloc
{

}

- (instancetype)initWithVideoURL:(NSURL *)URL {
    self = [super init];
    if (self)
    {
        self.videoURL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initUI];
}


#pragma mark - event response

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private methods
#pragma mark --UI

-(void)_initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(10, 10, 50, 40)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self _addPlayerView];
    
    [self._playerView play];
}


-(void)_addPlayerView
{
    MGPlayerView *playerView = [[MGPlayerView alloc]initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width - 120)];
    [self.view addSubview:playerView];
    self._playerView = playerView;
}


#pragma mark - override
#pragma mark --支持横屏
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}


@end
