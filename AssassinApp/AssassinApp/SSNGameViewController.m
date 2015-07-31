//
//  SSNGameViewController.m
//  AssassinApp
//
//  Created by Manav Mandhani on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNGameViewController.h"
#import "SSNLastSeenViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "SSNCreateGameViewController.h"
#import "MBProgressHUD.h"


@interface SSNGameViewController ()

@property (nonatomic, strong) NSDictionary *playerDict;
@property (nonatomic, strong) NSDictionary *playerAttributes;
@property (nonatomic, strong) NSString *timeRemaining;
@property (nonatomic, strong) NSString *targetPlayer;
@property (nonatomic, strong) NSString *lastKill;
@property (nonatomic, strong) PFUser *loggedInUser;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) PFObject *userPlayerObject;
@property (nonatomic, strong) PFObject *targetPlayerObject;
@property (nonatomic) NSInteger currMinute;
@property (nonatomic) NSInteger currSeconds;
@property (nonatomic) NSInteger currHour;
@property (nonatomic) MBProgressHUD *hud;


@end

@implementation SSNGameViewController

- (void)viewDidLoad {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Loading Game";
    
    [super viewDidLoad];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for(UIViewController *tempVC in viewControllers)
    {
        if([tempVC isKindOfClass:[SSNCreateGameViewController class]])
        {
            [tempVC removeFromParentViewController];
        }
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {

        NSLog(@"%@", gameObject);
        self.lastKill = gameObject[@"last_kill"];
        self.playerDict = gameObject[@"player_dict"];
        
        self.loggedInUser = [PFUser currentUser];
        NSLog(@"%@", self.loggedInUser.username);
        self.playerAttributes = [self.playerDict valueForKeyPath:self.loggedInUser.username];
        
        PFQuery *userPlayerQuery = [PFQuery queryWithClassName:@"Player"];
        [query whereKey:@"userId" equalTo:self.loggedInUser.objectId];
        self.userPlayerObject = [userPlayerQuery getFirstObject];
        
        self.targetPlayer = self.playerAttributes[@"target"];
        NSLog(@"%@", self.targetPlayer);
        PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
        [userQuery whereKey:@"username" equalTo:self.targetPlayer];
        PFObject *targetUser = [userQuery getFirstObject];
        
        if (targetUser != nil){
            PFQuery *targetPlayerQuery = [PFQuery queryWithClassName:@"Player"];
            [targetPlayerQuery whereKey:@"userId" equalTo:targetUser.objectId];
            self.targetPlayerObject = [targetPlayerQuery getFirstObject];
        }
        
        self.targetLabel.hidden = false;
        self.targetLabel.text = self.targetPlayerObject[@"fullName"];
        
        self.timeRemaining = self.playerAttributes[@"last_date_to_kill"];
        NSLog(@"%@ Time remaining: %@", self.targetPlayer, self.timeRemaining);

        self.lastKillLabel.hidden = false;
        self.lastKillLabel.text = self.lastKill;
        
        PFFile *profilePicture = self.targetPlayerObject[@"profilePicture"];
        self.targetImage.image = [UIImage imageWithData:[profilePicture getData]];
        self.targetImage.layer.cornerRadius = self.targetImage.frame.size.width/2;
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
        
        if ([gameObject[@"player_dict"][self.loggedInUser.username][@"status"]  isEqual: @NO]) {
            self.timerCountdownLabel.hidden = true;
            self.killConfirmButton.hidden = true;
            self.targetHeadingLabel.text = @"You have been assassinated";
            self.lastLocationLabel.hidden = true;
            self.targetImage.image = [UIImage imageNamed:@"dead_assassin.png"];
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
    SSNLastSeenViewController *lastSeenController = [[SSNLastSeenViewController alloc] init];
    lastSeenController.targetPoint = self.targetPlayerObject[@"lastSeen"];
    [self.navigationController pushViewController:lastSeenController animated:YES];
}

#pragma kills/suicide

- (IBAction)confirmKill:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                   initWithTitle:@"Confirm Kill"
                   message:@"Are you sure you want to confirm kill?"
                   delegate:self
                   cancelButtonTitle:@"Cancel"
                   otherButtonTitles:@"Confirm", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        PFQuery *query = [PFQuery queryWithClassName:@"Games"];
        PFObject *gameObject = [query getObjectWithId:self.gameId];
        NSString *assassin = self.userPlayerObject[@"fullName"];
        NSString *target = self.targetPlayerObject[@"fullName"];
        NSString *newTarget = gameObject[@"player_dict"][target][@"target"];
        NSString *killMessage = [NSString stringWithFormat:@"%@ killed %@", assassin, target];
        
        //updating target's stats
        gameObject[@"player_dict"][target][@"status"] = @NO;
        gameObject[@"player_dict"][target][@"last_date_to_kill"] = @"0";
        gameObject[@"player_dict"][target][@"target"] = @"";
        
        //updating assassin's stats
        if (![newTarget isEqualToString: assassin])
        {
            //game is not over
            gameObject[@"player_dict"][assassin][@"target"] = newTarget;
            gameObject[@"player_dict"][assassin][@"last_date_to_kill"] = [self updateTime];
        }
        else
        {
            //game is over
            gameObject[@"player_dict"][target][@"status"] = @YES;
            gameObject[@"player_dict"][target][@"last_date_to_kill"] = @"0";
            gameObject[@"player_dict"][target][@"target"] = @"";
            self.timerCountdownLabel.hidden = true;
            self.killConfirmButton.hidden = true;
            self.targetLabel.text = @"Congratulations, you are the master assassin!";
            self.targetImage.image = [UIImage imageNamed:@"assassinlogo.png"];
            gameObject[@"active"] = @NO;
        }
                
        //updating game message
        gameObject[@"last_kill"] = killMessage;
        [gameObject saveInBackground];
            
        if ([gameObject[@"active"]  isEqual: @YES])
        {
        [self viewDidLoad];
        }
    }
    else {
        NSLog(@"Somehow another button got pressed. Jesus take the wheel!");
    }
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
            break;
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
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
