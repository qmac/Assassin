//
//  SSNSignUpViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNSignUpViewController.h"
#import "SSNUserViewController.h"

@interface SSNSignUpViewController () <PFSignUpViewControllerDelegate, UITextInputDelegate>

@end

@implementation SSNSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;

    self.signUpView.backgroundColor = [UIColor blackColor];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor redColor]];
    self.signUpView.additionalField.placeholder = @"Full Name";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move all fields down on smaller screen sizes
    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x,
                                                    fieldFrame.origin.y + yOffset,
                                                    fieldFrame.size.width,
                                                    fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x,
                                                         fieldFrame.origin.y + yOffset,
                                                         fieldFrame.size.width,
                                                         fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;

    [self.signUpView.signUpButton setFrame:CGRectMake(fieldFrame.origin.x,
                                                      fieldFrame.origin.y + yOffset,
                                                      fieldFrame.size.width,
                                                      fieldFrame.size.height)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] initWithNibName:@"SSNUserViewController" bundle:nil];
    [self presentViewController:userViewController animated:NO completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if((![self.signUpView.usernameField.text isEqualToString:@""] || ![self.signUpView.passwordField.text isEqualToString:@""] || ![self.signUpView.emailField.text isEqualToString:@""]) && [string isEqualToString:@""] && range.location == 0)
    {
        self.signUpView.signUpButton.enabled = NO;
    }
    else if((![self.signUpView.usernameField.text isEqualToString:@""] || ![self.signUpView.emailField.text isEqualToString:@""]) && ![string isEqualToString:@""] && [textField isEqual:self.signUpView.passwordField])
    {
        self.signUpView.signUpButton.enabled = YES;
    }
    else if((![self.signUpView.passwordField.text isEqualToString:@""] || ![self.signUpView.emailField.text isEqualToString:@""]) && ![string isEqualToString:@""] && [textField isEqual:self.signUpView.usernameField])
    {
        self.signUpView.signUpButton.enabled = YES;
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
