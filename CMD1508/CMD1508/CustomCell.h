//
//  CustomCell.h
//  CMD1508
//
//  Created by Alex Hardtke on 8/12/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
{
	IBOutlet UILabel *qtyLabel;
	IBOutlet UILabel *itemLabel;
	
}

-(void)refreshCellWithInfo:(NSString*)qtyString secondString:(NSString*)itemString;

@end
