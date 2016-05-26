//
//  AlertsViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface AlertsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet UITableView *alertTableView;
@property (nonatomic, weak) IBOutlet UILabel *activationLabel;

@end
