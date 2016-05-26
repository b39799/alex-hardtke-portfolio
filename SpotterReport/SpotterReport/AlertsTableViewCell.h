//
//  AlertsTableViewCell.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *alertTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *alertTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *alertLocationLabel;

@end
