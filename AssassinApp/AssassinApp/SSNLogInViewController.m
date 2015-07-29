//
//  SSNLogInViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNLogInViewController.h"
#import "SSNUserViewController.h"
#import "SSNGameViewController.h"
#import "Reachability.h"

@interface SSNLogInViewController () <PFLogInViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL internetActive;
@end

@implementation SSNLogInViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.logInView.logInButton.enabled = NO;
    self.logInView.dismissButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];

    // check if a pathway to a random host exists
    self.hostReachable = [Reachability reachabilityWithHostName:@"www.google.com"];
    [self.hostReachable startNotifier];
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
            self.internetActive = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"You are not connected to a network. Please connect and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // To launch User View
//    SSNUserViewController *userViewController = [[SSNUserViewController alloc] init];
//    [self.navigationController presentViewController:userViewController animated:NO completion:nil];
    
    // To launch game view
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] init];
    [self presentViewController:gameViewController animated:NO completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    if(!self.internetActive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"You are not connected to a network. Please connect and try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Username and password was not found." delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alert show];
    }
    self.logInView.passwordField.text = @"";
    self.logInView.logInButton.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(![self.logInView.usernameField.text isEqualToString:@""] && [string isEqualToString:@""] && range.location == 0)
    {
        self.logInView.logInButton.enabled = NO;
    }
    else if(![self.logInView.usernameField.text isEqualToString:@""] && ![string isEqualToString:@""] && [textField isEqual:self.logInView.passwordField])
    {
        self.logInView.logInButton.enabled = YES;
    }
    else if(![self.logInView.passwordField.text isEqualToString:@""] && ![string isEqualToString:@""] && [textField isEqual:self.logInView.usernameField])
    {
        self.logInView.logInButton.enabled = YES;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
