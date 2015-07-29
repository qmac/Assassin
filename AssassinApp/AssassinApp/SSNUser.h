//
//  SSNUser.h
//  AssassinApp
//
//  Created by Quinn McNamara on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <Parse/Parse.h>

@interface SSNUser : PFUser <PFSubclassing>

@property (nonatomic, strong, retain) NSString *fullName;

+ (SSNUser *)currentUser;

@end
