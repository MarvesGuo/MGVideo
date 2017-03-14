//
//  MGPlayerViewController.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "MGPlayerViewController.h"
#import "MGPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, MGTouchType)
{
    MGTouchTypeNone = 0,
    MGTouchTypeLeft,        //触摸左边 音量
    MGTouchTypeMiddle,      //触摸中间 快进
    MGTouchTypeRight        //触摸右边 亮度
};

@interface MGPlayerViewController ()
<
    MGPlayerViewDelegate
>
{
    BOOL __isSliderDragging;
    
    MGTouchType __currentTouchType;
    
    CGFloat __beginTouchX;
    CGFloat __offsetX;
    CGFloat __beginTouchY;
    CGFloat __offsetY;
}

@property (nonatomic,weak) MGPlayerView   *_playerView;

@property (nonatomic,weak) UILabel    *_swipeInfoLabel;
@property (nonatomic,weak) UIButton   *_playButton;
@property (nonatomic,weak) UISlider   *_slider;
@property (nonatomic,weak) UILabel    *_timeLabel;

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

- (void)mg_playerViewDidFinishPlay:(MGPlayerView *)playerView
{
    //刷新播放按钮
    [__playButton setTitle:@"播放" forState:UIControlStateNormal];
}


#pragma mark - event response

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playButtonAction
{
    if ([__playerView isPlaying])
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
    [self _addSwipeInfoLabel];
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

- (void)_addSwipeInfoLabel
{
    UILabel *swipeInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    swipeInfoLabel.center = CGPointMake(self.view.bounds.size.height/2.0, self.view.bounds.size.width/2.0);
    swipeInfoLabel.font = [UIFont systemFontOfSize:14];
    swipeInfoLabel.textColor = [UIColor whiteColor];
    swipeInfoLabel.textAlignment = NSTextAlignmentLeft;
    swipeInfoLabel.adjustsFontSizeToFitWidth = YES;
    swipeInfoLabel.text = @"快进 00:00/00:00";
    swipeInfoLabel.hidden = YES;
    [self.view addSubview:swipeInfoLabel];
    __swipeInfoLabel = swipeInfoLabel;
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

#pragma mark -- 滑动快进后退

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *oneTouch = [touches anyObject];
    __beginTouchX = [oneTouch locationInView:oneTouch.view].x;
    __beginTouchY = [oneTouch locationInView:oneTouch.view].y;
    
    if (__beginTouchX <= 120 && __beginTouchX >= 0)
    {
        __currentTouchType = MGTouchTypeLeft;
    }
    else if (__beginTouchX < self.view.frame.size.width - 120 && __beginTouchX >120)
    {
        __currentTouchType = MGTouchTypeMiddle;
    }
    else if (__beginTouchX <= self.view.frame.size.width && __beginTouchX >= self.view.frame.size.width - 120)
    {
        __currentTouchType = MGTouchTypeRight;
    }
    else
    {
        __currentTouchType = MGTouchTypeNone;
    }
    
}


//滑动快进/快退    (滑动一个个屏，走50%)
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (__currentTouchType == MGTouchTypeMiddle && [__playerView isPlaying] && __offsetX != 0)
    {
        [__playerView pause];
    }
    
    UITouch *oneTouch = [touches anyObject];
    __offsetX = [oneTouch locationInView:oneTouch.view].x - __beginTouchX;
    __offsetY = [oneTouch locationInView:oneTouch.view].y - __beginTouchY;

    CGFloat deltaPercentX = __offsetX / self.view.frame.size.height;
    CGFloat deltaPercentY = -__offsetY / self.view.frame.size.width;
    
    NSLog(@" ====== %f",deltaPercentY);
    
    switch (__currentTouchType)
    {
        case MGTouchTypeLeft:
        {
            
            MPVolumeView *volumeView = [[MPVolumeView alloc] init];
            UISlider* volumeViewSlider = nil;
            for (UIView *view in [volumeView subviews]){
                if ([view.class.description isEqualToString:@"MPVolumeSlider"])
                {
                    volumeViewSlider = (UISlider*)view;
                    break;
                }
            }
            
            // retrieve system volume
            CGFloat systemVolume = volumeViewSlider.value;
            CGFloat volume = systemVolume + deltaPercentY;
            // change system volume, the value is between 0.0f and 1.0f
            
            [volumeViewSlider setValue:volume animated:YES];
            // send UI control event to make the change effect right now.
            [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
        case MGTouchTypeMiddle:
        {
            CGFloat toTimePercent = __slider.value + deltaPercentX;
            toTimePercent = MIN(1, toTimePercent);
            toTimePercent = MAX(0, toTimePercent);
            
            if (__offsetX > 0)
            {
                __swipeInfoLabel.hidden = NO;
                __swipeInfoLabel.text = [NSString stringWithFormat:@">>> %@",[__playerView timeShowStringFromSliderValue:toTimePercent]];
            }
            else if (__offsetX < 0)
            {
                __swipeInfoLabel.hidden = NO;
                __swipeInfoLabel.text = [NSString stringWithFormat:@"<<< %@",[__playerView timeShowStringFromSliderValue:toTimePercent]];
            }
            else
            {
                __swipeInfoLabel.hidden = YES;
            }
        }
            break;
        case MGTouchTypeRight:
        {
            CGFloat brightness = [UIScreen mainScreen].brightness - deltaPercentY;
            brightness = MIN(1, brightness);
            brightness = MAX(0, brightness);
            [[UIScreen mainScreen] setBrightness: brightness];//0.5是自己设定认为比较合适的亮度值
        }
            break;
        case MGTouchTypeNone:
        {
            
        }
            break;
        default:
            break;
    }
    
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    __offsetX = [oneTouch locationInView:oneTouch.view].x - __beginTouchX;
    __offsetY = [oneTouch locationInView:oneTouch.view].y - __beginTouchY;
    
    CGFloat deltaPercentX = __offsetX / self.view.frame.size.height;
    CGFloat deltaPercentY = __offsetY / self.view.frame.size.width;
    
    switch (__currentTouchType)
    {
        case MGTouchTypeLeft:
        {
            
        }
            break;
        case MGTouchTypeMiddle:
        {
            __swipeInfoLabel.hidden = YES;
            CGFloat toTimePercent = __slider.value + deltaPercentX;
            toTimePercent = MIN(1, toTimePercent);
            toTimePercent = MAX(0, toTimePercent);
            [__playerView jumpToPercent:toTimePercent];
            
        }
            break;
        case MGTouchTypeRight:
        {
            
        }
            break;
        case MGTouchTypeNone:
        {
            
        }
            break;
        default:
            break;
    }
    
    __beginTouchX = 0;
    __offsetX = 0;
    
    __beginTouchY = 0;
    __offsetY = 0;

}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}


#pragma mark -- 支持横屏
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
