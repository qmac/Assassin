//
//  SSNLogInViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNLogInViewController.h"
#import "SSNUserViewController.h"

@interface SSNLogInViewController () <PFLogInViewControllerDelegate>

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
    
    if([self.logInView.usernameField.text isEqualToString:@""] && [self.logInView.passwordField.text isEqualToString:@""])
    {
        self.logInView.logInButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] init];
    [self.navigationController pushViewController:userViewController animated:NO];
    [self.navigationController presentViewController:userViewController animated:NO completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    NSLog(@"failed");
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
