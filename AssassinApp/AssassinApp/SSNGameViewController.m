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
        self.lastKill = gameObject[@"last_kill"];
        self.playerDict = gameObject[@"player_dict"];
        
        self.loggedInUser = [PFUser currentUser];
        self.playerAttributes =[_playerDict valueForKeyPath:_loggedInUser.username]; // Hard code to my username
        
        self.targetPlayer = _playerAttributes[@"target"];
        self.timeRemaining = _playerAttributes[@"time_remaining"];
        BOOL status = _playerAttributes[@"status"];

        self.targetLabel.hidden = false;
        self.targetLabel.text = _targetPlayer;
        
        self.lastKillLabel.hidden = false;
        self.lastKillLabel.text = _lastKill;
        
        NSString *timeRemainingMessage = [NSString stringWithFormat:@"Time remaining to kill target: %@", _timeRemaining];
        self.timeRemainingLabel.hidden = false;
        self.timeRemainingLabel.text = timeRemainingMessage;
        
        
        NSURL *url = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];
        self.targetImage.image = [UIImage imageWithData:mydata];
    }];
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
        NSDate *currentDate = [NSDate date];
        
        // Create and initialize date component instance
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:3];
        
        // Retrieve date with increased days count
        NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSString *dateToKill = [formatter stringFromDate:newDate];
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
@end
