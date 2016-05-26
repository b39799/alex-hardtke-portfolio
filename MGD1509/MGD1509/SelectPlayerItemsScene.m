//
//  SelectPlayerItemsScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "SelectPlayerItemsScene.h"

@implementation SelectPlayerItemsScene {
	
	// Init
	NSString *levelFileName;
	
	SKTextureAtlas *_spriteTextureAtlas;
	
	SKSpriteNode *blueShip, *greenShip, *redShip;
	SKSpriteNode *blueLaser, *greenLaser, *redLaser;
	SKLabelNode *startMission;
	
	// Update
	NSTimeInterval updateInterval, checkInterval;

	// Selection
	SKSpriteNode *shipSelection, *laserSelection;
	BOOL blueShipSelected, greenShipSelected, redShipSelected, blueLaserSelected, greenLaserSelected, redLaserSelected;
}

- (id)initWithSize:(CGSize)size withFile:(NSString*)file
{
	
	if (self = [super initWithSize:size]) {
		
		// Set defaults
		levelFileName = file;
		self.backgroundColor = [SKColor blackColor];
		
		// Set flags
		blueShipSelected = NO;
		greenShipSelected = NO;
		redShipSelected = NO;
		blueLaserSelected = NO;
		greenLaserSelected = NO;
		redLaserSelected = NO;
		
		
		SKLabelNode *header = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		header.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue: 25]);
		header.fontColor = [SKColor whiteColor];
		header.fontSize = [self convertValue: 18];
		header.text = @"SELECT SHIP AND LASER";
		[self addChild:header];
		
		_spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		
		// Ships
		SKLabelNode *shipsLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		shipsLabel.position = CGPointMake(self.frame.size.width * .25, header.position.y - [self convertValue: 25]);
		shipsLabel.fontColor = [SKColor whiteColor];
		shipsLabel.fontSize = [self convertValue: 18];
		shipsLabel.text = @"AVAILABLE SHIPS";
		[self addChild:shipsLabel];
		
		blueShip = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"blueShip"]];
		blueShip.position = CGPointMake(self.frame.size.width * .25, shipsLabel.position.y - [self convertValue: 50]);
		blueShip.name = @"blueShip";
		
		greenShip = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"greenShip"]];
		greenShip.position = CGPointMake(self.frame.size.width * .25, blueShip.position.y - [self convertValue: 75]);
		greenShip.name = @"greenShip";
		
		redShip = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"redShip"]];
		redShip.position = CGPointMake(self.frame.size.width * .25, greenShip.position.y - [self convertValue: 75]);
		redShip.name = @"redShip";
		
		
		// Lasers
		SKLabelNode *lasersLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		lasersLabel.position = CGPointMake(self.frame.size.width * .75, header.position.y - [self convertValue: 25]);
		lasersLabel.fontColor = [SKColor whiteColor];
		lasersLabel.fontSize = [self convertValue: 18];
		lasersLabel.text = @"AVAILABLE LASERS";
		[self addChild:lasersLabel];
		
		blueLaser = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"blueLaser"]];
		blueLaser.position = CGPointMake(self.frame.size.width * .75, shipsLabel.position.y - [self convertValue: 50]);
		blueLaser.name = @"blueLaser";
		
		greenLaser = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"greenLaser"]];
		greenLaser.position = CGPointMake(self.frame.size.width * .75, blueLaser.position.y - [self convertValue: 75]);
		greenLaser.name = @"greenLaser";
		
		redLaser = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"redLaser"]];
		redLaser.position = CGPointMake(self.frame.size.width * .75, greenLaser.position.y - [self convertValue: 75]);
		redLaser.name = @"redLaser";
		
		
		// Set selection squares
		shipSelection = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(60, 60)];
		shipSelection.position = CGPointMake(blueShip.position.x, blueShip.position.y);
		shipSelection.alpha = 0.1;
		[self addChild:shipSelection];
		[shipSelection setHidden:YES];
		
		laserSelection = [SKSpriteNode spriteNodeWithColor:[UIColor cyanColor] size:CGSizeMake(60, 60)];
		laserSelection.position = CGPointMake(blueLaser.position.x, blueLaser.position.y);
		laserSelection.alpha = 0.1;
		[self addChild:laserSelection];
		[laserSelection setHidden:YES];
		
		
		// Back
		SKLabelNode *back = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		back.position = CGPointMake(self.frame.size.width / 2, [self convertValue: 25]);
		back.fontColor = [SKColor yellowColor];
		back.fontSize = [self convertValue: 18];
		back.text = @"BACK";
		back.name = @"back";
		[self addChild:back];
		
		// Start Mission
		startMission = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		startMission.position = CGPointMake(self.frame.size.width / 2, back.position.y + [self convertValue: 25]);
		startMission.fontColor = [SKColor whiteColor];
		startMission.fontSize = [self convertValue: 18];
		startMission.text = @"START MISSION";
		startMission.name = @"startMission";
		[self addChild:startMission];
		
		// Setup ships and lasers
		[self setupShips];
		[self setupLasers];
	}
	
	return self;
}





