//
//  S2MFoldAnimator.m
//  S2MToolbox
//
//  Created by François Benaiteau on 23/07/14.
//  Copyright (c) 2014 SinnerSchrader Mobile. All rights reserved.
//


#import "S2MFoldAnimator.h"

@implementation S2MFoldAnimator

- (id)init
{
    self = [super init];
    if (self) {
        self.folds = 1;
        self.unfolding = YES;
        self.direction = S2MFoldAnimatorDirectionRightToLeft;
    }
    return self;
}

-(instancetype)initWithFolds:(NSUInteger)folds direction:(S2MFoldAnimatorDirection)direction unfolding:(BOOL)unfolding
{
    self = [super init];
    if (self) {
        self.folds = folds;
        self.unfolding = unfolding;
        self.direction = direction;
    }
    return self;
}

#pragma mark - Public


- (void)animateWithDuration:(NSTimeInterval)duration
                       view:(UIView *)view
              containerView:(UIView*)containerView
                 completion:(void (^)(BOOL finished))completion
{
    __block CGPoint viewOrigin;
    __block CGSize viewSize;
    __block CGFloat viewFoldMeasure;
    __block NSMutableArray* viewFolds;
    [UIView performWithoutAnimation:^{
        if (view.superview == nil) {
            [containerView addSubview:view];
        }
        viewSize = view.bounds.size;
        viewOrigin = view.frame.origin;
        // Add a perspective transform
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -0.005;
        containerView.layer.sublayerTransform = transform;
        
        viewFoldMeasure = [self foldMeasureForView:view];
        
        // arrays that hold the snapshot views
        viewFolds = [NSMutableArray new];
        for (NSUInteger i = 0 ; i < self.folds; i++){
            CGFloat viewOffset = (CGFloat)i * viewFoldMeasure * 2;
            
            UIView *leadingViewFold = [self createSnapshotFromView:view
                                                      afterUpdates:self.unfolding
                                                          offset:viewOffset
                                                           leading:YES];
            leadingViewFold.layer.position = [self initialPositionInView:view
                                                                 leading:YES
                                                              foldOffset:viewOffset
                                                             foldMeasure:viewFoldMeasure];
            [self applyTransformForView:leadingViewFold leading:YES initial:YES];
            [viewFolds addObject:leadingViewFold];
            if (!self.unfolding) {
                [leadingViewFold.subviews[1] setAlpha:0.0];
            }
            
            UIView *trailingViewFold = [self createSnapshotFromView:view
                                                       afterUpdates:self.unfolding
                                                           offset:viewOffset + viewFoldMeasure
                                                            leading:NO];
            trailingViewFold.layer.position = [self initialPositionInView:view
                                                                  leading:NO
                                                               foldOffset:viewOffset
                                                              foldMeasure:viewFoldMeasure];
            [self applyTransformForView:trailingViewFold leading:NO initial:YES];
            [viewFolds addObject:trailingViewFold];
            if (!self.unfolding) {
                [trailingViewFold.subviews[1] setAlpha:0.0];
            }
        }
        view.hidden = YES;
        
    }];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionLayoutSubviews| UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // set the final state for each fold
                         for (NSUInteger i = 0 ; i < self.folds; i++){
                             CGFloat viewOffset = (CGFloat)i * viewFoldMeasure * 2;
                             
                             UIView *leadingViewFold = viewFolds[i*2];
                             leadingViewFold.layer.position = [self finalPositionInView:view
                                                                                leading:YES
                                                                             foldOffset:viewOffset
                                                                            foldMeasure:viewFoldMeasure];
                             [self applyTransformForView:leadingViewFold leading:YES initial:NO];
                             [leadingViewFold.subviews[1] setAlpha:(self.unfolding) ? 0.0 : 1.0];
                             
                             UIView *trailingViewFold =  viewFolds[i*2+1];
                             trailingViewFold.layer.position = [self finalPositionInView:view
                                                                                 leading:NO
                                                                              foldOffset:viewOffset
                                                                             foldMeasure:viewFoldMeasure];
                             [self applyTransformForView:trailingViewFold leading:NO initial:NO];
                             [trailingViewFold.subviews[1] setAlpha:(self.unfolding) ? 0.0 : 1.0];
                         }
                     }  completion:^(BOOL finished) {
                         [UIView performWithoutAnimation:^{
                             // restore the to- and from- to the initial location
                             if (self.unfolding) {
                                 // put back toView frame to expected location
                                 view.frame = CGRectMake(viewOrigin.x, viewOrigin.y, viewSize.width, viewSize.height);
                             }else{
                                 if (self.direction == S2MFoldAnimatorDirectionRightToLeft) {
                                     view.frame = CGRectMake(viewOrigin.x, viewOrigin.y, 0, viewSize.height);
                                 }else if (self.direction == S2MFoldAnimatorDirectionLeftToRight) {
                                     view.frame = CGRectMake(viewOrigin.x + viewSize.width, viewOrigin.y, 0, viewSize.height);
                                 }else{
                                     // Disable this in order not to break constraints
                                 }
                             }
                             view.hidden = NO;
                             // remove the snapshot views
                             for (UIView *view in viewFolds) {
                                 [view removeFromSuperview];
                             }
                         }];
                         
                         if(completion){
                             completion(finished);
                         }
                     }];
}

