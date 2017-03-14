//
//  MGPlayerView.m
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import "MGPlayerView.h"

@implementation MGPlayerView


- (void)play
{
    _item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://videoplayer.babytreeimg.com/2017/0310/llfjkp_gxlhd0uNKXXYG1dX55_IU.mp4"]];
    _player = [AVPlayer playerWithPlayerItem:_item];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    if([[UIDevice currentDevice] systemVersion].intValue>=10)
    {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self.layer addSublayer:_playerLayer];
    [_player play];
}

@end
