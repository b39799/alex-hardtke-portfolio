//
//  ReportDetailViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reports.h"

@interface ReportDetailViewController : UIViewController {
	IBOutlet UIBarButtonItem *shareButton;
}

@property (nonatomic, weak) IBOutlet UILabel *reportDetailType;
@property (nonatomic, weak) IBOutlet UILabel *reportDetailType2;
@property (nonatomic, weak) IBOutlet UILabel *damageDetail;
@property (nonatomic, weak) IBOutlet UILabel *injuryDetail;
@property (nonatomic, weak) IBOutlet UILabel *reportDetailLocation;
@property (nonatomic, weak) IBOutlet UILabel *reportDetailTime;
@property (nonatomic, weak) IBOutlet UITextView *reportDetailDescription;
@property (nonatomic, weak) IBOutlet UIImageView *reportImageView;



@property (nonatomic, strong) Reports *report;

@end
