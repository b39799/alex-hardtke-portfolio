//
//  NewReportViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"

@interface NewReportViewController : UIViewController <CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>{
	Reachability *reachability;
	CLLocationManager *locationManager;
	
}

@property (nonatomic, weak) IBOutlet UITextField *dateTextField;

@property (nonatomic, weak) IBOutlet UILabel *spotterNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *spotterLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *editDateTimeButton;
@property (nonatomic, weak) IBOutlet UIButton *signOutButton;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *datePickerDoneButton;
@property (nonatomic, weak) IBOutlet UIToolbar *datePickerToolbar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mesoTypeSegControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *severeTypeSegControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *damageSegControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *injurySegControl;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *imageSelectButton;

@property (nonatomic, strong) UIImage *image;

@end
