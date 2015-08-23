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
#import "SSNLogInViewController.h"
#import "SSNCreateGameViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNUserViewController () <UITableViewDataSource, UITableViewDelegate, SSNCreateGameViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *activeGamesData;
@property (nonatomic, strong) NSMutableArray *inactiveGamesData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

static NSString *const CellIdentifier = @"gameCell";

@implementation SSNUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem *createGameButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchCreateGame:)];
    self.navigationItem.rightBarButtonItem = createGameButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(fetchGamesData)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xC0392B);
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x0A0A0A);
    self.navigationItem.title = @"My Games";
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: UIColorFromRGB(0xC0392B)}];

    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setFrame:CGRectMake(0, 0, 70, 50)];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    logoutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [logoutButton setTitleColor:UIColorFromRGB(0xC0392B) forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutUser) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
    self.navigationItem.leftBarButtonItem = logoutItem;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self fetchGamesData];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        if(error)
        {
            NSLog(@"Failed to update lastSeen");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error retrieving location"
                                  message:@""
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            PFUser *user = [PFUser currentUser];
            PFQuery *playerQuery = [PFQuery queryWithClassName:@"Player"];
            [playerQuery whereKey:@"userId" equalTo:user.objectId];
            PFObject *player = [playerQuery getFirstObject];
            player[@"lastSeen"] = geoPoint;
            [player saveInBackground];
        }
    }];
}


- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
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
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
}

#pragma mark - Nav Bar Handlers
- (void) launchCreateGame:(id)sender
{
    SSNCreateGameViewController *createGameViewController = [[SSNCreateGameViewController alloc] initWithNibName:@"SSNCreateGameViewController" bundle:nil];
    createGameViewController.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createGameViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) logoutUser
{
    NSLog(@"loggedout");
    [PFUser logOut];
    SSNLogInViewController *logInViewController = [[SSNLogInViewController alloc] init];
    [self presentViewController:logInViewController animated:YES completion:nil];
}

#pragma mark - Create game delegate
- (void)createGameViewControllerDidCreateGameWithId:(NSString *)gameId
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self fetchGamesData];
    [self launchGameViewWithId:gameId];
}

- (void)createGameViewControllerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISegmentedControl
- (IBAction)selectedSegmentChanged:(id)sender
{
    [self.tableView reloadData];
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
        cell.textLabel.text = [self.activeGamesData objectAtIndex:indexPath.row][@"game_title"];
    }
    else
    {
        cell.textLabel.text = [self.inactiveGamesData objectAtIndex:indexPath.row][@"game_title"];
    }
    cell.textLabel.textColor =[UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) return [self.activeGamesData count];
    return [self.inactiveGamesData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
        [self launchGameViewWithId:[[self.activeGamesData objectAtIndex:indexPath.row] objectId]];
    }
    else
    {
        return;
    }
}

- (void)launchGameViewWithId:(NSString *)gameId
{
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] initWithNibName:@"SSNGameViewController" bundle:nil];
    gameViewController.gameId = gameId;
    [self.navigationController pushViewController:gameViewController animated:YES];
}


@end
