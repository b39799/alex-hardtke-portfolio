//
//  PlayerData.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "PlayerData.h"

@implementation PlayerData

static NSString* const mAvailableShips = @"availableShips";
static NSString* const mAvailableLasers = @"availableLasers";
static NSString* const mLevelsCompleted = @"levelsCompleted";
static NSString* const mShipName = @"shipName";
static NSString* const mLaserName = @"laserName";
static NSString* const mCareerKills = @"careerKills";

static NSString* const mLevel1 = @"level1Completed";
static NSString* const mLevel2 = @"level2Completed";
static NSString* const mLevel3 = @"level3Completed";
static NSString* const mLevel4 = @"level4Completed";
static NSString* const mLevel5 = @"level5Completed";
static NSString* const mLevel6 = @"level6Completed";
static NSString* const mLevel7 = @"level7Completed";
static NSString* const mLevel8 = @"level8Completed";
static NSString* const mLevel9 = @"level9Completed";
static NSString* const mLevel10 = @"level10Completed";
static NSString* const mLevel11 = @"level11Completed";



+ (instancetype)sharedPlayerData
{
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [self loadInstance];
	});
	return sharedInstance;
}

+ (instancetype)loadInstance
{
	NSData *data = [NSData dataWithContentsOfFile:[PlayerData filePath]];
	if (data) {
		PlayerData *playerData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		return playerData;
	}
	return [[PlayerData alloc] init];
}

+ (NSString*)filePath
{
	static NSString* filePath = nil;
	if (!filePath) {
		filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
					stringByAppendingPathComponent:@"playerdata"];
	}
	return filePath;
}

- (void)reset
{
	self.availableLasers = 1;
	self.availableShips = 1;
	self.levelsCompleted = 0;
	self.shipName = @"blueShip";
	self.laserName = @"laserName";
	self.careerKills = 0;
	
	self.level1Complete = NO;
	self.level2Complete = NO;
	self.level3Complete = NO;
	self.level4Complete = NO;
	self.level5Complete = NO;
	self.level6Complete = NO;
	self.level7Complete = NO;
	self.level8Complete = NO;
	self.level9Complete = NO;
	self.level10Complete = NO;
	self.level11Complete = NO;
	
	[self save];
}

- (void)save
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[data writeToFile:[PlayerData filePath] atomically:YES];
}


- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:self.shipName forKey:mShipName];
	[encoder encodeObject:self.laserName forKey:mLaserName];
	[encoder encodeInteger:self.availableShips forKey:mAvailableShips];
	[encoder encodeInteger:self.availableLasers forKey:mAvailableLasers];
	[encoder encodeInteger:self.levelsCompleted forKey:mLevelsCompleted];
	[encoder encodeInteger:self.careerKills forKey:mCareerKills];
	
	[encoder encodeBool:self.level1Complete forKey:mLevel1];
	[encoder encodeBool:self.level2Complete forKey:mLevel2];
	[encoder encodeBool:self.level3Complete forKey:mLevel3];
	[encoder encodeBool:self.level4Complete forKey:mLevel4];
	[encoder encodeBool:self.level5Complete forKey:mLevel5];
	[encoder encodeBool:self.level6Complete forKey:mLevel6];
	[encoder encodeBool:self.level7Complete forKey:mLevel7];
	[encoder encodeBool:self.level8Complete forKey:mLevel8];
	[encoder encodeBool:self.level9Complete forKey:mLevel9];
	[encoder encodeBool:self.level10Complete forKey:mLevel10];
	[encoder encodeBool:self.level11Complete forKey:mLevel11];
}

- (instancetype)initWithCoder:(NSCoder*)decoder
{
	self = [self init];
	if (self) {
		self.availableLasers = [decoder decodeIntegerForKey:mAvailableLasers];
		self.availableShips = [decoder decodeIntegerForKey:mAvailableShips];
		self.levelsCompleted = [decoder decodeIntegerForKey:mLevelsCompleted];
		self.shipName = [decoder decodeObjectForKey:mShipName];
		self.laserName = [decoder decodeObjectForKey:mLaserName];
		self.careerKills = [decoder decodeIntegerForKey:mCareerKills];
		
		self.level1Complete = [decoder decodeBoolForKey:mLevel1];
		self.level2Complete = [decoder decodeBoolForKey:mLevel2];
		self.level3Complete = [decoder decodeBoolForKey:mLevel3];
		self.level4Complete = [decoder decodeBoolForKey:mLevel4];
		self.level5Complete = [decoder decodeBoolForKey:mLevel5];
		self.level6Complete = [decoder decodeBoolForKey:mLevel6];
		self.level7Complete = [decoder decodeBoolForKey:mLevel7];
		self.level8Complete = [decoder decodeBoolForKey:mLevel8];
		self.level9Complete = [decoder decodeBoolForKey:mLevel9];
		self.level10Complete = [decoder decodeBoolForKey:mLevel10];
		self.level11Complete = [decoder decodeBoolForKey:mLevel11];
	}
	return self;
}

@end
