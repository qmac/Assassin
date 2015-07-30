//
//  SSNGameViewController.m
//  AssassinApp
//
//  Created by Manav Mandhani on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNGameViewController.h"
#import "Parse/Parse.h"

@interface SSNGameViewController ()

@end


@implementation SSNGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)confirmKill:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query getObjectInBackgroundWithId:@"j5KvQKhcI3" block:^(PFObject *gameObject, NSError *error) {
        NSLog(@"%@", gameObject);
        [[gameObject[@"player_dict"] valueForKey:@"manavm"] setObject:(@"quinn") forKey:(@"target")];
        NSLog(@"%@", [gameObject[@"player_dict"] valueForKey:@"manavm"]);
        [gameObject saveInBackground];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)killConfirmButton:(id)sender {
}
@end