#pragma mark - Private

-(CGPoint)initialPositionInView:(UIView*)view leading:(BOOL)leading foldOffset:(CGFloat)foldOffset foldMeasure:(CGFloat)foldMeasure
{
    CGFloat middleY = view.frame.origin.y + (view.frame.size.height / 2);
    CGFloat middleX = view.frame.origin.x + (view.frame.size.width / 2);
    CGPoint point = CGPointZero;
    if (self.unfolding) {
        switch (self.direction) {
            case S2MFoldAnimatorDirectionRightToLeft:
                point = CGPointMake(CGRectGetMaxX(view.frame), middleY);
                break;
            case S2MFoldAnimatorDirectionLeftToRight:
                point = CGPointMake(CGRectGetMinX(view.frame), middleY);
                break;
            case S2MFoldAnimatorDirectionTopToBottom:
                point = CGPointMake(middleX, CGRectGetMinY(view.frame));
                break;
            case S2MFoldAnimatorDirectionBottomToTop:
                point = CGPointMake(middleX, CGRectGetMaxY(view.frame));
                break;
                
            default:
                break;
        }
    }else{
        switch (self.direction) {
            case S2MFoldAnimatorDirectionRightToLeft:
            case S2MFoldAnimatorDirectionLeftToRight:
                if (leading) {
                    point = CGPointMake(CGRectGetMinX(view.frame) + foldOffset, middleY);
                }else{
                    point = CGPointMake(CGRectGetMinX(view.frame) + foldOffset + foldMeasure*2, middleY);
                }
                break;
            case S2MFoldAnimatorDirectionTopToBottom:
            case S2MFoldAnimatorDirectionBottomToTop:
                if (leading) {
                    point = CGPointMake(middleX, CGRectGetMinY(view.frame) + foldOffset);
                }else{
                    point = CGPointMake(middleX, CGRectGetMinY(view.frame) + foldOffset + foldMeasure*2);
                }
                break;
                
            default:
                break;
        }
    }
    return point;
}