#pragma Setup methods

- (void) setupShips
{
	
	if ([PlayerData sharedPlayerData].availableShips <= 1) {
		
		[self addChild:blueShip];
		
	} else if ([PlayerData sharedPlayerData].availableShips == 2) {
		
		[self addChild:blueShip];
		[self addChild:greenShip];
		
	} else if ([PlayerData sharedPlayerData].availableShips == 3) {
		
		[self addChild:blueShip];
		[self addChild:greenShip];
		[self addChild:redShip];
		
	}
	
}

- (void) setupLasers
{
	
	if ([PlayerData sharedPlayerData].availableLasers <= 1) {
		
		[self addChild:blueLaser];
		
	} else if ([PlayerData sharedPlayerData].availableLasers == 2) {
		
		[self addChild:blueLaser];
		[self addChild:greenLaser];
		
	} else if ([PlayerData sharedPlayerData].availableLasers == 3) {
		
		[self addChild:blueLaser];
		[self addChild:greenLaser];
		[self addChild:redLaser];
		
	}
}





#pragma Update method

-(void)update:(NSTimeInterval)currentTime
{
	
	/* Called before each frame is rendered */
	CFTimeInterval lastUpdate = currentTime - updateInterval;
	updateInterval = currentTime;
	if (lastUpdate > 1) {
		// If it's been more than 1 second, update
		lastUpdate = 1.0 / 60.0; // Seconds
		updateInterval = currentTime;
	}
	
	checkInterval += lastUpdate;
	
	if (checkInterval > 1) {
		checkInterval = 0;
		[self checkItemsSet];
	}
	
}








#pragma Check if Laser and Ship Selection squares are shown

- (BOOL)checkItemsSet
{
	
	if (shipSelection.isHidden || laserSelection.isHidden) {
		startMission.fontColor = [SKColor whiteColor];
		return NO;
	}
	
	if (!shipSelection.isHidden && !laserSelection.isHidden) {
		startMission.fontColor = [SKColor cyanColor];
		return YES;
	}
	return NO;
	
}





#pragma Size Conversion methods

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






#pragma Animate Selection squares

- (void)animateShipSelection:(SKSpriteNode*)toShip selectionSquare:(SKSpriteNode*)selection
{
	
	SKAction *moveSelection = [SKAction moveTo:toShip.position duration:0.3];
	[selection runAction:moveSelection];
	
}

- (void)animateLaserSelection:(SKSpriteNode*)toLaser selectionSquare:(SKSpriteNode*)selection
{
	
	SKAction *moveSelection = [SKAction moveTo:toLaser.position duration:0.3];
	[selection runAction:moveSelection];
	
}






