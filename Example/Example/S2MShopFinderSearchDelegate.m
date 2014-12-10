//
//  S2MShopFinderSearchDelegate.m
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MShopFinderSearchDelegate.h"

@interface S2MShopFinderSearchDelegate()
@end


@implementation S2MShopFinderSearchDelegate

-(void)shopFinder:(S2MShopFinderController *)shopFinder searchTerm:(NSString *)term withResults:(void (^)(NSArray *))resultBlock
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = term;

    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        //second search
        MKMapItem *firstHit = [response.mapItems firstObject];
        
        MKCoordinateRegion region = MKCoordinateRegionMake(firstHit.placemark.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        
        [self shopFinder:shopFinder searchRegion:region withResults:^(NSArray *results) {
            if (resultBlock) {
                resultBlock(results);
            }
        }];
    }];
}

-(void)shopFinder:(S2MShopFinderController *)shopFinder searchAtLocation:(CLLocation*)location withResults:(void (^)(NSArray *))resultBlock
{
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self shopFinder:shopFinder searchRegion:region withResults:resultBlock];
}


/**
 *  Search with region like scrolling or user location
 *
 *  @param shopFinder
 *  @param region
 *  @param resultBlock
 */
-(void)shopFinder:(S2MShopFinderController *)shopFinder searchRegion:(MKCoordinateRegion)region withResults:(void (^)(NSArray *))resultBlock
{
    //let's say we search for tankstelle
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"Tankstelle";
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:response.mapItems.count];
        for (MKMapItem *item in response.mapItems) {
            [results addObject:item.placemark];
        }
        if (resultBlock) {
            resultBlock(results);
        }
    }];
}

@end
