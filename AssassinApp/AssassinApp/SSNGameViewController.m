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
{
    NSDictionary *playerDict;
    NSDictionary *playerAttributes;
    NSString *timeRemaining;
    NSString *targetPlayer;
    NSString *lastKill;
    PFUser *loggedInUser;

    NSTimer *timer;
    int currMinute;
    int currSeconds;
    int currHour;
}
@end

@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {

        NSLog(@"%@", gameObject);
        lastKill = gameObject[@"last_kill"];
        playerDict = gameObject[@"player_dict"];
        
        loggedInUser = [PFUser currentUser];
        NSLog(@"%@", loggedInUser.username);
        playerAttributes =[playerDict valueForKeyPath:loggedInUser.username]; // Hard code to my username
        
//        NSLog(@"%@", _playerDict);
        targetPlayer = playerAttributes[@"target"];
        timeRemaining = playerAttributes[@"last_date_to_kill"];
//        BOOL status = _playerAttributes[@"status"];
        
        NSLog(@"%@ Time remaining: %@", targetPlayer, timeRemaining);
        
        
        _targetLabel.hidden = false;
        _targetLabel.text = targetPlayer;
        
        _lastKillLabel.hidden = false;
        _lastKillLabel.text = lastKill;
        
        NSString *timeRemainingMessage = [NSString stringWithFormat:@"Time remaining to kill target: %@", timeRemaining];
        _timeRemainingLabel.hidden = false;
        _timeRemainingLabel.text = timeRemainingMessage;
        
        
        NSURL *url = [NSURL URLWithString:@"http://img4.wikia.nocookie.net/__cb20120524204707/gameofthrones/images/4/4d/Joffrey_in_armor2x09.jpg"];
        NSData *mydata = [[NSData alloc] initWithContentsOfURL:url];

        self.targetImage.image = [UIImage imageWithData:mydata];
        
        
        _timerCountdownLabel.textColor=[UIColor redColor];
        [_timerCountdownLabel setText:@"Time remaining to assassinate target:"];
        _timerCountdownLabel.backgroundColor=[UIColor clearColor];
//        [self.view addSubview:_timerCountdownLabel];
        
        [self start];
        
        
        NSDate* start = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *end = [formatter dateFromString:timeRemaining];
        NSTimeInterval duration = [end timeIntervalSinceDate:start];

        NSInteger hours = floor(duration/(60*60));
        NSInteger minutes = floor((duration/60) - hours * 60);
        NSInteger seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));

        
        NSLog(@"Duration: %f", duration);
        NSLog(@"%zd", hours);
        NSLog(@"%zd", minutes);
        NSLog(@"%zd", seconds);
        
        currHour = (int) hours;
        currMinute = (int) minutes;
        currSeconds = (int)seconds;
    }];
    NSLog(@"%@", playerDict);
}

- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {
        NSLog(@"%@", gameObject[@"player_dict"]);
        NSString *target = gameObject[@"player_dict"][loggedInUser.username][@"target"];
        NSString *newTarget = gameObject[@"player_dict"][target][@"target"];
        NSString *assassin = loggedInUser.username;
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

-(void)start
{
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    
}
-(void)timerFired
{
    if((currMinute>0 || currSeconds>=0) && currMinute>=0)
    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        }
        else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        if(currMinute == 0)
        {
            currHour -= 1;
            currMinute=59;
        }
        if(currHour>-1)
            [_timerCountdownLabel setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time remaining to assassinate target: ",currHour,@":",currMinute, @":", currSeconds]];
    }
    else
    {
        [timer invalidate];
    }
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
