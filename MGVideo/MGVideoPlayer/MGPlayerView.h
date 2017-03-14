//
//  MGPlayerView.h
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol MGPlayerViewDelegate;

@interface MGPlayerView : UIView

@property (nonatomic ,strong) NSString *videoURL;

@property (nonatomic ,readonly) AVPlayer *player;
@property (nonatomic ,readonly) AVPlayerLayer *playerLayer;
@property (nonatomic ,readonly) AVPlayerItem *item;

@property (nonatomic, weak) id<MGPlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)videoURL delegate:(id<MGPlayerViewDelegate> )delegate;

- (void)play;
- (void)pause;
- (void)stop;

- (NSString *)timeShowStringFromSliderValue:(CGFloat)value; //0-1

@end



@protocol MGPlayerViewDelegate

@optional

- (void)mg_playerView:(MGPlayerView *)playerView didChangeWithCurrentTime:(NSString *)timeString sliderValue:(float)sliderValue;

@end
