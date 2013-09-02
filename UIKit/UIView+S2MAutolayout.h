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

#pragma mark - Center Position
-(NSArray*)s2m_addCenterInSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addCenterYInSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addCenterXInSuperViewConstraint;

#pragma mark - Full Size
-(NSLayoutConstraint*)s2m_addFullWidthWithSuperViewConstraint;
-(NSLayoutConstraint*)s2m_addFullHeightWithSuperViewConstraint;

#pragma mark - Specific Position
-(NSLayoutConstraint*)s2m_addTopConstraint:(CGFloat)constant;
-(NSLayoutConstraint*)s2m_addBottomConstraint:(CGFloat)constant;
-(NSLayoutConstraint*)s2m_addLeftConstraint:(CGFloat)constant;
-(NSLayoutConstraint*)s2m_addRightConstraint:(CGFloat)constant;

#pragma mark - Specific Height
-(NSLayoutConstraint*)s2m_addHeightConstraint:(CGFloat)height;
-(NSLayoutConstraint*)s2m_addMinHeightConstraint:(CGFloat)height;
-(NSLayoutConstraint*)s2m_addMaxHeightConstraint:(CGFloat)height;

#pragma mark - Specific Width
-(NSLayoutConstraint*)s2m_addWidthConstraint:(CGFloat)width;
-(NSLayoutConstraint*)s2m_addMinWidthConstraint:(CGFloat)width;
-(NSLayoutConstraint*)s2m_addMaxWidthConstraint:(CGFloat)width;
@end
