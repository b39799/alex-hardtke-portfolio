//
//  LeaderboardScene.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/13/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LeaderboardScene : SKScene <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *myTableView;
	NSMutableArray *leaderboardArray;
}

@end
