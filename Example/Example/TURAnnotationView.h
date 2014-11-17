//
//  TURAnnotationView.h
//  Example
//
//  Created by Joern Ehmann on 06/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TURAnnotationView : MKAnnotationView

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView*)mapView;


@end
