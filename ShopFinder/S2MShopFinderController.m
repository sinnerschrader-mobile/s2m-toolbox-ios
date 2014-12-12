//
//  ShopFinderController.m
//  S2MToolboxApp
//
//  Created by Joern Ehmann on 04/11/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MShopFinderController.h"
static NSString* kAnnotIdentifier = @"kAnnotIdentifier";
static NSString* kCompleteIdentifier = @"kCompleteIdentifier";
static const CGFloat locateButtonWidth = 44.0f;

@interface S2MShopFinderController ()<UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate>

@property (nonatomic, strong) UITableView *resultsTableView;

//UI
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *locateButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSLayoutConstraint *locateButtonWidthConstraint;

@property (nonatomic, strong) id<MKAnnotation>searchLocation;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *manager;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL isMapRendered;
@property (nonatomic, assign) BOOL loadPlacesForRegion;


@property (nonatomic, copy) NSString *searchTerm;

//internal Data
@property (nonatomic, strong) MKAnnotationView *customCalloutView;
@property (nonatomic, strong) id <MKAnnotation> selectedAnnotation;

@property (nonatomic, strong) NSArray *autoCompleteResults;

@property (nonatomic, strong) NSMutableArray *addedAnnotations;

@end

@implementation S2MShopFinderController

#pragma mark Searching

-(void)showResults:(NSArray*)results
{
    if (results) {
        if (self.searchMode == S2MShopFinderSearchModeUserLocation) {
            if(self.addedAnnotations){
                [self.mapView removeAnnotations:self.addedAnnotations];
            }
            if (self.customCalloutView) {
                [self.mapView removeAnnotation:self.customCalloutView.annotation];
                self.customCalloutView = nil;
            }
            [self.mapView addAnnotations:results];
            self.addedAnnotations = [NSMutableArray arrayWithArray:results];
            
            //show results + user location
            NSMutableArray *resultsAndUser = [NSMutableArray arrayWithArray:results];
            [resultsAndUser addObject:self.mapView.userLocation];
            
            self.loadPlacesForRegion = YES;
            [self.mapView showAnnotations:resultsAndUser animated:YES];
            
            
        }else if (self.searchMode == S2MShopFinderSearchModeDragging){
            //just add
            [self.mapView addAnnotations:results];
            [self.addedAnnotations addObjectsFromArray:results];
        }else{
            //keyword -> add and search
            if(self.addedAnnotations){
                if (self.customCalloutView) {
                    [self.mapView removeAnnotation:self.customCalloutView.annotation];
                    self.customCalloutView = nil;
                }
                [self.mapView removeAnnotations:self.addedAnnotations];
            }
            [self.mapView addAnnotations:results];
            self.addedAnnotations = [NSMutableArray arrayWithArray:results];
            self.loadPlacesForRegion = YES;
            [self.mapView showAnnotations:results animated:NO];
        }
    }else{
        if(self.addedAnnotations){
            [self.mapView removeAnnotations:self.addedAnnotations];
            [self.addedAnnotations removeAllObjects];
        }
        if (self.customCalloutView) {
            [self.mapView removeAnnotation:self.customCalloutView.annotation];
            self.customCalloutView = nil;
        }
        
        //show Alert
        [[[UIAlertView alloc] initWithTitle:self.textForNoResults message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        
    }
    
    [self.activityIndicator stopAnimating];
    self.isSearching = NO;
}

-(void)search
{
    if (self.isSearching) {
        return;
    }
    [self.activityIndicator startAnimating];
    
    if (self.searchMode == S2MShopFinderSearchModeKeyword) {
        if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(shopFinder:searchTerm:withResults:)]) {
            self.isSearching = YES;
            [self.searchDelegate shopFinder:self searchTerm:self.searchTerm withResults:^(NSArray *results) {
                [self showResults:results];
                if (results) {
                    [self mapView:self.mapView selectAnnotation:results.firstObject];
                }
            }];
        }
    }else if(self.searchMode == S2MShopFinderSearchModeUserLocation){
        self.isSearching = YES;
        if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(shopFinder:searchAtLocation:withResults:)]) {
            
            [self.searchDelegate shopFinder:self searchAtLocation:self.mapView.userLocation.location withResults:^(NSArray *results) {
                [self showResults:results];
            }];
        }
    }else{
        self.isSearching = YES;
        if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(shopFinder:searchRegion:withResults:)]) {
            
            [self.searchDelegate shopFinder:self searchRegion:self.mapView.region withResults:^(NSArray *results) {
                [self showResults:results];
            }];
        }
    }
}

-(void)searchWithTerm:(NSString*)term
{
    self.searchTerm = term;
    self.searchMode = S2MShopFinderSearchModeKeyword;
    [self search];
}

