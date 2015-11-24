//
//  CLLocation+S2MAdditions.m
//  MoreMobile
//
//  Created by Andreas Buff on 12/09/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "CLLocation+S2MAdditions.h"

@implementation CLLocation (S2MAdditions)

- (BOOL)s2m_isValid
{
    return self.horizontalAccuracy >= 0;
}

+ (CLLocation *)bestLocationOfLocations:(NSArray *)locations
{
    CLLocation *bestLocation = nil;
    for (int i = 0; i < locations.count; ++i) {
        CLLocation *currentLocation = [locations objectAtIndex:i];
        if(i == 0) {
            bestLocation = currentLocation;
        } else if(abs([currentLocation.timestamp timeIntervalSinceNow]) < abs([bestLocation.timestamp timeIntervalSinceNow])) {
            bestLocation = currentLocation;
        } else if ((abs([currentLocation.timestamp timeIntervalSinceNow]) == abs([bestLocation.timestamp timeIntervalSinceNow]))
                   && currentLocation.horizontalAccuracy < bestLocation.horizontalAccuracy) {
            bestLocation = currentLocation;
        }
    }
    
    return bestLocation;
}

@end
