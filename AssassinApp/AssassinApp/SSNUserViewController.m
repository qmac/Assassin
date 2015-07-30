//
//  SSNUserViewController.m
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "Parse/Parse.h"

#import "SSNUserViewController.h"
#import "SSNGameViewController.h"
#import "SSNCreateGameViewController.h"

@interface SSNUserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableArray *activeGamesData;
@property (nonatomic, strong) NSMutableArray *inactiveGamesData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString *const CellIdentifier = @"gameCell";

@implementation SSNUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *createGameButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchCreateGame:)];
    self.navigationItem.rightBarButtonItem = createGameButton;
    
    [self fetchGamesData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse Methods
- (void) fetchGamesData
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Player"];
    [query whereKey:@"userId" equalTo:user.objectId];
    NSLog(@"%@", user.objectId);
    NSMutableArray *gameIds = (NSMutableArray *)[query getFirstObject][@"games"];
    
    NSLog(@"FetchingGames");
    PFQuery *activeQuery = [PFQuery queryWithClassName:@"Games"];
    [activeQuery whereKey:@"objectId" containedIn:gameIds];
    [activeQuery whereKey:@"active" equalTo:@YES];
    [activeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.activeGamesData = [objects mutableCopy];
            NSLog(@"%@", self.activeGamesData);
            [self.tableView reloadData];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    PFQuery *inactiveQuery = [PFQuery queryWithClassName:@"Games"];
    [inactiveQuery whereKey:@"objectId" containedIn:gameIds];
    [inactiveQuery whereKey:@"active" equalTo:@NO];
    [inactiveQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.inactiveGamesData = [objects mutableCopy];
            NSLog(@"%@", self.inactiveGamesData);
            [self.tableView reloadData];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Nav Bar Handlers
- (void) launchCreateGame:(id)sender
{
    SSNCreateGameViewController *createGameViewController = [[SSNCreateGameViewController alloc] initWithNibName:@"SSNCreateGameViewController" bundle:nil];
    [self.navigationController pushViewController:createGameViewController animated:YES];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(indexPath.section == 0)
    {
        cell.textLabel.text = [self.activeGamesData objectAtIndex:indexPath.row][@"game_title"];
    }
    else
    {
        cell.textLabel.text = [self.inactiveGamesData objectAtIndex:indexPath.row][@"game_title"];
    }
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor =[UIColor whiteColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [self.activeGamesData count];
    return [self.inactiveGamesData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    if (section == 0) return @"Active Games";
    return @"Inactive Games";
}


#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1){
        return;
    }
    
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] initWithNibName:@"SSNGameViewController" bundle:nil];
    [gameViewController setGameId:[[self.activeGamesData objectAtIndex:indexPath.row] objectId]];
    [self presentViewController:gameViewController animated:YES completion:nil];
}


@end
