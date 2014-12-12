//
//  ShopFinderController.h
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "S2MCalloutAnnotation.h"
@class S2MShopFinderController;
/**
 *  Implement this delegate to have autocomplete functionality for places search
 */
@protocol S2MShopFinderAutoCompleteDelegate <NSObject>

@required
/**
 *  Returns array of NSString to display in tableview for Autocompletion
 *
 *  @param shopFinder S2MShopFinderController instance
 *  @param term       searchTerm that Autocomplete begins with
 *
 *  @return array of NSString if sectioned is false, esle NSArray of NSArray of NSStrings
 */
-(NSArray*)shopFinder:(S2MShopFinderController*)shopFinder expectSections:(BOOL)sectioned autoCompleteResultsForTerm:(NSString*)term;
/**
 *  Called when selecting an autocompleted term in the autocomplete section
 *
 *  @param shopFinder S2MShopFinderController instance
 *  @param term       term that was clicked
 *  @param section    section it was clicked in, if you defined to use sections: see showsAutocompleteSections
 */
-(void)shopFinder:(S2MShopFinderController*)shopFinder didSelectAutoCompleteTerm:(NSString*)term inSection:(NSInteger)section;

@optional
/**
 *  Used to display section titles if showsAutocompleteSections is set to YES
 *
 *  @param shopFinder S2MShopFinderController instance
 *  @param section    section to get the title for
 *
 *  @return NSString for title
 */
-(NSString*)shopFinder:(S2MShopFinderController*)shopFinder titleInSection:(NSInteger)section;

@end

/**
 *  Implement Delegate to deliver results to map
 */
@protocol S2MShopFinderSearchDelegate <NSObject>
@required
/**
 *  Searches for a specific searchterm when user enters a searchterm in the searchbar
 *
 *  @param shopFinder  S2MShopFinderController instance
 *  @param term        term to search for
 *  @param resultBlock NSArray <MKAnnotation>, should be called on MainThread
 */
-(void)shopFinder:(S2MShopFinderController *)shopFinder
       searchTerm:(NSString*)term
      withResults:(void (^)(NSArray *))resultBlock;
/**
 *  Searches in a specific region e.g. when map is scrolled
 *
 *  @param shopFinder  S2MShopFinderController instance
 *  @param region      region to search at
 *  @param resultBlock NSArray <MKAnnotation>, should be called on MainThread
 */
-(void)shopFinder:(S2MShopFinderController *)shopFinder
     searchRegion:(MKCoordinateRegion)region
      withResults:(void (^)(NSArray *))resultBlock;
/**
 *  Searches for a specific location when user taps the "locate" button or initially starts
 *
 *  @param shopFinder  S2MShopFinderController instance
 *  @param location    location to search at
 *  @param resultBlock NSArray <MKAnnotation>, should be called on MainThread
 */
-(void)shopFinder:(S2MShopFinderController *)shopFinder
     searchAtLocation:(CLLocation*)location
      withResults:(void (^)(NSArray *))resultBlock;

@end

/**
 *  Special Delegate to handle taps on Annotation to make a special Callouts. The Callouts themselves are just special forms of annotationViews
 */
@protocol S2MShopFinderMapSpecialsDelegate <NSObject>
@required
/**
 *  called by the mapview to display a special callout
 *
 *  @param mapView    mapView used for displaying
 *  @param annotation annotation that callout should be displayed for
 *
 *  @return View for Callout Annotation
 */
-(MKAnnotationView *)mapView:(MKMapView *)mapView calloutViewForAnnotation:(id<MKAnnotation>)annotation;
/**
 *  called when the special callout was tapped
 *
 *  @param mapView    mapView used for displaying
 *  @param annotation annotation for the selected callout
 */
-(void)mapView:(MKMapView *)mapView calloutViewWasTappedForAnnotation:(id<MKAnnotation>)annotation;
@end

@interface S2MShopFinderController : UIViewController

/**
 *  Different SearchModes for map and searchbar
 */
