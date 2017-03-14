//
//  MGPlayerViewController.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "MGPlayerViewController.h"
#import "MGPlayerView.h"

@interface MGPlayerViewController ()
<
    MGPlayerViewDelegate
>

@property (nonatomic,weak) MGPlayerView   *_playerView;

@property (nonatomic,weak) UIButton   *_playButton;
@property (nonatomic,weak) UISlider   *_slider;
@property (nonatomic,weak) UILabel    *_timeLabel;

@property (nonatomic,assign) BOOL _isSliderDragging;

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


#pragma mark - delegate
#pragma mark - MGPlayerViewDelegate
- (void)mg_playerView:(MGPlayerView *)playerView didChangeWithCurrentTime:(NSString *)timeString sliderValue:(float)sliderValue
{
    if (!__isSliderDragging)
    {
        __timeLabel.text = timeString;
        [__slider setValue:sliderValue];
    }
}


#pragma mark - event response

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playButtonAction
{
    // rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
    if (__playerView.player.rate == 1.0)
    {
        [self pauseVideoAction];
    }
    else
    {
        [self playVideoAction];
    }
}

- (void)sliderValueDidChangeAction:(UISlider *)slider
{
    //改变时间
    __timeLabel.text = [__playerView timeShowStringFromSliderValue:slider.value];
}

- (void)sliderValueWillChangeAction:(UISlider *)slider
{
    __isSliderDragging = YES;
}
- (void)sliderChangeEndAction:(UISlider *)slider
{
    //跳到具体播放位置
    [__playerView jumpToPercent:slider.value];
    __isSliderDragging = NO;
}

- (void)sliderChangeOutEndAction:(UISlider *)slider
{
    __isSliderDragging = NO;
    
    //还原 显示Label
}

- (void)sliderChangeCancelAction:(UISlider *)slider
{
    __isSliderDragging = NO;
    
    // do nothing
}

#pragma mark -- player action
- (void)playVideoAction
{
    [__playerView play];
    [__playButton setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)pauseVideoAction
{
    [__playerView pause];
    [__playButton setTitle:@"播放" forState:UIControlStateNormal];
}


#pragma mark -- gestures action

- (void)doubleTapGestureAction
{
    [self playButtonAction];
}


#pragma mark - private methods
#pragma mark --UI

-(void)_initUI
{
    self.view.backgroundColor = [UIColor blackColor];

    [self _addBackButton];
    [self _addPlayerView];
    [self _addBottomView];
    
    [self _addGestures];
}

- (void)_addBackButton
{
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(10, 10, 50, 40)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

-(void)_addPlayerView
{
    MGPlayerView *playerView = [[MGPlayerView alloc]initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width - 120) videoURL:nil delegate:self];
    [self.view addSubview:playerView];
    self._playerView = playerView;
}

- (void)_addBottomView
{
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height, 60)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];

    //暂停 播放
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setFrame:CGRectMake(10, 10, 50, 40)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    __playButton = playButton;
    
    //进度条
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(__playButton.frame.origin.x + __playButton.frame.size.width + 20, __playButton.frame.origin.y, [UIScreen mainScreen].bounds.size.height - 200, 40)];
    [slider setMinimumValue:0];
    [slider setMaximumValue:1];
    [slider addTarget:self action:@selector(sliderValueDidChangeAction:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderValueWillChangeAction:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderChangeEndAction:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderChangeOutEndAction:) forControlEvents:UIControlEventTouchUpOutside];
    [slider addTarget:self action:@selector(sliderChangeCancelAction:) forControlEvents:UIControlEventTouchCancel];
    
    [bottomView addSubview:slider];
    __slider = slider;
    
    //播放时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(__slider.frame.origin.x + __slider.frame.size.width + 20, __slider.frame.origin.y, 100, 40)];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.text = @"00:00/00:00";
    [bottomView addSubview:timeLabel];
    __timeLabel = timeLabel;
    
    __timeLabel.text = [self timeShowStringFromCMTime:__playerView.player.currentTime];
}

- (void)_addGestures
{
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGestureAction)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
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

#pragma mark - utils
- (NSString *)timeShowStringFromCMTime:(CMTime)time
{
    float currentTimeValue = (CGFloat)time.value/time.timescale;//得到当前的播放时
    
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:currentTimeValue];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:currentDate];
    
    if (currentTimeValue >= 3600 )
    {
        return [NSString stringWithFormat:@"%2ld:%2ld:%2ld",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%2ld:%2ld",components.minute,components.second];
    }
}


@end
