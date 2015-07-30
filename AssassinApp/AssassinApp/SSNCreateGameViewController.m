//
//  SSNCreateGameViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNCreateGameViewController.h"

@interface SSNCreateGameViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *invitedPlayersTableView;
@property (nonatomic, strong) IBOutlet UITextField *gameTitleInput;
@property (nonatomic, strong) IBOutlet UITextField *addPlayerInput;
@property (nonatomic, strong) IBOutlet UIButton *addPlayerButton;
@property (nonatomic, strong) NSMutableArray *addedUsers;

@end

@implementation SSNCreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.addedUsers = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPlayerAction:(id)sender
{
    [self.addedUsers addObject:self.addPlayerInput.text];
    self.addPlayerInput.text = @"";
    [self.view endEditing:YES];
    [self arrayDidUpdate];
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
    
    cell.textLabel.text = [self.addedUsers objectAtIndex:[indexPath row]];
    
    return cell;
}

@end
