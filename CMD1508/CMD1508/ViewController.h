//
//  ViewController.h
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ViewController : UIViewController {
	IBOutlet UIButton *logInButton, *signUpButton;
	IBOutlet UITextField *usernameText, *passwordText;
	IBOutlet UILabel *usernameInfoText, *passwordInfoText;
	Reachability *reachability;
}

-(IBAction)onClick:(id)sender;


@end

