//
//  SettingsViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController {
	NSUserDefaults *userDefaults;
	BOOL isFarenheit, needsSave;
	NSInteger opacityValue;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Load saved settings
	[self loadUserDefaults];
	
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Load saved settings
	[self loadUserDefaults];
	
}

-(void)loadUserDefaults {
	
	// Load saved settings
	userDefaults = [NSUserDefaults standardUserDefaults];
	if (userDefaults != nil) {
		BOOL segFC = [userDefaults boolForKey:@"TempFC"];
		if (segFC) {
			NSLog(@"Load F");
			// Set seg control to F
			_tempControl.selectedSegmentIndex = 0;
		} else {
			NSLog(@"Load C");
			// Set seg control to C
			_tempControl.selectedSegmentIndex = 1;
		}
		
		NSInteger sliderVal = [userDefaults integerForKey:@"Opacity"];
		if (sliderVal) {
			_opacitySlider.value = sliderVal;
			int rounded = _opacitySlider.value;
			_opacityLabel.text = [NSString stringWithFormat:@"%d%%", rounded];
		} else {
			[_opacitySlider setValue:60 animated:YES];
			_opacityLabel.text = @"60%";
		}
		
	} else {
		[_tempControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	
	needsSave = NO;
	
}

-(void)viewWillDisappear:(BOOL)animated {
	
	if (needsSave) {
		UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"Save Changes?" message:@"Do you want to save your settings?" preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self savePreferences:self];
			needsSave = NO;
			[saveAlert dismissViewControllerAnimated:YES completion:nil];
		}];
		
		UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			needsSave = NO;
			[saveAlert dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[saveAlert addAction:ok];
		[saveAlert addAction:no];
		
		[self presentViewController:saveAlert animated:YES completion:nil];
	}
	
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// Handle Opacity Slider change events

-(IBAction)opacityChanged:(id)sender {
	UISlider *slider = (UISlider *)sender;
	int rounded = slider.value;
	opacityValue = rounded;
	_opacityLabel.text = [NSString stringWithFormat:@"%ld%%", (long)opacityValue];
	
	needsSave = YES;
}



// Handle Temp segment control events

-(IBAction)tempSegmentIndexChanged:(UISegmentedControl *)sender {
	
	switch (_tempControl.selectedSegmentIndex) {
  case 0:
			// Farenheit pressed
			if (isFarenheit == NO) {
				isFarenheit = YES;
				needsSave = YES;
			}
			break;
  case 1:
			// Celsius pressed
			if (isFarenheit == YES) {
				isFarenheit = NO;
				needsSave = YES;
			}

			break;
  default:
			break;
	}
}

-(void)alertSave {
	UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:@"Settings Saved" message:@"Your settings have been saved!" preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[saveAlert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[saveAlert addAction:ok];
	
	[self presentViewController:saveAlert animated:YES completion:nil];
}




// Set NSUserDefaults prefs

-(IBAction)savePreferences:(id)sender {
	userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:isFarenheit forKey:@"TempFC"];
	[userDefaults setInteger:opacityValue forKey:@"Opacity"];
	[userDefaults synchronize];
	needsSave = NO;
	[self alertSave];
}

@end
