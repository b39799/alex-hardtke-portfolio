//
//  AlertsViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "AlertsViewController.h"
#import "AlertsTableViewCell.h"
#import "AlertDetailViewController.h"

static NSString const *APIKEY = @"9da38a29e3df266c";

@implementation AlertsViewController{
	NSMutableArray *alertsTableData;
	NSString *alertType;
	
	BOOL hasAlerts;
	
	CLLocation *location;
	NSString *currentCityStr, *currentStateStr;
	
	UIActivityIndicatorView *activityInd;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	hasAlerts = NO;
	
	// Start activity indicator
	activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityInd.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 + 100);
	[self.view addSubview:activityInd];
	[activityInd startAnimating];
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[_locationManager requestWhenInUseAuthorization];
	}
	
	[_locationManager startUpdatingLocation];
	

	
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	//[_locationManager startUpdatingLocation];
}

-(void)getUserLocation {
	
	
	// Get user coordinates
	location = [_locationManager location];
	
	CLLocationCoordinate2D coord;
	coord.latitude = location.coordinate.latitude;
	coord.longitude = location.coordinate.longitude;
	coord = [location coordinate];
	
	// Get the nearest city based on user's location
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		
		if (!error) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			//NSLog(@"User placemark: %@", placemark);
			
			currentStateStr = placemark.administrativeArea;
			NSString *cityStr = placemark.locality;
			currentCityStr = [cityStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
			NSLog(@"User current state: %@", currentStateStr);
			NSLog(@"User current city: %@", currentCityStr);
			
			if (placemark != nil) {
				[self getAlerts];
			}
		}
		
	}];
	
	[activityInd stopAnimating];
	
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	//NSLog(@"%@", [locations lastObject]);
	
	[self getUserLocation];
	[_locationManager stopUpdatingLocation];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"LocationManager Failed: %@", error);
	
	if (currentCityStr == nil) {
		[self getUserLocation];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [alertsTableData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"AlertCell";
	
	AlertsTableViewCell *alertCell = (AlertsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	alertCell.tag = indexPath.row;
	
	if (alertCell == nil) {
		alertCell = [[AlertsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	NSString *alertTypeStr = [alertsTableData objectAtIndex:indexPath.row][1];
	NSString *alertTimeStr = [alertsTableData objectAtIndex:indexPath.row][0];
	
	NSLog(@"AlertType = %@", alertTypeStr);
	NSLog(@"AlertTime = %@", alertTimeStr);
	
	
	alertCell.alertTypeLabel.text = alertTypeStr;
	if (currentCityStr != nil) {
		alertCell.alertLocationLabel.text = [NSString stringWithFormat:@"%@, %@", currentCityStr, currentStateStr];
	}
	alertCell.alertTimeLabel.text = alertTimeStr;
	
	
	[activityInd stopAnimating];
	return alertCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	return 100;
}



// Get JSON Alerts from Wunderground API
-(void)getAlerts {
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/alerts/q/%@/%@.json", APIKEY, currentStateStr, currentCityStr]];
	
	NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]
									  dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
										  
										  if (data != nil) {
											  [self getJSONWIthData:data];
										  }
										  
										  if (error != nil) {
											  NSLog(@"Error: %@", error);
										  }
									  }];
	
	[dataTask resume];
}


-(NSMutableArray *)getJSONWIthData:(NSData*)data {
	
	NSError *error = nil;
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
	
	if (!error) {
		NSLog(@"Alert Data: %@", dictionary);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSArray *alertArr = [dictionary objectForKey:@"alerts"];
			if (![alertArr containsObject:@"date"]) {
				[self showAlert];
			}
			
			for (NSDictionary *alert in alertArr) {
				NSString *dateStr = [alert objectForKey:@"date"];
				NSString *titleStr = [alert objectForKey:@"description"];
				NSString *messageStr = [alert objectForKey:@"message"];
				
				NSArray *alertItem = [NSArray arrayWithObjects:dateStr, titleStr, messageStr, nil];
				
				alertsTableData = [NSMutableArray arrayWithObject:alertItem];
				NSLog(@"alertsTableData = %@", alertsTableData);
				[_alertTableView reloadData];
				
				hasAlerts = YES;
			}
		});
		
		
	} else {
		hasAlerts = NO;
	}
	
	if (hasAlerts == YES) {
		self.activationLabel.text = @"Spotter Activation Requested";
		self.activationLabel.textColor = [UIColor redColor];
	} else if (hasAlerts == NO) {
		NSLog(@"*****");
		self.activationLabel.text = @"No Spotter Activation Requested";
		self.activationLabel.textColor = [UIColor blackColor];
	}
	
	NSLog(@"HAS ALERTS: %hhd", hasAlerts);
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:hasAlerts forKey:@"Activation"];
	[userDefaults synchronize];
	
	if (error) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem loading alert data. Please try again." preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[alert dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[alert addAction:ok];
		[self presentViewController:alert animated:YES completion:nil];
	}
	return alertsTableData;
}

-(void)showAlert {
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Alerts" message:@"There are no active watches or warnings for your area." preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[alert addAction:ok];
	[self presentViewController:alert animated:YES completion:nil];
}




// Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"AlertDetailSegue"]) {
		AlertDetailViewController *alertDetailVC = [segue destinationViewController];
		alertType = [alertsTableData objectAtIndex:[sender tag]][1];
		alertDetailVC.typeStr = alertType;
		alertDetailVC.locationStr = @"";
		alertDetailVC.timeStr = [alertsTableData objectAtIndex:[sender tag]][0];
		alertDetailVC.descriptionStr = [alertsTableData objectAtIndex:[sender tag]][2];
		//alertDetailVC.descriptionStr = @"A weather hazard is in effect for your area until 8:00 PM. Seek shelter immediately. The safest place to be during a storm is an interior room on the lowest level of a sturdy building.";
		NSLog(@"alertType: %@", alertType);
	}
}

-(IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {

}

@end
