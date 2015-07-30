//
//  SSNUser.h
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <Parse/Parse.h>
#import "Parse/PFFile.h"

@interface SSNUser : PFUser <PFSubclassing>

@property (nonatomic, strong, retain) NSString *fullName;
@property (nonatomic, strong, retain) NSMutableArray *gamesPlaying;
@property (nonatomic, strong, retain) NSMutableArray *gamesPlayed;
@property (nonatomic, strong, retain) PFFile *profilePicture;
@property (nonatomic, strong, retain) PFGeoPoint *lastSeen;

+ (SSNUser *)currentUser;

@end
