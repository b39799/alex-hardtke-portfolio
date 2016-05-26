//
//  FirstViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/24/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "FirstViewController.h"
#import "Reachability.h"
#import "NewReportViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MPM 1609.344

static NSString const *APIKEY = @"9da38a29e3df266c";
static BOOL mapChanged = NO;

@interface FirstViewController ()

@end

@implementation FirstViewController {
	
	NSUserDefaults *userDefaults;
	BOOL isFarenheit, firstLoad, isUpdatingLocation;
	CLLocation *location;
	MKCoordinateRegion mapRegion;
	NSString *currentCityStr;
	NSString *currentStateStr;
	NSString *maxLat, *maxLon, *minLat, *minLon;
	int screenShotCount;
	float opacityValue;
	NSData *imageData;
	
	UIActivityIndicatorView *activityInd;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Start Location Manager
	//[_locationManager startUpdatingLocation];
	NSLog(@"ViewWillAppear start");
	
	_radarImg.image = nil;

	// Check user defaults
	userDefaults = [NSUserDefaults standardUserDefaults];
	if (userDefaults != nil) {
		
		NSLog(@"HAS USERDEFAULTS **");
		
		if ([userDefaults boolForKey:@"TempFC"] == YES) {
			// User default is F
			// If it's already F, do nothing. If it's C, tempChanged.
			isFarenheit = YES;
			
		} else if ([userDefaults boolForKey:@"TempFC"] == NO){
			// User default is C
			// If it's already C, do nothing. If it's F, tempChanged.
			isFarenheit = NO;
		}
		
		NSLog(@"Default temp: %hhd", [userDefaults boolForKey:@"TempFC"]);
		NSLog(@"Default opacity: %d", [userDefaults integerForKey:@"Opacity"]);
		
		if ([userDefaults integerForKey:@"Opacity"]) {
			int rounded = [userDefaults integerForKey:@"Opacity"];
			opacityValue = rounded;
		}
		
		[self getCurrentTemp];
		
		//isFarenheit = [userDefaults boolForKey:@"TempFC"];
	} else {
		// If no user defaults, set the default Temp to Farenheit & Opacity to 60
		isFarenheit = YES;
		opacityValue = 60;
	}
	
	if (location != nil) {
		if (isUpdatingLocation) {
			[self getUserLocation];
		} else {
			[_locationManager startUpdatingLocation];
			isUpdatingLocation = YES;
		}
		[self calculateMapBounds];
		[self getRadarImage];
	}

}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
	if (firstLoad) {
		firstLoad = NO;
		
		// Alert the user about the New Report on Touch functionality
		UIAlertController *newReportAlert = [UIAlertController alertControllerWithTitle:@"Location Specific Reports" message:@"To submit a location-specific report, touch and hold the location for about two seconds." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[newReportAlert dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[newReportAlert addAction:ok];
		[self presentViewController:newReportAlert animated:YES completion:nil];
	}
	
}


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"ViewDidLoad");
	
	firstLoad = YES;
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[_locationManager requestWhenInUseAuthorization];
	}
	
	[_locationManager startUpdatingLocation];
	isUpdatingLocation = YES;
	NSLog(@"Updating Location...");
	
	

	// Check network status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
	
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		
		// There is an internet connection, so load the map and radar
		_mapView.delegate = self;
		
		
		// Check user defaults
		userDefaults = [NSUserDefaults standardUserDefaults];
		if (userDefaults != nil) {
			
			isFarenheit = [userDefaults boolForKey:@"TempFC"];
			
			if ([userDefaults integerForKey:@"Opacity"]) {
				int rounded = [userDefaults integerForKey:@"Opacity"];
				opacityValue = rounded;
			}
			
		} else {
			// If no user defaults, set the default to Farenheit
			isFarenheit = YES;
			opacityValue = 60;
		}
				
		
		// Set up map - Hybrid, zoom, compass, user location
		_mapView.showsUserLocation = YES;
		_mapView.mapType = MKMapTypeHybrid;
		_mapView.zoomEnabled = YES;
		_mapView.showsCompass = YES;
		[_mapView setShowsPointsOfInterest:NO];
		
		// Set up long-press action to add marker
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
		longPress.minimumPressDuration = 2.0;
		[_mapView addGestureRecognizer:longPress];
		
		// Show user location on map
		MKUserLocation *userLocation = _mapView.userLocation;
		MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 15 * MPM, 15 * MPM);
		[_mapView setRegion:viewRegion animated:YES];
		
		// Start activity indicator
		activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityInd.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 + 100);
		[self.view addSubview:activityInd];
		
		
	} else {
		
		UIAlertController *noConnectionAlert = [UIAlertController alertControllerWithTitle:@"Network Not Found" message:@"You do not have a Network Connection. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[noConnectionAlert dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[noConnectionAlert addAction:ok];
		[self presentViewController:noConnectionAlert animated:YES completion:nil];
		
	}
	
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



// Get user location

-(void)getUserLocation {
	
	
	// Get user coordinates
	
	if (_locationManager != nil) {
		
		location = [_locationManager location];
		
		CLLocationCoordinate2D coord;
		coord.latitude = location.coordinate.latitude;
		coord.longitude = location.coordinate.longitude;
		coord = [location coordinate];
		
		//NSLog(@"Location = %@", location.description);
		
		// Get the nearest city based on user's location
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
			
			if (!error) {
				CLPlacemark *placemark = [placemarks objectAtIndex:0];
				//NSLog(@"User placemark: %@", placemark);
				
				currentCityStr = placemark.locality;
				currentStateStr = placemark.administrativeArea;
				NSLog(@"User current state: %@", currentStateStr);
				NSLog(@"User current city: %@", currentCityStr);
				
				// Set locationLabel
				_locationLabel.text = [NSString stringWithFormat:@"%@, %@", currentCityStr, currentStateStr];
				
				[self calculateMapBounds];
				[self getCurrentTemp];
			} else {
				NSLog(@"UserLocation Error: %@", error);
			}
			
		}];
		
	}
	
	
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	//NSLog(@"%@", [locations lastObject]);

	// Location updated, get location and stopUpdatingLocation
	[self getUserLocation];
	[_locationManager stopUpdatingLocation];
	isUpdatingLocation = NO;
	NSLog(@"Stopped Updating Location");
	
	// Get the bounds of the map
	[self calculateMapBounds];
	NSLog(@"CalculateMapBounds");
	// Get radar image
	[self getRadarImage];
	NSLog(@"GetRadarImage");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"LocationManager Failed: %@", error);
	
	if (currentCityStr == nil) {
		[self getUserLocation];
	}
}




