//
//  S2MCalloutAnnotation.h
//  Example
//
//  Created by Joern Ehmann on 10/12/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface S2MCalloutAnnotation : NSObject <MKAnnotation>

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSNumber* distanceInMeter;


@end