#pragma Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	
	
	// *** SHIPS ***
	if ([node.name isEqualToString:@"blueShip"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (blueShipSelected == NO) {
			blueShipSelected = YES;
			greenShipSelected = NO;
			redShipSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (shipSelection.isHidden) {
				[shipSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:blueShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"blueShip";
			} else if (!shipSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:blueShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"blueShip";
			}
		}
		// Else unflag it
		else if (blueShipSelected == YES) {
			blueShipSelected = NO;
		}
	}
	
	if ([node.name isEqualToString:@"greenShip"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (greenShipSelected == NO) {
			greenShipSelected = YES;
			blueShipSelected = NO;
			redShipSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (shipSelection.isHidden) {
				[shipSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:greenShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"greenShip";
			} else if (!shipSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:greenShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"greenShip";
			}
		}
		// Else unflag it
		else if (greenShipSelected == YES) {
			greenShipSelected = NO;
		}
	}
	
	if ([node.name isEqualToString:@"redShip"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (redShipSelected == NO) {
			redShipSelected = YES;
			blueShipSelected = NO;
			greenShipSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (shipSelection.isHidden) {
				[shipSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:redShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"redShip";
			} else if (!shipSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:redShip selectionSquare:shipSelection];
				[PlayerData sharedPlayerData].shipName = @"redShip";
			}
		}
		// Else unflag it
		else if (redShipSelected == YES) {
			redShipSelected = NO;
		}
	}
	
	

	// *** LASERS ***
	if ([node.name isEqualToString:@"blueLaser"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (blueLaserSelected == NO) {
			blueLaserSelected = YES;
			greenLaserSelected = NO;
			redLaserSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (laserSelection.isHidden) {
				[laserSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:blueLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"blueLaser";
			} else if (!laserSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:blueLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"blueLaser";
			}
		}
		// Else unflag it
		else if (blueLaserSelected == YES) {
			blueLaserSelected = NO;
		}
	}
	
	if ([node.name isEqualToString:@"greenLaser"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (greenLaserSelected == NO) {
			greenLaserSelected = YES;
			blueLaserSelected = NO;
			redLaserSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (laserSelection.isHidden) {
				[laserSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:greenLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"greenLaser";
			} else if (!laserSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:greenLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"greenLaser";
			}
		}
		// Else unflag it
		else if (greenLaserSelected == YES) {
			greenLaserSelected = NO;
		}
	}
	
	if ([node.name isEqualToString:@"redLaser"]) {
		
		// If the blue ship is not flagged as selected, flag it
		if (redLaserSelected == NO) {
			redLaserSelected = YES;
			blueLaserSelected = NO;
			greenLaserSelected = NO;
			
			// If the shipSelection square is hidden, show it
			if (laserSelection.isHidden) {
				[laserSelection setHidden:NO];
				
				// Now that the square is visible, set its position to be on this laser
				[self animateLaserSelection:redLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"redLaser";
			} else if (!laserSelection.isHidden) {
				// It's already visible, so move it
				[self animateLaserSelection:redLaser selectionSquare:laserSelection];
				[PlayerData sharedPlayerData].laserName = @"redLaser";
			}
		}
		// Else unflag it
		else if (redLaserSelected == YES) {
			redLaserSelected = NO;
		}
	}
	
	

	
	// If a ship and laser are selected
	if ([self checkItemsSet]) {
		
		// The player is ready to play the level
		if ([node.name isEqualToString:@"startMission"]) {
			
			self.gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size withFile:levelFileName];
			self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
			[self.view presentScene:self.gameScene transition:[SKTransition fadeWithDuration:0.5]];
			
		}
	}
	
	// Back
	if ([node.name isEqualToString:@"back"]) {
		
		self.playMapScene = [[PlayMapScene alloc] initWithSize:self.view.bounds.size];
		[self.view presentScene:self.playMapScene transition:[SKTransition pushWithDirection:SKTransitionDirectionDown duration:0.5]];
		
	}
}

@end