-(void)searchWithLocation:(CLLocation *)location
{
    self.searchBar.text = nil;
    self.searchMode = S2MShopFinderSearchModeUserLocation;
    self.userLocation = location;
    [self search];
}

#pragma mark Autocomplete

-(UITableView *)resultsTableView
{
    if(!_resultsTableView){
        _resultsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:_resultsTableView];
        
        _resultsTableView.delegate = self;
        _resultsTableView.dataSource = self;
        [_resultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCompleteIdentifier];
        _resultsTableView.rowHeight = 45;
        _resultsTableView.sectionHeaderHeight = 30;
        _resultsTableView.hidden = YES;
        _resultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.view sendSubviewToBack:_resultsTableView];
        
        //Layout
        NSMutableDictionary *views = [NSDictionaryOfVariableBindings(_resultsTableView, _searchBar) mutableCopy];
        [views setValue:self.bottomLayoutGuide forKey:@"bottom"];
        for (UIView *view in views.allValues) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchBar][_resultsTableView][bottom]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_resultsTableView]|" options:0 metrics:nil views:views]];
    }
    return _resultsTableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showsAutocompleteSections) {
        return self.autoCompleteResults.count;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.showsAutocompleteSections) {
        NSInteger count  = 0;
        if(self.searchBar.text.length > 0 && self.showsAutocompleteResults){
            count = self.autoCompleteResults.count;
        }
        
        //handle empty
        if(self.emptyTableView && !self.resultsTableView.hidden){
            [self showEmpty:count == 0];
        }
        return count;
    }else{
        NSInteger count  = 0;
        if(self.searchBar.text.length > 0 && self.showsAutocompleteResults){
            NSArray *sectionElements = [self.autoCompleteResults objectAtIndex:section];
            count = sectionElements.count;
        }
        
        //handle empty for sections
        if(self.emptyTableView && !self.resultsTableView.hidden){
            NSInteger totalcount = 0;
            for (NSArray *arr in self.autoCompleteResults) {
                totalcount += arr.count;
            }
            [self showEmpty:totalcount == 0];
        }
        return count;
    }
}

-(void)showEmpty:(BOOL)empty
{
    self.emptyTableView.hidden = !empty;
    
    if(empty){
        [self.view bringSubviewToFront:self.emptyTableView];
    }else{
        [self.view sendSubviewToBack:self.emptyTableView];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCompleteIdentifier forIndexPath:indexPath];
    
    if (!self.showsAutocompleteSections) {
        cell.textLabel.text = [self.autoCompleteResults objectAtIndex:indexPath.row];
    }else{
        NSArray *strings = [self.autoCompleteResults objectAtIndex:indexPath.section];
        cell.textLabel.text = [strings objectAtIndex:indexPath.row];
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    view.backgroundColor = [UIColor blueColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, tableView.sectionHeaderHeight)];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.translatesAutoresizingMaskIntoConstraints = YES;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    
    if ([self.autoCompleteDelegate respondsToSelector:@selector(shopFinder:titleInSection:)]) {
        label.text = [self.autoCompleteDelegate shopFinder:self titleInSection:section];
    }
    else{
        label.text =  [NSString stringWithFormat:@"Section: %li", (long)section];
    }
    return view;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    if([self.autoCompleteDelegate respondsToSelector:@selector(shopFinder:didSelectAutoCompleteTerm:inSection:)]){
        NSString *term;
        if (!self.showsAutocompleteSections) {
            term = [self.autoCompleteResults objectAtIndex:indexPath.row];
        }else{
            NSArray *strings = [self.autoCompleteResults objectAtIndex:indexPath.section];
            term = [strings objectAtIndex:indexPath.row];
        }
        self.searchBar.text = term;
        [self.autoCompleteDelegate shopFinder:self didSelectAutoCompleteTerm:term inSection:indexPath.section];
    }
}

-(void)showAutoCompleteForTerm:(NSString*)term
{    
    if([self.autoCompleteDelegate respondsToSelector:@selector(shopFinder:expectSections:autoCompleteResultsForTerm:)]){
        self.autoCompleteResults = [self.autoCompleteDelegate shopFinder:self expectSections:self.showsAutocompleteSections autoCompleteResultsForTerm:term];
        self.resultsTableView.hidden = NO;

        [self.view bringSubviewToFront:self.resultsTableView];
        [self.resultsTableView reloadData];
    }
}

