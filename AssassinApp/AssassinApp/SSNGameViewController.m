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
@property (nonatomic, strong) PFUser *loggedInUser;

@end


@implementation SSNGameViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {
        
        NSLog(@"%@", gameObject);
        _lastKill = gameObject[@"last_kill"];
        _playerDict = gameObject[@"player_dict"];
        
        _loggedInUser = [PFUser currentUser];
        NSLog(@"%@", _loggedInUser.username);
        _playerAttributes =[_playerDict valueForKeyPath:_loggedInUser.username]; // Hard code to my username
        
//        NSLog(@"%@", _playerDict);
        _targetPlayer = _playerAttributes[@"target"];
        _timeRemaining = _playerAttributes[@"time_remaining"];
        BOOL status = _playerAttributes[@"status"];
        
//        NSLog(@"%@ %@ %d", _targetPlayer, _timeRemaining, status);
        
        
        _targetLabel.hidden = false;
        _targetLabel.text = _targetPlayer;
        
        _lastKillLabel.hidden = false;
        _lastKillLabel.text = _lastKill;
        
        NSString *timeRemainingMessage = [NSString stringWithFormat:@"Time remaining to kill target: %@", _timeRemaining];
        _timeRemainingLabel.hidden = false;
        _timeRemainingLabel.text = timeRemainingMessage;
        
        
        NSURL *url = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
        _targetImage.image = [UIImage imageWithData:mydata];
    }];
    NSLog(@"%@", _playerDict);
    
//    PFObject *game = [PFObject objectWithClassName:@"Games"];
//    game[@"active"] = @YES;
//    game[@"last_kill"] = @"Manav kills Jason with MSMutableDictionaries";
//    game[@"game_title"] = @"Game 1";
//    
//    NSMutableDictionary *player_attr_dict = [NSMutableDictionary dictionaryWithDictionary:@{@"target": @"Jasoniful", @"status": @YES, @"time_remaining": @"259500"}];
//    NSMutableDictionary *player2_attr_dict = [NSMutableDictionary dictionaryWithDictionary: @{@"target": @"quinn", @"status": @YES, @"time_remaining": @"259500"}];
//    NSMutableDictionary *player_dict = [NSMutableDictionary dictionaryWithDictionary: @{@"ssnuser": player_attr_dict, @"Jasoniful": player2_attr_dict}];
//    
//    game[@"player_dict"] = player_dict;
//    
//    [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Yay it worked");
//        } else {
//            NSLog(error.description);
//        }
//    }];
}

- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {
        NSLog(@"%@", gameObject[@"player_dict"]);
        NSString *target = gameObject[@"player_dict"][_loggedInUser.username][@"target"];
        NSString *newTarget = gameObject[@"player_dict"][target][@"target"];
        NSString *assassin = _loggedInUser.username;
        NSString *killMessage = [NSString stringWithFormat:@"%@ killed %@", assassin, target];
        
        //updating target's stats
        gameObject[@"player_dict"][target][@"status"] = @NO;
        gameObject[@"player_dict"][target][@"time_remaining"] = @"0";
        gameObject[@"player_dict"][target][@"target"] = @"";
        
        //updating assasin's stats
        gameObject[@"player_dict"][[PFUser currentUser].username][@"target"] = newTarget;
        NSDate* start = [NSDate date];
        NSTimeInterval secondsInSeventyTwoHours = 72 * 60 * 60;
        NSDate *end = [start dateByAddingTimeInterval:secondsInSeventyTwoHours];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSString *dateToKill = [formatter stringFromDate:end];
        gameObject[@"player_dict"][[PFUser currentUser].username][@"time_remaining"] = dateToKill;
        
        //updating game message
        gameObject[@"last_kill"] = killMessage;
        
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
