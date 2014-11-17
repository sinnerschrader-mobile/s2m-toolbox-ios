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

const CGFloat locateButtonWidth = 44.0f;

@interface S2MCalloutAnnotation : NSObject <MKAnnotation>

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@implementation S2MCalloutAnnotation

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation{
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

@end

@interface S2MShopFinderController ()<UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

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
@property (nonatomic, assign) BOOL mapIsRendered;

@property (nonatomic, copy) NSString *searchTerm;

//internal Data
@property (nonatomic, strong) MKAnnotationView *customCallout;
@property (nonatomic, strong) NSArray *autoCompleteResults;

@end

@implementation S2MShopFinderController

#pragma mark Searching

-(void)showResults:(NSArray*)results
{
    if (self.searchMode == S2MShopFinderSearchModeUserLocation) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:results];
        [self.mapView showAnnotations:results animated:YES];
    }else if (self.searchMode == S2MShopFinderSearchModeDragging){
        //just add, but not center

        
        [self.mapView addAnnotations:results];
    }else{
        //keyword -> add and search
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:results];
        [self.mapView showAnnotations:results animated:YES];
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
            [self.searchDelegate shopFinder:self searchTerm:self.searchTerm withResults:^(NSArray *results, id<MKAnnotation> center) {
                
                self.searchLocation = center;
                NSMutableArray *combinedResults = [NSMutableArray arrayWithArray:results];
                [combinedResults addObject:center];
                [self showResults:combinedResults];
            }];
        }
    }else if(self.searchMode == S2MShopFinderSearchModeUserLocation){
        self.isSearching = YES;
        if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(shopFinder:searchRegion:withResults:)]) {
            
            //Create Region
            MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
            MKCoordinateRegion region = MKCoordinateRegionMake(self.userLocation.coordinate, span);
            [self.searchDelegate shopFinder:self searchRegion:region withResults:^(NSArray *results) {
                [self showResults:results];
            }];
        }
    }else{
        if (self.userLocation) {
            self.isSearching = YES;
            if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(shopFinder:searchRegion:withResults:)]) {
                
                [self.searchDelegate shopFinder:self searchRegion:self.mapView.region withResults:^(NSArray *results) {
                    [self showResults:results];
                }];
            }
        }
    }
}

-(void)searchWithTerm:(NSString*)term{
    self.searchTerm = term;
    self.searchMode = S2MShopFinderSearchModeKeyword;
    [self search];
}

-(void)searchWithLocation:(CLLocation *)location{
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
        _resultsTableView.rowHeight = 44;
        _resultsTableView.hidden = YES;
        [self.view sendSubviewToBack:_resultsTableView];
        
        //Layout
        NSMutableDictionary *views = [NSDictionaryOfVariableBindings(_resultsTableView, _searchBar) mutableCopy];
        for (UIView *view in views.allValues) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchBar][_resultsTableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_resultsTableView]|" options:0 metrics:nil views:views]];
    }
    return _resultsTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchBar.text.length > 0 && self.showsAutocompleteResults){
        return self.autoCompleteResults.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCompleteIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.autoCompleteResults objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    if([self.autoCompleteDelegate respondsToSelector:@selector(shopFinder:didSelectAutoCompleteTerm:)]){
        NSString *term = [self.autoCompleteResults objectAtIndex:indexPath.row];
        self.searchBar.text = term;
        [self.autoCompleteDelegate shopFinder:self didSelectAutoCompleteTerm:term];
    }
}

-(void)showAutoCompleteForTerm:(NSString*)term
{
    
    if([self.autoCompleteDelegate respondsToSelector:@selector(shopFinder:autoCompleteResultsForTerm:)]){
        self.autoCompleteResults = [self.autoCompleteDelegate shopFinder:self autoCompleteResultsForTerm:term];
        self.resultsTableView.hidden = NO;

        [self.view bringSubviewToFront:self.resultsTableView];
        [self.resultsTableView reloadData];
    }
}

-(void)hideAutocomplete{
    self.resultsTableView.hidden = YES;
    [self.view sendSubviewToBack:self.resultsTableView];
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
    if(self.hidesLocateButtonWhenActive){
        self.locateButtonWidthConstraint.constant = locateButtonWidth;
        [self.toolBar setNeedsLayout];
    }
    [searchBar setShowsCancelButton:NO animated:YES];
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

#pragma marm Map Delegate
//User Location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.searchMode == S2MShopFinderSearchModeUserLocation) {
    
        //only do another search if new location is 1km away
        if (!self.userLocation || [self.userLocation distanceFromLocation:userLocation.location] > 1000) {
            self.searchBar.text = nil;
            self.searchBar.placeholder = userLocation.title;
            self.userLocation = userLocation.location;
            [self search];
        }
    }
    self.userLocation = userLocation.location;
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    //TODO
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
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
    
    //Special Callout Annotation
    if([annotation isKindOfClass:[S2MCalloutAnnotation class]]){
        MKAnnotationView *callout = [self.mapSpecialsDelegate mapView:mapView calloutViewForAnnotation:annotation];
        self.customCallout = callout;
        return callout;
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
        if(self.customCallout){
            if(self.resultAnnotationInactiveImage && (annotation != self.customCallout.annotation)){
                view.image = self.resultAnnotationInactiveImage;
            }else{
                view.image = self.resultAnnotationActiveImage;
            }
        }else{
            view.image = self.resultAnnotationActiveImage;
        }
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
        pin.canShowCallout = NO;
        return pin;
    }
    return nil;
}

//Annotations
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //deactivate all annotations
    if(self.resultAnnotationActiveImage && self.resultAnnotationInactiveImage){
        for (id <MKAnnotation> annotation in self.mapView.annotations){
            MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
            if(view != self.customCallout){
                view.image = self.resultAnnotationInactiveImage;
            }
        }
    }
    //activate the selected again
    view.image = self.resultAnnotationActiveImage;
    
    
    if (self.customCallout) {
        [self.mapView removeAnnotation:self.customCallout.annotation];
        self.customCallout = nil;
    }
    
    //add custom annotation if implemented
    if(self.mapSpecialsDelegate && [self.mapSpecialsDelegate respondsToSelector:@selector(mapView:calloutViewForAnnotation:)]){
    
        S2MCalloutAnnotation *callout = [[S2MCalloutAnnotation alloc] initWithAnnotation:view.annotation];
        [self.mapView addAnnotation:callout];
        [self.mapView showAnnotations:@[callout] animated:YES];
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
    self.mapIsRendered = YES;
}


-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if (!animated && self.mapIsRendered) {
        self.searchMode = S2MShopFinderSearchModeDragging;
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (self.searchMode == S2MShopFinderSearchModeDragging && !animated) {
        [self search];
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
        [self searchWithLocation:self.mapView.userLocation.location];
    }
}

#pragma mark Defaults

-(void)initDefaults
{
    self.hidesNavigationBarWhenActive = YES;
    self.showsAutocompleteResults = NO;
    self.searchMode = S2MShopFinderSearchModeUserLocation;
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
    
    self.locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locateButton.clipsToBounds = YES;
    [self.locateButton addTarget:self action:@selector(relocate:) forControlEvents:UIControlEventTouchUpInside];
    [self.locateButton setImage:self.locateButtonImage forState:UIControlStateNormal];
    
    self.toolBar = [[UIToolbar alloc] init];
    [self.toolBar addSubview:self.searchBar];
    [self.toolBar addSubview:self.locateButton];
    
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.activityIndicator];
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
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self askForAuthorhization];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addElements];
    [self addLayout];
    [self initDefaults];
}


@end
