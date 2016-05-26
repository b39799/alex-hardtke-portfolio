//
//  Reports.h
//  SpotterReport
//
//  Created by Alex Hardtke on 3/11/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <Parse/Parse.h>

@interface Reports : PFObject<PFSubclassing>
+(NSString*)parseClassName;

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *stormType;
@property (nonatomic, strong) NSString *stormTypeDetail1;
@property (nonatomic, strong) NSString *stormTypeDetail2;
@property (nonatomic, strong) NSString *damage;
@property (nonatomic, strong) NSString *injuries;
@property (nonatomic, strong) NSString *observations;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFUser *user;


@end
