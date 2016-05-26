//
//  NewReportViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "NewReportViewController.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "Reports.h"

@interface NewReportViewController ()


@end

@implementation NewReportViewController {
	NSString *stormTypeID, *currentCityStr, *currentStateStr;
	BOOL damage, injuries;
	Reports *thisReport;
	NSUserDefaults *userDefaults;
}
@synthesize image;

-(void)viewDidAppear:(BOOL)animated {
	
	// Check network status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
	
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
			// User has not logged in yet, ask to sign in or sign up
			NSLog(@"Not logged in");
			[self logInUser];
		} else {
			PFUser *currentUser = [PFUser currentUser];
			if (currentUser) {
				// Signed in, so continue using report form
				NSLog(@"Logged In");
				return;
			}
		}
	}
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	[locationManager startUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[locationManager requestWhenInUseAuthorization];
	}
	
	[locationManager startUpdatingLocation];
	
	[self getUserLocation];
	
	
	// Set labels
	PFUser *currentUser = [PFUser currentUser];
	self.spotterNameLabel.text = currentUser.username;
	
	// Set date
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"MM-dd-yyyy"];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	self.dateTextField.text = [dateFormatter stringFromDate:date];
	
	// Hide date picker from view
	self.datePicker.hidden = YES;
	self.datePickerToolbar.hidden = YES;
	[self.dateTextField setDelegate:self];
	
	// Init new report PFObject
	thisReport = [Reports object];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)textFieldPressed:(id)sender {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"MM-dd-yyyy"];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	self.dateTextField.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]];
	_datePicker.hidden = NO;
	_datePickerToolbar.hidden = NO;
	_signOutButton.hidden = YES;
}

-(IBAction)datePickerChanged:(id)sender {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"MM-dd-yyyy"];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	self.dateTextField.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]];
}

-(IBAction)closeDatePicker:(id)sender {
	_datePicker.hidden = YES;
	_datePickerToolbar.hidden = YES;
	_signOutButton.hidden = NO;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getUserLocation {
	
	// Get user location
	
//	// Create Location Manager
//	locationManager = [[CLLocationManager alloc] init];
//	if (locationManager != nil) {
//		locationManager.delegate = self;
//		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//	}
//	
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//		[locationManager requestWhenInUseAuthorization];
//	}
	
	// Get user coordinates
	CLLocation *location = [locationManager location];
	
	CLLocationCoordinate2D coord;
	coord.latitude = location.coordinate.latitude;
	coord.longitude = location.coordinate.longitude;
	coord = [location coordinate];
	
	// Get the nearest city based on user's location
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = [placemarks objectAtIndex:0];
		//NSLog(@"User placemark: %@", placemark);
		
		//NSString *placeName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
		currentCityStr = placemark.locality;
		currentStateStr = placemark.administrativeArea;
		NSLog(@"User current state: %@", currentStateStr);
		NSLog(@"User current city: %@", currentCityStr);
		
		self.spotterLocationLabel.text = [NSString stringWithFormat:@"%@, %@", currentCityStr, currentStateStr];
		
	}];
	
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	//NSLog(@"%@", [locations lastObject]);
	if (currentCityStr == nil) {
		[self getUserLocation];
	}
	//[self getUserLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"LocationManager Failed: %@", error);
	[self getUserLocation];
}



// Select Image

-(IBAction)selectImage:(UIButton *)sender {
	
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.delegate = self;
	imgPicker.allowsEditing = NO;
	imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:imgPicker animated:YES completion:nil];
	
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	
	UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
	self.imageView.image = selectedImage;
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}



// Segment Controllers

