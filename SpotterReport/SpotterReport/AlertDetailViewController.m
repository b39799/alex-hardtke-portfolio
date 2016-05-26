//
//  AlertDetailViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "AlertDetailViewController.h"

@interface AlertDetailViewController ()

@end

@implementation AlertDetailViewController
@synthesize alertDetailType, alertDetailTime, alertDetailLocation, alertDetailDescription;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
	
	alertDetailType.text = _typeStr;
	alertDetailTime.text = _timeStr;
	alertDetailLocation.text = _locationStr;
	alertDetailDescription.text = _descriptionStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