-(void)hideAutocomplete
{
    self.resultsTableView.hidden = YES;
    [self.view sendSubviewToBack:self.resultsTableView];
    
    if(self.hidesLocateButtonWhenActive){
        self.locateButtonWidthConstraint.constant = locateButtonWidth;
        [self.toolBar setNeedsLayout];
    }
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    if(self.emptyTableView){
        [self showEmpty:NO];
    }
    self.searchBar.text = @"";
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchTerm = searchBar.text;
    self.searchMode = S2MShopFinderSearchModeKeyword;
    [self search];
    [self hideAutocomplete];
    
    [searchBar resignFirstResponder];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.placeholder = @"";
    
    if (self.hidesNavigationBarWhenActive) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if(self.hidesLocateButtonWhenActive){
        self.locateButtonWidthConstraint.constant = 0;
        [self.toolBar setNeedsLayout];
    }
    if(self.showsAutocompleteResults){
        [self showAutoCompleteForTerm:searchBar.text];
    }
    
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if (self.hidesNavigationBarWhenActive) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    return YES;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(self.showsAutocompleteResults){
        [self showAutoCompleteForTerm:searchText];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if(self.showsAutocompleteResults){
        [self hideAutocomplete];
    }
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if (bar == self.toolBar) {
        return UIBarPositionTopAttached;
    }else{
        return UIBarPositionAny;
    }
}

#pragma marm MKMapViewDelegate
//User Location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.searchMode == S2MShopFinderSearchModeUserLocation) {
    
        //only do another search if new location is 1km away
        if (!self.userLocation || [self.userLocation distanceFromLocation:userLocation.location] > 1000) {
            self.searchBar.text = nil;
            self.userLocation = userLocation.location;
            
            //do not search an recenter if user has selected an annotation
            if (!self.customCalloutView) {
                [self search];
            }
        }
    }
    self.userLocation = userLocation.location;
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    //TODO: Error handling needs to be defined
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    //Special Callout Annotation
    if([annotation isKindOfClass:[S2MCalloutAnnotation class]]){
        MKAnnotationView *callout = [self.mapSpecialsDelegate mapView:mapView calloutViewForAnnotation:annotation];
        self.customCalloutView = callout;
        return callout;
    }
    
    
    //Special Annotation for keyword search center
    if (annotation == self.searchLocation) {
        if (self.centerAnnotationImage) {
            MKAnnotationView *center = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            center.image = self.centerAnnotationImage;
            return center;
        }else{
            MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            pin.pinColor = MKPinAnnotationColorGreen;
            return pin;
        }
    }
    
    
    if (self.resultAnnotationActiveImage) {
        //custom Annotation
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotIdentifier];
        if (!view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotIdentifier];
        }else{
            view.annotation = annotation;
        }
        
        //active and inactive state
        if(self.customCalloutView){
            if(self.resultAnnotationInactiveImage && (annotation != self.selectedAnnotation)){
                view.image = self.resultAnnotationInactiveImage;
            }else{
                view.image = self.resultAnnotationActiveImage;
            }
        }else{
            view.image = self.resultAnnotationActiveImage;
        }
        view.calloutOffset = CGPointMake(0, -view.image.size.height);

        view.canShowCallout = NO;
        return view;
    }
    else{
        MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotIdentifier];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotIdentifier];
        }else{
            pin.annotation = annotation;
        }
        pin.canShowCallout = YES;
        return pin;
    }
    return nil;
}

//Annotations

-(void)mapView:(MKMapView*)mapView selectAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = [mapView viewForAnnotation:annotation];
    if (view) {
        [self mapView:mapView didSelectAnnotationView:view];
    }else{
        //force view
        view = [self mapView:mapView viewForAnnotation:annotation];
        if (view) {
            [self mapView:mapView didSelectAnnotationView:view];
        }
    }
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    if ([view.annotation isKindOfClass:[S2MCalloutAnnotation class]]) {
        return;
    }
    
    //deactivate all annotations
    if(self.resultAnnotationActiveImage && self.resultAnnotationInactiveImage){
        for (id <MKAnnotation> annotation in self.mapView.annotations){
            if(![annotation isKindOfClass:[MKUserLocation class]]){
                MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
                if(view != self.customCalloutView){
                    view.image = self.resultAnnotationInactiveImage;
                }
            }
        }
    }
    //activate the selected again
    if (self.resultAnnotationActiveImage) {
        view.image = self.resultAnnotationActiveImage;
    }
    self.selectedAnnotation = view.annotation;
    
    if (self.customCalloutView) {
        [self.mapView removeAnnotation:self.customCalloutView.annotation];
        self.customCalloutView = nil;
    }
    
    //add custom annotation if implemented
    if(self.mapSpecialsDelegate && [self.mapSpecialsDelegate respondsToSelector:@selector(mapView:calloutViewForAnnotation:)]){
        S2MCalloutAnnotation *callout = [[S2MCalloutAnnotation alloc] initWithAnnotation:view.annotation];
        [self.mapView addAnnotation:callout];
        
        [self.mapView showAnnotations:@[self.selectedAnnotation, callout] animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([self.mapSpecialsDelegate respondsToSelector:@selector(mapView:calloutViewWasTappedForAnnotation:)]){
        [self.mapSpecialsDelegate mapView:mapView calloutViewWasTappedForAnnotation:view.annotation];
    }
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    //start new search
    self.isMapRendered = YES;
}


-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if (!animated && self.isMapRendered) {
        self.searchMode = S2MShopFinderSearchModeDragging;
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (self.searchMode == S2MShopFinderSearchModeDragging && !animated) {
        [self search];
    }else if(self.loadPlacesForRegion) {
        
        [self.searchDelegate shopFinder:self searchRegion:mapView.region withResults:^(NSArray *results) {
            self.loadPlacesForRegion = NO;
            [self.mapView addAnnotations:results];
            [self.addedAnnotations addObjectsFromArray:results];
        }];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if (self.loadPlacesForRegion) {
        [self.searchDelegate shopFinder:self searchRegion:mapView.region withResults:^(NSArray *results) {
            self.loadPlacesForRegion = NO;
            [self.mapView addAnnotations:results];
            [self.addedAnnotations addObjectsFromArray:results];
        }];
    }
}


#pragma mark Authorization

-(BOOL)authorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES;
        case kCLAuthorizationStatusDenied:
            [self askForAuthorhization];
            return NO;
        case kCLAuthorizationStatusRestricted:
            [self askForAuthorhization];
            return NO;
        default:
            return NO;
    }
}

