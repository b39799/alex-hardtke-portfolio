//
//  AlertsTableViewCell.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "AlertsTableViewCell.h"

@implementation AlertsTableViewCell
@synthesize alertTypeLabel = _alertTypeLabel;
@synthesize alertTimeLabel = _alertTimeLabel;
@synthesize alertLocationLabel = _alertLocationLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
