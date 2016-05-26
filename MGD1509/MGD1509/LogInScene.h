//
//  LogInScene.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/7/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Reachability.h"

@interface LogInScene : SKScene <UITextFieldDelegate> {
	Reachability *reachability;
}

@end
