//
//  AppDelegate.h
//  MGVideo
//
//  Created by MarvesG on 2017/3/14.
//  Copyright © 2017年 MarvesG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

