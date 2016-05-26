//
//  Level.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "Level.h"
#import "GameScene.h"

@implementation Level

- (instancetype)initWithFile:(NSString *)filename {
	
	self = [super init];
	if (self != nil) {
		
		NSDictionary *dictionary = [self loadJSONFile:filename];
		
		// Assign values for the level
		self.enemySpeedMax = [dictionary[@"enemySpeedMax"] unsignedIntegerValue];
		self.enemySpeedMin = [dictionary[@"enemySpeedMin"] unsignedIntegerValue];
		self.killsRequired = [dictionary[@"killsRequired"] unsignedIntegerValue];
		self.totalAsteroids = [dictionary[@"totalAsteroids"] unsignedIntegerValue];
		self.levelNumber = [dictionary[@"levelNumber"] unsignedIntegerValue];
		self.isCompleted = [dictionary[@"isCompleted"] boolValue];
		self.fileName = filename;
		
	}
	
	return self;
	
}

- (NSDictionary*)loadJSONFile:(NSString*)filename {
	
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
	if (path == nil) {
		NSLog(@"File path failed: %@", filename);
		return nil;
	}
	
	NSError *error;
	NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
	if (data == nil) {
		NSLog(@"File data failed: %@. Error: %@", filename, error);
		return nil;
	}
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
		NSLog(@"File dictionary failed: %@. Error: %@", filename, error);
		return nil;
	}
	
	return dictionary;
	
}

@end
