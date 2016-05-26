//
//  Level.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/3/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject

@property (nonatomic, assign) NSUInteger enemySpeedMax;
@property (nonatomic, assign) NSUInteger enemySpeedMin;
@property (nonatomic, assign) NSUInteger killsRequired;
@property (nonatomic, assign) NSUInteger totalAsteroids;
@property (nonatomic, assign) NSUInteger levelNumber;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) NSString *fileName;

- (instancetype)initWithFile:(NSString*)filename;

@end
