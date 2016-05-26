//
//  OptionsScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "OptionsScene.h"
#import "InstructionsScene.h"
#import "CreditsScene.h"
#import "MenuScene.h"
#import "PlayerData.h"
#import "LeaderboardScene.h"
#import <Parse/Parse.h>
#import "SaveData.h"
#import "GameKitHelper.h"

@implementation OptionsScene {
	SKSpriteNode *resetFrame;
	SKLabelNode *resetYes, *resetNo, *resetTitle;
}

- (id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		NSLog(@"ScreenSize = %@", NSStringFromCGSize(size));
		
		self.backgroundColor = [SKColor blackColor];
		
		SKTextureAtlas *spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		
		// Set game title
		SKSpriteNode *gameLogo = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed:@"galaxyInvaders"]];
		gameLogo.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue: 25]);
		[self addChild: gameLogo];
		
		// Set options
		SKLabelNode *optionsTitle = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		optionsTitle.position = CGPointMake(self.frame.size.width / 2, gameLogo.position.y - [self convertValue:50]);
		optionsTitle.text = @"OPTIONS";
		optionsTitle.name = @"optionsTitle";
		optionsTitle.fontColor = [SKColor whiteColor];
		optionsTitle.fontSize = [self convertValue:22];
		[self addChild: optionsTitle];
		
		SKLabelNode *leaderboard = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		leaderboard.position = CGPointMake(self.frame.size.width / 2, optionsTitle.position.y - [self convertValue:75]);
		leaderboard.text = @"LEADERBOARD";
		leaderboard.name = @"leaderboard";
		leaderboard.fontColor = [SKColor whiteColor];
		leaderboard.fontSize = [self convertValue:16];
		[self addChild: leaderboard];
		
		SKLabelNode *instructions = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		instructions.position = CGPointMake(self.frame.size.width / 2, leaderboard.position.y - [self convertValue:25]);
		instructions.text = @"INSTRUCTIONS";
		instructions.name = @"instructions";
		instructions.fontColor = [SKColor whiteColor];
		instructions.fontSize = [self convertValue:16];
		[self addChild: instructions];
		
		SKLabelNode *credits = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		credits.position = CGPointMake(self.frame.size.width / 2, instructions.position.y - [self convertValue:25]);
		credits.text = @"CREDITS";
		credits.name = @"credits";
		credits.fontColor = [SKColor whiteColor];
		credits.fontSize = [self convertValue:16];
		[self addChild: credits];
		
		SKLabelNode *reset = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		reset.position = CGPointMake(self.frame.size.width / 2, credits.position.y - [self convertValue:25]);
		reset.fontColor = [SKColor whiteColor];
		reset.fontSize = [self convertValue:16];
		reset.text = @"RESET";
		reset.name = @"reset";
		[self addChild:reset];
		
		// Set back
		SKLabelNode *back = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		back.position = CGPointMake(self.frame.size.width / 2, [self convertValue:25]);
		back.text = @"BACK";
		back.name = @"back";
		back.fontSize = [self convertValue:18];
		back.fontColor = [SKColor yellowColor];
		[self addChild: back];
		
	}
	return self;
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

- (void)confirmReset {
	
	resetFrame = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
	resetFrame.position = CGPointMake(self.frame.size.width /2, self.frame.size.height/2);
	resetFrame.alpha = 0.8;
	[self addChild:resetFrame];
	
	
	resetTitle = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	resetTitle.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height/2 + [self convertValue:20]);
	resetTitle.fontColor = [SKColor yellowColor];
	resetTitle.text = @"RESET SAVED GAME?";
	resetTitle.name = @"resetTitle";
	[resetTitle setScale:0.1];
	[self addChild:resetTitle];
	
	resetYes = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	resetYes.position = CGPointMake(self.frame.size.width / 2 + [self convertValue:25], self.frame.size.height/2 - [self convertValue:20]);
	resetYes.fontColor = [SKColor whiteColor];
	resetYes.text = @"Yes";
	resetYes.name = @"resetYes";
	[resetYes setScale:0.1];
	[self addChild:resetYes];
	
	resetNo = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	resetNo.position = CGPointMake(self.frame.size.width / 2 - [self convertValue:25], self.frame.size.height/2 - [self convertValue:20]);
	resetNo.fontColor = [SKColor whiteColor];
	resetNo.text = @"No";
	resetNo.name = @"resetNo";
	[resetNo setScale:0.1];
	[self addChild:resetNo];
	
	SKAction *scaleLabel = [SKAction scaleTo:1.0 duration:0.5];
	[resetTitle runAction:scaleLabel];
	[resetYes runAction:scaleLabel];
	[resetNo runAction:scaleLabel];
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	if ([node.name isEqualToString:@"instructions"]) {
		
		// Show the instructions scene
		SKScene *instructionsScene = [InstructionsScene sceneWithSize:self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
		instructionsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:instructionsScene transition:trans];
		
	} else if ([node.name isEqualToString:@"credits"]) {
		
		SKScene *creditsScene = [CreditsScene sceneWithSize:self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
		creditsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:creditsScene transition:trans];
		
	} else if ([node.name isEqualToString:@"back"]) {
		
		SKScene *menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
		menuScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:menuScene transition:trans];
		
	} else if ([node.name isEqualToString:@"reset"]) {
		
		[self confirmReset];
		
	} else if ([node.name isEqualToString:@"resetYes"]) {
		
		[[PlayerData sharedPlayerData] reset];
		[[GameKitHelper sharedInstance] resetAchievements];
		
		[resetFrame removeFromParent];
		[resetNo removeFromParent];
		[resetTitle removeFromParent];
		[resetYes removeFromParent];
		
		// Transition to Main Menu
		SKScene *menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
		menuScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:menuScene transition:trans];
		
	} else if ([node.name isEqualToString:@"resetNo"]) {
		
		[resetFrame removeFromParent];
		[resetNo removeFromParent];
		[resetTitle removeFromParent];
		[resetYes removeFromParent];
		
	} else if ([node.name isEqualToString:@"leaderboard"]) {
		
		[[GameKitHelper sharedInstance] displayLeaderboardAchievements:YES];
		
//		SKScene *leaderboardScene = [LeaderboardScene sceneWithSize:self.view.bounds.size];
//		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
//		leaderboardScene.scaleMode = SKSceneScaleModeAspectFill;
//		[self.view presentScene:leaderboardScene transition:trans];
	}
	
}

@end
