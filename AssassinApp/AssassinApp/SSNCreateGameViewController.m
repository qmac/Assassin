//
//  SSNCreateGameViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNCreateGameViewController.h"
#import <Parse/Parse.h>
#import <Parse/PFObject.h>
#import "SSNGameViewController.h"
#import "SSNUserViewController.h"
#import <Parse/PFQuery.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNCreateGameViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *invitedPlayersTableView;
@property (nonatomic, strong) IBOutlet UITextField *gameTitleInput;
@property (nonatomic, strong) IBOutlet UITextField *addPlayerInput;
@property (nonatomic, strong) IBOutlet UIButton *addPlayerButton;
@property (nonatomic, strong) NSMutableArray *addedUsers;
@property (nonatomic, strong) PFObject *gameObject;
@property (strong, nonatomic) IBOutlet UIButton *startGameButton;
@property (nonatomic, strong) NSMutableDictionary *fullDictionary;
@property (nonatomic, strong) NSString *creatorUserName;

@end

@implementation SSNCreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.addedUsers = [[NSMutableArray alloc] init];
    self.gameObject = [PFObject objectWithClassName:@"Games"];
    self.fullDictionary = [[NSMutableDictionary alloc] init];
    self.creatorUserName = [PFUser currentUser].username;
    [self.addPlayerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addPlayerButton setBackgroundColor:UIColorFromRGB(0xC0392B)];
    [self.startGameButton setBackgroundColor:UIColorFromRGB(0xC0392B)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction)];
    UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(startGameAction:)];
    [cancelButton setTintColor:UIColorFromRGB(0xC0392B)];
    [startButton setTintColor:UIColorFromRGB(0xC0392B)];
    self.navigationItem.rightBarButtonItem = startButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPlayerAction:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.addPlayerInput.text];
    if([query countObjects] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:@"The entered username does not exist." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([self.addPlayerInput.text isEqualToString:[PFUser currentUser].username])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot add yourself to the game." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [self.addedUsers addObject:self.addPlayerInput.text];
        [self addUserToGame:self.addPlayerInput.text];
        [self arrayDidUpdate];
    }
    self.addPlayerInput.text = @"";
    [self.view endEditing:YES];
}

- (IBAction)startGameAction:(id)sender {
    if ([self.addedUsers count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Game" message:@"You must add people to the game." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSDate *currentDate = [NSDate date];
    
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:3];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateToKill = [formatter stringFromDate:newDate];
    
    NSMutableDictionary *playerAttributes = [NSMutableDictionary dictionaryWithDictionary:@{@"target": self.creatorUserName, @"status": @YES, @"last_date_to_kill": dateToKill}];
    [self.fullDictionary setObject:playerAttributes forKey:[self.addedUsers lastObject]];
    
    self.gameObject[@"active"] = @YES;
    self.gameObject[@"game_title"] = self.gameTitleInput.text;
    self.gameObject[@"player_dict"] = self.fullDictionary;
    self.gameObject[@"last_kill"] = @"No one has died yet :(";
    
    //create an array of targets
    NSMutableArray *targets = [[NSMutableArray alloc] init];
    for (NSString *key in self.gameObject[@"player_dict"])
    {
        [targets insertObject:key atIndex:0];
    }
    
    NSInteger count = [targets count];
    if (count > 2 )
    {
        //randomize targets
        NSString *currentPlayer = targets[0];
        NSString *previousAssassin = @"";
        NSString *randomTarget = @"";
        for (NSInteger k = 0; k < count; k++)
        {
            //get random target
            do
            {
                NSUInteger randomIndex = arc4random() % [targets count];
                randomTarget = targets[randomIndex];
            } while ([randomTarget isEqualToString:currentPlayer] || [randomTarget isEqualToString:previousAssassin]);
            
            //set target to random target
            self.gameObject[@"player_dict"][currentPlayer][@"target"] = randomTarget;
            previousAssassin = currentPlayer;
            currentPlayer = randomTarget;
            
            //remove randomTarget from target array
            NSInteger count2 = [targets count];
            for (NSInteger index = (count2 - 1); index >= 0; index--) {
                NSString *target = targets[index];
                if ([target isEqualToString:randomTarget]) {
                    [targets removeObjectAtIndex:index];
                    break;
                }
            }
        }
    }
    
    [self.gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"created new game");
            PFQuery *query = [PFQuery queryWithClassName:@"Player"];
            [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            PFObject *player = [query getFirstObject];
            NSMutableArray *gameIds = player[@"games"];
            [gameIds addObject:self.gameObject.objectId];
            [player setObject:gameIds forKey:@"games"];
            [player saveInBackground];
            for(int i = 0; i < self.addedUsers.count; i++)
            {
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"username" equalTo:self.addedUsers[i]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        NSString *objectId = [objects[0] objectId];
                        PFQuery *query = [PFQuery queryWithClassName:@"Player"];
                        [query whereKey:@"userId" equalTo:objectId];
                        PFObject *currPlayer = [query getFirstObject];
                        NSMutableArray *tempGames = currPlayer[@"games"];
                        [tempGames addObject:self.gameObject.objectId];
                        [currPlayer setObject:tempGames forKey:@"games"];
                        [currPlayer saveInBackground];
                    }
                }];
            }
            SSNUserViewController *userViewController = [[SSNUserViewController alloc] init];
            [self.navigationController pushViewController:userViewController animated:YES];
            SSNGameViewController *gameViewController = [[SSNGameViewController alloc] initWithNibName:@"SSNGameViewController" bundle:nil];
            [gameViewController setGameId:[self.gameObject objectId]];
            [userViewController.navigationController pushViewController:gameViewController animated:YES];
        }
        else
        {
            NSLog(@"%@", [error description]);
        }
    }];
}

#pragma mark - tableView

- (void)arrayDidUpdate
{
    [self.invitedPlayersTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.addedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.text = [self.addedUsers objectAtIndex:[indexPath row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)createHeaderWithTitle:(NSString *)title
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 45.0)];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (title)
    {
        UILabel *accountLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 18, 5,
                                                  self.view.frame.size.width - self.view.frame.size.width / 5,
                                                  35.0)];
        
        accountLabel.textAlignment = NSTextAlignmentLeft;
        accountLabel.text = title;
        accountLabel.textColor = [UIColor lightGrayColor];
        accountLabel.numberOfLines = 3;
        accountLabel.opaque = NO;
        accountLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:accountLabel];
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createHeaderWithTitle:[NSString stringWithFormat:@"Invited Players"]];
}

- (void)addUserToGame:(NSString *)userName
{
    NSDate *currentDate = [NSDate date];
    
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:3];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateToKill = [formatter stringFromDate:newDate];
    
    NSUInteger count = [self.addedUsers count];
    if(count == 1)
    {
        NSMutableDictionary *playerAttributes = [NSMutableDictionary dictionaryWithDictionary:@{@"target": userName, @"status": @YES, @"last_date_to_kill": dateToKill}];
        [self.fullDictionary setObject:playerAttributes forKey:self.creatorUserName];
    }
    else
    {
        NSMutableDictionary *playerAttributes = [NSMutableDictionary dictionaryWithDictionary:@{@"target": userName, @"status": @YES, @"last_date_to_kill": dateToKill}];
        [self.fullDictionary setObject:playerAttributes forKey:[self.addedUsers objectAtIndex:(count - 2)]];
    }
}
@end
