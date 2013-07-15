//
//  UIView+S2MAutolayout.m
//
//
//  Created by François Benaiteau on 5/28/13.
//  Copyright (c) 2013 SinnerSchrader Mobile. All rights reserved.
//

#import "UIView+S2MAutolayout.h"

@implementation UIView (S2MAutolayout)

-(void)s2m_addCenterInSuperViewConstraint
{
    if (!self.superview) {
        return;
    }

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* centerXConstraint = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0];
    NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0];

    [self.superview addConstraint:centerXConstraint];
    [self.superview addConstraint:centerYConstraint];
}

-(void)s2m_addCenterYInSuperViewConstraint
{
    if (!self.superview) {
        return;
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
}

-(void)s2m_addCenterXInSuperViewConstraint
{
    if (!self.superview) {
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    
    
    [self.superview addConstraint:centerYConstraint];
}

@end
