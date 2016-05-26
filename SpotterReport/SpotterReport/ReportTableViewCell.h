//
//  ReportTableViewCell.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *reportTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *reportTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *reportLocationLabel;

@end
