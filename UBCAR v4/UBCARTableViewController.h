//
//  UBCARTableViewController.h
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/20/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBCARMapPoint.h"
#import <CoreLocation/CoreLocation.h>

@interface UBCARTableViewController : UITableViewController

@property NSMutableArray *UBCARPoints;
@property (nonatomic) int selectedPoint;
@property float longitude;
@property float latitude;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
