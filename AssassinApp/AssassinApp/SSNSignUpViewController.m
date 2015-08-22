//
//  SSNSignUpViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNSignUpViewController.h"
#import "SSNUserViewController.h"
#import <Parse/Parse.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNSignUpViewController () <PFSignUpViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSString *userId;

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
    [self.signUpView.additionalField setReturnKeyType:UIReturnKeyDefault];
    [self.signUpView.emailField setReturnKeyType:UIReturnKeyDone];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    PFObject *player = [PFObject objectWithClassName:@"Player"];
    self.userId = user.objectId;
    player[@"userId"] = user.objectId;
    player[@"fullName"] = self.signUpView.additionalField.text;
    player[@"games"] = [[NSMutableArray alloc] init];
    NSURL *defaultPicUrl = [NSURL URLWithString:@"http://www.boiseweekly.com/images/icons/user_generic.gif"];
    player[@"profilePicture"] = [PFFile fileWithName:@"Default Selfie" data:[NSData dataWithContentsOfURL:defaultPicUrl]];
    player[@"lastSeen"] = [PFGeoPoint geoPoint];

    [player saveInBackground];
    
    [self launchCameraControllerFromViewController:self usingDelegate:self];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Selfie Time!"] && buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentUserViewController];
        }];
    }
    else if(buttonIndex == 0)
    {
        [self presentUserViewController];
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:self.signUpView.emailField])
    {
        [textField resignFirstResponder];
        [self.signUpView.signUpButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if([textField isEqual:self.signUpView.additionalField])
    {
        [self.signUpView.usernameField becomeFirstResponder];
    }
    else if([textField isEqual:self.signUpView.usernameField])
    {
        [self.signUpView.passwordField becomeFirstResponder];
    }
    else if([textField isEqual:self.signUpView.passwordField])
    {
        [self.signUpView.emailField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - Camera

-(void) launchCameraControllerFromViewController: (UIViewController *)controller usingDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate{
    //Launches camera controller.
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera || (delegate == nil) || (controller == nil)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera Not Available"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [cameraController setCameraDevice:UIImagePickerControllerCameraDeviceFront];
    
    cameraController.allowsEditing = NO;
    cameraController.delegate = delegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selfie Time!" message:@"Please take a picture for your profile"
                                                   delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Okay", nil];
    [alert show];
    [controller presentViewController:cameraController animated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentUserViewController];
    }];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(120, 150);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData * imageData = UIImagePNGRepresentation(newImage);

    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"userId" equalTo:self.userId];
    PFObject *player = [query getFirstObject];
    player[@"profilePicture"] = [PFFile fileWithName:@"Selfie" data:imageData];
    [player saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentUserViewController];
    }];
    
}

- (void)presentUserViewController
{
    SSNUserViewController *userViewController = [[SSNUserViewController alloc] initWithNibName:@"SSNUserViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:userViewController];
    [self presentViewController:navController animated:YES completion:nil];
}
@end
