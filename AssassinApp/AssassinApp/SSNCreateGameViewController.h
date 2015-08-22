//
//  SSNCreateGameViewController.h
//  AssassinApp
//
//  Created by Austin Tsao on 7/29/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSNCreateGameViewControllerDelegate <NSObject>

- (void)createGameViewControllerDidCreateGameWithId:(NSString *)gameId;
- (void)createGameViewControllerDidCancel;

@end


@interface SSNCreateGameViewController : UIViewController

@property (nonatomic, weak) id<SSNCreateGameViewControllerDelegate> delegate;

@end
