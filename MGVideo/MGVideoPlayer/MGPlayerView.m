//
//  MGPlayerView.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "MGPlayerView.h"


@interface MGPlayerView()

@property (nonatomic ,assign) CGFloat videoLength;
@property (nonatomic ,strong) id timeObserver;

@end



@implementation MGPlayerView

- (void)dealloc
{
    
    [self _removePlayerObserver];
    [self _removeNotification];
    [self _removePlayerTimeObserver];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}


- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)videoURL delegate:(id<MGPlayerViewDelegate> )delegate
{
    
    if(videoURL.length == 0)
    {
        videoURL = @"http://videoplayer.babytreeimg.com/2017/0310/llfjkp_gxlhd0uNKXXYG1dX55_IU.mp4";
    }
    
    if (self = [super initWithFrame:frame])
    {
        _videoURL = videoURL;
        _delegate = delegate;
        
        _item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:videoURL]];
        _player = [AVPlayer playerWithPlayerItem:_item];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        if([[UIDevice currentDevice] systemVersion].intValue >= 10)
        {
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
        [self.layer addSublayer:_playerLayer];

        [self _addPlayerObserver];
        [self _addNotifications];
        [self _addPlayerTimeObserver];
        
    }
    return self;
}

#pragma mark - Public methods

- (void)play
{
    [_player play];
}

- (void)pause
{
    [_player pause];
}

- (void)stop
{

}

#pragma mark - Private methods
#pragma mark -- KVO methods

- (void)_addPlayerObserver    //KVO
{
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removePlayerObserver {
    [_item removeObserver:self forKeyPath:@"status"];
    [_item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus status = _item.status;
        
        switch (status)
        {
            case AVPlayerItemStatusReadyToPlay:
            {
//                NSLog(@"AVPlayerItemStatusReadyToPlay");
                _videoLength = floor(_item.asset.duration.value * 1.0/ _item.asset.duration.timescale);
                [_player play];
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
//                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
//                NSLog(@"AVPlayerItemStatusFailed");
//                NSLog(@"%@",_item.error);
            }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        
    }
}


#pragma mark -- Notification methods

- (void)_addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerDidPlayToEndTimeAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerTimeJumpedAction:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerPlaybackStalledAction:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackgroundAction:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)_removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_playerDidPlayToEndTimeAction:(NSNotification *)sender
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)_playerTimeJumpedAction:(NSNotification *)sender
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)_playerPlaybackStalledAction:(NSNotification *)sender
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)_applicationDidEnterBackgroundAction:(NSNotification *)sender
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}



#pragma mark -- play time methods

- (void)_addPlayerTimeObserver
{
    __weak typeof (self)weakSelf = self;
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:NULL usingBlock:^(CMTime time)
    {
        float currentSliderValue = time.value * 1.0 / time.timescale / weakSelf.videoLength;
        
        NSString *currentString = [weakSelf timeShowStringFromTimeCMTime:time];
        NSString *totalString = [weakSelf timeShowStringFromTime:weakSelf.videoLength];
        NSString *showString = [NSString stringWithFormat:@"%@/%@", currentString,totalString];
        
        if (weakSelf.delegate && [(NSObject *)weakSelf.delegate respondsToSelector:@selector(mg_playerView:didChangeWithCurrentTime:sliderValue:)])
        {
            [weakSelf.delegate mg_playerView:weakSelf didChangeWithCurrentTime:showString sliderValue:currentSliderValue];
        }
    }];
}

- (void)_removePlayerTimeObserver
{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver =  nil;
}


#pragma mark - Utils

- (NSString *)timeShowStringFromTimeCMTime:(CMTime)time
{
    NSTimeInterval currentTimeValue = (NSTimeInterval)time.value/time.timescale;
    return [self timeShowStringFromTime:currentTimeValue];
}

- (NSString *)timeShowStringFromTime:(NSTimeInterval)time
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    if (time >= 60 * 60 )
    {
        return [NSString stringWithFormat:@"%ld:%ld:%ld",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld:%ld",components.minute,components.second];
    }
}



@end
