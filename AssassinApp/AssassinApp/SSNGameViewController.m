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
@property (nonatomic, strong) NSString *lastKill;

@end


@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"j5KvQKhcI3" block:^(PFObject *gameObject, NSError *error) {
        
        NSLog(@"%@", gameObject);
        _lastKill = gameObject[@"last_kill"];
        _playerDict = gameObject[@"player_dict"];
        _playerAttributes =[_playerDict valueForKeyPath:@"manavm"]; // Hard code to my username
        
        NSLog(@"%@", _playerDict);
        _targetPlayer = _playerAttributes[@"target"];
        _timeRemaining = _playerAttributes[@"time_remaining"];
        BOOL status = _playerAttributes[@"status"];
        
        NSLog(@"%@ %@ %d", _targetPlayer, _timeRemaining, status);
        
        
        _targetLabel.hidden = false;
        _targetLabel.text = _targetPlayer;
        
        NSURL *url = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
        _targetImage.image = [UIImage imageWithData:mydata];
        
        NSURL *url2 = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata2 = [[NSData alloc] initWithContentsOfURL:url2];
        _targetImage.image = [UIImage imageWithData:mydata2];
        
        _lastKillLabel.hidden = false;
        _lastKillLabel.text = _lastKill;
    }];
    
    NSLog(@"%@", _playerDict);
}


- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"j5KvQKhcI3" block:^(PFObject *gameObject, NSError *error) {
        NSLog(@"%@", gameObject);
        [[gameObject[@"player_dict"] valueForKey:@"manavm"] setObject:(@"quinn") forKey:(@"target")];
        NSLog(@"%@", [gameObject[@"player_dict"] valueForKey:@"manavm"]);
        [gameObject saveInBackground];
    }];
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
