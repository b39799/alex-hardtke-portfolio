//
//  ViewController.m
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "MainViewController.h"
#import "Reachability.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// Check network status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
	
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
			// User has not logged in yet
			return;
		} else {
			PFUser *currentUser = [PFUser currentUser];
			if (currentUser) {
				// Signed in, so go to main app
				UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
				MainViewController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
				[[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainController];
			}
		}
	}
	
}

-(void)networkUpdated:(NSNotification *)notification {
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	
	if (networkStatus == NotReachable) {
		UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not connected to the internet. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[notConnectedAlert show];
	} else if (networkStatus == ReachableViaWiFi) {
		UIAlertView *wifiConnectedAlert = [[UIAlertView alloc] initWithTitle:@"WiFi Connected" message:@"You have a WiFi connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[wifiConnectedAlert show];
	}
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)onClick:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	
	if (button.tag == 1) {
		// Sign Up Button clicked
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			PFUser *user = [PFUser user];
			user.username = usernameText.text;
			user.password = passwordText.text;
			
			// Validate sign up info
			if ([usernameText.text  isEqual: @""] && [passwordText.text  isEqual: @""]) {
				UIAlertView *fillOutFormAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out the form to sign up." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[fillOutFormAlert show];
			} else {
				
				if (usernameText.text.length >= 4 && usernameText.text.length <=10 && passwordText.text.length >= 8 && passwordText.text.length <=12) {
					// Valid!
					
					[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (!error) {
							// Successful Sign up
							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Sign Up Successful! Please Log In to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
							[alert show];
							
						} else {
							// Sign up failed
							NSString *errorString = [error userInfo][@"error"];
							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
							[alert show];
							
						}
					}];
				}
				
				if (usernameText.text.length < 4 || usernameText.text.length > 10) {
					// Username text length is incorrect.
					UIAlertView *usernameErrorAlert = [[UIAlertView alloc] initWithTitle:@"Username Error" message:@"The username you have entered must be 4 to 10 characters in length." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[usernameErrorAlert show];
				}
				
				if (passwordText.text.length < 8 || passwordText.text.length > 12) {
					// Password text length is incorrect.
					UIAlertView *passwordErrorAlert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"The password you have entered must be 8 to 12 characters in length." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[passwordErrorAlert show];
				}
			}
			
			
		} else if (networkStatus == NotReachable){
			// No connection
			UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[noConnectionAlert show];
		}
		
	} else if (button.tag == 0) {
		// Log In Button clicked
		
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			[PFUser logInWithUsernameInBackground:usernameText.text password:passwordText.text block:^(PFUser *user, NSError *error) {
				NSString *errorString = [error userInfo][@"error"];
				
				if (user) {
					// Successful login
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Log In Successful!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[alert show];
					
					UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
					MainViewController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
					[[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainController];
					
				} else {
					// Login failed
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[alert show];
				}
			}];
		} else if (networkStatus == NotReachable) {
			// No connection
			UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[noConnectionAlert show];
		}
	}
	
}



@end
