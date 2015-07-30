//
//  AppDelegate.m
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "SSNLogInViewController.h"
#import "SSNSignUpViewController.h"
#import "SSNUserViewController.h"
#import "SSNGameViewController.h"
#import "SSNUser.h"
#import "Reachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SSNUser registerSubclass];
    
    [Parse setApplicationId:@"u9m11ErRytB4i6hNRUNvBMBeROirhXRp93Zj5oKY"
                  clientKey:@"6KeMZ2zHH1wPXW5zv6isZqpyG08jX0TRh3iG3CEG"];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    self.hostReachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.hostReachable startNotifier];
    
    UIViewController *rootViewController;
    PFUser *loggedInUser = [PFUser currentUser];
    if(loggedInUser)
    {
        // To default into Game View
        //rootViewController = [[SSNGameViewController alloc] initWithNibName:@"SSNGameViewController" bundle:nil];
        
        // To default into User View
        rootViewController = [[SSNUserViewController alloc] initWithNibName:@"SSNUserViewController" bundle:nil];
    }
    else
    {
        rootViewController = [[SSNLogInViewController alloc] initWithNibName:@"SSNLogInViewController" bundle:nil];
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.isConnectedToInternet = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"You are not connected to a network. Please connect and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.isConnectedToInternet = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.isConnectedToInternet = YES;
            break;
        }
    }
}
@end
