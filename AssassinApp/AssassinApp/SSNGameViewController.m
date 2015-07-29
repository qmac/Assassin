//
//  SSNGameViewController.m
//  AssassinApp
//
//  Created by Manav Mandhani on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNGameViewController.h"
#import "Parse/Parse.h"

@interface SSNGameViewController ()

@property (nonatomic, strong) NSDictionary *playerDict;

@end


@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"VAOQ2LvVAQ" block:^(PFObject *gameObject, NSError *error) {
        NSLog(@"%@", gameObject);
        _playerDict = gameObject[@"player_dict"];
        NSDictionary *playerAttributes =[_playerDict valueForKeyPath:@"manavm"]; // Hard code to my username
        
        NSLog(@"%@", _playerDict);
        NSString *targetPlayer = playerAttributes[@"target"];
        NSString *timeRemaining = playerAttributes[@"time_remaining"];
        BOOL status = playerAttributes[@"status"];
        
        NSLog(@"%@ %@ %d", targetPlayer, timeRemaining, status);
    }];
    
}
- (IBAction)confirmKill:(id)sender {
    NSLog(@"%@", @"Die mothafucka");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)killConfirmButton:(id)sender {
}
@end