typedef NS_ENUM(NSUInteger, S2MShopFinderSearchMode){
    /**
     *  search at userlocation, mapview tracks movement and map and pins update
     */
    S2MShopFinderSearchModeUserLocation = 0,
    /**
     *  used when map is dragged
     */
    S2MShopFinderSearchModeDragging,
    /**
     *  search by keyword entered in searchbar or by autocomplete tap
     */
    S2MShopFinderSearchModeKeyword
};
/**
 *  mapView for the displayed annotations
 */
@property (nonatomic, readonly) MKMapView *mapView;
/**
 *  searchbar for autocomplete or normal search
 */
@property (nonatomic, readonly) UISearchBar *searchBar;
/**
 *  tableview for automcomplete results
 */
@property (nonatomic, readonly) UITableView *resultsTableView;


@property (nonatomic, weak) id <S2MShopFinderAutoCompleteDelegate> autoCompleteDelegate;
@property (nonatomic, weak) id <S2MShopFinderSearchDelegate> searchDelegate;
@property (nonatomic, weak) id <S2MShopFinderMapSpecialsDelegate> mapSpecialsDelegate;

/**
 *  image for locate button. default is blue arrow. Set from outside to customize
 */
@property (nonatomic, strong) UIImage *locateButtonImage;

/**
 *  custom image for an active annotation
 */
@property (nonatomic, strong) UIImage *resultAnnotationActiveImage;
/**
 *  custom image for an inactive annotation
 */
@property (nonatomic, strong) UIImage *resultAnnotationInactiveImage;
/**
 *  custom image for an annotation to display as center
 */
@property (nonatomic, strong) UIImage *centerAnnotationImage;


/**
 *  currently used searchmode, assign new property will not trigger new search
 */
@property (nonatomic, assign) S2MShopFinderSearchMode searchMode;

/**
 *  Default is YES
 */
@property (nonatomic, assign) BOOL hidesNavigationBarWhenActive;

/**
 *  Default is NO
 */
@property (nonatomic, assign) BOOL hidesLocateButtonWhenActive;
/**
 *  Default is NO, define resultAnnotationActiveImage and resultAnnotationInactiveImage when set to YES
 */
@property (nonatomic, assign) BOOL mapUsesCustomCallouts;

/**
 *  default is NO. If set to YES, assign autoCompleteDelegate
 */
@property (nonatomic, assign) BOOL showsAutocompleteResults;
/**
 *  default is NO. if set to YES, assign autoCompleteDelegate
 */
@property (nonatomic, assign) BOOL showsAutocompleteSections;

/**
 *  assign to specify custom emtpy view when using autocomplete
 */
@property (nonatomic, strong) UIView *emptyTableView;

/**
 *  displayed in alert when no results where found for search
 */
@property (nonatomic, copy) NSString* textForNoResults;

/**
 *  called when user searches with term via searchbar or autocomplete
 *
 *  @param term to search for
 */
-(void)searchWithTerm:(NSString*)term;
/**
 *  called when user taps locate button
 *
 *  @param location to search at
 */
-(void)searchWithLocation:(CLLocation*)location;
/**
 *  shows results on mapview, old results are deleted or stay according to searchmode
 *
 *  @param results array of <MKAnnotation>
 */
-(void)showResults:(NSArray*)results;

/**
 *  called on view appear
 *
 *  @param ignore define YES, to ignore current state and searchmode and force new location based search
 */
-(void)startLocatingIgnoreSelection:(BOOL)ignore;

/**
 *  call to programmatically select annotation. e.g. after deliver search results
 *
 *  @param mapView
 *  @param annotation to be selected
 */
-(void)mapView:(MKMapView*)mapView selectAnnotation:(id<MKAnnotation>)annotation;

/**
 *  call to show table view overlay for searchterm, needs autoCompleteDelegate to be assigned and implemented
 *
 *  @param term term to search for
 */
-(void)showAutoCompleteForTerm:(NSString*)term;
/**
 *  hide autocomplete table view
 */
-(void)hideAutocomplete;

@end




