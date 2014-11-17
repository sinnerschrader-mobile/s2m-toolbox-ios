//
//  TURShopFinderControllerViewController.m
//  Example
//
//  Created by Joern Ehmann on 05/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "TURShopFinderControllerViewController.h"
#import "TURAnnotationView.h"

@interface TURShopFinderControllerViewController ()<S2MShopFinderMapSpecialsDelegate, S2MShopFinderAutoCompleteDelegate>

@end

@implementation TURShopFinderControllerViewController

#pragma mark autoCompleteDelegate

-(NSArray*)shopFinder:(S2MShopFinderController*)shopFinder autoCompleteResultsForTerm:(NSString*)term{
    //TODO: change with real data
    
    NSMutableArray *results = [NSMutableArray array];
    for(int i = 0; i<term.length; i++){
        [results addObject:[NSString stringWithFormat:@"%@ %i", term, i]];
    }
    
    return results;
    
}
-(void)shopFinder:(S2MShopFinderController*)shopFinder didSelectAutoCompleteTerm:(NSString*)term{
    [self hideAutocomplete];
    [self searchWithTerm:term];
}


#pragma mark mapSpecials Delegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView calloutViewForAnnotation:(id<MKAnnotation>)annotation{
    TURAnnotationView *callout = [[TURAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil mapView:mapView];
    return callout;
}

-(void)mapView:(MKMapView *)mapView calloutViewWasTappedForAnnotation:(id<MKAnnotation>)annotation{
    //TODO open DetailViewController

}


#pragma mark Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.hidesNavigationBarWhenActive = NO;
    self.hidesLocateButtonWhenActive = YES;
    self.showsAutocompleteResults = YES;
    self.mapSpecialsDelegate = self;
    self.autoCompleteDelegate = self;
}


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        //special configuration

        self.locateButtonImage = [UIImage imageNamed:@"icn_location_active"];
        self.resultAnnotationActiveImage = [UIImage imageNamed:@"pin_active"];
        self.resultAnnotationInactiveImage = [UIImage imageNamed:@"pin_inactive"];

    }
    return self;
}

@end
