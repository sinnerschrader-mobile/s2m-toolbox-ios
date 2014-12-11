//
//  S2MRefreshControl.h
//  S2MToolbox
//
//  Created by François Benaiteau on 15/08/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const S2MRefreshControlHeight;
/**
 *  Custom Refresh Control that can be added on a UIScrollview based class. i.e. UICollectionView
 */
@interface S2MRefreshControl : UIControl
@property(nonatomic, strong, readonly)UIImageView* loadingImage;
@property(nonatomic, strong, readonly)UIActivityIndicatorView* indicatorView;
- (void)endRefreshing;
- (void)beginRefreshing;
- (BOOL)isRefreshing;
/**
 *  Initialize refresh control with a custom image to rotate
 *
 *  @param image image to rotate while pulling. If nil, UIActivityIndictator is used
 *
 *  @return instance of refreshControl
 */
- (instancetype)initWithImage:(UIImage*)image NS_DESIGNATED_INITIALIZER;
@end
