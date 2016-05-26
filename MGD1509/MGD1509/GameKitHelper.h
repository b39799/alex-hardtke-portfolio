//
//  GameKitHelper.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/22/15.
//  Copyright © 2015 Alex Hardtke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameViewController.h"

@interface GameKitHelper : NSObject <GKGameCenterControllerDelegate> {
	GameViewController *gameVC;
	BOOL gameCenterEnabled;
	BOOL authenticatedUser;
	NSString *_leaderboardIdentifier;
}

@property (readonly, assign) BOOL gameCenterEnabled;

+(GameKitHelper*)sharedInstance;

-(void)authenticateUserWithVC:(GameViewController*)gameVC;
-(void)postScore:(int)careerKills;
-(void)displayLeaderboardAchievements:(BOOL)showLeaderboard;
-(void)updateAchievements:(int)level win:(BOOL)win health:(BOOL)health score:(int)score;
-(void)resetAchievements;

@end
