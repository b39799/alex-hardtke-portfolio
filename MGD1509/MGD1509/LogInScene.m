//
//  LogInScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 10/7/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "LogInScene.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "MenuScene.h"

@implementation LogInScene {
	UITextField *userTextField, *passwordTextField;
}

static NSString* const mFontName = @"Futura-CondensedMedium";

- (id) initWithSize:(CGSize)size
{
	
	if (self = [super initWithSize:size]) {
		
		self.backgroundColor = [SKColor blackColor];
		
		SKLabelNode *titleLabel = [[SKLabelNode alloc] initWithFontNamed:mFontName];
		titleLabel.position = CGPointMake(size.width / 2, size.height - [self convertValue:50]);
		titleLabel.text = @"Welcome!";
		titleLabel.name = @"title";
		titleLabel.fontSize = [self convertValue: 24];
		titleLabel.fontColor = [SKColor whiteColor];
		[self addChild:titleLabel];
		
		SKLabelNode *logIn = [[SKLabelNode alloc] initWithFontNamed:mFontName];
		logIn.position = CGPointMake(size.width / 2, [self convertValue:75]);
		logIn.text = @"Log In";
		logIn.name = @"logIn";
		logIn.fontSize = [self convertValue: 22];
		logIn.fontColor = [SKColor blueColor];
		[self addChild:logIn];
		
		SKLabelNode *signUp = [[SKLabelNode alloc] initWithFontNamed:mFontName];
		signUp.position = CGPointMake(size.width / 2, [self convertValue:40]);
		signUp.text = @"Sign Up";
		signUp.name = @"signUp";
		signUp.fontSize = [self convertValue: 22];
		signUp.fontColor = [SKColor yellowColor];
		[self addChild:signUp];
		
	}
	
	return self;
	
}


// UITextField methods

-(void)didMoveToView:(SKView *)view {
	
	
	// Check network status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
			// User has not logged in yet
			
		} else {
			PFUser *currentUser = [PFUser currentUser];
			if (currentUser) {
				[userTextField removeFromSuperview];
				[passwordTextField removeFromSuperview];
				// Signed in already, so skip this scene and go to the maim menu
				SKScene *menuScene = [MenuScene sceneWithSize: self.view.bounds.size];
				menuScene.scaleMode = SKSceneScaleModeAspectFill;
				[self.view presentScene: menuScene];
				return;
			}
		}
	}
	
	
	float centerX = view.frame.size.width / 2;
	float centerY = view.frame.size.height / 2;
	
	CGPoint userPos = CGPointMake(centerX, centerY - [self convertValue:50]);
	CGPoint passPos = CGPointMake(centerX, centerY);
	
	userTextField = [[UITextField alloc] initWithFrame:CGRectMake(centerX - userTextField.frame.size.width / 2, centerY + [self convertValue:75], [self convertValue:200], [self convertValue:35])];
	userTextField.textColor = [UIColor blackColor];
	userTextField.center = userPos;
	userTextField.placeholder = @"Enter username";
	userTextField.font = [UIFont systemFontOfSize:17];
	userTextField.backgroundColor = [UIColor whiteColor];
	userTextField.borderStyle = UITextBorderStyleRoundedRect;
	userTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	userTextField.keyboardType = UIKeyboardTypeDefault;
	userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	userTextField.delegate = self;
	[self.view addSubview:userTextField];
	
	passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(centerX, centerY, [self convertValue:200], [self convertValue:35])];
	passwordTextField.textColor = [UIColor blackColor];
	passwordTextField.center = passPos;
	passwordTextField.placeholder = @"Enter password";
	passwordTextField.font = [UIFont systemFontOfSize:17];
	passwordTextField.backgroundColor = [UIColor whiteColor];
	passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
	passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	passwordTextField.keyboardType = UIKeyboardTypeDefault;
	passwordTextField.secureTextEntry = YES;
	passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	passwordTextField.delegate = self;
	[self.view addSubview:passwordTextField];
}

// Remove the UITextFields from the view
- (void)willMoveFromView:(SKView *)view {
	[userTextField removeFromSuperview];
	[passwordTextField removeFromSuperview];
}

