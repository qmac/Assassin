//
//  SSNSignUpViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNSignUpViewController.h"
#import "SSNUserViewController.h"
#import "SSNUser.h"

@interface SSNSignUpViewController () <PFSignUpViewControllerDelegate>

@end

@implementation SSNSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    [self.signUpView.signUpButton addTarget:self action:@selector(signUpCustomUser) forControlEvents:UIControlEventAllTouchEvents];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signUpCustomUser
{
    SSNUser *newUser = (SSNUser*)[SSNUser object];
    
    [newUser setUsername:self.signUpView.usernameField.text];
    [newUser setPassword:self.signUpView.passwordField.text];
    [newUser setFullName:self.signUpView.additionalField.text];
    [newUser signUp];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] initWithNibName:@"SSNUserViewController" bundle:nil];
    [self presentViewController:userViewController animated:NO completion:nil];
}

@end
