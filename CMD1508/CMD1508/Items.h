//
//  Items.h
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface Items : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (nonatomic, strong)NSString *item;
@property (nonatomic, strong)NSString *qty;
@property (nonatomic, strong)PFUser *user;

@end
