//
//  UBCARMapViewController.h
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/17/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "ViewController.h"
#import "UBCARMapPoint.h"
#import <MapKit/MapKit.h>

@interface UBCARMapViewController : ViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapTypeController;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) int selectedPoint;
@property (nonatomic) bool didCheck;
- (IBAction)changeMapType:(id)sender;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
