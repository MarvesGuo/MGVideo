//
//  MGPlayerViewController.h
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGPlayerViewController : UIViewController

@property (nonatomic,strong) NSURL *videoURL;

- (instancetype)initWithVideoURL:(NSURL *)URL;

@end
