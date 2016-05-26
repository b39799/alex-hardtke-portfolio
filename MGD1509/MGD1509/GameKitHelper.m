//
//  GameKitHelper.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/22/15.
//  Copyright © 2015 Alex Hardtke. All rights reserved.
//

#import "GameKitHelper.h"


@implementation GameKitHelper
@synthesize gameCenterEnabled;


// This class is a singleton that will be used throughout the game to handle all GameCenter related things
static GameKitHelper *helper = nil;
+(GameKitHelper*)sharedInstance {
	if (!helper) {
		helper = [[GameKitHelper alloc] init];
	}
	return helper;
}

-(id)init {
	if ((self = [super init])) {
		gameCenterEnabled = YES;
	}
	return self;
}



// Call these methods from the game to use this class

-(void)authenticateUserWithVC:(GameViewController*)gameViewController {
	// If GC is not enabled, return
	if (!gameCenterEnabled) return;
	
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	gameVC = gameViewController;
	
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
		if (viewController != nil) {
			[gameVC presentViewController:viewController animated:YES completion:nil];
		} else {
			if ([GKLocalPlayer localPlayer].authenticated) {
				gameCenterEnabled = YES;
				
				// Get leaderboard identifier
				[[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString * _Nullable leaderboardIdentifier, NSError * _Nullable error) {
					if (error != nil) {
						NSLog(@"Error: %@", [error localizedDescription]);
					} else {
						_leaderboardIdentifier = leaderboardIdentifier;
					}
				}];
			} else {
				gameCenterEnabled = NO;
			}
		}
	};
	
}

-(void)postScore:(int)careerKills {
	
	GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
	score.value = careerKills;
	
	[GKScore reportScores:@[score] withCompletionHandler:^(NSError * _Nullable error) {
		if (error != nil) {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
	}];
}

-(void)displayLeaderboardAchievements:(BOOL)showLeaderboard {
	
	GKGameCenterViewController *gameCenterVC = [[GKGameCenterViewController alloc] init];
	gameCenterVC.gameCenterDelegate = self;
	
	if (showLeaderboard) {
		gameCenterVC.viewState = GKGameCenterViewControllerStateLeaderboards;
		gameCenterVC.leaderboardIdentifier = _leaderboardIdentifier;
	} else {
		gameCenterVC.viewState = GKGameCenterViewControllerStateAchievements;
	}
	[gameVC presentViewController:gameCenterVC animated:YES completion:nil];
}

-(void)updateAchievements:(int)level win:(BOOL)win health:(BOOL)health score:(int)score {
	NSString *identifier;
	float progressPct = 0.0;
	BOOL progressMade = NO;
	
	GKAchievement *levelAchievement = nil;
	GKAchievement *scoreAchievement = nil;
	
	if (level == 1 && !win) {
		identifier = @"A_Level1";
	} else if (level <= 3 && win) {
		progressPct = level * 100 / 3;
		progressMade = YES;
		identifier = @"A_Level3";
	} else if (level < 6 && win) {
		progressPct = level * 100 / 5;
		progressMade = YES;
		identifier = @"A_Level5";
	} else if (level < 8 && win) {
		progressPct = level * 100 / 7;
		progressMade = YES;
		identifier = @"A_Level7";
	} else if (level < 9 && win) {
		progressPct = level * 100 / 8;
		progressMade = YES;
		identifier = @"A_Level8";
	} else if (level == 11 && win && health == 5) {
		
		identifier = @"A_Level11";
	}
	
	if (progressMade) {
		levelAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
		levelAchievement.percentComplete = progressPct;
	}
	
	if (score <= 30) {
		progressPct = score * 100 / 30;
	} else if (score <= 50) {
		progressPct = score * 100 / 50;
	} else if (score <= 70) {
		progressPct = score * 100 / 70;
	} else if (score <= 80) {
		progressPct = score * 100 / 80;
	} else {
		progressPct = score * 100 / 100;
	}
	
	scoreAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
	scoreAchievement.percentComplete = progressPct;
	
	NSArray *achievementsArr = (progressMade) ? @[levelAchievement, scoreAchievement] : @[scoreAchievement];
	
	[GKAchievement reportAchievements:achievementsArr withCompletionHandler:^(NSError * _Nullable error) {
		if (error != nil) {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
	}];
	
}

-(void)resetAchievements {
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError * _Nullable error) {
		if (error != nil) {
			NSLog(@"Error %@", [error localizedDescription]);
		}
	}];
}





// GKGameCenterViewControllerDelegate Method

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	[gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
