//
//  PlayMapScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "PlayMapScene.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "PlayerData.h"

@implementation PlayMapScene
{
	SKSpriteNode *level1, *level2, *level3, *level4, *level5, *level6, *level7, *level8, *level9, *level10, *level11;
	PFUser *currentUser;
}

- (id)initWithSize:(CGSize)size
{
	
	if (self = [super initWithSize:size]) {
		
		currentUser = [PFUser currentUser];
		
		self.backgroundColor = [SKColor blackColor];
		
		SKLabelNode *chooseMission = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		chooseMission.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue: 50]);
		chooseMission.fontColor = [SKColor whiteColor];
		chooseMission.fontSize = [self convertValue: 22];
		chooseMission.text = @"CHOOSE YOUR MISSION";
		chooseMission.name = @"chooseMission";
		[self addChild:chooseMission];
		
		level1 = [SKSpriteNode spriteNodeWithImageNamed:@"Level1Plot"];
		level1.position = CGPointMake(self.frame.size.width * .10, chooseMission.position.y - [self convertValue: 50]);
		level1.name = @"level1";
		
		level2 = [SKSpriteNode spriteNodeWithImageNamed:@"Level2Plot"];
		level2.position = CGPointMake(self.frame.size.width * .33, chooseMission.position.y - [self convertValue: 50]);
		level2.name = @"level2";
		
		level3 = [SKSpriteNode spriteNodeWithImageNamed:@"Level3Plot"];
		level3.position = CGPointMake(self.frame.size.width * .66, chooseMission.position.y - [self convertValue: 50]);
		level3.name = @"level3";
		
		level4 = [SKSpriteNode spriteNodeWithImageNamed:@"Level4Plot"];
		level4.position = CGPointMake(self.frame.size.width * .90, chooseMission.position.y - [self convertValue: 50]);
		level4.name = @"level4";
		
		level5 = [SKSpriteNode spriteNodeWithImageNamed:@"Level5Plot"];
		level5.position = CGPointMake(self.frame.size.width * .10, chooseMission.position.y - [self convertValue: 100]);
		level5.name = @"level5";
		
		level6 = [SKSpriteNode spriteNodeWithImageNamed:@"Level6Plot"];
		level6.position = CGPointMake(self.frame.size.width * .33, chooseMission.position.y - [self convertValue: 100]);
		level6.name = @"level6";
		
		level7 = [SKSpriteNode spriteNodeWithImageNamed:@"Level7Plot"];
		level7.position = CGPointMake(self.frame.size.width * .66, chooseMission.position.y - [self convertValue: 100]);
		level7.name = @"level7";
		
		level8 = [SKSpriteNode spriteNodeWithImageNamed:@"Level8Plot"];
		level8.position = CGPointMake(self.frame.size.width * .90, chooseMission.position.y - [self convertValue: 100]);
		level8.name = @"level8";
		
		level9 = [SKSpriteNode spriteNodeWithImageNamed:@"Level9Plot"];
		level9.position = CGPointMake(self.frame.size.width * .25, chooseMission.position.y - [self convertValue: 150]);
		level9.name = @"level9";
		
		level10 = [SKSpriteNode spriteNodeWithImageNamed:@"Level10Plot"];
		level10.position = CGPointMake(self.frame.size.width * .50, chooseMission.position.y - [self convertValue: 150]);
		level10.name = @"level10";
		
		level11 = [SKSpriteNode spriteNodeWithImageNamed:@"Level11Plot"];
		level11.position = CGPointMake(self.frame.size.width * .75, chooseMission.position.y - [self convertValue: 150]);
		level11.name = @"level11";
		
		SKLabelNode *back = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		back.position = CGPointMake(self.frame.size.width / 2, [self convertValue:25]);
		back.text = @"BACK";
		back.name = @"back";
		back.fontColor = [SKColor yellowColor];
		back.fontSize = [self convertValue: 22];
		[self addChild: back];
		
		[self setupLevels];
		
	}
	
	return self;
	
}


- (void)setupLevels
{
	
	
	
	if ([PlayerData sharedPlayerData].levelsCompleted == 0) {
		
		[self addChild:level1];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 1) {
		
		[self addChild:level1];
		[self addChild:level2];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 2) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 3) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 4) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 5) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 6) {
		
		 [self addChild:level1];
		 [self addChild:level2];
		 [self addChild:level3];
		 [self addChild:level4];
		 [self addChild:level5];
		 [self addChild:level6];
		 [self addChild:level7];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 7) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		[self addChild:level7];
		[self addChild:level8];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 8) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		[self addChild:level7];
		[self addChild:level8];
		[self addChild:level9];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 9) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		[self addChild:level7];
		[self addChild:level8];
		[self addChild:level9];
		[self addChild:level10];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 10) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		[self addChild:level7];
		[self addChild:level8];
		[self addChild:level9];
		[self addChild:level10];
		[self addChild:level11];
		
	} else if ([PlayerData sharedPlayerData].levelsCompleted == 11) {
		
		[self addChild:level1];
		[self addChild:level2];
		[self addChild:level3];
		[self addChild:level4];
		[self addChild:level5];
		[self addChild:level6];
		[self addChild:level7];
		[self addChild:level8];
		[self addChild:level9];
		[self addChild:level10];
		[self addChild:level11];
		
	}
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	if ([node.name isEqualToString:@"back"]) {
		
		// Show the main menu
		SKScene *menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
		menuScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: menuScene transition:trans];
		
	} else if ([node.name isEqualToString:@"level1"]) {
		
		// Load Level 1
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_1"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level2"]) {
		
		// Load Level 2
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_2"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level3"]) {
		
		// Load Level 3
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_3"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level4"]) {
		
		// Load Level 4
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_4"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level5"]) {
		
		// Load Level 5
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_5"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level6"]) {
		
		// Load Level 6
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_6"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level7"]) {
		
		// Load Level 7
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_7"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level8"]) {
		
		// Load Level 8
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_8"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level9"]) {
		
		// Load Level 9
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_9"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level10"]) {
		
		// Load Level 10
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_10"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} else if ([node.name isEqualToString:@"level11"]) {
		
		// Load Level 11
		self.selectPlayerItemsScene = [[SelectPlayerItemsScene alloc] initWithSize:self.view.bounds.size withFile:@"Level_11"];
		self.selectPlayerItemsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: self.selectPlayerItemsScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5]];
		
	} 
	
}










// ****** Size Conversion Methods

- (float) convertValue:(float)value
{
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return value * 2;
	} else {
		return value;
	}
	
}

- (SKTextureAtlas *) textureAtlasNamed:(NSString *)name
{
	
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
