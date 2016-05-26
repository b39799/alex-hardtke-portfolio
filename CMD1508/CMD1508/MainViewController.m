//
//  MainViewController.m
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "MainViewController.h"
#import "Items.h"
#import "ViewController.h"
#import <Parse/Parse.h>
#import "CustomCell.h"
#import "Reachability.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	PFUser *currentUser = [PFUser currentUser];
	NSString* userStr = currentUser.username;
	welcomeText.text = [NSString stringWithFormat:@"Welcome %@", userStr];
	
	isEditing = false;
	isAutoSyncing = false;
	
	// Check network status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUpdated:) name:kReachabilityChangedNotification object:nil];
	
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
		[self setPreferences];
		if (userDefaults != nil) {
			isAutoSyncing = [userDefaults boolForKey:@"autoSync"];
		}
		isAutoSyncing = [userDefaults boolForKey:@"autoSync"];
		if (isAutoSyncing) {
			[autoSyncSwitch setOn:YES animated:YES];
		} else {
			[autoSyncSwitch setOn:NO animated:YES];
		}
		[self updateList];
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

-(void)switchToggle:(id)sender {
	UISwitch *asyncSwitch = (UISwitch *)sender;
	if ([asyncSwitch isOn]) {
		isAutoSyncing = true;
		[self setPreferences];
		// Syncing
		[self autoSync:true];
		
	} else {
		isAutoSyncing = false;
		[self setPreferences];
		// Not auto syncing
		[self autoSync:false];
	}
}


-(void)autoSync:(BOOL)autoSync {
	
	if (autoSync) {
		// Auto sync started
		timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(updateList) userInfo:nil repeats:YES];
		NSLog(@"AutoSync Complete");
	} else {
		// Auto sync stopped
		[timer invalidate];
		NSLog(@"AutoSync Stopped");
	}
}




-(void)setPreferences {
	userDefaults = [NSUserDefaults standardUserDefaults];
	if ([autoSyncSwitch isOn]) {
		isAutoSyncing = true;
	} else {
		isAutoSyncing = false;
	}
	[userDefaults setBool:isAutoSyncing forKey:@"autoSync"];
	[userDefaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	
}


-(IBAction)onClick:(id)sender {
	// Save Text input to Parse and List
	UIButton *button = (UIButton*)sender;
	PFUser *currentUser = [PFUser currentUser];
	
	// Add button
	if (button.tag == 0) {
		
		if (!isEditing) {
			// Not editing, just adding a new item to the list
			
			//PFObject *item = [PFObject objectWithClassName:@"Item"];
			Items *item = [Items object];
			item.item = itemField.text;
			item.qty = qtyField.text;
			item.user = currentUser;
			[item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (succeeded) {
					// Item has been saved!
					[self updateList];
				} else {
					// Error saving item...
					NSLog([NSString stringWithFormat:@"Error: %@", error.description], error.description);
				}
			}];
			
			// Reset TextFields
			itemField.text = @"";
			qtyField.text = @"";
		} else if (isEditing) {
			editItem.item = itemField.text;
			editItem.qty = qtyField.text;
			[editItem saveEventually];
			
			[self updateList];
			itemField.text = @"";
			qtyField.text = @"";
		}
		
	} else if (button.tag == 1) {
		// Delete Button
		myTableView.editing = !myTableView.isEditing;
		
	}
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Remove data
		[itemArray removeObjectAtIndex:indexPath.row];
		
		// Remove the line from tableView
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		PFQuery *query = [Items query];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				Items *item = [objects objectAtIndex:indexPath.row];
				[item deleteInBackground];
			}
		}];
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"itemArray count = %lu", (unsigned long)itemArray.count);
	return [itemArray count];
}

// Tell the app to pass back the cells that are going to be fed into my table view
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
	if (cell != nil) {
		Items *item = [itemArray objectAtIndex:indexPath.row];
		NSLog(@"Item = %@", item.item);
		
		[cell refreshCellWithInfo:item.qty secondString:item.item];
	}
	return cell;
}

// Selecting a cell lets the user edit the text for the item
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	editItem = [[Items alloc] init];
	CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
	if (cell != nil) {
		editItem = [itemArray objectAtIndex:indexPath.row];
		NSLog(@"Item = %@", editItem.item);
		
		[self editListItem:editItem];
		
	}
}


// Logout action - takes us back to Welcome screen
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	MainViewController *mainViewController = segue.destinationViewController;
	if (mainViewController != nil) {
		[PFUser logOut];
	}
}

-(IBAction)exit:(UIStoryboardSegue*)sender {
	
}

-(void)updateList{
	//PFQuery *query = [PFQuery queryWithClassName:@"Item"];
	PFUser *user = [PFUser currentUser];
	
	PFQuery *query = [Items query];
	[query whereKey:@"user" equalTo:user];
	query.cachePolicy = kPFCachePolicyNetworkElseCache;
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			
			
			itemArray = [[NSMutableArray alloc] initWithArray:objects];
			NSLog(@"Objects = %@", objects);
			[myTableView reloadData];
		}
	}];
}

-(void)editListItem:(Items*)item {
	PFUser *user = [PFUser currentUser];
	
	PFQuery *query = [Items query];
	[query whereKey:@"user" equalTo:user];
	query.cachePolicy = kPFCachePolicyNetworkElseCache;
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			isEditing = true;
			itemField.text = item.item;
			qtyField.text = item.qty;
		}
	}];
}


@end
