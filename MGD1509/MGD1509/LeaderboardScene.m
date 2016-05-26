//
//  LeaderboardScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/13/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "LeaderboardScene.h"
#import <Parse/Parse.h>
#import "SaveData.h"
#import "OptionsScene.h"

@implementation LeaderboardScene {
	SaveData *saveData;
}

-(id)initWithSize:(CGSize)size {
	
	if (self = [super initWithSize:size]) {
		
		self.backgroundColor = [SKColor blackColor];
		
		SKLabelNode *leaderboardTitle = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		leaderboardTitle.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue:50]);
		leaderboardTitle.text = @"SELECT LEADERBOARD";
		leaderboardTitle.fontColor = [SKColor whiteColor];
		leaderboardTitle.fontSize = [self convertValue:22];
		[self addChild: leaderboardTitle];
		
		SKLabelNode *globalTitle = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		globalTitle.position = CGPointMake(self.frame.size.width / 2, leaderboardTitle.position.y - [self convertValue: 25]);
		globalTitle.fontColor = [SKColor yellowColor];
		globalTitle.fontSize = [self convertValue: 18];
		globalTitle.text = @"Refresh";
		globalTitle.name = @"global";
		[self addChild:globalTitle];
		
		SKLabelNode *back = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		back.position = CGPointMake(self.frame.size.width / 2, [self convertValue:25]);
		back.text = @"BACK";
		back.name = @"back";
		back.fontSize = [self convertValue:18];
		back.fontColor = [SKColor yellowColor];
		[self addChild: back];
		
		// Back button
		
	}
	
	return self;
}

-(void)updateList {
	
	//PFQuery *query = [PFQuery queryWithClassName:@"SaveData"];
	PFQuery *query = [SaveData query];
	query.cachePolicy = kPFCachePolicyIgnoreCache;
	[query orderByDescending:@"careerScore"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			//leaderboardArray = [[NSMutableArray alloc] initWithObjects:objects, nil];
			[leaderboardArray removeAllObjects];
			[leaderboardArray addObjectsFromArray:objects];
			NSLog(@"Count = %d", objects.count);
			NSLog(@"Objects = %@", objects);
			[myTableView reloadData];
		}
	}];
}

-(void)didMoveToView:(SKView *)view {
	myTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2 - 20, CGRectGetMaxX(self.frame) / 2, CGRectGetMaxY(self.frame) - 150)];
	myTableView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	myTableView.dataSource = self;
	myTableView.delegate = self;
	
	SaveData *obj = [[SaveData alloc] init];
	obj.userName = @"";
	
	
	leaderboardArray = [[NSMutableArray alloc] initWithObjects:obj, nil];
	[self.view addSubview:myTableView];
}

-(void)willMoveFromView:(SKView *)view {
	[myTableView removeFromSuperview];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"LeaderboardArray count = %lu", (unsigned long)[leaderboardArray count]);
	return [leaderboardArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *player, *score;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Identifier"];

	}
	
	SaveData *data = [leaderboardArray objectAtIndex:indexPath.row];
	player = [NSString stringWithFormat:@"%@", data.userName];
	score = [NSString stringWithFormat:@"%d", data.careerScore];
	
	if ([score isEqualToString:@"0"]) {
		score = @"";
	}
	
	[cell.textLabel setText:player];
	[cell.detailTextLabel setText:score];
	
	
	return cell;
	
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SaveData *data = [[SaveData alloc] init];
	data = [leaderboardArray objectAtIndex:indexPath.row];
	NSLog(@"Touched: %d", indexPath.row);
	[myTableView reloadData];
}





-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	if ([node.name isEqualToString:@"global"]) {
		[self updateList];
		[myTableView reloadData];
	} else if ([node.name isEqualToString:@"back"]) {
		// Transition back to Menu Scene
		SKScene *optionsScene = [OptionsScene sceneWithSize: self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
		optionsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: optionsScene transition:trans];
	}
}





// ****** Size Conversion Methods

- (float) convertValue:(float)value {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return value * 2;
	} else {
		return value;
	}
}

- (SKTextureAtlas *) textureAtlasNamed:(NSString *)name {
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		// Phone
		name = name;
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// Pad
		name = [NSString stringWithFormat:@"%@-ipad", name];
	}
	
	SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:name];
	
	return textureAtlas;
}

@end
