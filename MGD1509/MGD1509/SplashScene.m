//
//  SplashScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/18/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "SplashScene.h"
#import "LogInScene.h"
#import "MenuScene.h"

@implementation SplashScene

- (id) initWithSize:(CGSize)size {
	
	if (self = [super initWithSize: size]) {
		self.backgroundColor = [SKColor blackColor];
		
		SKTextureAtlas *spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		
		SKSpriteNode *game = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed:@"galaxyInvaders"]];
		game.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 1.5);
		[self addChild: game];
		
		SKSpriteNode *logo = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed:@"splashLogo"]];
		logo.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2.5);
		[self addChild: logo];
		
		// Transition to Log In Scene
		SKAction *logInTrans = [SKAction sequence:@[[SKAction waitForDuration:3.0],
												   [SKAction runBlock:^{
			SKTransition *showLogIn = [SKTransition fadeWithDuration:2.0];
			SKScene *logInScene = [MenuScene sceneWithSize: self.view.bounds.size];
			[self.view presentScene:logInScene transition: showLogIn];
		}]]];
		[self runAction: logInTrans];
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

@end
