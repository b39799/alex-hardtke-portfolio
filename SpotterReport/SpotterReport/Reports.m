//
//  Reports.m
//  SpotterReport
//
//  Created by Alex Hardtke on 3/11/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "Reports.h"
#import <Parse/PFObject+Subclass.h>

@implementation Reports
@dynamic date, location, stormType, stormTypeDetail1, stormTypeDetail2, damage, injuries, observations, imageFile, user;

+(void)load {
	[self registerSubclass];
}

+(NSString *)parseClassName {
	return @"Reports";
}

@end
