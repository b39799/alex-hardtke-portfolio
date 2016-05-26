//
//  SaveData.h
//  MGD1509
//
//  Created by Alex Hardtke on 10/8/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <Parse/Parse.h>
#import "PlayerData.h"
#import <Parse/PFObject+Subclass.h>

@interface SaveData : PFObject<PFSubclassing>

+ (NSString*)parseClassName;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) NSInteger careerScore;

@property (nonatomic, assign) NSInteger availableShips;
@property (nonatomic, assign) NSInteger availableLasers;
@property (nonatomic, assign) NSInteger levelsCompleted;
@property (nonatomic, strong) NSString *shipName;
@property (nonatomic, strong) NSString *laserName;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, assign) BOOL level1Complete;
@property (nonatomic, assign) BOOL level2Complete;
@property (nonatomic, assign) BOOL level3Complete;
@property (nonatomic, assign) BOOL level4Complete;
@property (nonatomic, assign) BOOL level5Complete;
@property (nonatomic, assign) BOOL level6Complete;
@property (nonatomic, assign) BOOL level7Complete;
@property (nonatomic, assign) BOOL level8Complete;
@property (nonatomic, assign) BOOL level9Complete;
@property (nonatomic, assign) BOOL level10Complete;
@property (nonatomic, assign) BOOL level11Complete;

@end
