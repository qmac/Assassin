//
//  SSNGameLeaderboardViewController.m
//  AssassinApp
//
//  Created by Quinn McNamara on 8/25/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <Parse/Parse.h>
#import "SSNGameLeaderboardViewController.h"

@interface SSNGameLeaderboardViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *gamePlayers;

@end

static NSString *const CellIdentifier = @"playerCell";

@implementation SSNGameLeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:self.gameId block:^(PFObject *gameObject, NSError *error) {
        self.gamePlayers = gameObject[@"player_dict"];
        self.tableView.tableHeaderView = [self configureTableHeader:gameObject];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)configureTableHeader:(PFObject *)gameObject
{
    UILabel *lastKillLabel = [[UILabel alloc] init];
    lastKillLabel.text = gameObject[@"last_kill"];
    
    return lastKillLabel;
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
    
    NSString *key = [self.gamePlayers allKeys][indexPath.row];
    
    NSDictionary *playerAttributes = self.gamePlayers[key];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row+1, key];
    cell.textLabel.textColor = [playerAttributes[@"status"] isEqual:@YES] ? [UIColor whiteColor] : [UIColor grayColor];
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gamePlayers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
