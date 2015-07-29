//
//  SSNSignUpViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNSignUpViewController.h"
#import "SSNUserViewController.h"

@interface SSNSignUpViewController () <PFSignUpViewControllerDelegate>

@end

@implementation SSNSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
