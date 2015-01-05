//
//  S2MCollectionViewController.m
//  S2MToolbox
//
//  Created by François Benaiteau on 11/12/14.
//  Copyright (c) 2014 Sinnerschrader Mobile. All rights reserved.
//

#import "S2MCollectionViewController.h"

#import <S2MToolbox/S2MRefreshControl.h>
#import "S2MTextLoadingView.h"

@interface S2MCollectionViewController ()
@property(nonatomic, strong)S2MRefreshControl* refreshControl;
@property(nonatomic, assign)BOOL useCustomRefreshControl;

@end

@implementation S2MCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

+(instancetype)sampleCollectionViewController
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
    S2MCollectionViewController* vc = [[self.class alloc] initWithCollectionViewLayout:flowLayout];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.useCustomRefreshControl = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(togglePullToRefresh:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)pullToRefresh:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

- (void)togglePullToRefresh:(id)sender
{
    self.useCustomRefreshControl = !self.useCustomRefreshControl;
}

- (void)setUseCustomRefreshControl:(BOOL)customRefreshControl
{
    _useCustomRefreshControl = customRefreshControl;
    if (self.refreshControl) {
        [self.refreshControl removeFromSuperview];
    }
    if (customRefreshControl) {
        S2MTextLoadingView* loadingView = [[S2MTextLoadingView alloc] init];
        self.refreshControl = [[S2MRefreshControl alloc] initWithLoadingView:loadingView];
    }else{
        UIImage* image = [UIImage imageNamed:@"loading_indicator"];
        self.refreshControl = [[S2MRefreshControl alloc] initWithLoadingImage:image];
    }
    self.refreshControl.startLoadingThreshold += 20;// section inset
    [self.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // see https://gist.github.com/kylefox/1689973
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    cell.backgroundColor = color;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"still called even if delegate of collectionView is refreshControl!");
    NSLog(@"self:%@", self);
    NSLog(@"refreshControl:%@", self.refreshControl);
    NSLog(@"collectionView delegate:%@", collectionView.delegate);
    
}

#pragma mark

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
