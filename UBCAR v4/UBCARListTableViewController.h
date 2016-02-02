//
//  UBCARListTableViewController.h
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/16/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBCARListTableViewController : UITableViewController

@property NSMutableArray *UBCARLayers;
@property NSMutableArray *UBCARTours;
@property NSMutableArray *UBCARAggregates;
@property NSString *selectedID;
@property NSString *selectedType;

@end
