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
    
    [self performFetch];
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
- (void) performFetch
{
    [self.tableView reloadData];
}

#pragma mark - Nav Bar Handlers
- (void) launchCreateGame:(id)sender
{
    NSLog(@"creating new game");
    PFObject *gameObject = [PFObject objectWithClassName:@"Game"];
    gameObject[@"active"] = @YES;
    gameObject[@"users"] = @"Bob the Builder";
    [gameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"created a dummy game");
        }
        else
        {
            NSLog(@"dummy game creation failed");
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
    // Handle when user taps on a cell
    SSNGameViewController *gameViewController = [[SSNGameViewController alloc] init];
    [self.navigationController presentViewController:gameViewController animated:NO completion:nil];
}


@end
