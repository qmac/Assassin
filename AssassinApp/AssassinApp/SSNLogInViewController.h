//
//  SSNLogInViewController.h
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <ParseUI/PFLogInViewController.h>

@class Reachability;

@interface SSNLogInViewController : PFLogInViewController

@property (nonatomic, strong) Reachability *internetReachable;
@property (nonatomic, strong) Reachability *hostReachable;

@end
