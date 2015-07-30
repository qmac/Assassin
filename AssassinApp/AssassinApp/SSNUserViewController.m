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

@interface SSNUserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableArray *gameIds;
@property (nonatomic, strong) NSArray *gamesData;
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
    
    PFUser *user = [PFUser currentUser];
    self.gameIds = user[@"games"];
    NSLog(@"%@", user[@"games"]);
    [self fetchGamesData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    NSLog(@"FetchingGames");
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"objectId" containedIn:self.gameIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            //self.games = [objects mutableCopy];
            self.gamesData = objects;
            NSLog(@"%@", self.gamesData);
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
//    PFObject *gameObject = [PFObject objectWithClassName:@"Games"];
//    gameObject[@"active"] = @YES;
//    gameObject[@"last_kill"] = @"Yash kills Jason";
//    
//    NSDictionary *playerAttributes = @{@"target": @"Austin Tsao", @"status": @YES, @"time_remaining": @"654500"};
//    NSDictionary *playerDictionary = @{@"quinnmac": playerAttributes};
//    
//    gameObject[@"player_dict"] = playerDictionary;
//    
//    [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded)
//        {
//            NSLog(@"created new game");
//        }
//        else
//        {
//            NSLog(@"%@", [error description]);
//        }
//    }];
//    [self.games addObject:gameObject];
}

#pragma mark - UITableView Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gamesData count];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] init];
    [self.navigationController presentViewController:gameViewController animated:NO completion:nil];
}


@end
