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
#import "SSNSignUpViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNLogInViewController () <PFLogInViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL internetActive;
@end

@implementation SSNLogInViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    SSNSignUpViewController *signUpController = [[SSNSignUpViewController alloc] initWithNibName:@"SSNSignUpViewController" bundle:nil];
    [signUpController setFields:(PFSignUpFieldsDefault | PFSignUpFieldsAdditional)];
    [self setSignUpController:signUpController];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.logInView.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assassinlogo.png"]];
    [self.logInView.passwordForgottenButton setTitleColor:UIColorFromRGB(0xC0392B) forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundColor:UIColorFromRGB(0xC0392B)];
    self.logInView.logInButton.enabled = NO;
    self.logInView.dismissButton.hidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move all fields down on smaller screen sizes
    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;

    CGRect fieldFrame = self.logInView.usernameField.frame;
    
    [self.logInView.logo setFrame:CGRectMake(66.5f, 50.0f, 190.0f, 190.0f)];

    yOffset += self.logInView.logo.frame.size.height + 45.0f;

    [self.logInView.usernameField setFrame:CGRectMake(fieldFrame.origin.x,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.logInView.passwordField setFrame:CGRectMake(fieldFrame.origin.x,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.logInView.logInButton setFrame:CGRectMake(fieldFrame.origin.x,
                                                    fieldFrame.origin.y + yOffset,
                                                    fieldFrame.size.width,
                                                    fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(fieldFrame.origin.x,
                                                     fieldFrame.origin.y + yOffset,
                                                     fieldFrame.size.width,
                                                     fieldFrame.size.height)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] init];
    [self.navigationController presentViewController:userViewController animated:NO completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Username and password was not found." delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
    [alert show];
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

@end
