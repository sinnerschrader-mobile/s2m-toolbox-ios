//
//  S2MCalloutAnnotation.m
//  Example
//
//  Created by Joern Ehmann on 10/12/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MCalloutAnnotation.h"

@implementation S2MCalloutAnnotation

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
{
    self = [super init];
    if(self){
        self.coordinate = annotation.coordinate;
        
        if([annotation respondsToSelector:@selector(title)]){
            self.title = annotation.title;
        }
        if([annotation respondsToSelector:@selector(subtitle)]){
            self.subtitle = annotation.subtitle;
        }
    }
    return self;
}

- (NSString *)subtitle
{
    if (self.distanceInMeter.integerValue > 0) {
        double distanceInKm = self.distanceInMeter.doubleValue / 1000.f;
        NSString *distanceString;
        if (distanceInKm > 10) {
            distanceString = [NSString stringWithFormat:@"%.0f", round(distanceInKm)];
        }else{
            distanceString = [NSString stringWithFormat:@"%.1f", distanceInKm];
        }
        return distanceString;
    }
    return nil;
}

@end
