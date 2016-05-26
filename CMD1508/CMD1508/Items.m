//
//  Items.m
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "Items.h"
#import <Parse/PFObject+Subclass.h>

@implementation Items
@dynamic item, qty, user;

+ (void)load {
	[self registerSubclass];
}

+ (NSString *)parseClassName {
	
	return @"Items";
}

@end
