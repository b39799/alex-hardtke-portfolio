//
//  SecondViewController.m
//  SpotterReport
//
//  Created by Alex Hardtke on 2/24/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import "SecondViewController.h"
#import "ReportTableViewCell.h"
#import "ReportDetailViewController.h"
#import "Reports.h"
#import <Parse/Parse.h>
#import <Social/Social.h>

@interface SecondViewController ()

@end

@implementation SecondViewController {
	NSMutableArray *reportTableData;
	NSString *reportType;
	UIActivityIndicatorView *activityInd;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// Start activity indicator
	activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityInd.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 + 100);
	[self.view addSubview:activityInd];
	[activityInd startAnimating];
	
	[self updateList];
	
	// Set list to display static reports for now
	//reportTableData = [NSArray arrayWithObjects:@"Tornado", @"Funnel Cloud", @"Wall Cloud", @"Hail", @"Wind", @"Flood", nil];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	[activityInd startAnimating];
	[self updateList];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)updateList {
	
	PFUser *user = [PFUser currentUser];
	
	if (user != nil) {
		PFQuery *query = [Reports query];
		[query whereKey:@"user" equalTo:user];
		query.cachePolicy = kPFCachePolicyNetworkElseCache;
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				reportTableData = [[NSMutableArray alloc] initWithArray:objects];
				reportTableData = (NSMutableArray *)[[reportTableData reverseObjectEnumerator] allObjects];
				//NSLog(@"Objects = %@", objects);
				[myTableView reloadData];
			}
			[activityInd stopAnimating];
		}];
	} else {
		NSLog(@"Not logged in");
		[activityInd stopAnimating];
	}
	
}


-(IBAction)shareButtonSelected:(id)sender {
	
	Reports *twitterReport = [reportTableData objectAtIndex:0];
	NSString *typeStr = twitterReport.stormType;
	NSString *locationStr = twitterReport.location;
	NSString *descriptionStr = twitterReport.observations;
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



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [reportTableData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"ReportsCell";
	
	
	ReportTableViewCell *reportCell = (ReportTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	reportCell.tag = indexPath.row;
	
	if (reportCell != nil) {
		Reports *report = [reportTableData objectAtIndex:indexPath.row];
		reportCell.reportTypeLabel.text = report.stormType;
		reportCell.reportTimeLabel.text = report.date;
		reportCell.reportLocationLabel.text = report.location;
	}
	return reportCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	return 100;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Remove data
		//reportTableData = (NSMutableArray *)[[reportTableData reverseObjectEnumerator] allObjects];
		[reportTableData removeObjectAtIndex:indexPath.row];
		
		// Remove the line from the tableview
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		PFQuery *query = [Reports query];
		[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
			if (!error) {
				objects = [[objects reverseObjectEnumerator] allObjects];
				Reports *reportDelete = [objects objectAtIndex:indexPath.row];
				[reportDelete deleteInBackground];
			}
		}];
	}
}

-(IBAction)deleteReportFromList:(id)sender {
	
	// Delete pressed
	myTableView.editing = !myTableView.isEditing;
}





// Segues


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ReportDetailSegue"]) {
		ReportDetailViewController *reportDetailVC = (ReportDetailViewController *)segue.destinationViewController;
		Reports *report = [reportTableData objectAtIndex:[sender tag]];
		//reportType = [reportTableData objectAtIndex:[sender tag]];
		reportDetailVC.report = report;
		
	}
}

-(IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
	
}


@end
