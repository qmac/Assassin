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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSNUserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableArray *activeGamesData;
@property (nonatomic, strong) NSMutableArray *inactiveGamesData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
    
    [self.view addSubview:self.tableView];
    
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

    [self fetchGamesData];
}


- (void)stopRefresh

{
    
    [self.refreshControl endRefreshing];
    
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
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
}

#pragma mark - Nav Bar Handlers
- (void) launchCreateGame:(id)sender
{
    SSNCreateGameViewController *createGameViewController = [[SSNCreateGameViewController alloc] initWithNibName:@"SSNCreateGameViewController" bundle:nil];
    [self.navigationController pushViewController:createGameViewController animated:YES];
}
-(void) logoutUser
{
    NSLog(@"loggedout");
    [PFUser logOut];
    SSNLogInViewController *logInViewController = [[SSNLogInViewController alloc] init];
    NSArray *viewStack = [self.navigationController viewControllers];
    if([viewStack containsObject:logInViewController])
    {
        [self.navigationController popToViewController:logInViewController animated:NO];
    }
    else
    {
        [self.navigationController pushViewController:logInViewController animated:NO];
    }
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
    cell.textLabel.textColor =[UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [self.activeGamesData count];
    return [self.inactiveGamesData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    if (section == 0) return @"ACTIVE GAMES";
    return @"INACTIVE GAMES";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:12];
    myLabel.textColor = UIColorFromRGB(0x818A8A);
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
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
    [self.navigationController pushViewController:gameViewController animated:YES];
}


@end
