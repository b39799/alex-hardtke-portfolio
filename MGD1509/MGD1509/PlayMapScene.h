//
//  PlayMapScene.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level.h"
#import "GameScene.h"
#import "PlayerData.h"
#import "SaveData.h"
#import "SelectPlayerItemsScene.h"
@class SelectPlayerItemsScene;

@interface PlayMapScene : SKScene

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) GameScene *gameScene;
@property (strong, nonatomic) SelectPlayerItemsScene *selectPlayerItemsScene;

- (id)initWithSize:(CGSize)size;

@end
