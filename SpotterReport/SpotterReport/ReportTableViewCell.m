//
//  ReportTableViewCell.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "ReportTableViewCell.h"

@implementation ReportTableViewCell
@synthesize reportTypeLabel = _reportTypeLabel;
@synthesize reportTimeLabel = _reportTimeLabel;
@synthesize reportLocationLabel = _reportLocationLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
