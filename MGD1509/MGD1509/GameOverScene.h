//
//  GameOverScene.h
//  MGD1509
//
//  Created by Alex Hardtke on 9/17/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PlayerData.h"

@interface GameOverScene : SKScene

- (id)initWithSize:(CGSize)size wonGame:(BOOL)result filename:(NSString*)filename;

@end
