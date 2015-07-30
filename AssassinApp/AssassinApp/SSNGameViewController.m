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
@property (nonatomic, strong) NSDictionary *playerAttributes;
@property (nonatomic, strong) NSString *timeRemaining;
@property (nonatomic, strong) NSString *targetPlayer;

@end


@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"j5KvQKhcI3" block:^(PFObject *gameObject, NSError *error) {
        
//        NSLog(@"%@", gameObject);
        _playerDict = gameObject[@"player_dict"];
        _playerAttributes =[_playerDict valueForKeyPath:@"manavm"]; // Hard code to my username
        
//        NSLog(@"%@", _playerDict);
        _targetPlayer = _playerAttributes[@"target"];
        _timeRemaining = _playerAttributes[@"time_remaining"];
        BOOL status = _playerAttributes[@"status"];
        
        NSLog(@"%@ %@ %d", _targetPlayer, _timeRemaining, status);
        
        
        _targetLabel.hidden = false;
        _targetLabel.text = _targetPlayer;
    }];
    
    NSLog(@"%@", _playerDict);
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
