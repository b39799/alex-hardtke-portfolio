//
//  AlertDetailViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *alertDetailType;
@property (nonatomic, weak) IBOutlet UILabel *alertDetailLocation;
@property (nonatomic, weak) IBOutlet UILabel *alertDetailTime;
@property (nonatomic, weak) IBOutlet UITextView *alertDetailDescription;

@property (nonatomic, copy) NSString *typeStr;
@property (nonatomic, copy) NSString *locationStr;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, copy) NSString *descriptionStr;


@end
