//
//  SSNCreateGameViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNCreateGameViewController.h"
#import <Parse/PFObject.h>
#import "SSNUser.h"
#import "SSNGameViewController.h"
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
    self.creatorUserName = [SSNUser currentUser].username;
    [self.addPlayerButton setTitleColor:UIColorFromRGB(0xC0392B) forState:UIControlStateNormal];
    [self.startGameButton setTitleColor:UIColorFromRGB(0xC0392B) forState:UIControlStateNormal];
    UIBarButtonItem *createGameButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:nil];
    self.navigationItem.leftBarButtonItem = createGameButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPlayerAction:(id)sender
{
    [self.addedUsers addObject:self.addPlayerInput.text];
    [self addUserToGame:self.addPlayerInput.text];
    self.addPlayerInput.text = @"";
    [self.view endEditing:YES];
    [self arrayDidUpdate];
}

- (IBAction)startGameAction:(id)sender {
    NSDate *currentDate = [NSDate date];
    
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:3];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDictionary *playerAttributes = @{@"target": self.creatorUserName, @"status": @YES, @"time_remaining": @"654500", @"last_date": newDate};
    [self.fullDictionary setObject:playerAttributes forKey:[self.addedUsers lastObject]];
    
    self.gameObject[@"active"] = @YES;
    self.gameObject[@"game_title"] = self.gameTitleInput.text;
    self.gameObject[@"player_dict"] = self.fullDictionary;
    [self.gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"created new game");
            NSMutableArray *games = [[PFUser currentUser] objectForKey:@"games"];
            [games addObject:[self.gameObject objectId]];
            [[PFUser currentUser] setObject:games forKey:@"games"];
            [[PFUser currentUser] saveInBackground];
            for(int i = 0; i < self.addedUsers.count; i++)
            {
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"username" equalTo:self.addedUsers[i]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        PFUser *user = (PFUser *)[objects firstObject];
                        NSMutableArray *games = [user objectForKey:@"games"];
                        [games addObject:[self.gameObject objectId]];
                        [user setObject:games forKey:@"games"];
                        [user saveInBackground];
                    }
                }];
            }
            SSNGameViewController *gameViewController = [[SSNGameViewController alloc] initWithNibName:@"SSNGameViewController" bundle:nil];
            [gameViewController setGameId:[self.gameObject objectId]];
            [self presentViewController:gameViewController animated:YES completion:nil];
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
    NSDictionary *playerAttributes = [[NSDictionary alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:3];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSUInteger count = [self.addedUsers count];
    if(count == 1)
    {
        playerAttributes = @{@"target": userName, @"status": @YES, @"time_remaining": @"654500", @"last_date": newDate};
        [self.fullDictionary setObject:playerAttributes forKey:self.creatorUserName];
    }
    else
    {
        playerAttributes = @{@"target": userName, @"status": @YES, @"time_remaining": @"654500", @"last_date": newDate};
        [self.fullDictionary setObject:playerAttributes forKey:[self.addedUsers objectAtIndex:(count - 2)]];
    }
}
@end
