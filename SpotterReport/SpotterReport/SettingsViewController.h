//
//  SettingsViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISwitch *spotterNetworkSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *skyWarnSwitch;

@property (nonatomic, weak) IBOutlet UISegmentedControl *tempControl;
@property (nonatomic, weak) IBOutlet UISlider *opacitySlider;
@property (nonatomic, weak) IBOutlet UILabel *opacityLabel;

@property (nonatomic, weak) IBOutlet UIButton *saveButton;


@end
