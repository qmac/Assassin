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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNSignUpViewController () <PFSignUpViewControllerDelegate, UITextInputDelegate>

@end

@implementation SSNSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;

    self.signUpView.backgroundColor = [UIColor blackColor];
    self.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assassinlogo.png"]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundColor:UIColorFromRGB(0xC0392B)];

    self.signUpView.additionalField.placeholder = @"Full Name";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move all fields down on smaller screen sizes
    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    
    [self.signUpView.logo setFrame:CGRectMake((self.signUpView.frame.size.width / 2) - (190/2), 50.0f, 190.0f, 190.0f)];
    
    yOffset += self.signUpView.logo.frame.size.height - 60.0f;
    
    CGRect fieldFrame = self.signUpView.additionalField.frame;
    
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x,
                                                         fieldFrame.origin.y + yOffset,
                                                         fieldFrame.size.width,
                                                         fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
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

    [self.signUpView.signUpButton setFrame:CGRectMake(fieldFrame.origin.x,
                                                      fieldFrame.origin.y + yOffset,
                                                      fieldFrame.size.width,
                                                      fieldFrame.size.height)];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    SSNUser *customUser = (SSNUser *)user;
    [customUser setFullName:self.signUpView.additionalField.text];
    [customUser setGames:[[NSMutableArray alloc] init]];
    NSString *pic = @"hellonsdata";
    NSData *data = [pic dataUsingEncoding:NSUTF8StringEncoding];
    [customUser setProfilePicture:[PFFile fileWithData:data]];
    [customUser setLastSeen:[PFGeoPoint geoPoint]];
    
    [customUser saveInBackground];
    
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] initWithNibName:@"SSNUserViewController" bundle:nil];
    [self presentViewController:userViewController animated:NO completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController * __nonnull)signUpController shouldBeginSignUp:(NSDictionary * __nonnull)info
{
    if([self.signUpView.additionalField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please enter your full name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if([self.signUpView.usernameField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please enter a username" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        return NO;

    }
    else if([self.signUpView.passwordField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please enter a password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if([self.signUpView.emailField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please enter your email" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
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
