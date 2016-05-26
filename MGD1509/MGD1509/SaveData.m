//
//  SaveData.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/8/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "SaveData.h"

@implementation SaveData
@dynamic user, userName, careerScore, shipName, laserName, levelsCompleted, availableShips, availableLasers, level1Complete, level2Complete, level3Complete, level4Complete, level5Complete, level6Complete, level7Complete, level8Complete, level9Complete, level10Complete, level11Complete;

+(void)load {
	[self registerSubclass];
}

+(NSString*)parseClassName {
	return @"SaveData";
}

@end
