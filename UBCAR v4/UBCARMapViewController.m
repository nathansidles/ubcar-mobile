//
//  UBCARMapViewController.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/17/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "UBCARMapViewController.h"
#import "UBCARPointViewController.h"
#import "UBCARListTableViewController.h"
#import "UBCARAggregate.h"
#import "AppDelegate.h"
@import CoreLocation;

@interface UBCARMapViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation UBCARMapViewController

- (void)viewDidLoad {
    
    [_locationManager requestWhenInUseAuthorization];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
    
    self.mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _didCheck = false;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if( self.didCheck == false ) {
        _mapView.centerCoordinate = userLocation.location.coordinate;
        self.didCheck = true;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    UBCARListTableViewController* referringController = (UBCARListTableViewController*)segue.sourceViewController;
    
    NSString* selectedID = referringController.selectedID;
    NSString* selectedType = referringController.selectedType;
    
    NSError *error;
    NSURL *UBCARURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_%@s%%5B%%5D=%@", selectedType, selectedID]];
    if( selectedID == 0 ) {
        UBCARURL = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json"];
    }
    NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
    
    if( jsonString != nil ) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        for( NSObject *point in json ) {
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[point valueForKey:@"latitude"] doubleValue];
            coordinate.longitude = [[point valueForKey:@"longitude"] doubleValue];
            
            UBCARMapPoint *newPoint = [[UBCARMapPoint alloc] initWithName:[point valueForKey:@"name"] idNumber:[[point valueForKey:@"id"] intValue] coordinate:coordinate];
            [_mapView addAnnotation:newPoint];
        }
        [_mapView showAnnotations:_mapView.annotations animated:true];
    }
}

- (IBAction)changeMapType:(id)sender {
    if (_mapView.mapType == MKMapTypeStandard) {
        _mapView.mapType = MKMapTypeSatellite;
        _mapTypeController.title = @"Map";
    } else {
        _mapView.mapType = MKMapTypeStandard;
        _mapTypeController.title = @"Terrain";
    }
}

-(void)addPoints {
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    NSError *error;
    NSURL *UBCARURL = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json"];
    NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
    if( jsonString != nil ) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        for( NSObject *point in json ) {
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[point valueForKey:@"latitude"] doubleValue];
            coordinate.longitude = [[point valueForKey:@"longitude"] doubleValue];
            
            UBCARMapPoint *newPoint = [[UBCARMapPoint alloc] initWithName:[point valueForKey:@"name"] idNumber:[[point valueForKey:@"id"] intValue] coordinate:coordinate];
            [_mapView addAnnotation:newPoint];
        }
        [_mapView showAnnotations:_mapView.annotations animated:true];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[UBCARMapPoint class]]) {
        MKPinAnnotationView* annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else
            annotationView.annotation = annotation;
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UBCARMapPoint *selectedPoint = view.annotation;
    self.selectedPoint = selectedPoint.idNumber;
    [self performSegueWithIdentifier:@"Test" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [[segue destinationViewController] isKindOfClass:[UBCARPointViewController class]] ) {
        UBCARPointViewController* destinationViewController = [segue destinationViewController];
        destinationViewController.hidesBottomBarWhenPushed = YES;
        destinationViewController.idNumber = self.selectedPoint;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UBCARAggregate" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(checked = %@)", [[NSNumber alloc] initWithInt:1]];
    [request setPredicate:pred ];
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if( objects.count != 0 ) {
        NSURL *UBCARURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_%@s%%5B%%5D=%@", [(NSManagedObject*)objects[0] valueForKey:@"type"], [(NSManagedObject*)objects[0] valueForKey:@"idNumber"]]];
        NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
        if( jsonString != nil ) {
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            for( NSObject *point in json ) {
                
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = [[point valueForKey:@"latitude"] doubleValue];
                coordinate.longitude = [[point valueForKey:@"longitude"] doubleValue];
                
                UBCARMapPoint *newPoint = [[UBCARMapPoint alloc] initWithName:[point valueForKey:@"name"] idNumber:[[point valueForKey:@"id"] intValue] coordinate:coordinate];
                [_mapView addAnnotation:newPoint];
            }
            self.didCheck = false;
            [_mapView showAnnotations:_mapView.annotations animated:true];
        }
    } else {
        [self addPoints];
    }
    self.didCheck = false;
}

@end