-(CGPoint)finalPositionInView:(UIView*)view leading:(BOOL)leading foldOffset:(CGFloat)foldOffset foldMeasure:(CGFloat)foldMeasure
{
    CGFloat middleY = view.frame.origin.y + (view.frame.size.height / 2);
    CGFloat middleX = view.frame.origin.x + (view.frame.size.width / 2);
    CGPoint point = CGPointZero;
    if (self.unfolding) {
        switch (self.direction) {
            case S2MFoldAnimatorDirectionRightToLeft:
            case S2MFoldAnimatorDirectionLeftToRight:
                if (leading) {
                    point = CGPointMake(CGRectGetMinX(view.frame) + foldOffset, middleY);
                }else{
                    point = CGPointMake(CGRectGetMinX(view.frame) + foldOffset + foldMeasure*2, middleY);
                }
                break;
            case S2MFoldAnimatorDirectionTopToBottom:
            case S2MFoldAnimatorDirectionBottomToTop:
                if (leading) {
                    point = CGPointMake(middleX, CGRectGetMinY(view.frame) + foldOffset);
                }else{
                    point = CGPointMake(middleX, CGRectGetMinY(view.frame) + foldOffset + foldMeasure * 2);
                }
                break;
                
            default:
                break;
        }
    }else{
        switch (self.direction) {
            case S2MFoldAnimatorDirectionRightToLeft:
                point = CGPointMake(CGRectGetMinX(view.frame), middleY);
                break;
            case S2MFoldAnimatorDirectionLeftToRight:
                point = CGPointMake(CGRectGetMaxX(view.frame), middleY);
                break;
            case S2MFoldAnimatorDirectionTopToBottom:
                point = CGPointMake(middleX, CGRectGetMaxY(view.frame));
                break;
            case S2MFoldAnimatorDirectionBottomToTop:
                point = CGPointMake(middleX, CGRectGetMinY(view.frame));
                break;
                
            default:
                break;
        }
    }
    return point;
}

- (void)applyTransformForView:(UIView*)view leading:(BOOL)leading initial:(BOOL)initial
{
    switch (self.direction) {
        case S2MFoldAnimatorDirectionRightToLeft:
        case S2MFoldAnimatorDirectionLeftToRight:
            if (self.unfolding && initial) {
                view.layer.transform = (leading) ? CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 0.0) : CATransform3DMakeRotation(-M_PI_2, 0.0, 1.0, 0.0);
            }else if (!initial) {
                if (self.unfolding) {
                    view.layer.transform = CATransform3DIdentity;
                }else{
                    view.layer.transform =  (leading) ? CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0.0, 1.0, 0) : CATransform3DRotate(CATransform3DIdentity, -M_PI_2, 0.0, 1.0, 0);
                }
            }
            break;
        case S2MFoldAnimatorDirectionTopToBottom:
        case S2MFoldAnimatorDirectionBottomToTop:
            if (self.unfolding && initial) {
                view.layer.transform = (leading) ? CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0) : CATransform3DMakeRotation(M_PI_2, 1.0, 0.0, 0.0);
            }else if (!self.unfolding && !initial) {
                view.layer.transform = (leading) ? CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0) : CATransform3DMakeRotation(M_PI_2, 1.0, 0.0, 0.0);
            }else {
                view.layer.transform = CATransform3DIdentity;
            }
            break;
            
        default:
            break;
    }
}

- (CGFloat)foldMeasureForView:(UIView*)view
{
    switch (self.direction) {
        case S2MFoldAnimatorDirectionRightToLeft:
        case S2MFoldAnimatorDirectionLeftToRight:
            return view.frame.size.width * 0.5 / (CGFloat)self.folds;
            break;
        case S2MFoldAnimatorDirectionTopToBottom:
        case S2MFoldAnimatorDirectionBottomToTop:
            return view.frame.size.height * 0.5 / (CGFloat)self.folds;
            break;
            
        default:
            break;
    }
    return 0;
    
}

#pragma mark Helper

- (UIView*)createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates offset:(CGFloat)offset leading:(BOOL)leading
{
    switch (self.direction) {
        case S2MFoldAnimatorDirectionRightToLeft:
        case S2MFoldAnimatorDirectionLeftToRight:
            return [self createSnapshotFromView:view afterUpdates:afterUpdates horizontalOffset:offset left:leading];
            break;
        case S2MFoldAnimatorDirectionTopToBottom:
        case S2MFoldAnimatorDirectionBottomToTop:
            return [self createSnapshotFromView:view afterUpdates:afterUpdates verticalOffset:offset top:leading];
            break;
            
        default:
            break;
    }
    return nil;
}

