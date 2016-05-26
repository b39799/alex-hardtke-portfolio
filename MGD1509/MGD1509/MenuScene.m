//
//  MenuScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/18/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "MenuScene.h"
#import "PlayMapScene.h"
#import "OptionsScene.h"
#import "Reachability.h"
#import "LogInScene.h"

@implementation MenuScene {
	PlayerData *playerData;
	PlayMapScene *playMapScene;
	
	PFUser *currentUser;
	Reachability *reachability;
}

- (id) initWithSize:(CGSize)size {
	
	if (self = [super initWithSize: size]) {
		
		
		// The user is signed in.
		// See if they have a saved game and load it if they do
		// If they don't, create a new one with default data
		currentUser = [PFUser currentUser];
				
		
		
		PFQuery *query = [SaveData query];
		[query whereKey:@"user" equalTo:currentUser];
		[query whereKeyExists:@"objectId"];
		//[query whereKey:@"objectId" equalTo:@"Cgp1apa4cb"];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error && objects.count > 0) {
				SaveData *saveData = [objects firstObject];
				NSLog(@"Has SaveData: %@", saveData);
			} else if (objects.count == 0) {
				SaveData *saveData = [SaveData object];
				saveData.availableLasers = 1;
				saveData.availableShips = 1;
				saveData.levelsCompleted = 0;
				saveData.shipName = @"blueShip";
				saveData.laserName = @"blueLaser";
				saveData.level1Complete = NO;
				saveData.level2Complete = NO;
				saveData.level3Complete = NO;
				saveData.level4Complete = NO;
				saveData.level5Complete = NO;
				saveData.level5Complete = NO;
				saveData.level6Complete = NO;
				saveData.level7Complete = NO;
				saveData.level8Complete = NO;
				saveData.level9Complete = NO;
				saveData.level10Complete = NO;
				saveData.level11Complete = NO;
				saveData.user = currentUser;
				saveData.userName = currentUser.username;
				[saveData saveInBackground];
				
				NSLog(@"New SaveData: %@", saveData);
			}
			
		}];
		
		
		
		// Check network status
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
		
		reachability = [Reachability reachabilityForInternetConnection];
		[reachability startNotifier];
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			
		}
				
		self.backgroundColor = [SKColor blackColor];
		
		SKTextureAtlas *spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		
		// Set Game Title
		SKSpriteNode *gameLogo = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed: @"galaxyInvaders"]];
		gameLogo.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue:25]);
		[self addChild: gameLogo];
		
		// Set Menu Title
		SKSpriteNode *menu = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed: @"menu"]];
		menu.position = CGPointMake(self.frame.size.width / 2, gameLogo.position.y - [self convertValue:75]);
		[self addChild: menu];
		
		// Set Menu options Labels
		SKLabelNode *play = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		play.position = CGPointMake(self.frame.size.width / 2, menu.position.y - [self convertValue:75]);
		play.text = @"PLAY";
		play.name = @"play";
		play.fontColor = [SKColor whiteColor];
		play.fontSize = [self convertValue:22];
		[self addChild: play];
		
		SKLabelNode *options = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		options.position = CGPointMake(self.frame.size.width / 2, play.position.y - [self convertValue:50]);
		options.text = @"OPTIONS";
		options.name = @"options";
		options.fontColor = [SKColor whiteColor];
		options.fontSize = [self convertValue:22];
		[self addChild: options];
		
		SKLabelNode *logOut = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		logOut.position = CGPointMake(self.frame.size.width / 2, [self convertValue:25]);
		logOut.text = @"LOG OUT";
		logOut.name = @"logOut";
		logOut.fontColor = [SKColor yellowColor];
		logOut.fontSize = [self convertValue:22];
		[self addChild:logOut];
		
	}
	
	return self;
}





-(void)networkUpdated:(NSNotification *)notification {
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	
	if (networkStatus == NotReachable) {
		UIAlertController *notConnectedAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You are not connected to the internet." preferredStyle:UIAlertControllerStyleAlert];
		[self.view.window.rootViewController presentViewController:notConnectedAlert animated:YES completion:nil];
		//UIAlertController *notConnectedAlert = [[UIAlertController alloc] initWithTitle:@"Error" message:@"You are not connected to the internet. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	} else if (networkStatus == ReachableViaWiFi) {
		UIAlertController *wifiConnectedAlert = [UIAlertController alertControllerWithTitle:@"Wifi Connected" message:@"You have a WiFi connection." preferredStyle:UIAlertControllerStyleAlert];
		[self.view.window.rootViewController presentViewController:wifiConnectedAlert animated:YES completion:nil];
//		UIAlertView *wifiConnectedAlert = [[UIAlertView alloc] initWithTitle:@"WiFi Connected" message:@"You have a WiFi connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//		[wifiConnectedAlert show];
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





- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *node = [self nodeAtPoint:location];
	
	if ([node.name isEqualToString:@"play"]) {
		// Start the game
		playMapScene = [[PlayMapScene alloc] initWithSize:self.view.bounds.size];
		playMapScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: playMapScene];
	} else if ([node.name isEqualToString:@"options"]) {
		// Show the instructions scene
		SKScene *optionsScene = [OptionsScene sceneWithSize: self.view.bounds.size];
		optionsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: optionsScene];
	} else if ([node.name isEqualToString:@"logOut"]) {
		// Log out to the Log In screen
		[PFUser logOut];
		SKScene *logInScene = [LogInScene sceneWithSize:self.view.bounds.size];
		logInScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:logInScene];
	}
}

@end
