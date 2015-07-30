//
//  SSNCreateGameViewController.m
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNCreateGameViewController.h"
#import <Parse/PFObject.h>

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

- (void)sendToDatabase
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
@end
