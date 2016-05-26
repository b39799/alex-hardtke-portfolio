//
//  GameScene.h
//  MGD1509
//

//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PlayerData.h"
#import "SaveData.h"
@class Level;
@class PlayMapScene;
@class PlayerData;

@interface GameScene : SKScene

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) PlayMapScene *playMap;

@property (nonatomic, assign) NSUInteger enemySpeedMax;
@property (nonatomic, assign) NSUInteger enemySpeedMin;
@property (nonatomic, assign) NSUInteger killsRequired;
@property (nonatomic, assign) NSUInteger totalAsteroids;

- (id)initWithSize:(CGSize)size withFile:(NSString*)file;

@end
