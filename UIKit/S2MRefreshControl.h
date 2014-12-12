//
//  S2MRefreshControl.h
//  S2MToolbox
//
//  Created by François Benaiteau on 15/08/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol S2MControlLoadingView <NSObject>

- (void)startAnimating;
- (void)stopAnimating;
- (void)animateWithFractionDragged:(CGFloat)fractionDragged;
@end
/**
 *  Custom Refresh Control that can be added on a UIScrollview based class. i.e. UICollectionView
 */
@interface S2MRefreshControl : UIControl
@property(nonatomic, strong, readonly)UIView* loadingView;
@property(nonatomic, assign)CGFloat refreshControlHeight;
@property(nonatomic, assign)CGFloat startLoadingThreshold;
- (void)endRefreshing;
- (void)beginRefreshing;
- (BOOL)isRefreshing;

/**
 *  Initialize refresh control with a custom view to animate
 *
 *  @param loadingView UIImageView or view conforming to S2MControlLoadingView. The view will be animated while pulling.
 *                     In case of imageView, image will be rotated.
 *
 *  @return instance of refreshControl
 */
- (instancetype)initWithLoadingView:(UIView*)loadingView NS_DESIGNATED_INITIALIZER;
@end
