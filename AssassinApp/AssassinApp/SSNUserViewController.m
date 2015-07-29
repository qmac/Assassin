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

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSMutableArray *games;

@end

static NSString *const CellIdentifier = @"gameCell";

@implementation SSNUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *createGameButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchCreateGame:)];
    self.navigationItem.rightBarButtonItem = createGameButton;
    
    self.user = [PFUser currentUser];
    
    [self fetchGames];
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
- (void) fetchGames
{
    
//    
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"Players"];
//    [query whereKey:@"user" equalTo:currentUser];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error)
//        {
//            self.games = [objects mutableCopy];
//            [self.tableView reloadData];
//        }
//        else
//        {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}

#pragma mark - Nav Bar Handlers
- (void) launchCreateGame:(id)sender
{
    PFObject *gameObject = [PFObject objectWithClassName:@"Games"];
    gameObject[@"active"] = @YES;
    gameObject[@"last_kill"] = @"Yash kills Jason";
    
    NSDictionary *playerAttributes = @{@"target": @"Austin Tsao", @"status": @YES, @"time_remaining": @"654500"};
    NSDictionary *playerDictionary = @{@"quinnmac": playerAttributes};
    
    gameObject[@"player_dict"] = playerDictionary;
    
    [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"created new game");
        }
        else
        {
            NSLog(@"%@", [error description]);
        }
    }];
    [self.games addObject:gameObject];
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
    return [self.games count];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] init];
    [self.navigationController presentViewController:gameViewController animated:NO completion:nil];
}


@end
