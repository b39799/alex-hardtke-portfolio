//
//  CreditsScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/18/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "CreditsScene.h"
#import "OptionsScene.h"

@implementation CreditsScene

- (id) initWithSize:(CGSize)size {
	
	if (self = [super initWithSize:size]) {
		
		self.backgroundColor = [SKColor blackColor];
		
		SKLabelNode *creditsTitle = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		creditsTitle.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue:50]);
		creditsTitle.text = @"CREDITS";
		creditsTitle.fontColor = [SKColor whiteColor];
		creditsTitle.fontSize = [self convertValue:22];
		[self addChild: creditsTitle];
		
		SKLabelNode *createdBy = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		createdBy.position = CGPointMake(self.frame.size.width / 2, creditsTitle.position.y - [self convertValue:100]);
		createdBy.text = @"Created by: Alex Hardtke, 2015";
		createdBy.fontColor = [SKColor whiteColor];
		createdBy.fontSize = [self convertValue:16];
		[self addChild: createdBy];
		
		SKLabelNode *art = [[SKLabelNode alloc] initWithFontNamed: @"Futura-CondensedMedium"];
		art.position = CGPointMake(self.frame.size.width / 2, createdBy.position.y - [self convertValue:50]);
		art.text = @"Artwork and Sounds: OpenGameArt.org";
		art.fontColor = [SKColor whiteColor];
		art.fontSize = [self convertValue:16];
		[self addChild: art];
		
		
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
