//
//  GameOverScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/17/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "PlayMapScene.h"
#import "MenuScene.h"

@implementation GameOverScene {
	NSString *fileName;
	SKLabelNode *play, *retry, *quit;
}

- (id)initWithSize:(CGSize)size wonGame:(BOOL)result filename:(NSString *)filename
{
	
	if (self = [super initWithSize:size]) {
		
		fileName = filename;
		
		
		self.backgroundColor = [SKColor blackColor];
		
		// Set a background frame
		SKSpriteNode *backgroundFrame = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
		backgroundFrame.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
		backgroundFrame.alpha = 0.8;
		backgroundFrame.name = @"backgroundFrame";
		[self addChild:backgroundFrame];
		
		// Result label
		SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
		
		// Set label text and set colors based on the BOOL result
		NSString *labelText;
		BOOL win;
		if (result) {
			labelText = @"Congratulations, you won!";
			label.fontColor = [SKColor greenColor];
			win = YES;
		} else {
			labelText = @"Sorry, try again!";
			label.fontColor = [SKColor redColor];
			win = NO;
		}
		label.text = labelText;
		label.fontSize = [self convertValue:22];
		label.position = CGPointMake(self.size.width/2, self.size.height * .60);
		[self addChild:label];
		
		
		
		
		if (win) {
			
			// Play win sound
			[self playSfx:@"win"];
			
			// Win label node
			play = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
			play.position = CGPointMake(self.frame.size.width /2 , label.position.y - [self convertValue:50]);
			play.text = @"CONTINUE";
			play.name = @"continue";
			play.fontColor = [SKColor yellowColor];
			play.fontSize = [self convertValue:24];
			[self addChild:play];
			
		} else {
			
			// Play lose sound
			[self playSfx:@"lose"];
			
			// Lose label nodes
			quit = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
			quit.position = CGPointMake(label.position.x - [self convertValue:25] , label.position.y - [self convertValue:50]);
			quit.text = @"QUIT";
			quit.name = @"quit";
			quit.fontColor = [SKColor whiteColor];
			quit.fontSize = [self convertValue:20];
			[self addChild:quit];
			
			retry = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
			retry.position = CGPointMake(label.position.x + [self convertValue:25] , label.position.y - [self convertValue:50]);
			retry.text = @"RETRY";
			retry.name = @"retry";
			retry.fontColor = [SKColor yellowColor];
			retry.fontSize = [self convertValue:24];
			[self addChild:retry];
		}
	}
	return self;
}






- (void)playSfx:(NSString*)soundFileName
{
	
	// Play the sound using SKAction. Append the ".wav" to the soundFileName first.
	NSString* soundName = [NSString stringWithFormat:@"%@.wav", soundFileName];
	SKAction* playSound = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
	[self runAction:playSound];
	
}







- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode: self];
	SKNode *node = [self nodeAtPoint: location];
	
	if ([node.name isEqualToString:@"retry"]) {
		// The player lost, so give them the option to try again or go quit back to the main menu.
		[self runAction:[SKAction runBlock:^{
			SKTransition *trans = [SKTransition flipHorizontalWithDuration:0.5];
			SKScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size withFile:fileName];
			[self.view presentScene:gameScene transition:trans];
		}]];
	} else if ([node.name isEqualToString:@"quit"]) {
		// The player quit, so take them back to the PlayMapScene so they can choose the next level
		[self runAction: [SKAction runBlock:^{
			SKTransition *trans = [SKTransition flipHorizontalWithDuration:0.5];
			SKScene *playMapScene = [[PlayMapScene alloc] initWithSize:self.size];
			[self.view presentScene:playMapScene transition:trans];
		}]];
	} else if ([node.name isEqualToString:@"continue"]) {
		// The player won, so take them back to the PlayMapScene so they can choose the next level
		[self runAction:[SKAction runBlock:^{
			SKTransition *trans = [SKTransition flipHorizontalWithDuration:0.5];
			SKScene *playMapScene = [[PlayMapScene alloc] initWithSize:self.size];
			[self.view presentScene:playMapScene transition:trans];
		}]];
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
