//
//  SecondViewController.h
//  SpotterReport
//
//  Created by Alex Hardtke on 2/24/16.
//  Copyright © 2016 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *myTableView;
	IBOutlet UIBarButtonItem *shareButton;
	IBOutlet UIBarButtonItem *deleteButton;
}

@end

