//
//  SSNUser.m
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation SSNUser

@dynamic fullName, games, profilePicture, lastSeen;

+ (SSNUser *)currentUser
{
    return (SSNUser *)[PFUser currentUser];
}

@end
