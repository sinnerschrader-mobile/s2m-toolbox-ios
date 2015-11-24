//
//  CLLocation+S2MAdditions.h
//  MoreMobile
//
//  Created by Andreas Buff on 12/09/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (S2MAdditions)
/**
 *  Checks if a location is valid
 *
 *  @return Yes if valid
 */
- (BOOL)s2m_isValid;

/**
 *  Get the location with the most accurracy from given locations
 *
 *  @param locations locations to be evaluated
 *
 *  @return best location
 */
+ (CLLocation *)bestLocationOfLocations:(NSArray *)locations;

@end
