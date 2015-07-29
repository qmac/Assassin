//
//  AppDelegate.h
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Reachability *internetReachable;
@property (nonatomic, strong) Reachability *hostReachable;
@property (nonatomic) BOOL isConnectedToInternet;

@end

