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
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSInteger currMinute;
@property (nonatomic) NSInteger currSeconds;
@property (nonatomic) NSInteger currHour;

@end

@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {

        NSLog(@"%@", gameObject);
        self.lastKill = gameObject[@"last_kill"];
        self.playerDict = gameObject[@"player_dict"];
        
        self.loggedInUser = [PFUser currentUser];
        NSLog(@"%@", self.loggedInUser.username);
        self.playerAttributes = [self.playerDict valueForKeyPath:self.loggedInUser.username];
        
        self.targetPlayer = self.playerAttributes[@"target"];
        NSLog(@"%@", self.targetPlayer);
        PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
        [userQuery whereKey:@"username" equalTo:self.targetPlayer];
        PFObject *targetUser = [userQuery getFirstObject];
        PFQuery *playerQuery = [PFQuery queryWithClassName:@"Player"];
        [playerQuery whereKey:@"userId" equalTo:targetUser.objectId];
        PFObject *player = [playerQuery getFirstObject];
        
        self.targetLabel.hidden = false;
        self.targetLabel.text = player[@"fullName"];
        
        self.timeRemaining = self.playerAttributes[@"last_date_to_kill"];
        NSLog(@"%@ Time remaining: %@", self.targetPlayer, self.timeRemaining);
        


        self.lastKillLabel.hidden = false;
        self.lastKillLabel.text = self.lastKill;
        
        PFFile *profilePicture = player[@"profilePicture"];
        self.targetImage.image = [UIImage imageWithData:[profilePicture getData]];
        self.targetImage.layer.cornerRadius = self.targetImage.layer.borderWidth/2;
        self.targetImage.layer.masksToBounds = YES;
        
        self.timerCountdownLabel.textColor=[UIColor redColor];
        [self.timerCountdownLabel setText:@"Time remaining:"];
        self.timerCountdownLabel.backgroundColor=[UIColor clearColor];
        
        [self start];
        
        NSDate* start = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *end = [formatter dateFromString:self.timeRemaining];
        NSTimeInterval duration = [end timeIntervalSinceDate:start];

        NSInteger hours = floor(duration/(60*60));
        NSInteger minutes = floor((duration/60) - hours * 60);
        NSInteger seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));

        
        NSLog(@"Duration: %f", duration);
        NSLog(@"%zd", hours);
        NSLog(@"%zd", minutes);
        NSLog(@"%zd", seconds);
        
        self.currHour = (int) hours;
        self.currMinute = (int) minutes;
        self.currSeconds = (int)seconds;
        
        if ([gameObject[@"player_dict"][[PFUser currentUser].username][@"status"]  isEqual: @NO]) {
            self.timerCountdownLabel.hidden = true;
            self.killConfirmButton.hidden = true;
        }
    }];
    NSLog(@"%@", self.playerDict);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(NSString *)updateTime
{
    NSDate *currentDate = [NSDate date];
    
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:3];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    return [formatter stringFromDate:newDate];
}

#pragma last seen
- (IBAction)openLastSeen:(id)sender
{
    
}

#pragma kills/suicide

- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFObject *gameObject = [query getObjectWithId:self.gameId];
    NSString *assassin = self.loggedInUser.username;
    NSString *target = gameObject[@"player_dict"][assassin][@"target"];
    NSString *newTarget = gameObject[@"player_dict"][target][@"target"];
    NSString *killMessage = [NSString stringWithFormat:@"%@ killed %@", assassin, target];
        
    //updating target's stats
    gameObject[@"player_dict"][target][@"status"] = @NO;
    gameObject[@"player_dict"][target][@"last_date_to_kill"] = @"0";
    gameObject[@"player_dict"][target][@"target"] = @"";
        
    //updating assasin's stats
    gameObject[@"player_dict"][assassin][@"target"] = newTarget;
    gameObject[@"player_dict"][assassin][@"last_date_to_kill"] = [self updateTime];
        
    //updating game message
    gameObject[@"last_kill"] = killMessage;
        
    [gameObject saveInBackground];
}

-(void)suicide
{
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFObject *gameObject = [query getObjectWithId:self.gameId];
    NSString *currentUser = self.loggedInUser.username;
    NSString *target = gameObject[@"player_dict"][currentUser][@"target"];
    
    //find your assassin
    NSString *yourAssassin;
    for (NSString *key in gameObject[@"player_dict"])
    {
        NSLog(@"%@", gameObject[@"player_dict"][key][@"target"]);
        if ([gameObject[@"player_dict"][key][@"target"] isEqualToString: currentUser])
        {
            yourAssassin = key;
        }
    }
    
    //updating suicider's stats
    gameObject[@"player_dict"][currentUser][@"status"] = @NO;
    gameObject[@"player_dict"][currentUser][@"last_date_to_kill"] = @"0";
    gameObject[@"player_dict"][currentUser][@"target"] = @"";
    
    //updating assasin's stats
    gameObject[@"player_dict"][yourAssassin][@"target"] = target;
    gameObject[@"player_dict"][yourAssassin][@"last_date_to_kill"] = [self updateTime];
    
    //updating game message
    NSString *killMessage = [NSString stringWithFormat:@"%@ committed suicide", currentUser];
    gameObject[@"last_kill"] = killMessage;
    
    [gameObject saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)start
{
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired
{
    if((self.currMinute>0 || self.currSeconds>=0) && self.currMinute>=0)
    {
        if(self.currSeconds==0)
        {
            self.currMinute-=1;
            self.currSeconds=59;
        }
        else if(self.currSeconds>0)
        {
            self.currSeconds-=1;
        }
        if(self.currMinute == 0)
        {
            self.currHour -= 1;
            self.currMinute=59;
        }
        if(self.currHour>-1)
            [self.timerCountdownLabel setText:[NSString stringWithFormat:@"%@%ld%@%02ld%@%02ld",@"Time remaining: ",(long)self.currHour,@":",(long)self.currMinute, @":", (long)self.currSeconds]];
    }
    else
    {
        [self.timer invalidate];
    }
}

@end