// Long press handler

-(void)mapLongPressed:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
	
	// Add a marker to the map
	CGPoint touchedLocation = [gestureRecognizer locationInView:self.mapView];
	CLLocationCoordinate2D touchedCoord = [self.mapView convertPoint:touchedLocation toCoordinateFromView:self.mapView];
	
	
	UIAlertController *markerReportAlert = [UIAlertController alertControllerWithTitle:@"New Report?" message:@"Do you want to submit a new report?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
		[marker setCoordinate:touchedCoord];
		[marker setTitle:@"Report"];
		[self.mapView addAnnotation:marker];
		
		// Take a screenshot to put in report
		[self takeScreenshot];
		
		// Go to report form
		NewReportViewController *newReportVC = [[NewReportViewController alloc] init];
		UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"NewReportSegue" source:self destination:newReportVC performHandler:^{
			//
			newReportVC.image = _image;
		}];
		if ([segue.identifier isEqualToString:@"NewReportSegue"]) {
			newReportVC = (NewReportViewController *)segue.destinationViewController;
			//newReportVC.image = _image;
			
		}
		
		[self performSegueWithIdentifier:@"NewReportSegue" sender:self];
		//[self presentViewController:newReportVC animated:YES completion:nil];
	}];
	
	UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[markerReportAlert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[markerReportAlert addAction:yes];
	[markerReportAlert addAction:no];
	[self presentViewController:markerReportAlert animated:YES completion:nil];
}



// Screenshot
-(void)takeScreenshot {
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size , NO, [UIScreen mainScreen].scale);
	} else {
		UIGraphicsBeginImageContext(self.view.window.bounds.size);
	}
	
	[self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
	_image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	imageData = UIImagePNGRepresentation(_image);
	
	NSLog(@"screenShot = %@", _image);
	
	
	if (imageData) {
		UIImageWriteToSavedPhotosAlbum(_image, 0, 0, 0);
		//[imgData writeToFile:[NSString stringWithFormat:@"%@.png", currentCityStr] atomically:YES];
	} else {
		NSLog(@"Screenshot Error");
	}
	
}





// Network updated

-(void)networkUpdated:(NSNotification *)notification {
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	
	if (networkStatus == NotReachable) {
		UIAlertController *notReachableAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You are not connected to the internet. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
		[notReachableAlert addAction:ok];
		[self presentViewController:notReachableAlert animated:YES completion:nil];
	} else if (networkStatus == ReachableViaWiFi) {
		UIAlertController *wifiConnectedAlert = [UIAlertController alertControllerWithTitle:@"WiFi Connected" message:@"You now have a WiFi connection." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
		[wifiConnectedAlert addAction:ok];
		[self presentViewController:wifiConnectedAlert animated:YES completion:nil];
	}
}




// Map location update
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	mapView.centerCoordinate = userLocation.location.coordinate;
	
}

