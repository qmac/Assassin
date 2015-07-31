//
//  SSNGameViewController.h
//  AssassinApp
//
//  Created by Manav Mandhani on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSNGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *targetTitle;
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastKillLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerCountdownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *targetImage;
@property (weak, nonatomic) IBOutlet UIButton *killConfirmButton;
@property (weak, nonatomic) IBOutlet UILabel *targetHeadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *lastLocationLabel;

@property (nonatomic, strong) NSString *gameId;

@end
