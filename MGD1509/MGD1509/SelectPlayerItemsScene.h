//
//  SelectPlayerItemsScene.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
#import "PlayerData.h"
#import "PlayMapScene.h"

@interface SelectPlayerItemsScene : SKScene

@property (nonatomic, strong) GameScene *gameScene;
@property (nonatomic, strong) PlayMapScene *playMapScene;

- (id)initWithSize:(CGSize)size withFile:(NSString*)file;

@end