-(void)askForAuthorhization
{
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.manager requestWhenInUseAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapView.showsUserLocation = YES;
    }
    [self search];
}

-(void)relocate:(id)sender
{
    if(![self authorized]){
        [self askForAuthorhization];
    }
    else{
        self.mapView.showsUserLocation = YES;
        BOOL forceSearch = (sender != nil);
        if (self.mapView.userLocation.location && (!self.customCalloutView || forceSearch)) {
            [self searchWithLocation:self.mapView.userLocation.location];
        }
    }
}

-(void)startLocatingIgnoreSelection:(BOOL)ignore
{
    if (ignore) {
        [self relocate:self];
    }else{
        [self relocate:nil];
    }
}

#pragma mark UI

- (void)addElements
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchBar.delegate = self;
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    
    if (self.locateButtonImage) {
        self.locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.locateButton setImage:self.locateButtonImage forState:UIControlStateNormal];
    }else{
        self.locateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.locateButton setTitle:@"reload" forState:UIControlStateNormal];
    }
    self.locateButton.clipsToBounds = YES;
    [self.locateButton addTarget:self action:@selector(relocate:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolBar = [[UIToolbar alloc] init];
    [self.toolBar addSubview:self.searchBar];
    [self.toolBar addSubview:self.locateButton];
    self.toolBar.delegate = self;
    
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.activityIndicator];
    
    //empty table
    if(self.emptyTableView){
        [self.view addSubview:self.emptyTableView];
        self.emptyTableView.hidden = YES;
        [self.view sendSubviewToBack:self.emptyTableView];
    }
}

- (void)addLayout
{
    NSMutableDictionary *views = [NSDictionaryOfVariableBindings(_mapView, _searchBar, _activityIndicator, _toolBar, _locateButton) mutableCopy];
    [views setObject:self.topLayoutGuide forKey:@"_top"];
    for (UIView *view in views.allValues) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    //MapView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:0 metrics:nil views:views]];
   
    //Toolbar
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_top][_toolBar(44)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolBar]|" options:0 metrics:nil views:views]];
    
    //Activity Indicator
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.view addConstraints:@[centerXConstraint, centerYConstraint]];
    
    //Toolbar Subviews
    [self.toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_searchBar]-(5)-[_locateButton]-(5)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_locateButton]|" options:0 metrics:nil views:views]];
    
    
    self.locateButtonWidthConstraint = [NSLayoutConstraint  constraintWithItem:self.locateButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:locateButtonWidth];
    [self.toolBar addConstraint:self.locateButtonWidthConstraint];
    
    if(self.emptyTableView){
        [views setObject:self.emptyTableView forKey:@"_empty"];
        [views setValue:self.bottomLayoutGuide forKey:@"bottom"];
        for (UIView *view in views.allValues) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchBar][_empty][bottom]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_empty]|" options:0 metrics:nil views:views]];
    }
}

#pragma mark Defaults
-(void)initDefaults
{
    self.hidesNavigationBarWhenActive = YES;
    self.showsAutocompleteResults = NO;
    self.showsAutocompleteSections = NO;
    self.searchMode = S2MShopFinderSearchModeUserLocation;
    self.textForNoResults = @"No results found. Customize text in subclass or property.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addElements];
    [self addLayout];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startLocatingIgnoreSelection:NO];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self initDefaults];
    }
    return self;
}


@end
