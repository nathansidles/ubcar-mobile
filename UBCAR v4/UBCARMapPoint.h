//
//  UBCARMapPoint.h
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/19/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UBCARMapPoint : NSObject <MKAnnotation>

@property (nonatomic) int idNumber;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

- (id)initWithName:(NSString*)name idNumber:(int)idNumber coordinate:(CLLocationCoordinate2D)coordinate;

@end