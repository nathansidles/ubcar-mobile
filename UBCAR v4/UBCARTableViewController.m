//
//  UBCARTableViewController.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/20/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "UBCARTableViewController.h"
#import "UBCARPointViewController.h"
#import "UBCARListTableViewController.h"
#import "AppDelegate.h"

@interface UBCARTableViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager2;

@end

@implementation UBCARTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![CLLocationManager locationServicesEnabled]) {
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    
    _locationManager2 = [[CLLocationManager alloc] init];
    self.locationManager2.delegate = self;
    
    self.locationManager2.desiredAccuracy = 1;

    self.locationManager2.distanceFilter = 1;
    
    if ([_locationManager2 respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager2 requestWhenInUseAuthorization];
    }
    [self.locationManager2 startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    _longitude = [[NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude] floatValue];
    _latitude = [[NSString stringWithFormat:@" %.8f", newLocation.coordinate.latitude] floatValue];
    
    for( NSObject* location in _UBCARPoints ) {
        float locationLatitude = [[location valueForKey:@"latitude"] floatValue];
        float locationLongitude = [[location valueForKey:@"longitude"] floatValue];
        
        CLLocation *locationLocation = [[CLLocation alloc] initWithLatitude:locationLatitude longitude:locationLongitude];
        CLLocationDistance distance = [newLocation distanceFromLocation:locationLocation];
        
        [location setValue:[NSString stringWithFormat:@"%f", distance] forKey:@"distance"];
        
    }
    
    [_UBCARPoints sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithFloat: [[a valueForKey:@"distance"] floatValue]];
        NSNumber *second = [NSNumber numberWithFloat: [[b valueForKey:@"distance"] floatValue]];
        return [first compare:second];
    }];
    [_myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_UBCARPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    cell.textLabel.text = [[_UBCARPoints objectAtIndex:indexPath.row] valueForKey:@"name"];
    NSString* distance = [[_UBCARPoints objectAtIndex:indexPath.row] valueForKey:@"distance"];
    NSMutableString* direction = [[NSMutableString alloc] initWithString:@""];
    
    float locationLatitude = [[[_UBCARPoints objectAtIndex:indexPath.row] valueForKey:@"latitude"] floatValue];
    float locationLongitude = [[[_UBCARPoints objectAtIndex:indexPath.row] valueForKey:@"longitude"] floatValue];
    
    float directionNS = locationLatitude - _latitude;
    float directionEW = locationLongitude - _longitude;
    
    if( 2 * fabsf(directionNS) > fabsf(directionEW) ) {
        if( directionNS > 0 ) {
            [direction appendString:@"N"];
        } else {
            [direction appendString:@"S"];
        }
    }
    if( fabsf(directionNS) < 2 * fabsf(directionEW) ) {
        if( directionEW > 0 ) {
            [direction appendString:@"E"];
        } else {
            [direction appendString:@"W"];
        }
    }
    
    int distanceInt = [distance intValue];
    if( distanceInt >= 1000 ) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d km %@", (distanceInt/1000), direction];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d m %@", distanceInt, direction];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPoint = (int) indexPath.row;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [[segue destinationViewController] isKindOfClass:[UBCARPointViewController class]] ) {
        UBCARPointViewController* destinationViewController = [segue destinationViewController];
        destinationViewController.hidesBottomBarWhenPushed = YES;
        self.selectedPoint = (int) [self.tableView indexPathForSelectedRow].row;
        destinationViewController.idNumber = [[_UBCARPoints[self.selectedPoint] valueForKey:@"id"] intValue];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
    UBCARListTableViewController* referringController = (UBCARListTableViewController*)segue.sourceViewController;
    
    NSString* selectedID = referringController.selectedID;
    NSString* selectedType = referringController.selectedType;
    
    NSError *error;
    NSURL *UBCARURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_%@s%%5B%%5D=%@", selectedType, selectedID]];
    if( selectedID == 0 ) {
        UBCARURL = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json"];
    }
    NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    CLLocation *currentLocation = [self.locationManager2 location];
    
    _longitude = [[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] floatValue];
    _latitude = [[NSString stringWithFormat:@" %.8f", currentLocation.coordinate.latitude] floatValue];
    
    for( NSObject* location in json ) {
        float locationLatitude = [[location valueForKey:@"latitude"] floatValue];
        float locationLongitude = [[location valueForKey:@"longitude"] floatValue];
        
        CLLocation *locationLocation = [[CLLocation alloc] initWithLatitude:locationLatitude longitude:locationLongitude];
        CLLocationDistance distance = [currentLocation distanceFromLocation:locationLocation];
        [location setValue:[NSString stringWithFormat:@"%f", distance] forKey:@"distance"];
        
    }
    
    [json sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithFloat: [[a valueForKey:@"distance"] floatValue]];
        NSNumber *second = [NSNumber numberWithFloat: [[b valueForKey:@"distance"] floatValue]];
        return [first compare:second];
    }];
    
    _UBCARPoints = json;
    
    [_myTableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UBCARAggregate" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(checked = %@)", [[NSNumber alloc] initWithInt:1]];
    [request setPredicate:pred ];
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSURL *UBCARURL = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json"];
    
    if( objects.count != 0 ) {
        UBCARURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_%@s%%5B%%5D=%@", [(NSManagedObject*)objects[0] valueForKey:@"type"], [(NSManagedObject*)objects[0] valueForKey:@"idNumber"]]];
    }
    NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

    CLLocation *currentLocation = [self.locationManager2 location];
    
    _longitude = [[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] floatValue];
    _latitude = [[NSString stringWithFormat:@" %.8f", currentLocation.coordinate.latitude] floatValue];
    
    for( NSObject* location in json ) {
        float locationLatitude = [[location valueForKey:@"latitude"] floatValue];
        float locationLongitude = [[location valueForKey:@"longitude"] floatValue];
        
        CLLocation *locationLocation = [[CLLocation alloc] initWithLatitude:locationLatitude longitude:locationLongitude];
        CLLocationDistance distance = [currentLocation distanceFromLocation:locationLocation];
        [location setValue:[NSString stringWithFormat:@"%f", distance] forKey:@"distance"];
        
    }
    
    [json sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithFloat: [[a valueForKey:@"distance"] floatValue]];
        NSNumber *second = [NSNumber numberWithFloat: [[b valueForKey:@"distance"] floatValue]];
        return [first compare:second];
    }];
    
    _UBCARPoints = json;
    
    [_myTableView reloadData];

}

@end
