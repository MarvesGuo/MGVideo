//
//  MGPlayerView.h
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface MGPlayerView : UIView

@property (nonatomic ,strong) NSString *playerUrl;

@property (nonatomic ,readonly) AVPlayer *player;
@property (nonatomic ,readonly) AVPlayerLayer *playerLayer;
@property (nonatomic ,readonly) AVPlayerItem *item;

- (void)play;

@end
