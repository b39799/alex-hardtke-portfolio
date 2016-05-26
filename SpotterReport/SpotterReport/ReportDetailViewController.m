//
//  ReportDetailViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/25/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "ReportDetailViewController.h"
#import <Parse/Parse.h>
#import "Reports.h"
#import <Social/Social.h>

@interface ReportDetailViewController ()

@end

@implementation ReportDetailViewController
@synthesize reportDetailDescription, reportDetailLocation, reportDetailTime, reportDetailType, reportDetailType2, reportImageView, damageDetail, injuryDetail, report;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
	
	
	
	reportDetailType.text = report.stormType;
	reportDetailTime.text = report.date;
	reportDetailLocation.text = report.location;
	reportDetailDescription.text = report.observations;
	reportDetailType2.text = report.stormTypeDetail1;
	
	if (report.damage != nil) {
		if ([report.damage isEqualToString:@"YES"]) {
			damageDetail.text = @"Damage: Yes";
			damageDetail.textColor = [UIColor redColor];
		} else if ([report.damage isEqualToString:@"NO"]) {
			damageDetail.text = @"Damage: No";
			damageDetail.textColor = [UIColor blackColor];
		}
	}
	
	if (report.injuries != nil) {
		if ([report.injuries isEqualToString:@"YES"]) {
			injuryDetail.text = @"Injuries: Yes";
			injuryDetail.textColor = [UIColor redColor];
		} else if ([report.injuries isEqualToString:@"NO"]) {
			injuryDetail.text = @"Injuries: No";
			injuryDetail.textColor = [UIColor blackColor];
		}
	}
	
	if (report.imageFile != nil) {
		//reportImageView.image;
		
		//PFFile *image = [report objectForKey:@"imageFile"];
		
		PFQuery *query = [PFQuery queryWithClassName:@"Reports"];
		
		[query whereKeyExists:@"imageFile"];
		[query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
			if (!object) {
				return NSLog(@"Error: %@", error);
			}
			
			PFFile *file = object[@"imageFile"];
			
			[file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
				if (!data) {
					return NSLog(@"Error: %@", error);
				}
				
				reportImageView.image = [UIImage imageWithData:data];
			}];
		}];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)shareButtonSelected:(id)sender {
	
	//Reports *twitterReport = [reportTableData objectAtIndex:0];
	NSString *typeStr = reportDetailType.text;
	NSString *locationStr = reportDetailLocation.text;
	NSString *descriptionStr = reportDetailDescription.text;
	NSString *twitterStr = [NSString stringWithFormat:@"%@ - %@: %@", typeStr, locationStr, descriptionStr];
	
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[twitterStr] applicationActivities:nil];
	if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
		activityVC.popoverPresentationController.barButtonItem = shareButton;
	}
	[self presentViewController:activityVC animated:YES completion:nil];
}


-(void)shareTwitter {
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		// Twitter
		SLComposeViewController *tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[tweetController setInitialText:@""];
		[self presentViewController:tweetController animated:YES completion:nil];
	} else if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		//Facebook
		SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[facebookController setInitialText:@""];
		[self presentViewController:facebookController animated:YES completion:nil];
	} else {
		// Error
		UIAlertController *tweetAlertController = [UIAlertController alertControllerWithTitle:@"Problem" message:@"There was a problem. Please make sure you have a network connection and that you have an account." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[tweetAlertController dismissViewControllerAnimated:YES completion:nil];
		}];
		
		[tweetAlertController addAction:ok];
		[self presentViewController:tweetAlertController animated:YES completion:nil];
	}
}

@end
