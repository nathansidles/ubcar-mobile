//
//  UBCARMapPoint.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/19/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "UBCARMapPoint.h"

@interface UBCARMapPoint ()
@end

@implementation UBCARMapPoint

- (id)initWithName:(NSString*)name idNumber:(int)idNumber coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown";
        }
        self.idNumber = idNumber;
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

@end
