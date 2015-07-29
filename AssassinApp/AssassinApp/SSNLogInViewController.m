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
#import "MBProgressHUD.h"

@interface SSNLogInViewController () <PFLogInViewControllerDelegate, UITextFieldDelegate>

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)logInViewController:(PFLogInViewController * __nonnull)logInController shouldBeginLogInWithUsername:(NSString * __nonnull)username password:(NSString * __nonnull)password
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    return YES;//[super logInViewController:logInController shouldBeginLogInWithUsername:username password:password];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // To launch User View
//    SSNUserViewController *userViewController = [[SSNUserViewController alloc] init];
//    [self.navigationController presentViewController:userViewController animated:NO completion:nil];
    
    // To launch game view
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] init];
    [self presentViewController:gameViewController animated:NO completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Login Failed";
    [hud hide:YES afterDelay:1.5];
    self.logInView.passwordField.text = @"";
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