-(void)networkUpdated:(NSNotification *)notification {
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	
	if (networkStatus == NotReachable) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You are not connected to the internet. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
		[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//		UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not connected to the internet. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//		[notConnectedAlert show];
	} else if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wifi Connected" message:@"You have a WiFi connection!" preferredStyle:UIAlertControllerStyleAlert];
		[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//		UIAlertView *wifiConnectedAlert = [[UIAlertView alloc] initWithTitle:@"WiFi Connected" message:@"You have a WiFi connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//		[wifiConnectedAlert show];
	}
}





-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *node = [self nodeAtPoint:location];
	
	if ([node.name isEqualToString:@"logIn"]) {
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			[PFUser logInWithUsernameInBackground:userTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error) {
				
				NSString *errorStr = [error userInfo][@"error"];
				
				if (user) {
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Log in successful!" preferredStyle:UIAlertControllerStyleAlert];
					[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
					// Successful login
//					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Log in successful!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//					[alert show];
					
					// Transition to Menu Scene
					SKAction *menuAction = [SKAction sequence:@[[SKAction waitForDuration:3.0],
																[SKAction runBlock:^{
						SKTransition *trans = [SKTransition fadeWithDuration:2.0];
						SKScene *menuScene = [MenuScene sceneWithSize: self.view.bounds.size];
						[self.view presentScene:menuScene transition: trans];
					}]]];
					[self runAction: menuAction];
					
				} else {
					// Login failed
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
					[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//					[alert show];
				}
				
			}];
		} else if (networkStatus == NotReachable) {
			// No connection
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection" message:@"You are not connected to the internet. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
			[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You have no internet connection. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//			[alert show];
		}
		
	} else if ([node.name isEqualToString:@"signUp"]) {
		
		NetworkStatus networkStatus = [reachability currentReachabilityStatus];
		
		if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
			// Connected
			
			PFUser *user = [PFUser user];
			user.username = userTextField.text;
			user.password = passwordTextField.text;
			
			// Validate sign up info
			if ([userTextField.text isEqualToString:@""] && [passwordTextField.text isEqualToString:@""]) {
				// The user needs to enter a username and password. Alert them to do so.
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please enter a username and password." preferredStyle:UIAlertControllerStyleAlert];
				[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter a username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//				[alert show];
			} else {
				
				if (userTextField.text.length >= 4 && userTextField.text.length <=10 && passwordTextField.text.length >= 5 && passwordTextField.text.length <=12) {
					// Valid!
					
					[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (!error) {
							// Successful sign up
							UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Sign up successful!" preferredStyle:UIAlertControllerStyleAlert];
							[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Sign up successful!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//							[alert show];
						} else {
							// Failed sign up
							NSString *errorStr = [error userInfo][@"error"];
							UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
							[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//							[alert show];
						}
					}];
				}
				
				if (userTextField.text.length < 4 || userTextField.text.length > 10) {
					// Username length is not valid
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Username Error" message:@"Your username must be 4 to 10 characters in length." preferredStyle:UIAlertControllerStyleAlert];
					[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username Error" message:@"Your username must be 4 to 10 characters in length." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//					[alert show];
				}
				
				if (passwordTextField.text.length < 5 || passwordTextField.text.length > 12) {
					// Password length is not valid
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Password Error" message:@"Your password must be 5 to 12 characters in length." preferredStyle:UIAlertControllerStyleAlert];
					[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"Your password must be 4 to 10 characters in length." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//					[alert show];
				}
			}
		} else if (networkStatus == NotReachable) {
			// No connection
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection" message:@"You have no internet connection. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
			[self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"You have no internet connection. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//			[alert show];
		}
	}
	
	
}





// ****** Size Conversion Methods

- (float) convertValue:(float)value {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return value * 2;
	} else {
		return value;
	}
}

- (SKTextureAtlas *) textureAtlasNamed:(NSString *)name {
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		// Phone
		name = name;
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// Pad
		name = [NSString stringWithFormat:@"%@-ipad", name];
	}
	
	SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:name];
	
	return textureAtlas;
}

@end
