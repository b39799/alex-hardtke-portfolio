//
//  FirstViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/24/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/Mapkit.h"
#import "Reachability.h"

@interface FirstViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate, NSXMLParserDelegate> {
	Reachability *reachability;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *dewLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *radarImg;

@property (nonatomic, strong) UIImage *image;

@end

