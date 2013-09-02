//
//  UIView+S2MAutolayout.h
//
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (S2MAutolayout)

-(NSArray*)s2m_addPositionAndSizeOfSuperViewConstraint;

#pragma mark - Position
-(NSArray*)s2m_addCenterInSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addCenterYInSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addCenterXInSuperViewConstraint;


#pragma mark - Size
-(NSLayoutConstraint*)s2m_addFullWidthWithSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addFullHeightWithSuperViewConstraint;

@end