-(IBAction)mesoSegmentIndexChanged:(UISegmentedControl *)sender {
	
	switch (_mesoTypeSegControl.selectedSegmentIndex) {
		case 0:
			if (_severeTypeSegControl != nil) {
				[_severeTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Tornado
			stormTypeID = @"Tornado";
			thisReport.stormType = @"Tornado";
			break;
		case 1:
			if (_severeTypeSegControl != nil) {
				[_severeTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Funnel Cloud
			stormTypeID = @"FunnelCloud";
			thisReport.stormType = @"Funnel Cloud";
			break;
		case 2:
			if (_severeTypeSegControl != nil) {
				[_severeTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Wall Cloud
			stormTypeID = @"WallCloud";
			thisReport.stormType = @"Wall Cloud";
			[self showStormTypeAlertPopup];
			break;
		default:
			break;
	}
	
	
	switch (_injurySegControl.selectedSegmentIndex) {
  case 0:
			injuries = NO;
			break;
		case 1:
			injuries = YES;
			break;
			
  default:
			break;
	}
}

-(IBAction)severeSegmentIndexChanged:(UISegmentedControl *)sender {
	
	switch (_severeTypeSegControl.selectedSegmentIndex) {
  case 0:
			if (_mesoTypeSegControl != nil) {
				[_mesoTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Hail
			stormTypeID = @"Hail";
			thisReport.stormType = @"Hail";
			[self showStormTypeAlertPopup];
			break;
		case 1:
			if (_mesoTypeSegControl != nil) {
				[_mesoTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Wind
			stormTypeID = @"Wind";
			thisReport.stormType = @"Wind";
			[self showStormTypeAlertPopup];
			break;
		case 2:
			if (_mesoTypeSegControl != nil) {
				[_mesoTypeSegControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
			}
			// Flood
			stormTypeID = @"Flood";
			thisReport.stormType = @"Flood";
			[self showStormTypeAlertPopup];
			break;
			
  default:
			break;
	}
}

-(IBAction)damageSegmentIndexChanged:(UISegmentedControl *)sender {
	
	switch (_damageSegControl.selectedSegmentIndex) {
  case 0:
			damage = YES;
			break;
		case 1:
			damage = NO;
			break;
			
  default:
			break;
	}
}

-(IBAction)injuriesSegmentIndexChanged:(UISegmentedControl *)sender {
	
	switch (_injurySegControl.selectedSegmentIndex) {
  case 0:
			injuries = YES;
			break;
		case 1:
			injuries = NO;
			break;
			
  default:
			break;
	}
}



-(void)showStormTypeAlertPopup {
	
	if ([stormTypeID isEqualToString:@"WallCloud"]) {
		
		UIAlertController *stormTypeAlertController = [UIAlertController alertControllerWithTitle:@"Wall Cloud" message:@"Is the Wall Cloud rotating?:" preferredStyle:UIAlertControllerStyleActionSheet];
//		if ([stormTypeAlertController respondsToSelector:@selector(popoverPresentationController)]) {
//			stormTypeAlertController.popoverPresentationController.sourceView = self.view;
//		}
		
		UIAlertAction *rotating = [UIAlertAction actionWithTitle:@"Rotating" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"Rotating";
		}];
		
		UIAlertAction *notRotating = [UIAlertAction actionWithTitle:@"Not Rotating" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"Not Rotating";
		}];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			// Save input
			
			thisReport.stormType = @"Wall Cloud";
			
			[stormTypeAlertController dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[stormTypeAlertController addAction:rotating];
		[stormTypeAlertController addAction:notRotating];
		[stormTypeAlertController addAction:ok];
		
		stormTypeAlertController.modalPresentationStyle = UIModalPresentationPopover;
		[self presentViewController:stormTypeAlertController animated:YES completion:nil];
		
		UIPopoverPresentationController *presCont = [stormTypeAlertController popoverPresentationController];
		presCont.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
		presCont.sourceView = self.view;
		presCont.sourceRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0);
		
	} else if ([stormTypeID isEqualToString:@"Hail"]) {
		
		UIAlertController *stormTypeAlertController = [UIAlertController alertControllerWithTitle:@"Hail" message:@"Size:" preferredStyle:UIAlertControllerStyleActionSheet];
		
		UIAlertAction *small = [UIAlertAction actionWithTitle:@"0.75\" (Penny)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"0.75\" (Penny)";
		}];
		
		UIAlertAction *medium = [UIAlertAction actionWithTitle:@"1.00\" (Quarter)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"1.00\" (Quarter)";
		}];
		
		UIAlertAction *large = [UIAlertAction actionWithTitle:@"1.75\" (Golf Ball)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"1.75\" (Golf Ball)";
		}];
		
		UIAlertAction *larger = [UIAlertAction actionWithTitle:@"2.00\"+ (Please specify in observations)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"2.00\"+ (Please see observations)";
		}];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			// Save input
			
			thisReport.stormType = @"Hail";
			
			[stormTypeAlertController dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[stormTypeAlertController addAction:small];
		[stormTypeAlertController addAction:medium];
		[stormTypeAlertController addAction:large];
		[stormTypeAlertController addAction:larger];
		[stormTypeAlertController addAction:ok];
		
		stormTypeAlertController.modalPresentationStyle = UIModalPresentationPopover;
		[self presentViewController:stormTypeAlertController animated:YES completion:nil];
		
		UIPopoverPresentationController *presCont = [stormTypeAlertController popoverPresentationController];
		presCont.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
		presCont.sourceView = self.view;
		presCont.sourceRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0);
		
	} else if ([stormTypeID isEqualToString:@"Wind"]) {
		
		UIAlertController *stormTypeAlertController = [UIAlertController alertControllerWithTitle:@"Wind" message:@"Please do NOT report winds under 50 MPH:" preferredStyle:UIAlertControllerStyleActionSheet];
		
		UIAlertAction *low = [UIAlertAction actionWithTitle:@"50 mph (Minimal Damage)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"50 mph (Minimal Damage)";
		}];
		
		UIAlertAction *medium = [UIAlertAction actionWithTitle:@"60 mph (<2\" Branches Broken)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"60 mph (<2\" Branches Broken)";
		}];
		
		UIAlertAction *high = [UIAlertAction actionWithTitle:@"70 mph (2\"-4\" Branches Broken)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"70 mph (2\"-4\" Branches Broken)";
		}];
		
		UIAlertAction *extreme = [UIAlertAction actionWithTitle:@"80+ mph (Significant Damage)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			thisReport.stormTypeDetail1 = @"80+ mph (Significant Damage)";
		}];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			// Save input
			
			thisReport.stormType = @"Wind";
			
			[stormTypeAlertController dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[stormTypeAlertController addAction:low];
		[stormTypeAlertController addAction:medium];
		[stormTypeAlertController addAction:high];
		[stormTypeAlertController addAction:extreme];
		[stormTypeAlertController addAction:ok];
		
		stormTypeAlertController.modalPresentationStyle = UIModalPresentationPopover;
		[self presentViewController:stormTypeAlertController animated:YES completion:nil];
		
		UIPopoverPresentationController *presCont = [stormTypeAlertController popoverPresentationController];
		presCont.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
		presCont.sourceView = self.view;
		presCont.sourceRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0);
		
	} else if ([stormTypeID isEqualToString:@"Flood"]) {
		
		UIAlertController *stormTypeAlertController = [UIAlertController alertControllerWithTitle:@"Flood" message:@"Please describe in observations." preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			// Save input
			
			thisReport.stormType = @"Flood";
			
			[stormTypeAlertController dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[stormTypeAlertController addAction:ok];
		
		stormTypeAlertController.modalPresentationStyle = UIModalPresentationPopover;
		[self presentViewController:stormTypeAlertController animated:YES completion:nil];
		
		UIPopoverPresentationController *presCont = [stormTypeAlertController popoverPresentationController];
		presCont.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
		presCont.sourceView = self.view;
		presCont.sourceRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0);
		
	}
}

// Date Picker





// SAVE REPORT

-(void)saveReport {
	
	// User
	PFUser *currentUser = [PFUser currentUser];
	thisReport.user = currentUser;
	
	
	
	// Date
	thisReport.date = self.dateTextField.text;
	
	// Damage
	if (damage == YES) {
		thisReport.damage = @"YES";
	} else if (damage == NO) {
		thisReport.damage = @"NO";
	}
	
	// Image
	if (injuries == YES) {
		thisReport.injuries = @"YES";
	} else if (injuries == NO) {
		thisReport.injuries = @"NO";
	}
	
	// Observations
	thisReport.observations = self.descriptionTextView.text;
	
	// Location
	thisReport.location = [NSString stringWithFormat:@"%@, %@", currentCityStr, currentStateStr];
	
	// Image
	if (self.imageView.image != nil) {
		NSLog(@"Image!");
		
		NSData *imgData = UIImagePNGRepresentation(self.imageView.image);
		PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", thisReport.user.username] data:imgData];
		[imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if (!error) {
				if (succeeded) {
					PFObject *photo = [PFObject objectWithClassName:@"ReportImage"];
					[photo setObject:imageFile forKey:@"image"];
					
					[photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
						if (!error) {
							NSLog(@"Saved Image");
							thisReport.imageFile = imageFile;
						} else {
							NSLog(@"Error: %@ %@", error, [error userInfo]);
						}
					}];
				}
			}
		}];
		thisReport.imageFile = imageFile;
		
	}
	
	
	// Save in background
	[thisReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if (succeeded) {
			// Report saved!
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			// Error saving report
			NSLog([NSString stringWithFormat:@"Error: %@", error.description], error.description);
		}
	}];
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


// Parse sign up/ sign in

-(void)logInUser {
	
	UIAlertController *parseAlert = [UIAlertController alertControllerWithTitle:@"Log In/ Sign Up" message:@"Please log in or sign up to continue." preferredStyle:UIAlertControllerStyleAlert];
	
	[parseAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Username (4 to 10 characters)";
	}];
	
	[parseAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Password (8 to 12 characters)";
		textField.secureTextEntry = YES;
	}];
	
	UIAlertAction *logIn = [UIAlertAction actionWithTitle:@"Log In" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		// Handle log in
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			[PFUser logInWithUsernameInBackground:parseAlert.textFields[0].text password:parseAlert.textFields[1].text block:^(PFUser *user, NSError *error) {
				NSString *errorStr = [error userInfo][@"error"];
				
				if (user) {
					// Log in successful
					self.spotterNameLabel.text = [user username];
					[parseAlert dismissViewControllerAnimated:YES completion:nil];
				} else {
					// Log in failed
					UIAlertController *logInAlert = [UIAlertController alertControllerWithTitle:@"Error" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
						[self logInUser];
					}];
					[logInAlert addAction:ok];
					[self presentViewController:logInAlert animated:YES completion:nil];
				}
			}];
		} else if (networkStatus == NotReachable) {
			// No connection
			UIAlertController *noConnectionAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Internet connection. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				[noConnectionAlert dismissViewControllerAnimated:YES completion:nil];
			}];
			[noConnectionAlert addAction:ok];
			[self presentViewController:noConnectionAlert animated:YES completion:nil];
		}
		
	}];
	
	UIAlertAction *signUp = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		// Handle sign up
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			PFUser *user = [PFUser user];
			user.username = parseAlert.textFields[0].text;
			user.password = parseAlert.textFields[1].text;
			
			// Validate sign up info
			if ([parseAlert.textFields[0].text isEqualToString:@""] && [parseAlert.textFields[1].text isEqualToString:@""]) {
				// Both text fields are empty. Alert the user to fill out the form.
				UIAlertController *emptyAlert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please fill out the form to sign up." preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
					[emptyAlert dismissViewControllerAnimated:YES completion:nil];
				}];
				[emptyAlert addAction:ok];
				[self presentViewController:emptyAlert animated:YES completion:nil];
			} else {
				// The user has entered something into the textfields, so check if it's valid
				
				if (parseAlert.textFields[0].text.length >= 4 && parseAlert.textFields[0].text.length <=10 && parseAlert.textFields[1].text.length >= 8 && parseAlert.textFields[1].text.length <=12) {
					
					// Valid!
					
					[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (!error) {
							// Successful sign up
							
							[parseAlert dismissViewControllerAnimated:YES completion:nil];
						} else {
							// Sign up failed
							NSString *errorStr = [error userInfo][@"error"];
							UIAlertController *signUpFailedAlert = [UIAlertController alertControllerWithTitle:@"Error" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
							UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
								[signUpFailedAlert dismissViewControllerAnimated:YES completion:nil];
							}];
							[signUpFailedAlert addAction:ok];
							[self presentViewController:signUpFailedAlert animated:YES completion:nil];
						}
					}];
				}
				
				if (parseAlert.textFields[0].text.length < 4 || parseAlert.textFields[0].text.length > 10) {
					// Username entry is too short or too long
					UIAlertController *usernameAlert = [UIAlertController alertControllerWithTitle:@"Username Error" message:@"Your username must be 4 to 10 characters in length." preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
						[usernameAlert dismissViewControllerAnimated:YES completion:nil];
					}];
					[usernameAlert addAction:ok];
					[self presentViewController:usernameAlert animated:YES completion:nil];
				}
				
				if (parseAlert.textFields[1].text.length < 8 || parseAlert.textFields[1].text.length > 12) {
					// Password entry is too short or too long
					UIAlertController *passwordAlert = [UIAlertController alertControllerWithTitle:@"Password Error" message:@"Your password must be 8 to 12 characters in length." preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
						[passwordAlert dismissViewControllerAnimated:YES completion:nil];
					}];
					[passwordAlert addAction:ok];
					[self presentViewController:passwordAlert animated:YES completion:nil];
				}
			}
		} else if (networkStatus == NotReachable) {
			// No connection
			UIAlertController *noConnectionAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Internet connection. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[noConnectionAlert dismissViewControllerAnimated:YES completion:nil];
			}];
			[noConnectionAlert addAction:ok];
			[self presentViewController:noConnectionAlert animated:YES completion:nil];
		}
		
	}];
	[parseAlert addAction:logIn];
	[parseAlert addAction:signUp];
	[self presentViewController:parseAlert animated:YES completion:nil];
	
}

-(IBAction)logOutUser:(id)sender {
	[PFUser logOut];
	[self logInUser];
}

-(IBAction)saveReportButton:(id)sender {
	[self saveReport];
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)editDateTimePressed:(id)sender {
	UIButton *button = (UIButton *)sender;
		
	UIViewController *datePickerViewController = [[UIViewController alloc] init];
	UIView *datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	
	self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	self.datePicker.hidden = NO;
	self.datePicker.date = [NSDate date];
	[self.datePicker addTarget:self action:@selector(formatDate:) forControlEvents:UIControlEventValueChanged];
	
	[datePickerView addSubview:self.datePicker];
	[datePickerViewController.view addSubview:datePickerView];
	datePickerViewController.modalPresentationStyle = UIModalPresentationPopover;
	datePickerViewController.popoverPresentationController.sourceView = self.view;
	datePickerViewController.popoverPresentationController.sourceRect = button.frame;
	[self presentViewController:datePickerViewController animated:YES completion:nil];


}

@end