- (UIView*)createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates verticalOffset:(CGFloat)verticalOffset top:(BOOL)top
{
    
    CGSize size = view.frame.size;
    UIView *containerView = view.superview;
    float foldHeight = [self foldMeasureForView:view];
    
    UIView* snapshotView;
    
    if (!afterUpdates) {
        // create a regular snapshot
        CGRect snapshotRegion = CGRectMake(0.0, verticalOffset, size.width, foldHeight);
        snapshotView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        
    } else {
        // for the to- view for some reason the snapshot takes a while to create. Here we place the snapshot within
        // another view, with the same bckground color, so that it is less noticeable when the snapshot initially renders
        snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, foldHeight)];
        snapshotView.backgroundColor = view.backgroundColor;
        CGRect snapshotRegion = CGRectMake(0.0, verticalOffset, size.width, foldHeight);
        UIView* snapshotView2 = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        [snapshotView addSubview:snapshotView2];
        
    }
    
    // create a shadow
    UIView* snapshotWithShadowView = [self addShadowToView:snapshotView reverse:top];
    
    // add to the container
    [containerView addSubview:snapshotWithShadowView];
    
    // set the anchor to the top or bottom edge of the view
    snapshotWithShadowView.layer.anchorPoint = CGPointMake( 0.5, top ? 0.0 : 1.0);
    
    return snapshotWithShadowView;
}


// creates a snapshot for the gives view
- (UIView*)createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates horizontalOffset:(CGFloat)horizontalOffset left:(BOOL)left
{
    
    CGSize size = view.frame.size;
    UIView *containerView = view.superview;
    float foldWidth = [self foldMeasureForView:view];
    
    UIView* snapshotView;
    
    if (!afterUpdates) {
        // create a regular snapshot
        CGRect snapshotRegion = CGRectMake(horizontalOffset, 0.0, foldWidth, size.height);
        snapshotView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        
    } else {
        // for the to- view for some reason the snapshot takes a while to create. Here we place the snapshot within
        // another view, with the same bckground color, so that it is less noticeable when the snapshot initially renders
        snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, foldWidth, size.height)];
        snapshotView.backgroundColor = view.backgroundColor;
        CGRect snapshotRegion = CGRectMake(horizontalOffset, 0.0, foldWidth, size.height);
        UIView* snapshotView2 = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        [snapshotView addSubview:snapshotView2];
        
    }
    
    // create a shadow
    UIView* snapshotWithShadowView = [self addShadowToView:snapshotView reverse:left];
    
    // add to the container
    [containerView addSubview:snapshotWithShadowView];
    
    // set the anchor to the left or right edge of the view
    snapshotWithShadowView.layer.anchorPoint = CGPointMake( left ? 0.0 : 1.0, 0.5);
    
    return snapshotWithShadowView;
}


// adds a gradient to an image by creating a containing UIView with both the given view
// and the gradient as subviews
- (UIView*)addShadowToView:(UIView*)view reverse:(BOOL)reverse
{
    // create a view with the same frame
    UIView* viewWithShadow = [[UIView alloc] initWithFrame:view.frame];
    
    // create a shadow
    UIView* shadowView = [[UIView alloc] initWithFrame:viewWithShadow.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(reverse ? 0.0 : 1.0, reverse ? 0.2 : 0.0);
    gradient.endPoint = CGPointMake(reverse ? 1.0 : 0.0, reverse ? 0.0 : 1.0);
    [shadowView.layer insertSublayer:gradient atIndex:1];
    
    // add the original view into our new view
    view.frame = view.bounds;
    [viewWithShadow addSubview:view];
    
    // place the shadow on top
    [viewWithShadow addSubview:shadowView];
    
    return viewWithShadow;
}


@end