-(BOOL)mapRegionChanged {
	UIView *view = self.mapView.subviews.firstObject;
	
	for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
		if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
			return YES;
		}
	}
	
	return NO;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	mapChanged = [self mapRegionChanged];
	
	if (mapChanged) {
		// The user changed the map region so calculate the new bounds and load the new radar image
		dispatch_async(dispatch_get_main_queue(), ^{
			_radarImg.image = nil;
		});
		
	} else {
		[self calculateMapBounds];
		[self getRadarImage];
	}
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	
	if (mapChanged) {
		// The user changed the map region
		[self calculateMapBounds];
		[self getRadarImage];
	}
}

-(void)calculateMapBounds {
	CGPoint nePt = CGPointMake((self.mapView.bounds.origin.x + self.mapView.bounds.size.width), self.mapView.bounds.origin.y);
	CGPoint swPt = CGPointMake(self.mapView.bounds.origin.x, (self.mapView.bounds.origin.y + self.mapView.bounds.size.height));
	
	CLLocationCoordinate2D neCoordinate = [self.mapView convertPoint:nePt toCoordinateFromView:self.mapView];
	CLLocationCoordinate2D swCoordinate = [self.mapView convertPoint:swPt toCoordinateFromView:self.mapView];
	
	maxLat = [NSString stringWithFormat:@"%f", neCoordinate.latitude];
	maxLon = [NSString stringWithFormat:@"%f", neCoordinate.longitude];
	minLat = [NSString stringWithFormat:@"%f", swCoordinate.latitude];
	minLon = [NSString stringWithFormat:@"%f", swCoordinate.longitude];
	
	//[self getRadarImage];
}





// Get Current Temp
-(void)getCurrentTemp {
	
	NSString *cityStr = [currentCityStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	NSLog(@"cityStr = %@", cityStr);
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", APIKEY, currentStateStr, cityStr]];
	
	NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]
	dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		if (data != nil) {
			[self getJSONWIthData:data];
		}
		
		if (error != nil) {
			NSLog(@"CurrentTemp Error: %@", error);
		}
	}];
	
	[dataTask resume];
}





// Get Radar

-(void)getRadarImage {
	
	[activityInd startAnimating];
	
	NSString *width = [NSString stringWithFormat:@"%f", self.mapView.bounds.size.width];
	NSString *height = [NSString stringWithFormat:@"%f", self.mapView.bounds.size.height];
	//NSLog(@"Map Width = %f", self.mapView.bounds.size.width);
	//NSLog(@"Map Height = %f", self.mapView.bounds.size.height);
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/radar/image.png?maxlat=%@&maxlon=%@&minlat=%@&minlon=%@&width=%@&height=%@&rainsnow=1&noclutter=1&reproj.automerc=1&smooth=1", APIKEY, maxLat, maxLon, minLat, minLon, width, height]];
	
	NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
	downloadTaskWithURL:url completionHandler:^(NSURL *locationImg, NSURLResponse *response, NSError *error) {
		
		if (locationImg != nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				UIImage *downloadImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:locationImg]];
				if (_radarImg.image == nil) {
					[_radarImg setImage:downloadImg];
					
					NSString *opacity = [NSString stringWithFormat:@"0.%f", opacityValue];
					NSLog(@"opacity = %f", [opacity floatValue]);
					[_radarImg setAlpha:[opacity floatValue]];
					NSLog(@"Set Radar Img");
				}
				
				[activityInd stopAnimating];
			});
		}
		
		if (error != nil) {
			NSLog(@"Radar Error: %@", error);
			[activityInd stopAnimating];
		}
	}];
	
	[downloadTask resume];
}


// Handle JSON responses from WeatherUnderground API

-(void)getJSONWIthData:(NSData*)data {
	
	NSError *error = nil;
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
	
	if (!error) {
		NSLog(@"Weather Data: %@", dictionary);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isFarenheit) {
				// Farenheit
				_tempLabel.text = [NSString stringWithFormat:@"%@º", [dictionary[@"current_observation"][@"temp_f"]stringValue]];
				
				_dewLabel.text = [NSString stringWithFormat:@"%@º", [dictionary[@"current_observation"][@"dewpoint_f"]stringValue]];
			} else if (!isFarenheit) {
				// Celsius
				_tempLabel.text = [NSString stringWithFormat:@"%@º", [dictionary[@"current_observation"][@"temp_c"]stringValue]];
				_dewLabel.text = [NSString stringWithFormat:@"%@º", [dictionary[@"current_observation"][@"dewpoint_c"]stringValue]];
			}
		});
	} else {
		NSLog(@"Weather Data Error: %@", error);
	}
}

@end
