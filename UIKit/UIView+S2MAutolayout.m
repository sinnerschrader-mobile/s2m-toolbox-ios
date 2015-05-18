//
//  UIView+S2MAutolayout.m
//  S2MToolbox
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "UIView+S2MAutolayout.h"

@implementation UIView (S2MAutolayout)


-(NSArray*)s2m_addPositionAndSizeOfSuperViewConstraint
{
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    NSArray* horizontalConstraints = [self s2m_addLeftRightConstraint:0];
    if (horizontalConstraints) {
        [constraints addObjectsFromArray:horizontalConstraints];
    }
    NSArray* verticalConstraints = [self s2m_addTopBottomConstraint:0];
    if (verticalConstraints) {
        [constraints addObjectsFromArray:verticalConstraints];
    }
    
    return constraints;
}

#pragma mark - Position

-(NSArray*)s2m_addCenterInSuperViewConstraint
{
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    NSLayoutConstraint* constraint = [self s2m_addCenterXInSuperViewConstraint];
    if (constraint) {
        [constraints addObject:constraint];
    }
    
    constraint = [self s2m_addCenterYInSuperViewConstraint];
    if (constraint) {
        [constraints addObject:constraint];
    }
    return constraints;
}

-(NSLayoutConstraint*)s2m_addCenterYInSuperViewConstraint
{
    if (!self.superview) {
        return nil;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0];
    
    
    [self.superview addConstraint:centerYConstraint];
    return centerYConstraint;
}

-(NSLayoutConstraint*)s2m_addCenterXInSuperViewConstraint
{
    if (!self.superview) {
        return nil;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* centerXconstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    
    
    [self.superview addConstraint:centerXconstraint];
    return centerXconstraint;
}


#pragma mark - Size

-(NSLayoutConstraint*)s2m_addFullWidthWithSuperViewConstraint
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* fullWithConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.superview
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0
                                                                           constant:0];
    
    [self.superview addConstraint:fullWithConstraint];
    return fullWithConstraint;
}

-(NSLayoutConstraint*)s2m_addFullHeightWithSuperViewConstraint
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* fullHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.superview
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:0];
    
    [self.superview addConstraint:fullHeightConstraint];
    return fullHeightConstraint;
}

#pragma mark - Specific Position

-(NSLayoutConstraint*)s2m_addTopConstraint:(CGFloat)constant
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:constant];
    
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint*)s2m_addBottomConstraint:(CGFloat)constant
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.superview
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:constant];
    
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint*)s2m_addLeftConstraint:(CGFloat)constant
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:constant];
    
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint*)s2m_addRightConstraint:(CGFloat)constant
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.superview
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:constant];
    
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSArray*)s2m_addLeftRightConstraint:(CGFloat)constant
{
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    NSLayoutConstraint* constraint = [self s2m_addLeftConstraint:constant];
    if(constraint){
        [constraints addObject:constraint];
    }
    constraint = [self s2m_addRightConstraint:constant];
    if(constraint){
        [constraints addObject:constraint];
    }
    return constraints;
}

-(NSArray*)s2m_addTopBottomConstraint:(CGFloat)constant
{
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    NSLayoutConstraint* constraint = [self s2m_addTopConstraint:constant];
    if(constraint){
        [constraints addObject:constraint];
    }
    constraint = [self s2m_addBottomConstraint:constant];
    if(constraint){
        [constraints addObject:constraint];
    }
    return constraints;
}

- (NSLayoutConstraint *)s2m_addLeadingConstraint:(CGFloat)constant
{
	if (!self.superview) {
		return nil;
	}
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
																  attribute:NSLayoutAttributeLeading
																  relatedBy:NSLayoutRelationEqual
																	 toItem:self.superview
																  attribute:NSLayoutAttributeLeading
																 multiplier:1.0
																   constant:constant];
	
	[self.superview addConstraint:constraint];
	return constraint;
}

- (NSLayoutConstraint *)s2m_addTrailingConstraint:(CGFloat)constant
{
	if (!self.superview) {
		return nil;
	}
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
																  attribute:NSLayoutAttributeTrailing
																  relatedBy:NSLayoutRelationEqual
																	 toItem:self.superview
																  attribute:NSLayoutAttributeTrailing
																 multiplier:1.0
																   constant:constant];
	
	[self.superview addConstraint:constraint];
	return constraint;
}



#pragma mark - Specific Height

-(NSLayoutConstraint*)s2m_addHeightConstraint:(CGFloat)height
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:height];
    [self.superview addConstraint:heightConstraint];
    return heightConstraint;
}

-(NSLayoutConstraint*)s2m_addMinHeightConstraint:(CGFloat)height
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:height];
    [self.superview addConstraint:heightConstraint];
    return heightConstraint;
}

-(NSLayoutConstraint*)s2m_addMaxHeightConstraint:(CGFloat)height
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:height];
    [self.superview addConstraint:heightConstraint];
    return heightConstraint;
}


#pragma mark - Specific Width

-(NSLayoutConstraint*)s2m_addWidthConstraint:(CGFloat)width
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:width];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint*)s2m_addMinWidthConstraint:(CGFloat)width
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:width];
    [self.superview addConstraint:constraint];
    return constraint;
    
}

-(NSLayoutConstraint*)s2m_addMaxWidthConstraint:(CGFloat)width
{
    if (!self.superview) {
        return nil;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:width];
    [self.superview addConstraint:constraint];
    return constraint;
}

@end
