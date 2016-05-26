//
//  InstructionsScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/18/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "InstructionsScene.h"
#import "OptionsScene.h"

@implementation InstructionsScene

- (id) initWithSize:(CGSize)size {
	
	if (self = [super initWithSize:size]) {
		
		self.backgroundColor = [SKColor blackColor];
		
		SKTextureAtlas *spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		
		SKLabelNode *instructionsTitle = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		instructionsTitle.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue:50]);
		instructionsTitle.text = @"INSTRUCTIONS";
		instructionsTitle.fontColor = [SKColor whiteColor];
		instructionsTitle.fontSize = [self convertValue:22];
		[self addChild: instructionsTitle];
		
		SKLabelNode *instructions = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		instructions.position = CGPointMake(self.frame.size.width / 2, instructionsTitle.position.y - [self convertValue:50]);
		instructions.text = @"Destroy 10 Invaders before they pass your ship! Watch out for asteroids!";
		instructions.fontColor = [SKColor whiteColor];
		instructions.fontSize = [self convertValue:18];
		[self addChild: instructions];
		
		SKSpriteNode *player = [SKSpriteNode spriteNodeWithTexture:[spriteTextureAtlas textureNamed:@"greenShip"]];
		player.position = CGPointMake(self.frame.size.width / 2, instructions.position.y - [self convertValue:100]);
		[self addChild: player];
		
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



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	if ([node.name isEqualToString:@"back"]) {
		// Transition back to Menu Scene
		SKScene *optionsScene = [OptionsScene sceneWithSize: self.view.bounds.size];
		SKTransition *trans = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
		optionsScene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene: optionsScene transition:trans];
	}
}

@end
