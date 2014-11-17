//
//  ShopFinderController.h
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class S2MShopFinderController;

@protocol S2MShopFinderAutoCompleteDelegate <NSObject>

@required
/**
 *  Returns array of NSString to display in tableview for Autocompletion
 *
 *  @param shopFinder
 *  @param term       searchTerm that Autocomplete begins with
 *
 *  @return array of NSString
 */
-(NSArray*)shopFinder:(S2MShopFinderController*)shopFinder autoCompleteResultsForTerm:(NSString*)term;
-(void)shopFinder:(S2MShopFinderController*)shopFinder didSelectAutoCompleteTerm:(NSString*)term;

@end


@protocol S2MShopFinderSearchDelegate <NSObject>
@optional


-(void)shopFinder:(S2MShopFinderController *)shopFinder
       searchTerm:(NSString*)term
      withResults:(void (^)(NSArray *, id<MKAnnotation>center))resultBlock;

-(void)shopFinder:(S2MShopFinderController *)shopFinder
     searchRegion:(MKCoordinateRegion)region
      withResults:(void (^)(NSArray *))resultBlock;

@end

@protocol S2MShopFinderMapSpecialsDelegate <NSObject>
@required
-(MKAnnotationView *)mapView:(MKMapView *)mapView calloutViewForAnnotation:(id<MKAnnotation>)annotation;
-(void)mapView:(MKMapView *)mapView calloutViewWasTappedForAnnotation:(id<MKAnnotation>)annotation;
@end

@interface S2MShopFinderController : UIViewController

typedef NS_ENUM(NSUInteger, S2MShopFinderSearchMode) {
    S2MShopFinderSearchModeUserLocation = 0,
    S2MShopFinderSearchModeDragging,
    S2MShopFinderSearchModeKeyword
};

@property (nonatomic, readonly) MKMapView *mapView;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) UITableView *resultsTableView;


@property (nonatomic, weak) NSObject <S2MShopFinderAutoCompleteDelegate> *autoCompleteDelegate;
@property (nonatomic, weak) NSObject <S2MShopFinderSearchDelegate> *searchDelegate;
@property (nonatomic, weak) NSObject <S2MShopFinderMapSpecialsDelegate> *mapSpecialsDelegate;



@property (nonatomic, strong) UIImage *locateButtonImage;

/**
 *  we assume it's like a pin an the image is pointing to the bottom middle of the image
 */
@property (nonatomic, strong) UIImage *resultAnnotationActiveImage;
@property (nonatomic, strong) UIImage *resultAnnotationInactiveImage;

@property (nonatomic, strong) UIImage *centerAnnotationImage;
@property (nonatomic, strong) UIView  *loadingOverlay;


@property (nonatomic, assign) S2MShopFinderSearchMode searchMode;

@property (nonatomic, assign) BOOL hidesNavigationBarWhenActive;
@property (nonatomic, assign) BOOL hidesLocateButtonWhenActive;
@property (nonatomic, assign) BOOL mapUsesCustomCallouts;

//autocomplete configuation
@property (nonatomic, assign) BOOL showsAutocompleteResults;

//shown when autocomplete table has no results
@property (nonatomic, strong) UIView *emptyTableView;


-(void)searchWithTerm:(NSString*)term;
-(void)searchWithLocation:(CLLocation*)location;

-(void)showAutoCompleteForTerm:(NSString*)term;
-(void)hideAutocomplete;


@end
