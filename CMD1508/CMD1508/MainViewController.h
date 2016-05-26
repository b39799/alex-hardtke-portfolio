//
//  MainViewController.h
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Items.h"
#import "Reachability.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIButton *addButton, *deleteButton, *logOutButton;
	IBOutlet UILabel *welcomeText;
	IBOutlet UITextField *itemField, *qtyField;
	IBOutlet UITableView *myTableView;
	IBOutlet UISwitch *autoSyncSwitch;
	Items *editItem;
	BOOL isEditing, isAutoSyncing;
	NSMutableArray *itemArray;
	Reachability *reachability;
	NSUserDefaults *userDefaults;
	NSTimer *timer;
}

-(IBAction)onClick:(id)sender;
-(IBAction)switchToggle:(id)sender;

@end
